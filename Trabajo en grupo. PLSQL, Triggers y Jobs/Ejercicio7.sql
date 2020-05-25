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


CREATE OR REPLACE PACKAGE BODY AUTORACLE_GESTION_EMPLEADOS AS

    procedure CREA_EMPLEADO(NOMBRE empleado.nombre%type, APELLIDO1 empleado.apellido1%type, APELLIDO2 empleado.apellido2%type, FECHA_ENTRADA empleado.fecentrada%type, 
                            DESPEDIDO empleado.despedido%type, SUELDOBASE empleado.sueldobase%type, HORAS empleado.horas%type, PUESTO empleado.puesto%type, 
                            RETENCIONES empleado.retenciones%type) IS

        ID_EMPLEADO Varchar(16);
        BEGIN


        -- 1º Comprobar si count(IDMPLEADO) ya está cogido como codigo primario, incrementar uno repetir y almacenar


        insert into empleado (IDEMPLEADO, NOMBRE, APELLIDO1, APELLIDO2, FECENTRADA, DESPEDIDO, SUELDOBASE, HORAS, PUESTO, RETENCIONES)
        values ( TO_CHAR(emp.NEXTVAL) , NOMBRE, APELLIDO1, APELLIDO2, FECHA_ENTRADA, DESPEDIDO, SUELDOBASE, HORAS, PUESTO, RETENCIONES);

        Select IDEMPLEADO into ID_EMPLEADO from empleado where NOMBRE = NOMBRE and apellido1 = apellido1 and FECENTRADA = FECHA_ENTRADA;

        Execute immediate 'CREATE user '||NOMBRE||TO_CHAR(ID_EMPLEADO)||' identified by autouse';

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
