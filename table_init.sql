CREATE TABLE CLIENT
(
    cl_dni          varchar2(9) PRIMARY KEY,
    cl_name         varchar2(20) NOT NULL,
    cl_address      varchar2(50),
    cl_city         varchar2(20),
    cl_phoneNumber  varchar2(9)  NOT NULL,
    cl_clientCard   number(8),
    cl_totalSpent   number(8, 2) NOT NULL,
    cl_discountType number(2) DEFAULT 0,
    constraint CK_cl_phoneNumber_valid CHECK (LENGTH(cl_phoneNumber) = 9 AND
                                              cl_phoneNumber BETWEEN '000000000' AND '999999999')
);
CREATE TABLE CLIENT_CARD
(
    cc_number number(8) PRIMARY KEY,
    cc_points number(7) NOT NULL
);
CREATE TABLE DISCOUNT_TYPE
(
    dt_id          number(2) PRIMARY KEY,
    dt_description varchar2(50),
    dt_percentage  number(2)
);
CREATE TABLE DISTRIBUTOR
(
    ds_cif           varchar2(9) PRIMARY KEY,
    ds_name          varchar2(20) NOT NULL,
    ds_address       varchar2(50),
    ds_city          varchar2(20),
    ds_phoneNumber   varchar2(9)  NOT NULL,
    ds_contactPerson varchar2(20),
    ds_totalBought   number(10, 2),
    constraint CK_ds_phoneNumber_valid CHECK (LENGTH(ds_phoneNumber) = 9 AND
                                              ds_phoneNumber BETWEEN '000000000' AND '999999999')
);
CREATE TABLE EMPLOYEE
(
    em_dni         varchar2(9) PRIMARY KEY,
    em_name        varchar2(20) NOT NULL,
    em_address     varchar2(50),
    em_city        varchar2(20),
    em_phoneNumber varchar2(9)  NOT NULL,
    em_salary      number(8, 2) NOT NULL,
    em_comission   number(7, 2),
    constraint CK_em_phoneNumber_valid CHECK (LENGTH(em_phoneNumber) = 9 AND
                                              em_phoneNumber BETWEEN '000000000' AND '999999999')
);
CREATE TABLE PRODUCT
(
    pr_id           number(8) PRIMARY KEY,
    pr_name         varchar2(40),
    pr_description  varchar2(50),
    pr_price        number(7, 2) NOT NULL,
    pr_currentStock number(3)    NOT NULL,
    pr_minStock     number(2)    NOT NULL,
    pr_distributor  varchar2(9)  NOT NULL
);
CREATE TABLE SALE
(
    sl_number   number(8) PRIMARY KEY,
    sl_client   varchar2(9) NOT NULL,
    sl_employee varchar2(9) NOT NULL,
    sl_date     date,
    sl_discount number(2)
);
CREATE TABLE SALE_DETAILS
(
    sd_id           number(8) PRIMARY KEY,
    sd_saleNumber   number(8) NOT NULL,
    sd_productId    number(8) NOT NULL,
    sd_productCount number(3) DEFAULT 1
);
CREATE TABLE INVOICE
(
    in_id         number(8) PRIMARY KEY,
    in_sale       number(8)    NOT NULL,
    in_totalPrice number(8, 2) NOT NULL,
    in_iva        number(2)    NOT NULL,
    in_discount   number(7, 2) NOT NULL,
    in_finalPrice number(8, 2) NOT NULL
);
create table product_order
(
    o_pr_id           number(8),
    o_date            date,
    o_pr_currentStock number(3),
    o_quantity        number(4),
    constraint PK_order primary key (o_pr_id, o_quantity)
);

ALTER TABLE CLIENT
    ADD FOREIGN KEY (cl_clientCard) REFERENCES CLIENT_CARD (cc_number);
ALTER TABLE CLIENT
    ADD FOREIGN KEY (cl_discountType) REFERENCES DISCOUNT_TYPE (dt_id);
ALTER TABLE PRODUCT
    ADD FOREIGN KEY (pr_distributor) REFERENCES DISTRIBUTOR (ds_cif);
ALTER TABLE SALE
    ADD FOREIGN KEY (sl_client) REFERENCES CLIENT (cl_dni);
ALTER TABLE SALE
    ADD FOREIGN KEY (sl_employee) REFERENCES EMPLOYEE (em_dni);
ALTER TABLE SALE
    ADD FOREIGN KEY (sl_discount) REFERENCES DISCOUNT_TYPE (dt_id);
ALTER TABLE SALE_DETAILS
    ADD FOREIGN KEY (sd_saleNumber) REFERENCES SALE (sl_number);
ALTER TABLE SALE_DETAILS
    ADD FOREIGN KEY (sd_productId) REFERENCES PRODUCT (pr_id);
ALTER TABLE INVOICE
    ADD FOREIGN KEY (in_sale) REFERENCES SALE (sl_number);
ALTER TABLE PRODUCT_ORDER
    ADD FOREIGN KEY (o_pr_id) REFERENCES PRODUCT (pr_id);

COMMIT;