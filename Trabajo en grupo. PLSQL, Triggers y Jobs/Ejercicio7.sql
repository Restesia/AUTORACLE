SET serveroutput ON;
alter session set "_ORACLE_SCRIPT"=true;
Declare
    cursor c_cursor is select * from empleado;
    N_username number := 0;
    sentencia VARCHAR(100);
Begin
    
    for datos in c_cursor loop
        select count(username) into N_username from all_users where username = upper(datos.NOMBRE)||datos.IDEMPLEADO ;
        
            IF N_username = 0 then
            
                sentencia := 'Create user '||replace(datos.NOMBRE, ' ', '')||datos.IDEMPLEADO||' identified by autouser';
                DBMS_OUTPUT.put_line (sentencia);
                Execute immediate SENTENCIA;
                
             END IF;
        
    end loop;

end;
/ 
Create SEQUENCE emp START WITH 3000
INCREMENT BY 1;

create or replace package AUTORACLE_GESTION_EMPLEADOS as
    

    procedure CREA_EMPLEADO(NOMBRE empleado.nombre%type, APELLIDO1 empleado.apellido1%type, APELLIDO2 empleado.apellido2%type, FECHA_ENTRADA empleado.fecentrada%type, 
                            DESPEDIDO empleado.despedido%type, SUELDOBASE empleado.sueldobase%type, HORAS empleado.horas%type, PUESTO empleado.puesto%type, 
                            RETENCIONES empleado.retenciones%type);

    procedure BORRA_EMPLEADO(ID_EMPLEADO empleado.IDEMPLEADO%type) ;

    procedure MODIFICA_EMPLEADO(ID_EMPLEADO empleado.IDEMPLEADO%type, NOMBRE empleado.nombre%type, APELLIDO1 empleado.apellido1%type, APELLIDO2 empleado.apellido2%type, FECHA_ENTRADA empleado.fecentrada%type, 
                            DESPEDIDO empleado.despedido%type, SUELDOBASE empleado.sueldobase%type, HORAS empleado.horas%type, PUESTO empleado.puesto%type, 
                            RETENCIONES empleado.retenciones%type);

    procedure BLOQUEAR_EMPLEADO(ID_EMPLEADO empleado.IDEMPLEADO%type) ;

    procedure DESBLOQUEAR_EMPLEADO(ID_EMPLEADO empleado.IDEMPLEADO%type) ;

    procedure BLOQUEAR_TODOS;

    procedure DESBLOQUEAR_TODOS;

END AUTORACLE_GESTION_EMPLEADOS;
/


create or replace NONEDITIONABLE PACKAGE BODY AUTORACLE_GESTION_EMPLEADOS AS

    procedure CREA_EMPLEADO(NOMBRE empleado.nombre%type, APELLIDO1 empleado.apellido1%type, APELLIDO2 empleado.apellido2%type, FECHA_ENTRADA empleado.fecentrada%type, 
                            DESPEDIDO empleado.despedido%type, SUELDOBASE empleado.sueldobase%type, HORAS empleado.horas%type, PUESTO empleado.puesto%type, 
                            RETENCIONES empleado.retenciones%type) IS

        ID_EMPLEADO Varchar(16);
        SENTENCIA Varchar(100);
        BEGIN


        -- 1º Comprobar si count(IDMPLEADO) ya está cogido como codigo primario, incrementar uno repetir y almacenar


        insert into empleado (IDEMPLEADO, NOMBRE, APELLIDO1, APELLIDO2, FECENTRADA, DESPEDIDO, SUELDOBASE, HORAS, PUESTO, RETENCIONES)
        values ( TO_CHAR(emp.NEXTVAL) , NOMBRE, APELLIDO1, APELLIDO2, FECHA_ENTRADA, DESPEDIDO, SUELDOBASE, HORAS, PUESTO, RETENCIONES);

        Select IDEMPLEADO into ID_EMPLEADO from empleado where NOMBRE = NOMBRE and apellido1 = apellido1 and FECENTRADA = FECHA_ENTRADA;
        
        SENTENCIA:= 'CREATE user '||NOMBRE||TO_CHAR(ID_EMPLEADO)||' identified by autouser' ;
        
        DBMS_OUTPUT.PUT_LINE(SENTENCIA);
        
        Execute immediate SENTENCIA;

    END;


    PROCEDURE BORRA_EMPLEADO(ID_EMPLEADO empleado.IDEMPLEADO%type) as


        Nom Varchar(64);
        BEGIN

        Select NOMBRE into Nom from empleado where IDEMPLEADO = ID_EMPLEADO;
        delete from empleado where IDEMPLEADO = ID_EMPLEADO;

        -- Bloquear el usuario
        execute immediate 'ALTER USER '||Nom||ID_EMPLEADO||' ACCOUNT LOCK';

    END;


    procedure MODIFICA_EMPLEADO(ID_EMPLEADO empleado.IDEMPLEADO%type, NOMBRE empleado.nombre%type, APELLIDO1 empleado.apellido1%type, APELLIDO2 empleado.apellido2%type, FECHA_ENTRADA empleado.fecentrada%type, 
                            DESPEDIDO empleado.despedido%type, SUELDOBASE empleado.sueldobase%type, HORAS empleado.horas%type, PUESTO empleado.puesto%type, 
                            RETENCIONES empleado.retenciones%type) is
        USR VARCHAR(64);

    BEGIN

        update empleado set NOMBRE = NOMBRE,
        APELLIDO1 = APELLIDO1,
        APELLIDO2 = APELLIDO2,
        FECENTRADA = FECHA_ENTRADA,
        DESPEDIDO = DESPEDIDO,
        SUELDOBASE = SUELDOBASE,
        HORAS = HORAS,
        PUESTO = PUESTO,
        RETENCIONES = RETENCIONES
        where IDEMPLEADO = ID_EMPLEADO ;

        -- Comprobar si el usuario es NULL y crear de ser necesario
        Select USERNAME into USR from all_users where USERNAME = NOMBRE||ID_EMPLEADO;

        IF USR is null then
        Execute immediate 'Create user '||NOMBRE||ID_EMPLEADO||' identified by autouser';
        END IF;



    END;


    procedure BLOQUEAR_EMPLEADO(ID_EMPLEADO empleado.IDEMPLEADO%type) is
            Nom  empleado.nombre%type;
        BEGIN

        Select NOMBRE into Nom from empleado where IDEMPLEADO = ID_EMPLEADO;

        -- Bloquear el usuario
        Execute immediate 'ALTER USER '||Nom||ID_EMPLEADO||' ACCOUNT LOCK';



    END;


    procedure DESBLOQUEAR_EMPLEADO(ID_EMPLEADO empleado.IDEMPLEADO%type) is


                Nom Varchar(64);
        BEGIN

        Select NOMBRE into Nom from empleado where IDEMPLEADO = ID_EMPLEADO;

        -- Bloquear el usuario
        Execute immediate 'ALTER USER '||Nom||ID_EMPLEADO||' ACCOUNT UNLOCK';


    END;


    procedure BLOQUEAR_TODOS is



            Cursor c_cursor is select * from empleado;
        BEGIN
            FOR datos in c_cursor LOOP
                         Execute immediate 'ALTER USER '||datos.NOMBRE||datos.IDEMPLEADO||' ACCOUNT LOCK';
            END LOOP;


    END;


    procedure DESBLOQUEAR_TODOS is


            Cursor c_cursor is select * from empleado;
        BEGIN
            FOR datos in c_cursor LOOP
                        Execute immediate 'ALTER USER '||datos.NOMBRE||datos.IDEMPLEADO||' ACCOUNT UNLOCK';
            END LOOP;


    END;


END AUTORACLE_GESTION_EMPLEADOS;

/

/*
    Con el objetivo de probar el funcionamiento del paquete vamos a lanzar varias veces el primero de los procedures que 
    implemtea el paquete para comprobar que efectivamente crea de la forma deseada los usuarios.
*/
SET SERVEROUTPUT ON;

alter session set "_Oracle_SCRIPT"=true;  


Create user julian12 identified by autouse;

drop user julian12 cascade;

EXECUTE autoracle_gestion_empleados.crea_empleado('Pepe', 'Pepito', 'Grillito', SYSDATE - 30000, 0, 1200, 12, 'mecanico', 0);
EXECUTE autoracle_gestion_empleados.crea_empleado('Pepa', 'Pepito', 'Grillito', SYSDATE - 30000, 0, 1200, 12, 'mecanico', 0);
EXECUTE autoracle_gestion_empleados.crea_empleado('Pepo', 'Pepito', 'Grillito', SYSDATE - 30000, 0, 1200, 12, 'mecanico', 0);
EXECUTE autoracle_gestion_empleados.crea_empleado('Pepi', 'Pepito', 'Grillito', SYSDATE - 30000, 0, 1200, 12, 'mecanico', 0);
EXECUTE autoracle_gestion_empleados.crea_empleado('Pepu', 'Pepito', 'Grillito', SYSDATE - 30000, 0, 1200, 12, 'mecanico', 0);


--Al ejecutar estas dos sentencias podemos ver en las respectivas tablas como los usuarios y los hempleados se crean y se insertan adecuadamente
select * from all_users where username like 'PEP%';
select * from empleado where nombre like 'Pep%' ; 
