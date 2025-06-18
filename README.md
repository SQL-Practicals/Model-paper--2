# MODEL PAPER 02

## Inventory Management System – SQL Script and Execution

This project demonstrates the creation of an Inventory Management System using SQL. It includes the creation of tables with constraints, inserting valid and invalid data, adding indexes, writing stored procedures, and executing relevant queries.

```sql
-- Create database
CREATE DATABASE InventoryMangment;
USE InventoryMangment;

-- Create Products table
CREATE TABLE Products(
	product_id INT,
	product_name VARCHAR(100) NOT NULL,
	price DECIMAL(10,2) CHECK(price > 0),
	added_on DATE DEFAULT CURRENT_DATE,
	PRIMARY KEY(product_id)
);

-- Create Suppliers table
CREATE TABLE Suppliers(
	supplier_id INT,
	supplier_name VARCHAR(100) NOT NULL,
	contact_email VARCHAR(100) UNIQUE,
	established_year INT CHECK (established_year >= 2000),
	PRIMARY KEY(supplier_id)
);

-- Create StockMovements table
CREATE TABLE StockMovements(
	movement_id INT,
	product_id INT,
	supplier_id INT,
	movement_type VARCHAR(10) CHECK (movement_type IN ('IN' , 'OUT')),
	movement_date DATE DEFAULT CURRENT_DATE,
	quantity INT CHECK (quantity > 0),
	PRIMARY KEY(movement_id)
);

-- Add foreign keys
ALTER TABLE StockMovements ADD FOREIGN KEY(product_id) REFERENCES Products(product_id);
ALTER TABLE StockMovements ADD FOREIGN KEY(supplier_id) REFERENCES Suppliers(supplier_id);

-- Insert 1: Valid product
INSERT INTO Products (product_id, product_name, price, added_on) 
VALUES (1, 'Laptop', 1200.00, CURRENT_DATE);

SELECT * FROM Products;

-- Insert 2: Invalid product (price <= 0)
INSERT INTO Products (product_id, product_name, price, added_on) 
VALUES (2, 'Smartphone', -50.00, CURRENT_DATE);
-- Error: CONSTRAINT `products.price` failed

-- Insert 3: Valid supplier
INSERT INTO Suppliers (supplier_id, supplier_name, contact_email, established_year) 
VALUES (101, 'TechSupply Co.', 'contact@techsupply.com', 2010);

SELECT * FROM Suppliers;

-- Insert 4: Invalid supplier (duplicate email)
INSERT INTO Suppliers (supplier_id, supplier_name, contact_email, established_year) 
VALUES (102, 'Gadget World', 'contact@techsupply.com', 2012);
-- Error: Duplicate entry 'contact@techsupply.com'

-- Insert 5: Invalid supplier (year < 2000)
INSERT INTO Suppliers (supplier_id, supplier_name, contact_email, established_year) 
VALUES (103, 'Old Supplier', 'old@supplier.com', 1995);
-- Error: CONSTRAINT `suppliers.established_year` failed

-- Insert 6: Valid stock movement
INSERT INTO StockMovements (movement_id, product_id, supplier_id, movement_type, quantity, movement_date) 
VALUES (1001, 1, 101, 'IN', 50, CURRENT_DATE);

-- Insert 7: Invalid stock movement (invalid movement_type)
INSERT INTO StockMovements (movement_id, product_id, supplier_id, movement_type, quantity, movement_date) 
VALUES (1002, 1, 101, 'INOUT', 10, CURRENT_DATE);
-- Error: CONSTRAINT `stockmovements.movement_type` failed

-- Insert 8: Invalid stock movement (quantity <= 0)
INSERT INTO StockMovements (movement_id, product_id, supplier_id, movement_type, quantity, movement_date) 
VALUES (1003, 1, 101, 'OUT', 0, CURRENT_DATE);
-- Error: CONSTRAINT `stockmovements.quantity` failed

-- Index on product_id
CREATE INDEX idx_stock_product_id ON StockMovements(product_id);

-- Query: Suppliers who supplied quantity > 50
SELECT DISTINCT s.supplier_name
FROM StockMovements sm 
JOIN Suppliers s ON sm.supplier_id = s.supplier_id
WHERE sm.quantity > 50;

-- Procedure: GetStockMovementsBySupplier
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

-- Call procedure
CALL GetStockMovementsBySupplier('TechSupply Co.');

-- Query: Total number of products per supplier
SELECT s.supplier_name, COUNT(DISTINCT sm.product_id) AS total_products
FROM StockMovements sm
JOIN Suppliers s ON sm.supplier_id = s.supplier_id
GROUP BY s.supplier_name;

-- Index on quantity column
CREATE INDEX idx_stock_quantity ON StockMovements(quantity);

-- Procedure: GetProductStock
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

-- Call procedure to check stock
CALL GetProductStock(1, @level);
SELECT @level AS current_stock;

-- Show indexes
SHOW INDEXES FROM StockMovements;
SHOW INDEXES FROM Suppliers;
SHOW INDEXES FROM Products;
