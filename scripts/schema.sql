CREATE TYPE account_type AS ENUM ('admin', 'user');
CREATE TYPE kyc_type AS ENUM ('aadhar', 'pan');
CREATE TYPE transaction_type AS ENUM ('buy', 'sell');

DROP SCHEMA IF EXISTS users CASCADE;

-- user schema
CREATE SCHEMA users;
CREATE TABLE IF NOT EXISTS users.account(
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type account_type NOT NULL DEFAULT 'user',
    created TIMESTAMP WITH TIME ZONE DEFAULT now(),
    email TEXT NOT NULL UNIQUE,
    contact TEXT NOT NULL,
    password TEXT NOT NULL,
    verified TIMESTAMP WITH TIME ZONE, -- email verification
    kyc_verified BOOLEAN DEFAULT FALSE, -- admin verification complete
    kyc_uploaded BOOLEAN DEFAULT FALSE -- kyc upload complete
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
    image UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),

    UNIQUE (account, type)
);
CREATE TABLE IF NOT EXISTS users.transaction(
    account UUID NOT NULL REFERENCES users.account,
    created TIMESTAMP WITH TIME ZONE DEFAULT now(),
    type transaction_type NOT NULL,
    symbol TEXT NOT NULL,
    quantity INTEGER NOT NULL,
    price DECIMAL NOT NULL
);

-- orderbook schema
CREATE SCHEMA orderbook;
CREATE TABLE orderbook.detail(
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created TIMESTAMP WITH TIME ZONE DEFAULT now(),
    account UUID NOT NULL REFERENCES users.account,
    symbol TEXT NOT NULL,
    type transaction_type NOT NULL,
    quantity INTEGER NOT NULL,
    price DECIMAL NOT NULL
);
