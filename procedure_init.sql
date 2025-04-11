CREATE OR REPLACE PROCEDURE new_empty_sale(p_saleNumber NUMBER, p_saleClient VARCHAR2, p_saleEmployee VARCHAR2) AS
    v_saleDiscount NUMBER;

    e_saleNumberExists exception;
    PRAGMA EXCEPTION_INIT (e_saleNumberExists, -20001);
BEGIN
    IF (p_saleNumber IN (SELECT sl_number FROM SALE)) THEN
        RAISE e_saleNumberExists;
    end if;

    SELECT DT_ID
    INTO v_saleDiscount
    FROM DISCOUNT_TYPE
             JOIN SYSTEM.CLIENT C2 on DISCOUNT_TYPE.DT_ID = C2.CL_DISCOUNTTYPE
    WHERE C2.CL_DNI = p_saleClient;

    INSERT INTO SALE (sl_number, sl_client, sl_employee, sl_date, sl_discount)
    VALUES (p_saleNumber, p_saleClient, p_saleEmployee, SYSDATE, v_saleDiscount);
EXCEPTION
    WHEN e_saleNumberExists THEN
        DBMS_OUTPUT.PUT_LINE('This sale number already exists');
end;

CREATE OR REPLACE PROCEDURE add_sale_product(p_detailsId NUMBER, p_saleNumber NUMBER, p_productId NUMBER,
                                             p_productQuantity NUMBER) AS
    e_saleDetailsIdExists exception;
    PRAGMA EXCEPTION_INIT (e_saleDetailsIdExists, -20001);
BEGIN
    IF (p_detailsId IN (SELECT sd_id FROM SALE_DETAILS)) THEN
        RAISE e_saleDetailsIdExists;
    end if;

    IF (p_productId IN (SELECT SD_PRODUCTID FROM SALE_DETAILS WHERE SD_SALENUMBER = p_saleNumber)) THEN
        UPDATE SALE_DETAILS
        SET SD_PRODUCTCOUNT = SD_PRODUCTCOUNT + p_productQuantity
        WHERE SD_PRODUCTID = p_productId
          AND SD_SALENUMBER = p_saleNumber;
    ELSE
        INSERT INTO SALE_DETAILS (sd_id, sd_salenumber, sd_productid, sd_productcount)
        VALUES (p_detailsId, p_saleNumber, p_productId, p_productQuantity);
    end if;
EXCEPTION
    WHEN e_saleDetailsIdExists THEN
        DBMS_OUTPUT.PUT_LINE('This sale details id already exists');
end;

create or replace procedure update_total_spent(p_cl_dni varchar2, p_total_sale_amount number) is
begin
     update client set CL_TOTALSPENT = CL_TOTALSPENT + p_total_sale_amount where CL_DNI = p_cl_dni;
end;

CREATE OR REPLACE PROCEDURE list_invoice(p_invoiceId NUMBER) AS
    cursor c_products IS  SELECT SD_PRODUCTID, PR_NAME, SD_PRODUCTCOUNT, PR_PRICE
                           FROM INVOICE I
                                    JOIN SALE SL ON I.IN_SALE = SL.SL_NUMBER
                                    JOIN SALE_DETAILS SD ON SL.SL_NUMBER = SD.SD_SALENUMBER
                                    JOIN PRODUCT P ON SD.SD_PRODUCTID = P.PR_ID
                           WHERE IN_ID = p_invoiceId; v_invoice_data VARCHAR2(500);
BEGIN

    SELECT c.cl_name || ' -- ' || e.em_name || ' -- ' || TO_CHAR(s.sl_date, 'YYYY-MM-DD') || ' -- ' ||
           dt.dt_percentage || '% -- ' || IN_FINALPRICE || '€'
    INTO v_invoice_data
    FROM INVOICE i
             JOIN SALE s ON i.in_sale = s.sl_number
             JOIN CLIENT c ON s.sl_client = c.cl_dni
             JOIN EMPLOYEE e ON s.sl_employee = e.em_dni
             JOIN DISCOUNT_TYPE dt ON s.sl_discount = dt.dt_id
    WHERE i.in_id = p_invoiceId;

    DBMS_OUTPUT.PUT_LINE('CLIENT -- VENEDOR -- DATA -- DESCOMPTE APLICAT -- TOTAL A PAGAR');
    DBMS_OUTPUT.PUT_LINE(v_invoice_data); DBMS_OUTPUT.PUT_LINE('ID PRODUCTE -- NOM PRODUCTE -- QUANTITAT -- PREU');
    for product IN c_products
        LOOP
            DBMS_OUTPUT.PUT_LINE(product.SD_PRODUCTID || ' -- ' || product.PR_NAME || ' -- ' ||
                                 product.SD_PRODUCTCOUNT || ' -- ' || product.PR_PRICE);

        end loop;

end;

create or replace procedure create_order(p_pr_id number, p_pr_current_stock number, p_quantity number) is
begin
    insert into PRODUCT_ORDER values (p_pr_id, sysdate, p_pr_current_stock, p_quantity);
end;

CREATE OR REPLACE PROCEDURE validate_sale(p_saleNumber NUMBER, p_invoiceID NUMBER, p_iva NUMBER) AS
    r_saleInfo      SALE%ROWTYPE;
    v_discountValue NUMBER;
    v_totalAmount   NUMBER;
BEGIN
    SELECT * INTO r_saleInfo FROM SALE WHERE SL_NUMBER = p_saleNumber;
    SELECT DT_PERCENTAGE INTO v_discountValue FROM DISCOUNT_TYPE WHERE DT_ID = r_saleInfo.SL_DISCOUNT;
    v_totalAmount := TOTAL_SALE_AMOUNT(p_saleNumber);

    INSERT INTO INVOICE (IN_ID, IN_SALE, IN_TOTALPRICE, IN_IVA, IN_DISCOUNT, IN_FINALPRICE)
    VALUES (p_invoiceID, r_saleInfo.SL_NUMBER, v_totalAmount, p_iva, v_discountValue,
            CALCULATE_FINAL_PRICE(v_totalAmount, p_iva, v_discountValue));
end;

COMMIT;