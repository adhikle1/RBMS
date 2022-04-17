drop trigger new_customer;

-- trigger adds entry in log table when a new customer is added into the database

create or replace trigger new_customer

after insert on customers
for each row

declare
        myuser logs.user_name%type;
        myoperation logs.operation%type;
        my_logtime logs.op_time%type;
        --tablename logs.table_name%type;
        mytuple_pkey logs.tuple_pkey%type;


begin
        myoperation := 'Insert';
        mytuple_pkey := :new.cid;
--      tablename := 'customers';

        select user into myuser from dual;
        select sysdate into my_logtime from dual;

        insert into logs values (log_id.nextval, myuser, myoperation, my_logtime,'customers', mytuple_pkey );

end;
/


drop trigger update_visits_made_customer;

-- trigger adds entry in log table when a customers visits_made is updated

create or replace trigger update_visits_made_customer

after update of visits_made on customers
for each row

declare
        myuser logs.user_name%type;
        myoperation logs.operation%type;
        my_logtime logs.op_time%type;
        --tablename logs.table_name%type;
        mytuple_pkey logs.tuple_pkey%type;


begin
        myoperation := 'Update';
        mytuple_pkey := :new.cid;
--      tablename := 'customers';

        select user into myuser from dual;
        select sysdate into my_logtime from dual;

        insert into logs values (log_id.nextval, myuser, myoperation, my_logtime,'customers', mytuple_pkey );

end;
/

 drop trigger update_last_visit_date;
-- trigger adds entry in log table when last visit date of customer is updated
create or replace trigger update_last_visit_date
        after update of last_visit_date on customers
        for each row
        when (new.last_visit_date > old.last_visit_date)
        declare
            myuser logs.user_name%type;
            myoperation logs.operation%type;
            my_logtime logs.op_time%type;
            mytuple_pkey logs.tuple_pkey%type;
        begin
            myoperation := 'Update';
            mytuple_pkey := :new.cid;
            select user into myuser from dual;
            select sysdate into my_logtime from dual;

            insert into logs values (log_id.nextval, myuser, myoperation, my_logtime,'customers', mytuple_pkey );
end;
/

drop trigger update_qoh_products;
-- Trigger insert a log entry when qoh of product is updated
create or replace trigger update_qoh_products

after update of qoh on products
for each row

declare
        myuser logs.user_name%type;
        myoperation logs.operation%type;
        my_logtime logs.op_time%type;
        mytuple_pkey logs.tuple_pkey%type;


begin
        myoperation := 'Update';
        mytuple_pkey := :new.pid;

        select user into myuser from dual;
        select sysdate into my_logtime from dual;

        insert into logs values (log_id.nextval, myuser, myoperation, my_logtime,'products', mytuple_pkey );

end;
/


drop trigger qoh_products;

-- trigger for decreasing the value qoh after a purchase done
-- and it will update the qoh when the user entered qty is greater than qoh
-- inserts log entry into the table after insert purchases is successful

create or replace trigger qoh_products

after insert on purchases
for each row

declare
        mynew_purqty purchases.qty%type;
        mypid products.pid%type;
        oldqoh products.qoh%type;
        updated_qoh products.qoh%type;
        threshold products.qoh_threshold%type;

        -- For log table
        myuser logs.user_name%type;
        myoperation logs.operation%type;
        my_logtime logs.op_time%type;
        mytuple_pkey logs.tuple_pkey%type;

begin

        mynew_purqty := :new.qty;
        mypid := :new.pid;

        select qoh into oldqoh from products p where p.pid = mypid ;
        select qoh_threshold into threshold from products p where p.pid = mypid ;

        updated_qoh := oldqoh - mynew_purqty;
        -- This condition checks if the qoh of the product to be below qoh_threshold
        if(updated_qoh < threshold) then
            dbms_output.put_line('The current qoh of the product is below the required threshold and new supply is required.');
            updated_qoh := threshold +10;
            update products set qoh =  updated_qoh where pid = mypid;
            dbms_output.put_line('The current qoh of the product is updated to'||updated_qoh);
        elsif(updated_qoh >= 0) then
            -- Updates the value of qoh of products
                update products set qoh =  updated_qoh where pid = mypid;
        end if;

        -- Inserts the purchase entry in log table
        myoperation := 'Insert';
        mytuple_pkey := :new.pur#;

        select user into myuser from dual;
        select sysdate into my_logtime from dual;

        insert into logs values (log_id.nextval, myuser, myoperation, my_logtime,'purchases', mytuple_pkey );

end;

/

drop trigger update_customer_visits;
-- (Query 2 for purchase )
create or replace trigger update_customer_visits
after insert on purchases
for each row
declare
my_logtime logs.op_time%type;

begin

	update customers
	set visits_made = visits_made + 1 where cid = :new.cid;
	update customers
	set last_visit_date = sysdate where cid = :new.cid and TRUNC(last_visit_date) <> TRUNC(sysdate);
end;
/

show errors