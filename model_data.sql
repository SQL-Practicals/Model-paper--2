-- 1. Valid insert into Products
INSERT INTO Products (product_id, product_name, price, added_on) 
VALUES (1, 'Laptop', 1200.00, CURRENT_DATE);

-- 2. Invalid insert into Products: price <= 0 (should fail)
INSERT INTO Products (product_id, product_name, price, added_on) 
VALUES (2, 'Smartphone', -50.00, CURRENT_DATE);

-- 3. Valid insert into Suppliers
INSERT INTO Suppliers (supplier_id, supplier_name, contact_email, established_year) 
VALUES (101, 'TechSupply Co.', 'contact@techsupply.com', 2010);

-- 4. Invalid insert into Suppliers: duplicate email (should fail)
INSERT INTO Suppliers (supplier_id, supplier_name, contact_email, established_year) 
VALUES (102, 'Gadget World', 'contact@techsupply.com', 2012);

-- 5. Invalid insert into Suppliers: established_year < 2000 (should fail)
INSERT INTO Suppliers (supplier_id, supplier_name, contact_email, established_year) 
VALUES (103, 'Old Supplier', 'old@supplier.com', 1995);

-- 6. Valid insert into StockMovements
INSERT INTO StockMovements (movement_id, product_id, supplier_id, movement_type, quantity, movement_date) 
VALUES (1001, 1, 101, 'IN', 50, CURRENT_DATE);

-- 7. Invalid insert into StockMovements: movement_type not 'IN' or 'OUT' (should fail)
INSERT INTO StockMovements (movement_id, product_id, supplier_id, movement_type, quantity, movement_date) 
VALUES (1002, 1, 101, 'INOUT', 10, CURRENT_DATE);

-- 8. Invalid insert into StockMovements: quantity <= 0 (should fail)
INSERT INTO StockMovements (movement_id, product_id, supplier_id, movement_type, quantity, movement_date) 
VALUES (1003, 1, 101, 'OUT', 0, CURRENT_DATE);
