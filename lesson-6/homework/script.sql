CREATE TABLE InputTbl (
    col1 VARCHAR(10),
    col2 VARCHAR(10)
);

INSERT INTO InputTbl (col1, col2) VALUES 
('a', 'b'),
('a', 'b'),
('b', 'a'),
('c', 'd'),
('c', 'd'),
('m', 'n'),
('n', 'm');

SELECT DISTINCT
    CASE WHEN col1 < col2 THEN col1 ELSE col2 END AS col1,
    CASE WHEN col1 < col2 THEN col2 ELSE col1 END AS col2
FROM InputTbl;


SELECT 
    MIN(col1) AS col1,
    MAX(col2) AS col2
FROM (
    SELECT 
        CASE WHEN col1 < col2 THEN col1 ELSE col2 END AS col1,
        CASE WHEN col1 < col2 THEN col2 ELSE col1 END AS col2
    FROM InputTbl
) AS norm
GROUP BY col1, col2;


CREATE TABLE TestMultipleZero (
    A INT NULL,
    B INT NULL,
    C INT NULL,
    D INT NULL
);

INSERT INTO TestMultipleZero(A,B,C,D)
VALUES 
    (0,0,0,1),
    (0,0,1,0),
    (0,1,0,0),
    (1,0,0,0),
    (0,0,0,0), -- this should be removed
    (1,1,1,0);


SELECT *
FROM TestMultipleZero
WHERE COALESCE(A,0) + COALESCE(B,0) + COALESCE(C,0) + COALESCE(D,0) <> 0;



CREATE TABLE section1 (
    id INT,
    name VARCHAR(20)
);

INSERT INTO section1 VALUES 
(1, 'Been'),
(2, 'Roma'),
(3, 'Steven'),
(4, 'Paulo'),
(5, 'Genryh'),
(6, 'Bruno'),
(7, 'Fred'),
(8, 'Andro');


SELECT *
FROM section1
WHERE id % 2 = 1;







