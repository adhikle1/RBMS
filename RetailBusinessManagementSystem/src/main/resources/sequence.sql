-- sequence for log id in logs table
drop sequence log_id;
create sequence log_id start with 1001 maxvalue 9999;

-- sequence for purchase id  in purchases table
drop sequence seqpur#;
create sequence seqpur# start with 100001 maxvalue 999999;