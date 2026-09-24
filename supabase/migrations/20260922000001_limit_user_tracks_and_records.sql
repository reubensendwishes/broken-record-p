-- Lower the per-user track cap from 1000 to 200, and per-user record cap from 1000 to 100.
-- The enforce_maximum_user_tracks / enforce_maximum_user_records triggers already call these
-- functions, so replacing them is enough.
CREATE OR REPLACE FUNCTION "public"."prevent_exceed_max_user_tracks"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    PERFORM pg_advisory_xact_lock(hashtext('tracks'), hashtext(NEW.user_id::text));

    IF (SELECT COUNT(*) FROM public.tracks WHERE user_id = NEW.user_id) >= 200 THEN
        RAISE EXCEPTION 'User cannot have more than 200 tracks';
    END IF;

    RETURN NEW;
END
$$;

CREATE OR REPLACE FUNCTION "public"."prevent_exceed_max_user_records"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    PERFORM pg_advisory_xact_lock(hashtext('records'), hashtext(NEW.user_id::text));

    IF (SELECT COUNT(*) FROM public.records WHERE user_id = NEW.user_id) >= 100 THEN
        RAISE EXCEPTION 'User cannot have more than 100 records';
    END IF;

    RETURN NEW;
END
$$;
