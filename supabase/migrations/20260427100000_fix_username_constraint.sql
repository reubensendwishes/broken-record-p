ALTER TABLE profiles
    DROP CONSTRAINT profiles_username_check,
    ADD CONSTRAINT profiles_username_check CHECK (
        char_length(username) >= 1
        AND char_length(username) <= 30
        AND username ~ '^[a-zA-Z0-9]([a-zA-Z0-9_-]*[a-zA-Z0-9])?$'
    );
