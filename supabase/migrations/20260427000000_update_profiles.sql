ALTER TABLE profiles RENAME COLUMN full_name TO display_name;

ALTER TABLE profiles
    DROP CONSTRAINT profiles_full_name_check,
    ADD CONSTRAINT profiles_display_name_check CHECK (char_length(display_name) BETWEEN 1 AND 60);

CREATE POLICY "users can update own profile" ON profiles
    FOR UPDATE USING (id = auth.uid())
    WITH CHECK (id = auth.uid() AND username = (SELECT username FROM profiles WHERE id = auth.uid()));

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO profiles (id, username, display_name)
    VALUES (
        NEW.id,
        NEW.raw_user_meta_data->>'username',
        NEW.raw_user_meta_data->>'display_name'
    );
    RETURN NEW;
END
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION normalize_display_name()
RETURNS TRIGGER AS $$
BEGIN
    NEW.display_name := normalize(NEW.display_name, NFC);
    RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER normalize_display_name_on_upsert
    BEFORE INSERT OR UPDATE OF display_name ON profiles
    FOR EACH ROW EXECUTE FUNCTION normalize_display_name();
