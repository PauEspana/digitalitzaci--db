create or replace trigger tr_validate_client_DNI
    before insert or update of cl_dni
    on client
    for each row
declare
    e_invalid_dni exception;
    pragma exception_init (e_invalid_dni, -20002 );
begin
    if (NOT validate_DNI(:NEW.CL_DNI)) then
        raise e_invalid_dni;
    end if;
exception
    when e_invalid_dni then
        dbms_output.put_line('Invalid DNI, NIF or CIF format.');
        RAISE;
end;


create or replace trigger tr_validate_employee_DNI
    before insert or update of em_dni
    on EMPLOYEE
    for each row
declare
    e_invalid_dni exception;
    pragma exception_init ( e_invalid_dni, -20002 );
begin
    if (NOT validate_DNI(:NEW.em_DNI)) then
        raise e_invalid_dni;
    end if;
exception
    when e_invalid_dni then
        dbms_output.put_line('Invalid DNI, NIF or CIF format.');
        RAISE;
end;


create or replace trigger tr_validate_distributor_CIF
    before insert or update of ds_cif
    on DISTRIBUTOR
    for each row
declare
    e_invalid_dni exception;
    pragma exception_init ( e_invalid_dni, -20002 );
begin
    if (NOT VALIDATE_CIF(:NEW.DS_CIF)) then
        raise e_invalid_dni;
    end if;
exception
    when e_invalid_dni then
        dbms_output.put_line('Invalid DNI, NIF or CIF format.');
        RAISE;
end;

create or replace trigger tr_update_total_spent
    after insert
    on INVOICE
    for each row
declare
    v_sl_client varchar2(9);
begin
    select SL_CLIENT
    into v_sl_client
    from SALE
    where SL_NUMBER = :new.in_sale;
    update_total_spent(v_sl_client, :new.IN_FINALPRICE);
end;

CREATE OR REPLACE TRIGGER tr_ban_sales_outside_work_hours
    BEFORE INSERT
    ON SALE
DECLARE
    v_currentHour NUMBER := EXTRACT(HOUR FROM SYSTIMESTAMP); e_invalidHourException exception; pragma exception_init (e_invalidHourException, -20004);
begin
    if (v_currentHour NOT BETWEEN 8 AND 15) THEN raise e_invalidHourException; end if;
end;

create or replace trigger tr_reduce_stock_after_sale
    after insert
    on sale_details
    for each row

begin
    update product
    set PR_CURRENTSTOCK = PR_CURRENTSTOCK - :new.sd_productCount
    where PR_ID = :new.SD_PRODUCTID;
end;

CREATE OR REPLACE TRIGGER tr_ban_product_without_stock
    BEFORE INSERT
    ON SALE_DETAILS
    FOR EACH ROW
DECLARE
    v_productStock NUMBER; e_no_stock EXCEPTION; PRAGMA EXCEPTION_INIT (e_no_stock, -20003);
BEGIN
    SELECT PR_CURRENTSTOCK INTO v_productStock FROM PRODUCT WHERE PR_ID = :NEW.SD_PRODUCTID;
    IF (v_productStock < 0) THEN RAISE e_no_stock; end if;
EXCEPTION
    WHEN e_no_stock THEN DBMS_OUTPUT.PUT_LINE('There is no stock for product with id: ' || :NEW.SD_PRODUCTID);
    RAISE;
end;

create or replace trigger tr_create_order
    after insert
    on sale_details
    for each row
declare
    v_pr_currentStock number;
    v_pr_minStock     number;
begin
    select PR_CURRENTSTOCK, PR_MINSTOCK
    into v_pr_currentStock, v_pr_minStock
    from PRODUCT
    where pr_id = :NEW.sd_productid;


    if v_pr_minStock > v_pr_currentStock then
        create_order(:new.SD_PRODUCTID, v_pr_currentStock, (v_pr_minStock + 30));
    end if;
end;

CREATE OR REPLACE TRIGGER tr_add_points_on_invoice
    AFTER INSERT
    ON INVOICE
    FOR EACH ROW
DECLARE
BEGIN

    UPDATE CLIENT_CARD
    SET CC_POINTS = CC_POINTS + (10 / 100 * :NEW.IN_FINALPRICE)
    WHERE CC_NUMBER = (SELECT CL_CLIENTCARD
                       FROM CLIENT
                       WHERE CL_DNI = (SELECT SL_CLIENT FROM SALE WHERE SL_NUMBER = :NEW.IN_SALE));

end;

create or replace trigger TR_EMPLOYEE_DISCOUNT
    before insert or update
    on CLIENT
    for each row
DECLARE
    v_is_employee NUMBER := 0;
BEGIN
    IF (:NEW.CL_DISCOUNTTYPE = 1) THEN
        SELECT COUNT(*) INTO v_is_employee FROM EMPLOYEE WHERE EM_DNI = :NEW.CL_DNI;
        IF (v_is_employee = 0) THEN RAISE_APPLICATION_ERROR(-20003, 'This client is not an employee'); END IF;
    end if;
END;

SELECT *
FROM CLIENT;

create or replace trigger tr_avoid_setting_higher_salary
    before
        UPDATE
    on EMPLOYEE
    for each row

declare
    cursor cEmployee is
        select SL_EMPLOYEE
        from SALE
        WHERE SL_DATE <= SYSDATE - 7
        GROUP BY SL_EMPLOYEE
        having COUNT(SL_EMPLOYEE) = (SELECT MIN(COUNT(SL_EMPLOYEE))
                                     FROM SALE
                                     GROUP BY SL_EMPLOYEE);
begin
    for e IN cEmployee
        LOOP
            if (e.SL_EMPLOYEE = :NEW.EM_DNI and
                (:new.em_salary > :old.em_salary or :new.em_comission > :old.em_comission)) THEN
                RAISE_APPLICATION_ERROR(-20004,
                                        'This employee''s comission and salary can not be increased due to insufficient sales during the last week.');
            end if;
        end loop;
end;

create or replace trigger tr_set_christmas_discount
    before insert
    on SALE
    for each row

begin
    if extract(day from :new.SL_DATE) = 23 and extract(month from :new.sl_date) = 12 then
        update SALE
        set SL_DISCOUNT = 2
        where sl_number = :new.sl_number;
    end if;
end;

COMMIT;