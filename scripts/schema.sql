CREATE TYPE kyc_type AS ENUM (
    'aadhar', 'pan'
);

DROP SCHEMA IF EXISTS users CASCADE;

-- user schema
CREATE SCHEMA users;
CREATE TABLE IF NOT EXISTS users.account(
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created TIMESTAMP WITH TIME ZONE DEFAULT now(),
    email TEXT NOT NULL UNIQUE,
    contact TEXT NOT NULL,
    password TEXT NOT NULL,
    verified TIMESTAMP WITH TIME ZONE, -- email verification
    kyc BOOLEAN DEFAULT FALSE
);
CREATE TABLE IF NOT EXISTS users.verification(
    account UUID NOT NULL REFERENCES users.account,
    created TIMESTAMP WITH TIME ZONE DEFAULT now(),
    token UUID NOT NULL DEFAULT gen_random_uuid()
);
CREATE TABLE IF NOT EXISTS users.kyc(
    account UUID NOT NULL REFERENCES users.account,
    created TIMESTAMP WITH TIME ZONE DEFAULT now(),
    type kyc_type NOT NULL,
    id TEXT NOT NULL,
    image UUID NOT NULL UNIQUE DEFAULT gen_random_uuid()
);
