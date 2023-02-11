-- password: 1234
INSERT INTO users.account (id, email, contact, password, verified, kyc_verified, kyc_uploaded)
    VALUES (
        '793fb8f3-3a76-4522-af5a-56a916729d2b', 'admin@harpocrates.unfla.me',
        '+91 XXXXX-YYYYY', '$argon2id$v=19$m=65536,t=2,p=1$3jG47ISWVMcUEgpEWe2JFQ$uWz4LhgaiAzzA8Tv7+eHm4TI6CL4qULI7K5jqmRr+dg',
        now(), TRUE, TRUE
    );

-- password: 1234
INSERT INTO users.account (id, email, contact, password, verified)
    VALUES (
        'c512a2aa-a14b-486e-9be7-651e2bb44c38', 'harpocrates@example.net',
        '+91 XXXXX-YYYYY', '$argon2id$v=19$m=65536,t=2,p=1$3jG47ISWVMcUEgpEWe2JFQ$uWz4LhgaiAzzA8Tv7+eHm4TI6CL4qULI7K5jqmRr+dg',
        now()
    );

INSERT INTO orderbook.detail (account, symbol, type, quantity, price)
    VALUES ('c512a2aa-a14b-486e-9be7-651e2bb44c38', 'HARPOCRATES', 'sell', 100, 20.30),
           ('c512a2aa-a14b-486e-9be7-651e2bb44c38', 'HARPOCRATES', 'sell', 100, 20.25),
           ('c512a2aa-a14b-486e-9be7-651e2bb44c38', 'HARPOCRATES', 'sell', 200, 20.30),
           ('c512a2aa-a14b-486e-9be7-651e2bb44c38', 'HARPOCRATES', 'buy', 250, 20.25),
           ('c512a2aa-a14b-486e-9be7-651e2bb44c38', 'AAPL', 'sell', 100, 20.30),
           ('c512a2aa-a14b-486e-9be7-651e2bb44c38', 'AAPL', 'sell', 100, 20.25),
           ('c512a2aa-a14b-486e-9be7-651e2bb44c38', 'AAPL', 'sell', 200, 20.30),
           ('c512a2aa-a14b-486e-9be7-651e2bb44c38', 'AAPL', 'buy', 250, 20.25);
