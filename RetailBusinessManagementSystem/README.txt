RetailBusinessManagementSystem

This sytems provides console to handle operations for Retail business management systems

It includes functionality like :
1. Adding new customer
2. Displaying all employees, customers, products, purchases
3. Adding a new purchases
4. Displays number of customers who purchases given products
5. Handles all validations for customer id, employee id, product id, and purchases date.

Design Doc :
Design Document STUDENT REGISTRATION SYSTEM CS532 – Database Systems
Submitted by:
Tejal Rasal
Aditya Dhikle
Nikhil Kulkarni

Design Document Explanation of all Oracle Objects used:
All procedures are declared in package name ‘RBMS'.

1. show_employees
- Objective: To display the tuples in employees table
- Usage: RBMS.show_employees
- Approach: Open a cursor to select all the tuples from employees table. Fetch a row using the cursor until a row is found and print row when it is found.

2. show_products
- Objective: To display the tuples in products table
- Usage: RBMS.show_products
- Approach: Open a cursor to select all the tuples from products table. Fetch a row using the cursor until a row is found and print row when it is found.

3. show_customers
- Objective: To display the tuples in customers table
- Usage: RBMS.show_customers
- Approach: Open a cursor to select all the tuples from customers table. Fetch a row using the cursor until a row is found and print row when it is found.

4. show_purchases
- Objective: To display the tuples in purchases table
- Usage: RBMS.show_purchases
- Approach: Open a cursor to select all the tuples from customers table. Fetch a row using the cursor until a row is found and print row when it is found.

5. show_logs
- Objective: To display the tuples in logs table
- Usage: RBMS.show_logs
- Approach: Open a cursor to select all the tuples from logs table. Fetch a row using the cursor until a row is found and print row when it is found.

6. purchase_made
- Objective: To display the purchase made tuples for given customer
- Usage: RBMS.purchase_made
- Approach: Open a cursor to select all the tuples from customers and purchases where cid of purchases and customer table matches with entered cid. Fetch a row using the cursor until a row is found and print row when it is found.

7. number_customers
- Objective: Give a number of customers who have purchases a specific product
- Approach: Once pid is entered, this function gives count of customers who have purchases that product from purchases table.

8. add_customers
- Objective: To insert new customer in the customers table
- Usage: RBMS.add_customers
- Approach:
First check for the input parameter and check for : 1. if entered customer is present in DB 2. check the unique constraint on the telephone by comparing the entered number with the customers table.
If both te above conditions staifies then insert the record else raise the exception of invalid cid if not valid or invalid phone if already present in DB.

9. add_purchase



10. Triggers

Trigger 'qoh_products'

- Objective: To update and check qoh in products table and insert a tuple into log table when a new purchase is being made
- Approach: Select qoh and qoh threshold from products, check the incoming product quantity and set updated qoh. If updated qoh is less than threshold it will give a message and set qoh to threshold + 10.
  When a new purchase is made, its pur#, log id, username, time, operation and table name values are added to logs

Trigger 'update_customer_visits'
- Objective: Update customer visits and last visit date when a purchase happens
- Approach: When a new purchase is made, visits are upped by one and last visit date is updated with system date


Trigger 'new_customer'
- Objective: insert a tuple into log table when a new customer is added
- Approach: When a new customer is added, new cid, log id, username, time, operation and table name values are added to logs

Trigger 'update_last_visit_date'
- Objective: insert a tuple into log table when last_visit_date is updated
- Approach: When last_visit_date is updated, its cid, log id, username, time, operation and table name values are added to logs

Trigger 'update_visits_made_customer'
- Objective: insert a tuple into log table when visits made is updated
- Approach: When visits made is updated, its cid, log id, username, time, operation and table name values are added to logs


Trigger 'update_qoh_products'
- Objective: insert a tuple into log table when qoh is updated
- Approach: When a qoh is updated, its pid, log id, username, time, operation and table name values are added to logs