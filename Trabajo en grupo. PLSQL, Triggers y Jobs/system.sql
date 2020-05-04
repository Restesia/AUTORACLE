
/*
Ejecutamos todas estas sentencias desde SYSTEM para dar privilegios a nuestro usuario
AUTORACLE:
*/

grant connect to AUTORACLE with admin option;
grant create view, create user, drop user, create job, create role, create trigger, create table, create procedure, create sequence to AUTORACLE;
grant create profile to AUTORACLE with admin option;
grant alter user to AUTORACLE with admin option;

select * from dba_users where username = 'AUTORACLE'; -- PARA VISUALIZAR DATOS