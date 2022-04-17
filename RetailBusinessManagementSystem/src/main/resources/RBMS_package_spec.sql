create or replace package RBMS as

--Query2
--procedure to show all the tuples from employees table
procedure show_employees
        (emp_cursor out sys_refcursor);


--procedure to show all the tuples from customers table
procedure show_customers
        (cust_cursor out sys_refcursor);


--procedure to show all the tuples from purchases table
procedure show_purchases
        (pur_cursor out sys_refcursor);


--procedure to show all the tuples from products table
procedure show_products
        (prod_cursor out sys_refcursor);


--procedure to show all the tuples from logs table
procedure show_logs
        (log_cursor out sys_refcursor);

-- Query3
--Name of the customer and his every purchase
procedure purchases_made
        (v_cid in customers.cid%type, pur_cursor out sys_refcursor);

-- Query4
--Number of customers who have bought a particular pid
function number_customers
        (prod_id in purchases.pid%type)
        return number;

-- Query 5
--adding new customer to Customer Table
procedure add_customer
        (c_id in customers.cid%type,
        c_name in customers.name%type,
        c_telephone in customers.telephone#%type);

-- Query 6
--Add a new purchase in Purchases Table with conditions
procedure add_purchase
    (v_eid in purchases.eid%type,
    v_pid in purchases.pid%type,
    v_cid in purchases.cid%type,
    v_qty in purchases.qty%type,
    v_unitp in purchases.unit_price%type,
    is_qoh_reset out number,
    new_qoh out number);


end;
/