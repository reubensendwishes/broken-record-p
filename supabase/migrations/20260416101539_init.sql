CREATE TYPE bar_type AS ENUM ('spelling','word','interval');
CREATE TYPE bar_lang AS ENUM ('en-US','zh-TW');

CREATE TABLE records(
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    position TEXT NOT NULL,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE tracks(
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    position TEXT NOT NULL,
    record_id UUID NOT NULL REFERENCES records(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE sections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    position TEXT NOT NULL,
    repetitions INTEGER NOT NULL DEFAULT 1,
    track_id UUID NOT NULL REFERENCES tracks(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE bars (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type bar_type NOT NULL,
    content TEXT NOT NULL,
    position TEXT NOT NULL,
    section_id UUID NOT NULL REFERENCES sections(id) ON DELETE CASCADE,
    lang bar_lang,
    repetitions INTEGER,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT interval_no_lang CHECK (
        type != 'interval' OR lang IS NULL
    ),
    CONSTRAINT interval_no_repetitions CHECK (
        type != 'interval' OR repetitions IS NULL
    ),
    CONSTRAINT speech_requires_lang CHECK (
        type = 'interval' OR lang IS NOT NULL
    ),
    CONSTRAINT speech_requires_repetitions CHECK (
        type = 'interval' OR repetitions IS NOT NULL
    )
);

ALTER TABLE records ENABLE ROW LEVEL SECURITY;
ALTER TABLE tracks ENABLE ROW LEVEL SECURITY;
ALTER TABLE sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE bars ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users can access own records" ON records
    USING (user_id = auth.uid());

CREATE POLICY "users can access own tracks" ON tracks
    USING (
        EXISTS (
            SELECT 1 FROM records
            WHERE records.id = tracks.record_id
            AND records.user_id = auth.uid()
        )
    );

CREATE POLICY "users can access own section" ON sections
    USING (
        EXISTS (
            SELECT 1 FROM tracks
            JOIN records ON records.id = tracks.record_id
            WHERE tracks.id = sections.track_id
            AND records.user_id = auth.uid()
        )
    );

CREATE POLICY "users can access own bars" ON bars
    USING (
        EXISTS (
            SELECT 1 FROM sections
            JOIN tracks ON tracks.id = sections.track_id
            JOIN records ON records.id = tracks.record_id
            WHERE sections.id = bars.section_id
            AND records.user_id = auth.uid()
        )
    );

