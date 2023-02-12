-- password: 1234
INSERT INTO users.account (id, email, contact, password, verified, kyc_verified, kyc_uploaded, type)
    VALUES (
        '793fb8f3-3a76-4522-af5a-56a916729d2b', 'admin@harpocrates.unfla.me',
        '+91 XXXXX-YYYYY', '$argon2id$v=19$m=65536,t=2,p=1$3jG47ISWVMcUEgpEWe2JFQ$uWz4LhgaiAzzA8Tv7+eHm4TI6CL4qULI7K5jqmRr+dg',
        now(), TRUE, TRUE, 'admin'
    );

-- password: 1234
INSERT INTO users.account (id, email, contact, password, verified)
    VALUES (
        'c512a2aa-a14b-486e-9be7-651e2bb44c38', 'harpocrates@unfla.me',
        '+91 XXXXX-YYYYY', '$argon2id$v=19$m=65536,t=2,p=1$3jG47ISWVMcUEgpEWe2JFQ$uWz4LhgaiAzzA8Tv7+eHm4TI6CL4qULI7K5jqmRr+dg',
        now()
    );

INSERT INTO users.account (email, contact, password, verified)
    VALUES (
        'user1@unfla.me',
        '+91 XXXXX-YYYYY', '$argon2id$v=19$m=65536,t=2,p=1$3jG47ISWVMcUEgpEWe2JFQ$uWz4LhgaiAzzA8Tv7+eHm4TI6CL4qULI7K5jqmRr+dg',
        now()
    );

INSERT INTO orderbook.detail (account, symbol, type, quantity, price)
    VALUES ('c512a2aa-a14b-486e-9be7-651e2bb44c38', 'NHAI', 'sell', 100, 1135.49),
           ('c512a2aa-a14b-486e-9be7-651e2bb44c38', 'NHAI', 'sell', 100, 1134.30),
           ('c512a2aa-a14b-486e-9be7-651e2bb44c38', 'NHAI', 'sell', 200, 1130),
           ('c512a2aa-a14b-486e-9be7-651e2bb44c38', 'NHAI', 'buy', 250, 1150),
           ('c512a2aa-a14b-486e-9be7-651e2bb44c38', 'HUDCO', 'sell', 100, 46.85),
           ('c512a2aa-a14b-486e-9be7-651e2bb44c38', 'HUDCO', 'sell', 100, 45.8),
           ('c512a2aa-a14b-486e-9be7-651e2bb44c38', 'HUDCO', 'sell', 200, 45.3),
           ('c512a2aa-a14b-486e-9be7-651e2bb44c38', 'HUDCO', 'buy', 250, 46);
