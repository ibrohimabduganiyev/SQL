-- Create and populate tables
CREATE TABLE Person (
    personId  INT,
    firstName VARCHAR(255),
    lastName  VARCHAR(255)
);

CREATE TABLE Address (
    addressId INT,
    personId  INT,
    city      VARCHAR(255),
    state     VARCHAR(255)
);

TRUNCATE TABLE Person;
INSERT INTO Person (personId, lastName, firstName) VALUES 
(1, 'Wang', 'Allen'),
(2, 'Alice', 'Bob');

TRUNCATE TABLE Address;
INSERT INTO Address (addressId, personId, city, state) VALUES 
(1, 2, 'New York City', 'New York'),
(2, 3, 'Leetcode', 'California');

-- ✅ Final query
SELECT 
    p.firstName,
    p.lastName,
    a.city,
    a.state
FROM Person AS p
LEFT JOIN Address AS a
    ON p.personId = a.personId;

