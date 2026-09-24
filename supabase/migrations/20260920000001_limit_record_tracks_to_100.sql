-- Lower the per-record track cap from 1000 to 100.
-- The enforce_maximum_record_tracks trigger already calls this function, so replacing it is enough.
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

    IF current_count >= 100 THEN
        RAISE EXCEPTION 'Record cannot have more than 100 tracks';
    END IF;

    RETURN NEW;
END
$$;
