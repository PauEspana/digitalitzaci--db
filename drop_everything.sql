DROP TRIGGER tr_validate_client_DNI;
DROP TRIGGER tr_validate_employee_DNI;
DROP TRIGGER tr_validate_distributor_CIF;
DROP TRIGGER tr_update_total_spent;
DROP TRIGGER tr_ban_sales_outside_work_hours;
DROP TRIGGER tr_reduce_stock_after_sale;
DROP TRIGGER tr_ban_product_without_stock;
DROP TRIGGER tr_create_order;
DROP TRIGGER tr_add_points_on_invoice;
DROP TRIGGER tr_avoid_setting_higher_salary;
DROP TRIGGER tr_set_christmas_discount;

DROP TABLE CLIENT CASCADE CONSTRAINTS;
DROP TABLE CLIENT_CARD CASCADE CONSTRAINTS;
DROP TABLE DISCOUNT_TYPE CASCADE CONSTRAINTS;
DROP TABLE DISTRIBUTOR CASCADE CONSTRAINTS;
DROP TABLE EMPLOYEE CASCADE CONSTRAINTS;
DROP TABLE PRODUCT CASCADE CONSTRAINTS;
DROP TABLE SALE CASCADE CONSTRAINTS;
DROP TABLE SALE_DETAILS CASCADE CONSTRAINTS;
DROP TABLE INVOICE CASCADE CONSTRAINTS;
DROP TABLE product_order CASCADE CONSTRAINTS;

DROP PROCEDURE new_empty_sale;
DROP PROCEDURE add_sale_product;
DROP PROCEDURE update_total_spent;
DROP PROCEDURE list_invoice;
DROP PROCEDURE create_order;
DROP PROCEDURE validate_sale;

DROP FUNCTION validate_DNI;
DROP FUNCTION validate_cif;
DROP FUNCTION total_sale_amount;
DROP FUNCTION total_sale_amount_from_employee;
DROP FUNCTION most_sold_product;
DROP FUNCTION CALCULATE_FINAL_PRICE;

DROP ROLE C##role_sales;
DROP ROLE C##role_purchasing;
DROP ROLE C##role_administration;
DROP ROLE C##role_dbadmin;

DROP USER C##empl_sales1 CASCADE;
DROP USER C##empl_sales2 CASCADE;
DROP USER C##empl_sales3 CASCADE;
DROP USER C##emp_purchasing1 CASCADE;
DROP USER C##emp_purchasing2 CASCADE;
DROP USER C##emp_purchasing3 CASCADE;
DROP USER C##emp_administration1 CASCADE;
DROP USER C##emp_administration2 CASCADE;
DROP USER C##emp_administration3 CASCADE;
DROP USER C##superuser CASCADE;