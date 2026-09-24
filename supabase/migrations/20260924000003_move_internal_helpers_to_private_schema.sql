-- Move internal helper functions out of the API-exposed "public" schema so they can no
-- longer be called directly via /rest/v1/rpc. Only "public" and "graphql_public" are exposed.
CREATE SCHEMA IF NOT EXISTS "private";

-- The public RPCs that call these helpers are SECURITY INVOKER, so they run as the
-- signed-in user, who needs USAGE on the schema. CHECK constraints on user_settings also
-- call text_array_max_length as the current user.
GRANT USAGE ON SCHEMA "private" TO "authenticated", "service_role";

-- SET SCHEMA keeps each function's OID and privileges, so the CHECK constraints that use
-- text_array_max_length follow it automatically.
ALTER FUNCTION "public"."find_intermediate"("p1" integer, "q1" integer, "p2" integer, "q2" integer, OUT "p" integer, OUT "q" integer) SET SCHEMA "private";
ALTER FUNCTION "public"."bar_bounds"("p_section_id" "uuid", "p_reference_bar_id" "uuid", "p_is_before" boolean, OUT "lo_p" integer, OUT "lo_q" integer, OUT "hi_p" integer, OUT "hi_q" integer) SET SCHEMA "private";
ALTER FUNCTION "public"."section_bounds"("p_track_id" "uuid", "p_reference_section_id" "uuid", "p_is_before" boolean, OUT "lo_p" integer, OUT "lo_q" integer, OUT "hi_p" integer, OUT "hi_q" integer) SET SCHEMA "private";
ALTER FUNCTION "public"."renormalize_bars"("p_section_id" "uuid") SET SCHEMA "private";
ALTER FUNCTION "public"."renormalize_sections"("p_track_id" "uuid") SET SCHEMA "private";
ALTER FUNCTION "public"."renormalize_record_tracks"("p_record_id" "uuid") SET SCHEMA "private";
ALTER FUNCTION "public"."text_array_max_length"("text"[], integer) SET SCHEMA "private";

-- Function bodies reference helpers by name, so re-create the callers with private.* calls.
-- Bodies are unchanged apart from the schema prefix.
CREATE OR REPLACE FUNCTION "public"."append_tracks_to_record"("p_record_id" "uuid", "p_track_ids" "uuid"[]) RETURNS SETOF "public"."record_tracks"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
DECLARE
    lo_p INTEGER; lo_q INTEGER;
    new_p INTEGER; new_q INTEGER;
    attempt INTEGER;
    v_track_id UUID;
    pending_tracks UUID[] := ARRAY[]::UUID[];
    pending_ps INTEGER[] := ARRAY[]::INTEGER[];
    pending_qs INTEGER[] := ARRAY[]::INTEGER[];
BEGIN
    PERFORM 1 FROM public.records WHERE id = p_record_id FOR UPDATE;

    SELECT p, q INTO lo_p, lo_q FROM public.record_tracks
    WHERE record_id = p_record_id
    ORDER BY sort_key DESC LIMIT 1;

    FOREACH v_track_id IN ARRAY p_track_ids LOOP
        FOR attempt IN 1..2 LOOP
            SELECT * INTO new_p, new_q FROM private.find_intermediate(
                COALESCE(lo_p, 0), COALESCE(lo_q, 1), 1, 0
            );

            EXIT WHEN new_p <= 10000000 AND new_q <= 10000000;

            IF array_length(pending_tracks, 1) > 0 THEN
                INSERT INTO public.record_tracks (record_id, track_id, p, q)
                SELECT DISTINCT ON (t.track_id) p_record_id, t.track_id, t.p, t.q
                FROM unnest(pending_tracks, pending_ps, pending_qs)
                    WITH ORDINALITY AS t(track_id, p, q, ord)
                ORDER BY t.track_id, t.ord DESC
                ON CONFLICT (record_id, track_id) DO UPDATE SET p = EXCLUDED.p, q = EXCLUDED.q;

                pending_tracks := ARRAY[]::UUID[];
                pending_ps := ARRAY[]::INTEGER[];
                pending_qs := ARRAY[]::INTEGER[];
            END IF;

            PERFORM private.renormalize_record_tracks(p_record_id);
            SELECT p, q INTO lo_p, lo_q FROM public.record_tracks
            WHERE record_id = p_record_id
            ORDER BY sort_key DESC LIMIT 1;
        END LOOP;

        pending_tracks := array_append(pending_tracks, v_track_id);
        pending_ps := array_append(pending_ps, new_p);
        pending_qs := array_append(pending_qs, new_q);

        lo_p := new_p;
        lo_q := new_q;
    END LOOP;

    IF array_length(pending_tracks, 1) > 0 THEN
        INSERT INTO public.record_tracks (record_id, track_id, p, q)
        SELECT DISTINCT ON (t.track_id) p_record_id, t.track_id, t.p, t.q
        FROM unnest(pending_tracks, pending_ps, pending_qs)
            WITH ORDINALITY AS t(track_id, p, q, ord)
        ORDER BY t.track_id, t.ord DESC
        ON CONFLICT (record_id, track_id) DO UPDATE SET p = EXCLUDED.p, q = EXCLUDED.q;
    END IF;

    RETURN QUERY
        SELECT * FROM public.record_tracks
        WHERE record_id = p_record_id AND track_id = ANY(p_track_ids)
        ORDER BY sort_key;
END;
$$;

CREATE OR REPLACE FUNCTION "public"."create_bar"("p_section_id" "uuid", "p_type" "public"."bar_type", "p_content" "text", "p_lang" "public"."bar_lang", "p_repetitions" integer, "p_reference_bar_id" "uuid" DEFAULT NULL::"uuid", "p_is_before" boolean DEFAULT false) RETURNS "public"."bars"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
DECLARE
    bounds RECORD;
    new_p INTEGER; new_q INTEGER;
    attempt INTEGER;
    result public.bars;
BEGIN
    PERFORM 1 FROM public.sections WHERE id = p_section_id FOR UPDATE;

    FOR attempt IN 1..2 LOOP
        SELECT * INTO bounds FROM private.bar_bounds(
            p_section_id, p_reference_bar_id, p_is_before
        );
        SELECT * INTO new_p, new_q FROM private.find_intermediate(
            bounds.lo_p, bounds.lo_q, bounds.hi_p, bounds.hi_q
        );

        EXIT WHEN new_p <= 10000000 AND new_q <= 10000000;
        PERFORM private.renormalize_bars(p_section_id);
    END LOOP;

    INSERT INTO public.bars (type, content, lang, repetitions, p, q, section_id)
    VALUES (p_type, p_content, p_lang, p_repetitions, new_p, new_q, p_section_id)
    RETURNING * INTO result;

    RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION "public"."create_section"("p_track_id" "uuid", "p_name" "text", "p_repetitions" integer, "p_reference_section_id" "uuid" DEFAULT NULL::"uuid", "p_is_before" boolean DEFAULT false) RETURNS "public"."sections"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
DECLARE
    bounds RECORD;
    new_p INTEGER; new_q INTEGER;
    attempt INTEGER;
    result public.sections;
BEGIN
    PERFORM 1 FROM public.tracks WHERE id = p_track_id FOR UPDATE;

    FOR attempt IN 1..2 LOOP
        SELECT * INTO bounds FROM private.section_bounds(
            p_track_id, p_reference_section_id, p_is_before
        );
        SELECT * INTO new_p, new_q FROM private.find_intermediate(
            bounds.lo_p, bounds.lo_q, bounds.hi_p, bounds.hi_q
        );

        EXIT WHEN new_p <= 10000000 AND new_q <= 10000000;
        PERFORM private.renormalize_sections(p_track_id);
    END LOOP;

    INSERT INTO public.sections (name, repetitions, p, q, track_id)
    VALUES (p_name, p_repetitions, new_p, new_q, p_track_id)
    RETURNING * INTO result;

    RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION "public"."import_sections"("p_source_track_id" "uuid", "p_target_track_id" "uuid", "p_only_starred" boolean DEFAULT false) RETURNS SETOF "public"."sections"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
DECLARE
    lo_p INTEGER; lo_q INTEGER;
    new_p INTEGER; new_q INTEGER;
    attempt INTEGER;
    src public.sections%ROWTYPE;
    pending_ids UUID[] := ARRAY[]::UUID[];
    pending_names TEXT[] := ARRAY[]::TEXT[];
    pending_reps INTEGER[] := ARRAY[]::INTEGER[];
    pending_ps INTEGER[] := ARRAY[]::INTEGER[];
    pending_qs INTEGER[] := ARRAY[]::INTEGER[];
    pending_src_ids UUID[] := ARRAY[]::UUID[];
    all_ids UUID[] := ARRAY[]::UUID[];
BEGIN
    PERFORM 1 FROM public.tracks WHERE id = p_target_track_id FOR UPDATE;

    SELECT p, q INTO lo_p, lo_q FROM public.sections
    WHERE track_id = p_target_track_id
    ORDER BY sort_key DESC LIMIT 1;

    FOR src IN
        SELECT * FROM public.sections
        WHERE track_id = p_source_track_id
            AND (NOT p_only_starred OR is_starred)
        ORDER BY sort_key
    LOOP
        FOR attempt IN 1..2 LOOP
            SELECT * INTO new_p, new_q FROM private.find_intermediate(
                COALESCE(lo_p, 0), COALESCE(lo_q, 1), 1, 0
            );

            EXIT WHEN new_p <= 10000000 AND new_q <= 10000000;

            IF array_length(pending_ids, 1) > 0 THEN
                INSERT INTO public.sections (id, name, repetitions, p, q, track_id, is_starred)
                SELECT t.id, t.name, t.repetitions, t.p, t.q, p_target_track_id, FALSE
                FROM unnest(pending_ids, pending_names, pending_reps, pending_ps, pending_qs)
                    AS t(id, name, repetitions, p, q);

                INSERT INTO public.bars (type, content, lang, repetitions, p, q, section_id)
                SELECT b.type, b.content, b.lang, b.repetitions, b.p, b.q, m.new_id
                FROM public.bars b
                JOIN unnest(pending_src_ids, pending_ids) AS m(old_id, new_id)
                    ON b.section_id = m.old_id;

                all_ids := all_ids || pending_ids;
                pending_ids := ARRAY[]::UUID[];
                pending_names := ARRAY[]::TEXT[];
                pending_reps := ARRAY[]::INTEGER[];
                pending_ps := ARRAY[]::INTEGER[];
                pending_qs := ARRAY[]::INTEGER[];
                pending_src_ids := ARRAY[]::UUID[];
            END IF;

            PERFORM private.renormalize_sections(p_target_track_id);
            SELECT p, q INTO lo_p, lo_q FROM public.sections
            WHERE track_id = p_target_track_id
            ORDER BY sort_key DESC LIMIT 1;
        END LOOP;

        pending_ids := array_append(pending_ids, gen_random_uuid());
        pending_names := array_append(pending_names, src.name);
        pending_reps := array_append(pending_reps, src.repetitions);
        pending_ps := array_append(pending_ps, new_p);
        pending_qs := array_append(pending_qs, new_q);
        pending_src_ids := array_append(pending_src_ids, src.id);

        lo_p := new_p;
        lo_q := new_q;
    END LOOP;

    IF array_length(pending_ids, 1) > 0 THEN
        INSERT INTO public.sections (id, name, repetitions, p, q, track_id, is_starred)
        SELECT t.id, t.name, t.repetitions, t.p, t.q, p_target_track_id, FALSE
        FROM unnest(pending_ids, pending_names, pending_reps, pending_ps, pending_qs)
            AS t(id, name, repetitions, p, q);

        INSERT INTO public.bars (type, content, lang, repetitions, p, q, section_id)
        SELECT b.type, b.content, b.lang, b.repetitions, b.p, b.q, m.new_id
        FROM public.bars b
        JOIN unnest(pending_src_ids, pending_ids) AS m(old_id, new_id)
            ON b.section_id = m.old_id;

        all_ids := all_ids || pending_ids;
    END IF;

    RETURN QUERY
        SELECT * FROM public.sections
        WHERE id = ANY(all_ids)
        ORDER BY sort_key;
END;
$$;

CREATE OR REPLACE FUNCTION "public"."move_bar"("p_bar_id" "uuid", "p_target_section_id" "uuid" DEFAULT NULL::"uuid", "p_reference_bar_id" "uuid" DEFAULT NULL::"uuid", "p_is_before" boolean DEFAULT false) RETURNS "public"."bars"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_source_section_id UUID;
    v_target_section_id UUID;
    bounds RECORD;
    new_p INTEGER; new_q INTEGER;
    attempt INTEGER;
    result public.bars;
BEGIN
    SELECT section_id INTO v_source_section_id FROM public.bars WHERE id = p_bar_id;
    IF v_source_section_id IS NULL THEN
        RAISE EXCEPTION 'Bar not found';
    END IF;

    v_target_section_id := COALESCE(p_target_section_id, v_source_section_id);

    IF v_target_section_id = v_source_section_id THEN
        PERFORM 1 FROM public.sections WHERE id = v_source_section_id FOR UPDATE;
    ELSE
        PERFORM 1 FROM public.sections
        WHERE id IN (v_source_section_id, v_target_section_id)
        ORDER BY id FOR UPDATE;
    END IF;

    FOR attempt IN 1..2 LOOP
        SELECT * INTO bounds FROM private.bar_bounds(
            v_target_section_id, p_reference_bar_id, p_is_before
        );
        SELECT * INTO new_p, new_q FROM private.find_intermediate(
            bounds.lo_p, bounds.lo_q, bounds.hi_p, bounds.hi_q
        );

        EXIT WHEN new_p <= 10000000 AND new_q <= 10000000;
        PERFORM private.renormalize_bars(v_target_section_id);
    END LOOP;

    UPDATE public.bars SET p = new_p, q = new_q, section_id = v_target_section_id
    WHERE id = p_bar_id
    RETURNING * INTO result;

    RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION "public"."move_section"("p_section_id" "uuid", "p_reference_section_id" "uuid" DEFAULT NULL::"uuid", "p_is_before" boolean DEFAULT false) RETURNS "public"."sections"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_track_id UUID;
    bounds RECORD;
    new_p INTEGER; new_q INTEGER;
    attempt INTEGER;
    result public.sections;
BEGIN
    SELECT track_id INTO v_track_id FROM public.sections WHERE id = p_section_id;
    IF v_track_id IS NULL THEN
        RAISE EXCEPTION 'Section not found';
    END IF;

    PERFORM 1 FROM public.tracks WHERE id = v_track_id FOR UPDATE;

    FOR attempt IN 1..2 LOOP
        SELECT * INTO bounds FROM private.section_bounds(
            v_track_id, p_reference_section_id, p_is_before
        );
        SELECT * INTO new_p, new_q FROM private.find_intermediate(
            bounds.lo_p, bounds.lo_q, bounds.hi_p, bounds.hi_q
        );

        EXIT WHEN new_p <= 10000000 AND new_q <= 10000000;
        PERFORM private.renormalize_sections(v_track_id);
    END LOOP;

    UPDATE public.sections SET p = new_p, q = new_q
    WHERE id = p_section_id
    RETURNING * INTO result;

    RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION "public"."place_record_track"("p_record_id" "uuid", "p_track_id" "uuid", "p_reference_track_id" "uuid" DEFAULT NULL::"uuid", "p_is_before" boolean DEFAULT false) RETURNS "public"."record_tracks"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
DECLARE
    ref_sort_key DOUBLE PRECISION;
    lo_p INTEGER; lo_q INTEGER;
    hi_p INTEGER; hi_q INTEGER;
    new_p INTEGER; new_q INTEGER;
    attempt INTEGER;
    result public.record_tracks;
BEGIN
    PERFORM 1 FROM public.records WHERE id = p_record_id FOR UPDATE;

    FOR attempt IN 1..2 LOOP
        lo_p := NULL; lo_q := NULL; hi_p := NULL; hi_q := NULL;

        IF p_reference_track_id IS NOT NULL THEN
            SELECT sort_key INTO ref_sort_key FROM public.record_tracks
            WHERE record_id = p_record_id AND track_id = p_reference_track_id;

            IF ref_sort_key IS NULL THEN
                RAISE EXCEPTION 'Reference track not found in record';
            END IF;

            IF p_is_before THEN
                SELECT p, q INTO hi_p, hi_q FROM public.record_tracks
                WHERE record_id = p_record_id AND track_id = p_reference_track_id;
                SELECT p, q INTO lo_p, lo_q FROM public.record_tracks
                WHERE record_id = p_record_id AND sort_key < ref_sort_key
                ORDER BY sort_key DESC LIMIT 1;
            ELSE
                SELECT p, q INTO lo_p, lo_q FROM public.record_tracks
                WHERE record_id = p_record_id AND track_id = p_reference_track_id;
                SELECT p, q INTO hi_p, hi_q FROM public.record_tracks
                WHERE record_id = p_record_id AND sort_key > ref_sort_key
                ORDER BY sort_key ASC LIMIT 1;
            END IF;
        ELSIF p_is_before THEN
            SELECT p, q INTO hi_p, hi_q FROM public.record_tracks
            WHERE record_id = p_record_id
            ORDER BY sort_key ASC LIMIT 1;
        ELSE
            SELECT p, q INTO lo_p, lo_q FROM public.record_tracks
            WHERE record_id = p_record_id
            ORDER BY sort_key DESC LIMIT 1;
        END IF;

        SELECT * INTO new_p, new_q FROM private.find_intermediate(
            COALESCE(lo_p, 0), COALESCE(lo_q, 1),
            COALESCE(hi_p, 1), COALESCE(hi_q, 0)
        );

        EXIT WHEN new_p <= 10000000 AND new_q <= 10000000;
        PERFORM private.renormalize_record_tracks(p_record_id);
    END LOOP;

    UPDATE public.record_tracks SET p = new_p, q = new_q
    WHERE record_id = p_record_id AND track_id = p_track_id
    RETURNING * INTO result;

    RETURN result;
END;
$$;
