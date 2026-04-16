CREATE OR REPLACE FUNCTION check_sections_limit()
RETURNS TRIGGER AS $$
DECLARE
    current_total INTEGER;
BEGIN
    IF TG_OP = 'INSERT' THEN
        current_total := (SELECT COALESCE(SUM(repetitions), 0) FROM sections WHERE track_id = NEW.track_id);
        IF current_total + COALESCE(NEW.repetitions, 1) > 100 THEN
            RAISE EXCEPTION 'Track cannot have more than 100 sections';
        END IF;
    ELSIF TG_OP = 'UPDATE' THEN
        current_total := (SELECT COALESCE(SUM(repetitions), 0) FROM sections WHERE track_id = NEW.track_id AND id != OLD.id);
        IF current_total + COALESCE(NEW.repetitions, 1) > 100 THEN
            RAISE EXCEPTION 'Track cannot have more than 100 sections';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enforce_sections_limit
    BEFORE INSERT OR UPDATE ON sections
    FOR EACH ROW EXECUTE FUNCTION check_sections_limit();

CREATE OR REPLACE FUNCTION check_bars_limit()
RETURNS TRIGGER AS $$
DECLARE
    current_total INTEGER;
BEGIN
    IF TG_OP = 'INSERT' THEN
        current_total := (SELECT COALESCE(SUM(repetitions), 0) FROM bars WHERE section_id = NEW.section_id);
        IF current_total + COALESCE(NEW.repetitions, 1) > 10 THEN
            RAISE EXCEPTION 'Section cannot have more than 10 bars';
        END IF;
    ELSIF TG_OP = 'UPDATE' THEN
        current_total := (SELECT COALESCE(SUM(repetitions), 0) FROM bars WHERE section_id = NEW.section_id AND id != OLD.id);
        IF current_total + COALESCE(NEW.repetitions, 1) > 10 THEN
            RAISE EXCEPTION 'Section cannot have more than 10 bars';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enforce_bars_limit
    BEFORE INSERT OR UPDATE ON bars
    FOR EACH ROW EXECUTE FUNCTION check_bars_limit();
