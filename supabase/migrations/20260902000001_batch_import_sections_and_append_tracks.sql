


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "extensions";






COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."bar_lang" AS ENUM (
    'en-US',
    'zh-TW'
);


ALTER TYPE "public"."bar_lang" OWNER TO "postgres";


CREATE TYPE "public"."bar_type" AS ENUM (
    'spelling',
    'word',
    'interval'
);


ALTER TYPE "public"."bar_type" OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."record_tracks" (
    "record_id" "uuid" NOT NULL,
    "track_id" "uuid" NOT NULL,
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "p" integer NOT NULL,
    "q" integer NOT NULL,
    "sort_key" double precision GENERATED ALWAYS AS ((("p")::double precision / ("q")::double precision)) STORED
);


ALTER TABLE "public"."record_tracks" OWNER TO "postgres";


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
            SELECT * INTO new_p, new_q FROM public.find_intermediate(
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

            PERFORM public.renormalize_record_tracks(p_record_id);
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


ALTER FUNCTION "public"."append_tracks_to_record"("p_record_id" "uuid", "p_track_ids" "uuid"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bar_bounds"("p_section_id" "uuid", "p_reference_bar_id" "uuid", "p_is_before" boolean, OUT "lo_p" integer, OUT "lo_q" integer, OUT "hi_p" integer, OUT "hi_q" integer) RETURNS "record"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
DECLARE
    ref_sort_key DOUBLE PRECISION;
BEGIN
    IF p_reference_bar_id IS NOT NULL THEN
        SELECT sort_key INTO ref_sort_key FROM public.bars
        WHERE id = p_reference_bar_id AND section_id = p_section_id;

        IF ref_sort_key IS NULL THEN
            RAISE EXCEPTION 'Reference bar not found in section';
        END IF;

        IF p_is_before THEN
            SELECT p, q INTO hi_p, hi_q FROM public.bars WHERE id = p_reference_bar_id;
            SELECT p, q INTO lo_p, lo_q FROM public.bars
            WHERE section_id = p_section_id AND sort_key < ref_sort_key
            ORDER BY sort_key DESC LIMIT 1;
        ELSE
            SELECT p, q INTO lo_p, lo_q FROM public.bars WHERE id = p_reference_bar_id;
            SELECT p, q INTO hi_p, hi_q FROM public.bars
            WHERE section_id = p_section_id AND sort_key > ref_sort_key
            ORDER BY sort_key ASC LIMIT 1;
        END IF;
    ELSIF p_is_before THEN
        SELECT p, q INTO hi_p, hi_q FROM public.bars
        WHERE section_id = p_section_id
        ORDER BY sort_key ASC LIMIT 1;
    ELSE
        SELECT p, q INTO lo_p, lo_q FROM public.bars
        WHERE section_id = p_section_id
        ORDER BY sort_key DESC LIMIT 1;
    END IF;

    lo_p := COALESCE(lo_p, 0); lo_q := COALESCE(lo_q, 1);
    hi_p := COALESCE(hi_p, 1); hi_q := COALESCE(hi_q, 0);
END;
$$;


ALTER FUNCTION "public"."bar_bounds"("p_section_id" "uuid", "p_reference_bar_id" "uuid", "p_is_before" boolean, OUT "lo_p" integer, OUT "lo_q" integer, OUT "hi_p" integer, OUT "hi_q" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_bars_limit"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    current_count INTEGER;
BEGIN
    IF TG_OP = 'INSERT' THEN
        SELECT COUNT(*) INTO current_count FROM bars WHERE section_id = NEW.section_id;
        IF current_count + 1 > 10 THEN
            RAISE EXCEPTION 'Section cannot have more than 10 bars';
        END IF;
    ELSIF TG_OP = 'UPDATE' THEN
        SELECT COUNT(*) INTO current_count FROM bars WHERE section_id = NEW.section_id AND id != OLD.id;
        IF current_count + 1 > 10 THEN
            RAISE EXCEPTION 'Section cannot have more than 10 bars';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."check_bars_limit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_sections_limit"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    current_count INTEGER;
BEGIN
    IF TG_OP = 'INSERT' THEN
        SELECT COUNT(*) INTO current_count FROM sections WHERE track_id = NEW.track_id;
        IF current_count + 1 > 100 THEN
            RAISE EXCEPTION 'Track cannot have more than 100 sections';
        END IF;
    ELSIF TG_OP = 'UPDATE' THEN
        SELECT COUNT(*) INTO current_count FROM sections WHERE track_id = NEW.track_id AND id != OLD.id;
        IF current_count + 1 > 100 THEN
            RAISE EXCEPTION 'Track cannot have more than 100 sections';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."check_sections_limit"() OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."bars" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "type" "public"."bar_type" NOT NULL,
    "content" "text" NOT NULL,
    "section_id" "uuid" NOT NULL,
    "lang" "public"."bar_lang",
    "repetitions" integer,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "p" integer NOT NULL,
    "q" integer NOT NULL,
    "sort_key" double precision GENERATED ALWAYS AS ((("p")::double precision / ("q")::double precision)) STORED,
    CONSTRAINT "bars_repetitions_range" CHECK ((("repetitions" >= 1) AND ("repetitions" <= 5))),
    CONSTRAINT "interval_content_length" CHECK ((("type" <> 'interval'::"public"."bar_type") OR (("char_length"("content") >= 1) AND ("char_length"("content") <= 2)))),
    CONSTRAINT "interval_no_lang" CHECK ((("type" <> 'interval'::"public"."bar_type") OR ("lang" IS NULL))),
    CONSTRAINT "interval_no_repetitions" CHECK ((("type" <> 'interval'::"public"."bar_type") OR ("repetitions" IS NULL))),
    CONSTRAINT "non_interval_content_length" CHECK ((("type" = 'interval'::"public"."bar_type") OR (("char_length"("content") >= 1) AND ("char_length"("content") <= 300)))),
    CONSTRAINT "speech_requires_lang" CHECK ((("type" = 'interval'::"public"."bar_type") OR ("lang" IS NOT NULL))),
    CONSTRAINT "speech_requires_repetitions" CHECK ((("type" = 'interval'::"public"."bar_type") OR ("repetitions" IS NOT NULL)))
);


ALTER TABLE "public"."bars" OWNER TO "postgres";


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
        SELECT * INTO bounds FROM public.bar_bounds(
            p_section_id, p_reference_bar_id, p_is_before
        );
        SELECT * INTO new_p, new_q FROM public.find_intermediate(
            bounds.lo_p, bounds.lo_q, bounds.hi_p, bounds.hi_q
        );

        EXIT WHEN new_p <= 10000000 AND new_q <= 10000000;
        PERFORM public.renormalize_bars(p_section_id);
    END LOOP;

    INSERT INTO public.bars (type, content, lang, repetitions, p, q, section_id)
    VALUES (p_type, p_content, p_lang, p_repetitions, new_p, new_q, p_section_id)
    RETURNING * INTO result;

    RETURN result;
END;
$$;


ALTER FUNCTION "public"."create_bar"("p_section_id" "uuid", "p_type" "public"."bar_type", "p_content" "text", "p_lang" "public"."bar_lang", "p_repetitions" integer, "p_reference_bar_id" "uuid", "p_is_before" boolean) OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."sections" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "repetitions" integer DEFAULT 1 NOT NULL,
    "track_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "p" integer NOT NULL,
    "q" integer NOT NULL,
    "sort_key" double precision GENERATED ALWAYS AS ((("p")::double precision / ("q")::double precision)) STORED,
    "is_starred" boolean DEFAULT false NOT NULL,
    CONSTRAINT "sections_name_length" CHECK ((("char_length"("name") >= 1) AND ("char_length"("name") <= 120))),
    CONSTRAINT "sections_repetitions_range" CHECK ((("repetitions" >= 1) AND ("repetitions" <= 5)))
);


ALTER TABLE "public"."sections" OWNER TO "postgres";


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
        SELECT * INTO bounds FROM public.section_bounds(
            p_track_id, p_reference_section_id, p_is_before
        );
        SELECT * INTO new_p, new_q FROM public.find_intermediate(
            bounds.lo_p, bounds.lo_q, bounds.hi_p, bounds.hi_q
        );

        EXIT WHEN new_p <= 10000000 AND new_q <= 10000000;
        PERFORM public.renormalize_sections(p_track_id);
    END LOOP;

    INSERT INTO public.sections (name, repetitions, p, q, track_id)
    VALUES (p_name, p_repetitions, new_p, new_q, p_track_id)
    RETURNING * INTO result;

    RETURN result;
END;
$$;


ALTER FUNCTION "public"."create_section"("p_track_id" "uuid", "p_name" "text", "p_repetitions" integer, "p_reference_section_id" "uuid", "p_is_before" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."duplicate_bar"("p_bar_id" "uuid") RETURNS "public"."bars"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
DECLARE
    src public.bars;
    result public.bars;
BEGIN
    SELECT * INTO src FROM public.bars WHERE id = p_bar_id;
    IF src.id IS NULL THEN
        RAISE EXCEPTION 'Bar not found';
    END IF;

    SELECT * INTO result FROM public.create_bar(
        src.section_id, src.type, src.content, src.lang, src.repetitions,
        p_bar_id, FALSE
    );

    RETURN result;
END;
$$;


ALTER FUNCTION "public"."duplicate_bar"("p_bar_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."duplicate_section"("p_section_id" "uuid") RETURNS "public"."sections"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
DECLARE
    src public.sections;
    new_section public.sections;
BEGIN
    SELECT * INTO src FROM public.sections WHERE id = p_section_id;
    IF src.id IS NULL THEN
        RAISE EXCEPTION 'Section not found';
    END IF;

    SELECT * INTO new_section FROM public.create_section(
        src.track_id, src.name, src.repetitions, p_section_id, FALSE
    );

    INSERT INTO public.bars (type, content, lang, repetitions, p, q, section_id)
    SELECT type, content, lang, repetitions, p, q, new_section.id
    FROM public.bars
    WHERE section_id = p_section_id;

    RETURN new_section;
END;
$$;


ALTER FUNCTION "public"."duplicate_section"("p_section_id" "uuid") OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."tracks" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "last_played_at" timestamp with time zone,
    "note" "text",
    CONSTRAINT "tracks_name_length" CHECK ((("char_length"("name") >= 1) AND ("char_length"("name") <= 130))),
    CONSTRAINT "tracks_note_length" CHECK ((("note" IS NULL) OR (("char_length"("note") >= 1) AND ("char_length"("note") <= 600))))
);


ALTER TABLE "public"."tracks" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."duplicate_track"("source_track_id" "uuid") RETURNS "public"."tracks"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
DECLARE
    new_track public.tracks;
BEGIN
    INSERT INTO public.tracks (name, user_id)
    SELECT name || ' (Copy)', auth.uid()
    FROM public.tracks
    WHERE id = source_track_id
    RETURNING * INTO new_track;

    IF new_track.id IS NULL THEN
        RAISE EXCEPTION 'Track not found';
    END IF;

    INSERT INTO public.sections (name, p, q, repetitions, track_id)
    SELECT name, p, q, repetitions, new_track.id
    FROM public.sections
    WHERE track_id = source_track_id;

    INSERT INTO public.bars (type, content, p, q, lang, repetitions, section_id)
    SELECT b.type, b.content, b.p, b.q, b.lang, b.repetitions, ns.id
    FROM public.bars b
    JOIN public.sections os ON os.id = b.section_id
    JOIN public.sections ns ON ns.track_id = new_track.id
        AND ns.p = os.p AND ns.q = os.q
    WHERE os.track_id = source_track_id;

    RETURN new_track;
END;
$$;


ALTER FUNCTION "public"."duplicate_track"("source_track_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."enforce_rate_limit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_action TEXT := TG_ARGV[0];
    v_max_count INTEGER := TG_ARGV[1]::INTEGER;
    v_window INTERVAL := TG_ARGV[2]::INTERVAL;
BEGIN
    IF v_user_id IS NULL THEN
        RETURN NULL;
    END IF;

    IF (
        SELECT COUNT(*) FROM public.rate_limit_events
        WHERE user_id = v_user_id
        AND action = v_action
        AND created_at > now() - v_window
    ) >= v_max_count THEN
        RAISE EXCEPTION 'Rate limit exceeded for %, please slow down', v_action
            USING ERRCODE = 'P0001';
    END IF;

    INSERT INTO public.rate_limit_events (user_id, action) VALUES (v_user_id, v_action);
    RETURN NULL;
END
$$;


ALTER FUNCTION "public"."enforce_rate_limit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."find_intermediate"("p1" integer, "q1" integer, "p2" integer, "q2" integer, OUT "p" integer, OUT "q" integer) RETURNS "record"
    LANGUAGE "plpgsql" IMMUTABLE STRICT
    SET "search_path" TO 'public'
    AS $$
DECLARE
    pl INTEGER := 0;
    ql INTEGER := 1;
    ph INTEGER := 1;
    qh INTEGER := 0;
BEGIN
    IF (p1::BIGINT * q2 + 1) <> (p2::BIGINT * q1) THEN
        LOOP
            p := pl + ph;
            q := ql + qh;
            IF (p::BIGINT * q1 <= q::BIGINT * p1) THEN
                pl := p; ql := q;
            ELSIF (p2::BIGINT * q <= q2::BIGINT * p) THEN
                ph := p; qh := q;
            ELSE
                EXIT;
            END IF;
        END LOOP;
    ELSE
        p := p1 + p2;
        q := q1 + q2;
    END IF;
END;
$$;


ALTER FUNCTION "public"."find_intermediate"("p1" integer, "q1" integer, "p2" integer, "q2" integer, OUT "p" integer, OUT "q" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    INSERT INTO public.profiles (id, username, display_name)
    VALUES (
        NEW.id,
        NEW.raw_user_meta_data->>'username',
        'Pig'
    );

    RETURN NEW;
END
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


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
            SELECT * INTO new_p, new_q FROM public.find_intermediate(
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

            PERFORM public.renormalize_sections(p_target_track_id);
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


ALTER FUNCTION "public"."import_sections"("p_source_track_id" "uuid", "p_target_track_id" "uuid", "p_only_starred" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."mark_track_played"("p_track_id" "uuid") RETURNS "void"
    LANGUAGE "sql"
    SET "search_path" TO 'public'
    AS $$
    UPDATE public.tracks
    SET last_played_at = now()
    WHERE id = p_track_id;
$$;


ALTER FUNCTION "public"."mark_track_played"("p_track_id" "uuid") OWNER TO "postgres";


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
        SELECT * INTO bounds FROM public.bar_bounds(
            v_target_section_id, p_reference_bar_id, p_is_before
        );
        SELECT * INTO new_p, new_q FROM public.find_intermediate(
            bounds.lo_p, bounds.lo_q, bounds.hi_p, bounds.hi_q
        );

        EXIT WHEN new_p <= 10000000 AND new_q <= 10000000;
        PERFORM public.renormalize_bars(v_target_section_id);
    END LOOP;

    UPDATE public.bars SET p = new_p, q = new_q, section_id = v_target_section_id
    WHERE id = p_bar_id
    RETURNING * INTO result;

    RETURN result;
END;
$$;


ALTER FUNCTION "public"."move_bar"("p_bar_id" "uuid", "p_target_section_id" "uuid", "p_reference_bar_id" "uuid", "p_is_before" boolean) OWNER TO "postgres";


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
        SELECT * INTO bounds FROM public.section_bounds(
            v_track_id, p_reference_section_id, p_is_before
        );
        SELECT * INTO new_p, new_q FROM public.find_intermediate(
            bounds.lo_p, bounds.lo_q, bounds.hi_p, bounds.hi_q
        );

        EXIT WHEN new_p <= 10000000 AND new_q <= 10000000;
        PERFORM public.renormalize_sections(v_track_id);
    END LOOP;

    UPDATE public.sections SET p = new_p, q = new_q
    WHERE id = p_section_id
    RETURNING * INTO result;

    RETURN result;
END;
$$;


ALTER FUNCTION "public"."move_section"("p_section_id" "uuid", "p_reference_section_id" "uuid", "p_is_before" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."normalize_display_name"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.display_name := normalize(NEW.display_name, NFC);
    RETURN NEW;
END
$$;


ALTER FUNCTION "public"."normalize_display_name"() OWNER TO "postgres";


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

        SELECT * INTO new_p, new_q FROM public.find_intermediate(
            COALESCE(lo_p, 0), COALESCE(lo_q, 1),
            COALESCE(hi_p, 1), COALESCE(hi_q, 0)
        );

        EXIT WHEN new_p <= 10000000 AND new_q <= 10000000;
        PERFORM public.renormalize_record_tracks(p_record_id);
    END LOOP;

    UPDATE public.record_tracks SET p = new_p, q = new_q
    WHERE record_id = p_record_id AND track_id = p_track_id
    RETURNING * INTO result;

    RETURN result;
END;
$$;


ALTER FUNCTION "public"."place_record_track"("p_record_id" "uuid", "p_track_id" "uuid", "p_reference_track_id" "uuid", "p_is_before" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."prevent_exceed_max_record_tracks"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    current_count INTEGER;
BEGIN
    IF TG_OP = 'INSERT' THEN
        SELECT COUNT(*) INTO current_count FROM public.record_tracks WHERE record_id = NEW.record_id;
    ELSE
        SELECT COUNT(*) INTO current_count FROM public.record_tracks
        WHERE record_id = NEW.record_id AND track_id != NEW.track_id;
    END IF;

    IF current_count >= 1000 THEN
        RAISE EXCEPTION 'Record cannot have more than 1000 tracks';
    END IF;

    RETURN NEW;
END
$$;


ALTER FUNCTION "public"."prevent_exceed_max_record_tracks"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."prevent_exceed_max_user_records"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    PERFORM pg_advisory_xact_lock(hashtext('records'), hashtext(NEW.user_id::text));

    IF (SELECT COUNT(*) FROM public.records WHERE user_id = NEW.user_id) >= 1000 THEN
        RAISE EXCEPTION 'User cannot have more than 1000 records';
    END IF;

    RETURN NEW;
END
$$;


ALTER FUNCTION "public"."prevent_exceed_max_user_records"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."prevent_exceed_max_user_tracks"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    PERFORM pg_advisory_xact_lock(hashtext('tracks'), hashtext(NEW.user_id::text));

    IF (SELECT COUNT(*) FROM public.tracks WHERE user_id = NEW.user_id) >= 1000 THEN
        RAISE EXCEPTION 'User cannot have more than 1000 tracks';
    END IF;

    RETURN NEW;
END
$$;


ALTER FUNCTION "public"."prevent_exceed_max_user_tracks"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."renormalize_bars"("p_section_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
BEGIN
    PERFORM 1 FROM public.sections WHERE id = p_section_id FOR UPDATE;

    UPDATE public.bars b
    SET p = s2.new_rnum, q = 2
    FROM (
        SELECT id,
               is_existing = 0 AS is_new,
               rnum + 2 * (SUM(is_existing) OVER (ORDER BY rnum)) AS new_rnum
        FROM (
            SELECT id,
                   2 * (ROW_NUMBER() OVER (ORDER BY sort_key)) - 1 AS rnum,
                   0 AS is_existing
            FROM public.bars
            WHERE section_id = p_section_id
            UNION ALL
            SELECT id,
                   p + 2 - 2 * (COUNT(*) OVER (ORDER BY p)) AS rnum,
                   1 AS is_existing
            FROM public.bars
            WHERE section_id = p_section_id AND q = 2
        ) s1
    ) s2
    WHERE s2.id = b.id AND s2.is_new;
END;
$$;


ALTER FUNCTION "public"."renormalize_bars"("p_section_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."renormalize_record_tracks"("p_record_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
BEGIN
    PERFORM 1 FROM public.records WHERE id = p_record_id FOR UPDATE;

    UPDATE public.record_tracks rt
    SET p = s2.new_rnum, q = 2
    FROM (
        SELECT id,
               is_existing = 0 AS is_new,
               rnum + 2 * (SUM(is_existing) OVER (ORDER BY rnum)) AS new_rnum
        FROM (
            SELECT id,
                   2 * (ROW_NUMBER() OVER (ORDER BY sort_key)) - 1 AS rnum,
                   0 AS is_existing
            FROM public.record_tracks
            WHERE record_id = p_record_id
            UNION ALL
            SELECT id,
                   p + 2 - 2 * (COUNT(*) OVER (ORDER BY p)) AS rnum,
                   1 AS is_existing
            FROM public.record_tracks
            WHERE record_id = p_record_id AND q = 2
        ) s1
    ) s2
    WHERE s2.id = rt.id AND s2.is_new;
END;
$$;


ALTER FUNCTION "public"."renormalize_record_tracks"("p_record_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."renormalize_sections"("p_track_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
BEGIN
    PERFORM 1 FROM public.tracks WHERE id = p_track_id FOR UPDATE;

    UPDATE public.sections s
    SET p = s2.new_rnum, q = 2
    FROM (
        SELECT id,
               is_existing = 0 AS is_new,
               rnum + 2 * (SUM(is_existing) OVER (ORDER BY rnum)) AS new_rnum
        FROM (
            SELECT id,
                   2 * (ROW_NUMBER() OVER (ORDER BY sort_key)) - 1 AS rnum,
                   0 AS is_existing
            FROM public.sections
            WHERE track_id = p_track_id
            UNION ALL
            SELECT id,
                   p + 2 - 2 * (COUNT(*) OVER (ORDER BY p)) AS rnum,
                   1 AS is_existing
            FROM public.sections
            WHERE track_id = p_track_id AND q = 2
        ) s1
    ) s2
    WHERE s2.id = s.id AND s2.is_new;
END;
$$;


ALTER FUNCTION "public"."renormalize_sections"("p_track_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."section_bounds"("p_track_id" "uuid", "p_reference_section_id" "uuid", "p_is_before" boolean, OUT "lo_p" integer, OUT "lo_q" integer, OUT "hi_p" integer, OUT "hi_q" integer) RETURNS "record"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
DECLARE
    ref_sort_key DOUBLE PRECISION;
BEGIN
    IF p_reference_section_id IS NOT NULL THEN
        SELECT sort_key INTO ref_sort_key FROM public.sections
        WHERE id = p_reference_section_id AND track_id = p_track_id;

        IF ref_sort_key IS NULL THEN
            RAISE EXCEPTION 'Reference section not found in track';
        END IF;

        IF p_is_before THEN
            SELECT p, q INTO hi_p, hi_q FROM public.sections WHERE id = p_reference_section_id;
            SELECT p, q INTO lo_p, lo_q FROM public.sections
            WHERE track_id = p_track_id AND sort_key < ref_sort_key
            ORDER BY sort_key DESC LIMIT 1;
        ELSE
            SELECT p, q INTO lo_p, lo_q FROM public.sections WHERE id = p_reference_section_id;
            SELECT p, q INTO hi_p, hi_q FROM public.sections
            WHERE track_id = p_track_id AND sort_key > ref_sort_key
            ORDER BY sort_key ASC LIMIT 1;
        END IF;
    ELSIF p_is_before THEN
        SELECT p, q INTO hi_p, hi_q FROM public.sections
        WHERE track_id = p_track_id
        ORDER BY sort_key ASC LIMIT 1;
    ELSE
        SELECT p, q INTO lo_p, lo_q FROM public.sections
        WHERE track_id = p_track_id
        ORDER BY sort_key DESC LIMIT 1;
    END IF;

    lo_p := COALESCE(lo_p, 0); lo_q := COALESCE(lo_q, 1);
    hi_p := COALESCE(hi_p, 1); hi_q := COALESCE(hi_q, 0);
END;
$$;


ALTER FUNCTION "public"."section_bounds"("p_track_id" "uuid", "p_reference_section_id" "uuid", "p_is_before" boolean, OUT "lo_p" integer, OUT "lo_q" integer, OUT "hi_p" integer, OUT "hi_q" integer) OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" NOT NULL,
    "username" "text" NOT NULL,
    "display_name" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "profiles_display_name_check" CHECK ((("char_length"("display_name") >= 1) AND ("char_length"("display_name") <= 60))),
    CONSTRAINT "profiles_username_check" CHECK ((("char_length"("username") >= 1) AND ("char_length"("username") <= 30) AND ("username" ~ '^[a-zA-Z0-9]([a-zA-Z0-9_-]*[a-zA-Z0-9])?$'::"text")))
);


ALTER TABLE "public"."profiles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."rate_limit_events" (
    "id" bigint NOT NULL,
    "user_id" "uuid" NOT NULL,
    "action" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."rate_limit_events" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."rate_limit_events_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."rate_limit_events_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."rate_limit_events_id_seq" OWNED BY "public"."rate_limit_events"."id";



CREATE TABLE IF NOT EXISTS "public"."records" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "records_name_length" CHECK ((("char_length"("name") >= 1) AND ("char_length"("name") <= 120)))
);


ALTER TABLE "public"."records" OWNER TO "postgres";


ALTER TABLE ONLY "public"."rate_limit_events" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."rate_limit_events_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."bars"
    ADD CONSTRAINT "bars_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."bars"
    ADD CONSTRAINT "bars_section_id_sort_key_key" UNIQUE ("section_id", "sort_key");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_username_key" UNIQUE ("username");



ALTER TABLE ONLY "public"."rate_limit_events"
    ADD CONSTRAINT "rate_limit_events_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."record_tracks"
    ADD CONSTRAINT "record_tracks_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."record_tracks"
    ADD CONSTRAINT "record_tracks_record_id_sort_key_key" UNIQUE ("record_id", "sort_key");



ALTER TABLE ONLY "public"."record_tracks"
    ADD CONSTRAINT "record_tracks_record_id_track_id_key" UNIQUE ("record_id", "track_id");



ALTER TABLE ONLY "public"."records"
    ADD CONSTRAINT "records_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."sections"
    ADD CONSTRAINT "sections_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."sections"
    ADD CONSTRAINT "sections_track_id_sort_key_key" UNIQUE ("track_id", "sort_key");



ALTER TABLE ONLY "public"."tracks"
    ADD CONSTRAINT "tracks_pkey" PRIMARY KEY ("id");



CREATE INDEX "idx_bars_section_id" ON "public"."bars" USING "btree" ("section_id");



CREATE INDEX "idx_sections_track_id" ON "public"."sections" USING "btree" ("track_id");



CREATE INDEX "rate_limit_events_user_action_created_idx" ON "public"."rate_limit_events" USING "btree" ("user_id", "action", "created_at");



CREATE OR REPLACE TRIGGER "enforce_bars_limit" BEFORE INSERT OR UPDATE ON "public"."bars" FOR EACH ROW EXECUTE FUNCTION "public"."check_bars_limit"();



CREATE OR REPLACE TRIGGER "enforce_maximum_record_tracks" BEFORE INSERT OR UPDATE ON "public"."record_tracks" FOR EACH ROW EXECUTE FUNCTION "public"."prevent_exceed_max_record_tracks"();



CREATE OR REPLACE TRIGGER "enforce_maximum_user_records" BEFORE INSERT ON "public"."records" FOR EACH ROW EXECUTE FUNCTION "public"."prevent_exceed_max_user_records"();



CREATE OR REPLACE TRIGGER "enforce_maximum_user_tracks" BEFORE INSERT ON "public"."tracks" FOR EACH ROW EXECUTE FUNCTION "public"."prevent_exceed_max_user_tracks"();



CREATE OR REPLACE TRIGGER "enforce_sections_limit" BEFORE INSERT OR UPDATE ON "public"."sections" FOR EACH ROW EXECUTE FUNCTION "public"."check_sections_limit"();



CREATE OR REPLACE TRIGGER "normalize_display_name_on_upsert" BEFORE INSERT OR UPDATE OF "display_name" ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."normalize_display_name"();



CREATE OR REPLACE TRIGGER "rate_limit_bars" BEFORE INSERT OR DELETE OR UPDATE ON "public"."bars" FOR EACH STATEMENT EXECUTE FUNCTION "public"."enforce_rate_limit"('bars', '60', '1 minute');



CREATE OR REPLACE TRIGGER "rate_limit_record_tracks" BEFORE INSERT OR DELETE OR UPDATE ON "public"."record_tracks" FOR EACH STATEMENT EXECUTE FUNCTION "public"."enforce_rate_limit"('record_tracks', '60', '1 minute');



CREATE OR REPLACE TRIGGER "rate_limit_records" BEFORE INSERT OR DELETE OR UPDATE ON "public"."records" FOR EACH STATEMENT EXECUTE FUNCTION "public"."enforce_rate_limit"('records', '60', '1 minute');



CREATE OR REPLACE TRIGGER "rate_limit_sections" BEFORE INSERT OR DELETE OR UPDATE ON "public"."sections" FOR EACH STATEMENT EXECUTE FUNCTION "public"."enforce_rate_limit"('sections', '60', '1 minute');



CREATE OR REPLACE TRIGGER "rate_limit_tracks" BEFORE INSERT OR DELETE OR UPDATE ON "public"."tracks" FOR EACH STATEMENT EXECUTE FUNCTION "public"."enforce_rate_limit"('tracks', '60', '1 minute');



ALTER TABLE ONLY "public"."bars"
    ADD CONSTRAINT "bars_section_id_fkey" FOREIGN KEY ("section_id") REFERENCES "public"."sections"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."record_tracks"
    ADD CONSTRAINT "record_tracks_record_id_fkey" FOREIGN KEY ("record_id") REFERENCES "public"."records"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."record_tracks"
    ADD CONSTRAINT "record_tracks_track_id_fkey" FOREIGN KEY ("track_id") REFERENCES "public"."tracks"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."records"
    ADD CONSTRAINT "records_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."sections"
    ADD CONSTRAINT "sections_track_id_fkey" FOREIGN KEY ("track_id") REFERENCES "public"."tracks"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."tracks"
    ADD CONSTRAINT "tracks_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE "public"."bars" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."rate_limit_events" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."record_tracks" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."records" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."sections" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."tracks" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "users can access own bars" ON "public"."bars" USING ((EXISTS ( SELECT 1
   FROM ("public"."sections"
     JOIN "public"."tracks" ON (("tracks"."id" = "sections"."track_id")))
  WHERE (("sections"."id" = "bars"."section_id") AND ("tracks"."user_id" = "auth"."uid"())))));



CREATE POLICY "users can access own record_tracks" ON "public"."record_tracks" USING ((EXISTS ( SELECT 1
   FROM "public"."records"
  WHERE (("records"."id" = "record_tracks"."record_id") AND ("records"."user_id" = "auth"."uid"())))));



CREATE POLICY "users can access own records" ON "public"."records" USING (("user_id" = "auth"."uid"()));



CREATE POLICY "users can access own section" ON "public"."sections" USING ((EXISTS ( SELECT 1
   FROM "public"."tracks"
  WHERE (("tracks"."id" = "sections"."track_id") AND ("tracks"."user_id" = "auth"."uid"())))));



CREATE POLICY "users can access own tracks" ON "public"."tracks" USING (("user_id" = "auth"."uid"()));



CREATE POLICY "users can view own profile" ON "public"."profiles" FOR SELECT USING (("id" = "auth"."uid"()));





ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";





GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";































































































































































GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."record_tracks" TO "anon";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."record_tracks" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."record_tracks" TO "service_role";



GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."bars" TO "anon";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."bars" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."bars" TO "service_role";



GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."sections" TO "anon";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."sections" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."sections" TO "service_role";



GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."tracks" TO "anon";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."tracks" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."tracks" TO "service_role";


















GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."profiles" TO "anon";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."profiles" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."profiles" TO "service_role";



GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."rate_limit_events" TO "anon";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."rate_limit_events" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."rate_limit_events" TO "service_role";



GRANT UPDATE ON SEQUENCE "public"."rate_limit_events_id_seq" TO "anon";
GRANT UPDATE ON SEQUENCE "public"."rate_limit_events_id_seq" TO "authenticated";
GRANT UPDATE ON SEQUENCE "public"."rate_limit_events_id_seq" TO "service_role";



GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."records" TO "anon";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."records" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."records" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT UPDATE ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT UPDATE ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT UPDATE ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLES TO "service_role";
































--
-- Dumped schema changes for auth and storage
--

CREATE OR REPLACE TRIGGER "on_auth_user_created" AFTER INSERT ON "auth"."users" FOR EACH ROW EXECUTE FUNCTION "public"."handle_new_user"();



