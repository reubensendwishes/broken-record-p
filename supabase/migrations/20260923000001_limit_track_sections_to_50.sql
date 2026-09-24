-- Lower the per-track section cap from 100 to 50.
-- The enforce_sections_limit trigger already calls this function, so replacing it is enough.
CREATE OR REPLACE FUNCTION "public"."check_sections_limit"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    current_count INTEGER;
BEGIN
    IF TG_OP = 'INSERT' THEN
        SELECT COUNT(*) INTO current_count FROM sections WHERE track_id = NEW.track_id;
        IF current_count + 1 > 50 THEN
            RAISE EXCEPTION 'Track cannot have more than 50 sections';
        END IF;
    ELSIF TG_OP = 'UPDATE' THEN
        SELECT COUNT(*) INTO current_count FROM sections WHERE track_id = NEW.track_id AND id != OLD.id;
        IF current_count + 1 > 50 THEN
            RAISE EXCEPTION 'Track cannot have more than 50 sections';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;
