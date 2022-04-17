
create or replace package body RBMS as

--Query2
--procedure to show all the tuples from employees tablea

procedure show_employees
        (emp_cursor out sys_refcursor) is
begin
        open emp_cursor for select * from employees order by eid;
end;

procedure show_customers
        (cust_cursor out sys_refcursor) is
begin
        open cust_cursor for select * from customers order by cid;
end;

procedure show_purchases
        (pur_cursor out sys_refcursor) is
begin
        open pur_cursor for select * from purchases order by pur#;
end;

procedure show_products
        (prod_cursor out sys_refcursor) is
begin
        open prod_cursor for select * from products order by pid;
end;

procedure show_logs
        (log_cursor out sys_refcursor) is
begin
        open log_cursor for select * from logs order by log#;
end;

-- Query3
--Name of the customer and his every purchase
procedure purchases_made
        (v_cid in customers.cid%type, pur_cursor out sys_refcursor) is

        invalid_cid exception;
        purchase_not_made_cid exception;
        custcount number(10);
        custpurcount number(10);
begin
        custcount := 0;
        custpurcount := 0;

        select count(*) into custcount from customers where cid = v_cid;
        select count(*) into custpurcount from purchases where cid = v_cid;

-- check if customer exists & has made any purchase
        if(custcount = 0) then
                raise invalid_cid;
        elsif(custpurcount = 0) then
                raise purchase_not_made_cid;
        end if;

-- Cursor assignment
        open pur_cursor for select customers.name, purchases.pid, purchases.pur_date, purchases.qty, purchases.unit_price, purchases.total
        from purchases, customers
        where customers.cid = v_cid and customers.cid = purchases.cid;


        exception
                when invalid_cid then
                        raise_application_error(-20101, 'Customer is not present in database..!!');
                when purchase_not_made_cid then
                        raise_application_error(-20102, 'Customer has not made any  purchase..!!');
end;

--Query 4
--Number of customers who have bought a particular pid
function number_customers
        (prod_id in purchases.pid%type)
        return number is cid_count number;
        invalid_prod_id exception;
        prodcount number(10);
begin
        prodcount := 0;
        select count(*) into prodcount from products where pid = prod_id;

-- Check pid entered is valid
        if(prodcount = 0) then
                raise invalid_prod_id;
        end if;

-- Count distinct cid who bought that pid
        select count(distinct(purchases.cid)) into cid_count
        from purchases
        where purchases.pid = prod_id;

        return cid_count;

         exception
                when invalid_prod_id then
                        raise_application_error(-20103, 'Product is not present in database..!!');

end;

-- Query 5
--adding new customer to Customer Table
procedure add_customer
        (c_id in customers.cid%type,
        c_name in customers.name%type,
        c_telephone in customers.telephone#%type) is
        invalid_cid exception;
        invalid_telephone exception;
--local variables
        custcount number(10);
        telephonecount number(10);
begin
        custcount := 0;
        telephonecount := 0;

        select count(*) into custcount from customers where cid = c_id;
        select count(*) into telephonecount from customers where telephone# = c_telephone;

--Check if CID & Telephone is unique
        if(custcount > 0) then
                raise invalid_cid;
        elsif(telephonecount > 0) then
                raise invalid_telephone;
        end if;

--Insert statement in Customer table
            insert into customers values (c_id, c_name, c_telephone, 1, TRUNC(sysdate));

            exception
                when invalid_cid then
                        raise_application_error(-20104, 'Customer with same CID present in database..!!');
                when invalid_telephone then
                        raise_application_error(-20105, 'Customer with same telephone number present in database..!!');
end;


-- Query 6
--Add a new purchase in Purchases Table with conditions
procedure add_purchase
	(v_eid in purchases.eid%type,
	 v_pid in purchases.pid%type,
	 v_cid in purchases.cid%type,
	 v_qty in purchases.qty%type,
	 v_unitp in purchases.unit_price%type,
	 is_qoh_reset out number,
	 new_qoh out number) is

-- initialising local variables
	v_total purchases.total%type;
	v_saving purchases.saving%type;
	v_regularp products.regular_price%type;
	v_qoh products.qoh%type;
	--new_qoh products.qoh%type;
	v_qohthres products.qoh_threshold%type;
	empcount number;
	prodcount number;
	custcnt number;
	existingcount number;

-- initialising exceptions
	insufficient_qty exception;
	invalid_eid exception;
	invalid_pid exception;
	invalid_cid exception;
	invalid_record exception;

begin
-- Checking if entered eid, pid, cid exist in the table.
        select count(eid) into empcount from employees where eid = v_eid;
    	select count(pid) into prodcount from products where pid = v_pid;
    	select count(cid) into custcnt from customers where cid = v_cid;
    	select count(*) into existingcount from purchases where eid = v_eid and pid = v_pid and cid = v_cid and pur_date = TRUNC(sysdate);

    	if (empcount = 0) then
        	    raise invalid_eid;
        	elsif (prodcount = 0) then
        	    raise invalid_pid;
        	elsif (custcnt = 0) then
        	    raise invalid_cid;
        	elsif (existingcount > 0) then
                raise invalid_record;
        end if;

    is_qoh_reset := 0;
    new_qoh := 0;

-- Selecting Regular Price & QOH to calculate other parameters
	select regular_price,qoh into v_regularp, v_qoh from products
	where pid = v_pid;
	v_total := v_qty * v_unitp;
	v_saving := v_qty*(v_regularp - v_unitp);
	-- dbms_output.put_line('total:' || v_total ||'Saving ' || v_saving ||' Qoh '||v_qoh);

--Purchase request is accepted only when quantity is less than QOH.
	if (v_qty > v_qoh) then
	    raise insufficient_qty;
	    -- dbms_output.put_line('Insufficient Quantity on hand qoh is '||v_qoh);
	end if;
	    insert into purchases values (seqpur#.nextval, v_eid, v_pid, v_cid, TRUNC(sysdate), v_qty, v_unitp, v_total, v_saving);

--Check if QOH got updated by the trigger
	    select qoh into new_qoh from products
	    where pid = v_pid;

		if(new_qoh <> v_qoh - v_qty) then
		    is_qoh_reset := 1;
		end if;

exception
    when insufficient_qty then
	    raise_application_error(-20101, 'Insufficient quantity in stock');
    when invalid_eid then
        raise_application_error(-20102, 'Entered Employee ID is not present in database');
    when invalid_pid then
        raise_application_error(-20103, 'Entered Product ID is not present in database');
    when invalid_cid then
         raise_application_error(-20104, 'Entered Customer ID is not present in database');
    when invalid_record then
         raise_application_error(-20105, 'You can not purchase same product on same day from same employee');
end;

end;
/
show errors