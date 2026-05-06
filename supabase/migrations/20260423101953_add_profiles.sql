CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users (id) ON DELETE CASCADE,
    username TEXT UNIQUE NOT NULL CHECK (char_length(username) >=1 AND char_length(username) <= 30 AND username ~ '^[a-zA-Z0-9][a-zA-Z0-9_-]*[a-zA-Z0-9]$' ),
    full_name TEXT NOT NULL CHECK (char_length(full_name) >=1 AND char_length( full_name) <= 64),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users can view own profile" ON profiles
    FOR SELECT USING (id = auth.uid());
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN 
    INSERT INTO profiles (id, username, full_name)
    VALUES (
        NEW.id,
        NEW.raw_user_meta_data->>'username',
        NEW.raw_user_meta_data->>'full_name'
    );
    RETURN NEW;
END
$$ LANGUAGE plpgsql SECURITY DEFINER;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION handle_new_user();