CREATE TYPE resource_type AS ENUM (
    'aadhar-proof', 'pan-proof'
);

-- user schema
CREATE SCHEMA users;
CREATE TABLE IF NOT EXISTS users.account(
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created TIMESTAMP WITH TIME ZONE DEFAULT now(),
    username TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    phone TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL
);

-- resource schema
CREATE SCHEMA resource;
CREATE TABLE IF NOT EXISTS resource.media(
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type resource_type NOT NULL,
    uploaded_by UUID NOT NULL REFERENCES users.account,
    created TIMESTAMP WITH TIME ZONE DEFAULT now(),
    deleted TIMESTAMP WITH TIME ZONE,
    details JSONB,
    resolution TEXT,
    file_key UUID UNIQUE DEFAULT gen_random_uuid()
);
