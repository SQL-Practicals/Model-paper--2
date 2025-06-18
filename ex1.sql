create database InventoryMangment;

use InventoryMangment;

CREATE TABLE Products(
	product_id INT ,
	product_name VARCHAR(100) NOT NULL,
	price DECIMAL(10,2) CHECK(price > 0),
	added_on DATE DEFAULT CURRENT_DATE,
	PRIMARY KEY(product_id)
);

CREATE TABLE Suppliers(
	supplier_id INT,
	supplier_name VARCHAR(100) NOT NULL,
	contact_email VARCHAR(100) UNIQUE,
	established_year INT CHECK (established_year >= 2000),
	PRIMARY KEY(supplier_id)
);

CREATE TABLE StockMovements(
	movement_id INT,
	product_id INT,
	supplier_id INT,
	movement_type VARCHAR(10) CHECK (movement_type IN ('IN' , 'OUT')),
	movement_date DATE DEFAULT CURRENT_DATE,
	quantity INT CHECK (quantity > 0),
	PRIMARY KEY(movement_id)
);

ALTER TABLE StockMovements
ADD FOREIGN KEY(product_id)
REFERENCES products(product_id);
Query OK, 0 rows affected (0.067 sec)
Records: 0  Duplicates: 0  Warnings: 0

ALTER TABLE StockMovements
ADD FOREIGN KEY(supplier_id)
REFERENCES Suppliers(supplier_id);
Query OK, 0 rows affected (0.074 sec)
Records: 0  Duplicates: 0  Warnings: 0

-- 1. Valid insert into Products
INSERT INTO Products (product_id, product_name, price, added_on) 
VALUES (1, 'Laptop', 1200.00, CURRENT_DATE);
Query OK, 1 row affected (0.008 sec)

select * from Products;
+------------+--------------+---------+------------+
| product_id | product_name | price   | added_on   |
+------------+--------------+---------+------------+
|          1 | Laptop       | 1200.00 | 2025-06-18 |
+------------+--------------+---------+------------+
1 row in set (0.000 sec)


-- 2. Invalid insert into Products: price <= 0 (should fail)
INSERT INTO Products (product_id, product_name, price, added_on) 
VALUES (2, 'Smartphone', -50.00, CURRENT_DATE);
ERROR 4025 (23000): CONSTRAINT `products.price` failed for `inventorymangment`.`products


-- 3. Valid insert into Suppliers
INSERT INTO Suppliers (supplier_id, supplier_name, contact_email, established_year) 
VALUES (101, 'TechSupply Co.', 'contact@techsupply.com', 2010);

select * from Suppliers;
+-------------+----------------+------------------------+------------------+
| supplier_id | supplier_name  | contact_email          | established_year |
+-------------+----------------+------------------------+------------------+
|         101 | TechSupply Co. | contact@techsupply.com |             2010 |
+-------------+----------------+------------------------+------------------+

-- 4. Invalid insert into Suppliers: duplicate email (should fail)
INSERT INTO Suppliers (supplier_id, supplier_name, contact_email, established_year) 
VALUES (102, 'Gadget World', 'contact@techsupply.com', 2012);
ERROR 1062 (23000): Duplicate entry 'contact@techsupply.com' for key 'contact_email'


-- 5. Invalid insert into Suppliers: established_year < 2000 (should fail)
INSERT INTO Suppliers (supplier_id, supplier_name, contact_email, established_year) 
VALUES (103, 'Old Supplier', 'old@supplier.com', 1995);
ERROR 4025 (23000): CONSTRAINT `suppliers.established_year` failed for `inventorymangment`.`suppliers`

-- 6. Valid insert into StockMovements
INSERT INTO StockMovements (movement_id, product_id, supplier_id, movement_type, quantity, movement_date) 
VALUES (1001, 1, 101, 'IN', 50, CURRENT_DATE);


-- 7. Invalid insert into StockMovements: movement_type not 'IN' or 'OUT' (should fail)
INSERT INTO StockMovements (movement_id, product_id, supplier_id, movement_type, quantity, movement_date) 
VALUES (1002, 1, 101, 'INOUT', 10, CURRENT_DATE);
ERROR 4025 (23000): CONSTRAINT `stockmovements.movement_type` failed for `inventorymangment`.`stockmovements`

-- 8. Invalid insert into StockMovements: quantity <= 0 (should fail)
INSERT INTO StockMovements (movement_id, product_id, supplier_id, movement_type, quantity, movement_date) 
VALUES (1003, 1, 101, 'OUT', 0, CURRENT_DATE);
ERROR 4025 (23000): CONSTRAINT `stockmovements.quantity` failed for `inventorymangment`.`stockmovements`



CREATE INDEX idx_stock_product_id ON StockMovements(product_id);
Query OK, 0 rows affected (0.021 sec)
Records: 0  Duplicates: 0  Warnings: 0


SELECT DISTINCT s.supplier_name
FROM StockMovements sm 
JOIN Suppliers s ON sm.supplier_id = s.supplier_id
WHERE sm.quantity > 50;



DELIMITER //
CREATE PROCEDURE GetStockMovementsBySupplier 
(IN supp_name VARCHAR(100))
BEGIN
    SELECT p.product_name, s.supplier_name, sm.movement_type, sm.quantity, sm.movement_date
    FROM StockMovements sm
    JOIN Products p ON sm.product_id = p.product_id
    JOIN Suppliers s ON sm.supplier_id = s.supplier_id
    WHERE s.supplier_name = supp_name;
END //

DELIMITER ;
Query OK, 0 rows affected (0.014 sec)

CALL GetStockMovementsBySupplier('TechSupply Co.');

SELECT s.supplier_name, COUNT(DISTINCT sm.product_id) AS total_products
FROM StockMovements sm
JOIN Suppliers s ON sm.supplier_id = s.supplier_id
GROUP BY s.supplier_name;

CREATE INDEX idx_stock_quantity ON StockMovements(quantity);
Query OK, 0 rows affected (0.018 sec)
Records: 0  Duplicates: 0  Warnings: 0

DELIMITER //

CREATE PROCEDURE GetProductStock(IN pid INT, OUT stock_level INT)
BEGIN
    DECLARE total_in INT DEFAULT 0;
    DECLARE total_out INT DEFAULT 0;

    SELECT SUM(quantity) INTO total_in
    FROM StockMovements
    WHERE product_id = pid AND movement_type = 'IN';

    SELECT SUM(quantity) INTO total_out
    FROM StockMovements
    WHERE product_id = pid AND movement_type = 'OUT';

    SET stock_level = IFNULL(total_in, 0) - IFNULL(total_out, 0);
END //

DELIMITER ;

CALL GetProductStock(1, @level);
SELECT @level AS current_stock;



SHOW INDEXES FROM StockMovements; 
+----------------+------------+----------------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table          | Non_unique | Key_name             | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+----------------+------------+----------------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| stockmovements |          0 | PRIMARY              |            1 | movement_id | A         |           0 |     NULL | NULL   |      | BTREE      |         |               |
| stockmovements |          1 | supplier_id          |            1 | supplier_id | A         |           0 |     NULL | NULL   | YES  | BTREE      |         |               |
| stockmovements |          1 | idx_stock_product_id |            1 | product_id  | A         |           0 |     NULL | NULL   | YES  | BTREE      |         |               |
| stockmovements |          1 | idx_stock_quantity   |            1 | quantity    | A         |           0 |     NULL | NULL   | YES  | BTREE      |         |               |
+----------------+------------+----------------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
4 rows in set (0.001 sec)

SHOW INDEXES FROM Suppliers;
+-----------+------------+---------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table     | Non_unique | Key_name      | Seq_in_index | Column_name   | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+-----------+------------+---------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| suppliers |          0 | PRIMARY       |            1 | supplier_id   | A         |           1 |     NULL | NULL   |      | BTREE      |         |               |
| suppliers |          0 | contact_email |            1 | contact_email | A         |           1 |     NULL | NULL   | YES  | BTREE      |         |               |
+-----------+------------+---------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
2 rows in set (0.001 sec)

SHOW INDEXES FROM Products;
+----------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table    | Non_unique | Key_name | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+----------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| products |          0 | PRIMARY  |            1 | product_id  | A         |           1 |     NULL | NULL   |      | BTREE      |         |               |
+----------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
1 row in set (0.001 sec)