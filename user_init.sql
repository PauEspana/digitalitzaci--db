CREATE ROLE C##role_sales;
CREATE ROLE C##role_purchasing;
CREATE ROLE C##role_administration;
CREATE ROLE C##role_dbadmin;

GRANT SELECT ON SALE TO C##role_sales;
GRANT SELECT ON SALE_DETAILS TO C##role_sales;
GRANT EXECUTE ON NEW_EMPTY_SALE TO C##role_sales;
GRANT EXECUTE ON ADD_SALE_PRODUCT TO C##role_sales;

GRANT SELECT ON PRODUCT_ORDER TO C##role_purchasing;

GRANT SELECT ON INVOICE TO C##role_administration;

GRANT SELECT, INSERT, UPDATE, DELETE ON CLIENT TO C##role_dbadmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON CLIENT_CARD TO C##role_dbadmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON DISCOUNT_TYPE TO C##role_dbadmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON EMPLOYEE TO C##role_dbadmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON DISTRIBUTOR TO C##role_dbadmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON PRODUCT TO C##role_dbadmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON SALE TO C##role_dbadmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON SALE_DETAILS TO C##role_dbadmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON INVOICE TO C##role_dbadmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON PRODUCT_ORDER TO C##role_dbadmin;

CREATE USER C##empl_sales1 IDENTIFIED BY emptyPassword1;
CREATE USER C##empl_sales2 IDENTIFIED BY emptyPassword2;
CREATE USER C##empl_sales3 IDENTIFIED BY emptyPassword3;
CREATE USER C##emp_purchasing1 IDENTIFIED BY emptyPassword1;
CREATE USER C##emp_purchasing2 IDENTIFIED BY emptyPassword2;
CREATE USER C##emp_purchasing3 IDENTIFIED BY emptyPassword3;
CREATE USER C##emp_administration1 IDENTIFIED BY emptyPassword1;
CREATE USER C##emp_administration2 IDENTIFIED BY emptyPassword2;
CREATE USER C##emp_administration3 IDENTIFIED BY emptyPassword3;
CREATE USER C##superuser IDENTIFIED BY superuserpassword;

GRANT C##role_sales TO C##empl_sales1;
GRANT C##role_sales TO C##empl_sales2;
GRANT C##role_sales TO C##empl_sales3;

GRANT C##role_purchasing TO C##emp_purchasing1;
GRANT C##role_purchasing TO C##emp_purchasing2;
GRANT C##role_purchasing TO C##emp_purchasing3;

GRANT C##role_administration TO C##emp_administration1;
GRANT C##role_administration TO C##emp_administration2;
GRANT C##role_administration TO C##emp_administration3;

GRANT C##role_dbadmin TO C##superuser;