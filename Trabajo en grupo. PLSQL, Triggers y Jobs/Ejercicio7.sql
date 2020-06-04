SET serveroutput ON;

Declare
    cursor c_cursor is select * from empleado;
    N_username number := 0;
    sentencia VARCHAR(100);
Begin
    
    for datos in c_cursor loop
        select count(username) into N_username from all_users where username = upper(replace(datos.NOMBRE, ' ', ''))||datos.IDEMPLEADO ;
        
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
                            RETENCIONES empleado.retenciones%type, PASS empleado.nombre%type);

    procedure BORRA_EMPLEADO(ID_EMPLEADO empleado.IDEMPLEADO%type) ;

    procedure MODIFICA_EMPLEADO(ID_EMPLEAD empleado.IDEMPLEADO%type, NOMBR empleado.nombre%type, APELLID1 empleado.apellido1%type, APELLID2 empleado.apellido2%type, FECHA_ENTRAD empleado.fecentrada%type, 
                            DESPEDID empleado.despedido%type, SUELDOBAS empleado.sueldobase%type, HORA empleado.horas%type, PUEST empleado.puesto%type, 
                            RETENCIONE empleado.retenciones%type, PASS empleado.nombre%type);

    procedure BLOQUEAR_EMPLEADO(ID_EMPLEADO empleado.IDEMPLEADO%type) ;

    procedure DESBLOQUEAR_EMPLEADO(ID_EMPLEADO empleado.IDEMPLEADO%type) ;

    procedure BLOQUEAR_TODOS;

    procedure DESBLOQUEAR_TODOS;

END AUTORACLE_GESTION_EMPLEADOS;
/


create or replace PACKAGE BODY AUTORACLE_GESTION_EMPLEADOS AS

    procedure CREA_EMPLEADO(NOMBRE empleado.nombre%type, APELLIDO1 empleado.apellido1%type, APELLIDO2 empleado.apellido2%type, FECHA_ENTRADA empleado.fecentrada%type, 
                            DESPEDIDO empleado.despedido%type, SUELDOBASE empleado.sueldobase%type, HORAS empleado.horas%type, PUESTO empleado.puesto%type, 
                            RETENCIONES empleado.retenciones%type, PASS empleado.nombre%type) IS

        ID_EMPLEADO Varchar(16);
        SENTENCIA Varchar(100);
        BEGIN
        
        ID_EMPLEADO := TO_CHAR(emp.NEXTVAL);
        -- 1º Comprobar si count(IDMPLEADO) ya está cogido como codigo primario, incrementar uno repetir y almacenar


        insert into empleado (IDEMPLEADO, NOMBRE, APELLIDO1, APELLIDO2, FECENTRADA, DESPEDIDO, SUELDOBASE, HORAS, PUESTO, RETENCIONES)
        values (  ID_EMPLEADO, NOMBRE, APELLIDO1, APELLIDO2, FECHA_ENTRADA, DESPEDIDO, SUELDOBASE, HORAS, PUESTO, RETENCIONES);

        

        SENTENCIA:= 'CREATE user '||replace(NOMBRE, ' ', '')||ID_EMPLEADO||' identified by '||PASS ;
        DBMS_OUTPUT.PUT_LINE(SENTENCIA);
        Execute immediate SENTENCIA;

    END;


    PROCEDURE BORRA_EMPLEADO(ID_EMPLEADO empleado.IDEMPLEADO%type) as


        Nom Varchar(64);
        BEGIN

        Select NOMBRE into Nom from empleado where IDEMPLEADO = ID_EMPLEADO;
        delete from empleado where IDEMPLEADO = ID_EMPLEADO;

        -- Bloquear el usuario
        execute immediate 'ALTER USER '||replace(Nom, ' ', '')||ID_EMPLEADO||' ACCOUNT LOCK';

    END;


    procedure MODIFICA_EMPLEADO(ID_EMPLEAD empleado.IDEMPLEADO%type, NOMBR empleado.nombre%type, APELLID1 empleado.apellido1%type, APELLID2 empleado.apellido2%type, FECHA_ENTRAD empleado.fecentrada%type, 
                            DESPEDID empleado.despedido%type, SUELDOBAS empleado.sueldobase%type, HORA empleado.horas%type, PUEST empleado.puesto%type, 
                            RETENCIONE empleado.retenciones%type, PASS empleado.nombre%type) is
        USR number := 0;
        SENTENCIA Varchar(100);
    BEGIN

        update empleado set NOMBRE = NOMBR,
        APELLIDO1 = APELLID1,
        APELLIDO2 = APELLID2,
        FECENTRADA = FECHA_ENTRAD,
        DESPEDIDO = DESPEDID,
        SUELDOBASE = SUELDOBAS,
        HORAS = HORA,
        PUESTO = PUEST,
        RETENCIONES = RETENCIONE
        where IDEMPLEADO = ID_EMPLEAD ;

        -- Comprobar si el usuario es NULL y crear de ser necesario
        Select count(USERNAME) into USR from all_users where USERNAME = UPPER(NOMBR)||ID_EMPLEAD;

        IF USR = 0 then
        
            SENTENCIA:= 'CREATE user '||replace(NOMBR, ' ', '')||ID_EMPLEAD||' identified by '||PASS ;
            DBMS_OUTPUT.PUT_LINE(SENTENCIA);
            Execute immediate SENTENCIA;
        
        END IF;

        IF PASS IS NOT NULL then
        
            SENTENCIA:= 'ALTER user '||replace(NOMBR, ' ', '')||ID_EMPLEAD||' identified by '||PASS ;
            DBMS_OUTPUT.PUT_LINE(SENTENCIA);
            Execute immediate SENTENCIA;
        
        END IF;


    END;


    procedure BLOQUEAR_EMPLEADO(ID_EMPLEADO empleado.IDEMPLEADO%type) is
            SENTENCIA Varchar(100);
            Nom  empleado.nombre%type;
        BEGIN

        Select NOMBRE into Nom from empleado where IDEMPLEADO = ID_EMPLEADO;

        -- Bloquear el usuario
        Sentencia := 'ALTER USER '||UPPER(replace(Nom, ' ', ''))||ID_EMPLEADO||' ACCOUNT LOCK';
        DBMS_OUTPUT.PUT_LINE(SENTENCIA);
        Execute immediate SENTENCIA;



    END;


    procedure DESBLOQUEAR_EMPLEADO(ID_EMPLEADO empleado.IDEMPLEADO%type) is

                SENTENCIA Varchar(100);
                Nom Varchar(64);
        BEGIN

        Select NOMBRE into Nom from empleado where IDEMPLEADO = ID_EMPLEADO;

        -- DesBloquear el usuario
        Sentencia := 'ALTER USER '||UPPER(replace(Nom, ' ', ''))||ID_EMPLEADO||' ACCOUNT UNLOCK';
        DBMS_OUTPUT.PUT_LINE(SENTENCIA);
        Execute immediate SENTENCIA;

    END;


    procedure BLOQUEAR_TODOS is

            SENTENCIA Varchar(100);
            Cursor c_cursor is select NOMBRE, IDEMPLEADO from empleado;
        BEGIN
            FOR datos in c_cursor LOOP
                SENTENCIA := 'ALTER USER '||UPPER(replace(datos.NOMBRE, ' ', ''))||datos.IDEMPLEADO||' ACCOUNT LOCK';
                DBMS_OUTPUT.PUT_LINE(SENTENCIA);
                Execute immediate SENTENCIA; 
            END LOOP;


    END;


    procedure DESBLOQUEAR_TODOS is

            SENTENCIA Varchar(100);
            Cursor c_cursor is select * from empleado;
        BEGIN
            FOR datos in c_cursor LOOP
                SENTENCIA := 'ALTER USER '||UPPER(replace(datos.NOMBRE, ' ', ''))||datos.IDEMPLEADO||' ACCOUNT UNLOCK';
                DBMS_OUTPUT.PUT_LINE(SENTENCIA);
                Execute immediate SENTENCIA; 
            END LOOP;


    END;



END AUTORACLE_GESTION_EMPLEADOS;
/


/*
    Con el objetivo de probar el funcionamiento del paquete vamos a lanzar varias veces el primero de los procedures que 
    implemtea el paquete para comprobar que efectivamente crea de la forma deseada los usuarios.

    Debido a que el procedimiento basa su funcionamiento en una sequence y el siguiente script trata de predecir su comportamiento 
    ejecutarse las primeras cinco veces si las sentencias son ejecutadas una segunda vez estas no funcionaran
*/

EXECUTE autoracle_gestion_empleados.crea_empleado('Pepe', 'Pepito', 'Grillito', SYSDATE - 30000, 0, 1200, 12, 'mecanico', 0, 'caracol');
EXECUTE autoracle_gestion_empleados.crea_empleado('Pepa', 'Pepito', 'Grillito', SYSDATE - 30000, 0, 1200, 12, 'mecanico', 0, 'caracol');
EXECUTE autoracle_gestion_empleados.crea_empleado('Pepo', 'Pepito', 'Grillito', SYSDATE - 30000, 0, 1200, 12, 'mecanico', 0, 'caracol');
EXECUTE autoracle_gestion_empleados.crea_empleado('Pepi', 'Pepito', 'Grillito', SYSDATE - 30000, 0, 1200, 12, 'mecanico', 0, 'caracol');
EXECUTE autoracle_gestion_empleados.crea_empleado('Pepu', 'Pepito', 'Grillito', SYSDATE - 30000, 0, 1200, 12, 'mecanico', 0, 'caracol');


--Al ejecutar estas dos sentencias podemos ver en las respectivas tablas como los usuarios y los hempleados se crean y se insertan adecuadamente
select * from all_users where username like 'PEP%';
select * from empleado where nombre like 'Pep%' ; 

/*
    El siguiente fragmento de codigo se implementa con el objetivo de probar el buen funcionamiento del procedure 
    MODIFICA_EMPLEADO que implementa el package que acabamos de crear. Lo que haremos sera modificar los empleados que acabamos 
    de crear para testear el procedimiento anterior.
*/



EXECUTE autoracle_gestion_empleados.MODIFICA_EMPLEADO('3000', 'Pepe', 'Pepito', 'Grillito', SYSDATE - 30000, 0, 1200, 12, 'Marinero', 0, NULL);
EXECUTE autoracle_gestion_empleados.MODIFICA_EMPLEADO('3001', 'Pepa', 'Pepito', 'Grillito', SYSDATE - 30000, 0, 1200, 12, 'Piloto', 0,  NULL);
EXECUTE autoracle_gestion_empleados.MODIFICA_EMPLEADO('3002', 'Pepo', 'Pepito', 'Grillito', SYSDATE - 30000, 0, 1200, 12, 'Comandante', 0, NULL);
EXECUTE autoracle_gestion_empleados.MODIFICA_EMPLEADO('3003', 'Pepi', 'Pepito', 'Grillito', SYSDATE - 30000, 0, 1200, 12, 'Pescadero', 0,  NULL);
EXECUTE autoracle_gestion_empleados.MODIFICA_EMPLEADO('3004', 'Pepu', 'Pepito', 'Grillito', SYSDATE - 30000, 0, 1200, 12, 'Presidente del gobierno', 0,  NULL);


--Al ejecutar esta sentencia podemos ver Como el campo Puesto de los empleados fue modificado, antes todos eran mecanicos, ahora su profesión ha cambiado
select * from empleado where nombre like 'Pep%' ; 

/*
    A continuación bloquearemos y desbloquearemos la cuenta de Pepe Pepito Grillito, empleado añadido anteriormente. Con eso
    demostraremos el buen funcionamiento de dicho procedimiento. 
*/


select * from empleado where nombre like 'Pep%' ; 



/*
    A continuación bloquearemos y desbloquearemos la cuenta de Pepe Pepito Grillito, empleado añadido anteriormente. Con eso
    demostraremos el buen funcionamiento de dicho procedimiento. 
*/



EXECUTE autoracle_gestion_empleados.BLOQUEAR_EMPLEADO('3001') ;
    

-- Esta sentencia debe ejecutarse desde System
select Username, account_status from dba_users where username = 'PEPA3001' ;


EXECUTE autoracle_gestion_empleados.DESBLOQUEAR_EMPLEADO('3001');


-- Como podemos ver en ambas consultas el usuario se ha bloqueado y desbloqueado correctamente.
-- Por lo que ambos metodos funcionan bien.
select Username, account_status from dba_users where username = 'PEPA3001' ;


/*
    Ahora mostraremos los dos procedimientos que se encargan de bloquear y desbloquear a todos 
    Los empleados de la base de datos.
*/

EXECUTE autoracle_gestion_empleados.BLOQUEAR_TODOS;

-- Esta sentencia debe ser ejecutada desde System 
select Username, account_status from dba_users;

EXECUTE autoracle_gestion_empleados.DESBLOQUEAR_TODOS;

-- Esta sentencia debe ser ejecutada desde System  
select Username, account_status from dba_users;

EXECUTE autoracle_gestion_empleados.BORRA_EMPLEADO('3000');
EXECUTE autoracle_gestion_empleados.BORRA_EMPLEADO('3001');
EXECUTE autoracle_gestion_empleados.BORRA_EMPLEADO('3002');
EXECUTE autoracle_gestion_empleados.BORRA_EMPLEADO('3003');
EXECUTE autoracle_gestion_empleados.BORRA_EMPLEADO('3004');

select * from all_users where username like 'PEP%';
select * from empleado where nombre like 'Pep%' ; 
