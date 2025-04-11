create or replace function validate_DNI(p_dni VARCHAR2) return boolean is
begin
    if REGEXP_LIKE(p_dni, '^[0-9]{8}[A-Z]$') then
        return true;
    else
        return false;
    end if;
end;

create or replace function validate_cif(p_dni VARCHAR2) return boolean is
begin
    if REGEXP_LIKE(p_dni, '^[A-Z][0-9]{8}$') then
        return true;
    else
        return false;
    end if;
end;

create or replace function total_sale_amount(p_saleNumber Varchar2) return number is
    v_total_amount number := 0;
    cursor c_SlDetails is
        select SD_PRODUCTCOUNT, PR_PRICE
        from SALE_DETAILS
                 join product on pr_id = SD_PRODUCTID
                 join sale on sd_salenumber = SL_NUMBER
        where SL_NUMBER = p_saleNumber;
begin
    for i in c_SlDetails
        loop
            v_total_amount := v_total_amount + (i.SD_PRODUCTCOUNT * i.PR_PRICE);
        end loop;
    DBMS_OUTPUT.PUT_LINE('TEST: ' || v_total_amount);
    return v_total_amount;
end;

CREATE OR REPLACE FUNCTION total_sale_amount_from_employee(p_employeeDNI varchar2) RETURN NUMBER AS
    cursor c_SalesFromEmployee IS SELECT PR_PRICE price, SD_PRODUCTCOUNT count
                                  FROM SALE SL
                                           JOIN EMPLOYEE E ON SL.SL_EMPLOYEE = E.EM_DNI
                                           JOIN SALE_DETAILS SD ON SL.SL_NUMBER = SD.SD_SALENUMBER
                                           JOIN SYSTEM.PRODUCT P on P.PR_ID = SD.SD_PRODUCTID
                                  WHERE SL_EMPLOYEE = p_employeeDNI; v_totalAmount NUMBER := 0; v_employeeExists NUMBER := 0;
    e_employeeNotExists exception;
    PRAGMA EXCEPTION_INIT (e_employeeNotExists, -20001);
BEGIN
    SELECT COUNT(EM_DNI) INTO v_employeeExists FROM EMPLOYEE WHERE EM_DNI = p_employeeDNI;
    if (v_employeeExists <= 0) THEN raise e_employeeNotExists; end if;
    for product in c_SalesFromEmployee
        LOOP
            v_totalAmount := v_totalAmount + (product.price * product.count);
        end loop;
    return v_totalAmount;
EXCEPTION
    WHEN e_employeeNotExists THEN DBMS_OUTPUT.PUT_LINE('Employee does not exist'); return 0;
end;
create or replace function most_sold_product(initialDate Date, finalDate Date) return varchar2 is
    v_most_sold_product       varchar2(40);
    v_most_sold_product_count number;
    e_invalid_date exception;
    pragma exception_init ( e_invalid_date,-20003);
begin
    if initialDate > finalDate then
        raise e_invalid_date;
    end if;
    select PR_NAME, sum(SD_PRODUCTCOUNT)
    into v_most_sold_product, v_most_sold_product_count
    from product
             join SALE_DETAILS on product.PR_ID = SALE_DETAILS.SD_PRODUCTID
    group by PR_NAME
    having sum(SD_PRODUCTCOUNT) = (select max(sum(SD_PRODUCTCOUNT)) count
                                   from SALE_DETAILS
                                            join sale on SALE_DETAILS.SD_SALENUMBER = sale.SL_NUMBER
                                   where SL_DATE between initialDate and finalDate
                                   GROUP BY SD_PRODUCTID);

    return v_most_sold_product;
exception
    when e_invalid_date then
        dbms_output.put_line('Final date must be greater than initial date.');
        return 0;
end;

create or replace function CALCULATE_FINAL_PRICE(v_totalPrice number, v_iva number, v_discountPercentage number) return number is
    v_finalPrice NUMBER;
begin
    v_finalPrice := (v_totalPrice + (v_totalPrice * (v_iva / 100))) * (1 - (v_discountPercentage / 100));

    return v_finalPrice;
end;

COMMIT;