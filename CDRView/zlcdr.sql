--sys用户登录执行
-- Create the user
--创建APEX服务器上的CDR用户，用于存储临床视图的配置信息
create user zlcdr identified by zlsoft
      default tablespace zlcdr_tbs
      temporary tablespace TEMP
      profile DEFAULT
      password expire
      quota unlimited on zlcdr_tbs;
-- Grant/Revoke object privileges
grant execute, debug on APEX_180100.HTMLDB_UTIL to zlcdr;
grant execute on SYS.DBMS_LOB to zlcdr;
grant execute on SYS.UTL_FILE to zlcdr;
grant apex_administrator_role to zlcdr;

grant dba to zlcdr with admin option;
grant apex_administrator_role TO zlcdr;

grant create any index to zlcdr;
grant create any table to zlcdr;
grant create any trigger to zlcdr;
grant create any view to zlcdr;
grant create cluster to zlcdr;
grant create dimension to zlcdr;
grant create indextype to zlcdr;
grant create job to zlcdr;
grant create materialized view to zlcdr;
grant create operator to zlcdr;
grant create procedure to zlcdr;
grant create sequence to zlcdr;
grant create session to zlcdr;
grant create synonym to zlcdr;
grant create table to zlcdr;
grant create trigger to zlcdr;
grant create type to zlcdr;
grant create view to zlcdr;
grant debug any procedure to zlcdr;
grant debug connect session to zlcdr;
grant unlimited tablespace to zlcdr with admin option;

--授权可以访问CDR用户的对象
alter session set current_schema=cdr;
begin
for i in (select 'grant select on cdr.'||table_name||' to zlcdr' as exesql from all_tables where owner='CDR'
) loop
execute immediate i.exesql;
end loop;
end;

begin
for i in (select 'grant select on EMPI.'||table_name||' to zlcdr' as exesql from all_tables where owner='EMPI'
) loop
execute immediate i.exesql;
end loop;
end;
