drop table purchases;
drop table employees;
drop table customers;
drop table products;
drop table logs;

create table employees
(eid char(3) primary key,
name varchar2(15) not null,
telephone# char(12),
email varchar2(20) unique);

create table customers
(cid char(4) primary key,
name varchar2(15),
telephone# char(12),
visits_made number(4) check (visits_made >= 1),
last_visit_date date);

create table products
(pid char(4) primary key,
name varchar2(15),
qoh number(4),
qoh_threshold number(4),
regular_price number(6,2),
discnt_rate number(3,2) check (discnt_rate in (0.0, 0.05, 0.1, 0.15, 0.2, 0.25)));

create table purchases
(pur# number(6) primary key,
eid char(3) references employees(eid),
pid char(4) references products(pid),
cid char(4) references customers(cid),
pur_date date,
qty number(5),
unit_price number(6,2),
total number(7,2),
saving number(6,2),
unique(eid, pid, cid, pur_date));

create table logs
(log# number(4) primary key,
user_name varchar2(12) not null,
operation varchar2(6) not null,
op_time date not null,
table_name varchar2(20) not null,
tuple_pkey varchar2(6));
