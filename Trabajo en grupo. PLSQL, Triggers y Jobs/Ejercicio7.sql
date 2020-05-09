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

        Condicion_salida NUMBER(2);
        Total_Empleados NUMBER(6);
        ID_EMPLEADO Varchar(16);
        BEGIN

        Select Count(IDEMPLEADO) into Total_empleados from empleado;
        Condicion_salida := 1;

        -- 1º Comprobar si count(IDMPLEADO) ya está cogido como codigo primario, incrementar uno repetir y almacenar

        WHILE ID_EMPLEADO != NULL LOOP

            Total_empleados := Total_Empleados +1;
            Select IDEMPLEADO into ID_EMPLEADO from empleado where IDEMPLEADO = TO_CHAR(Total_Empleados);

        END LOOP;

        insert into empleado (IDEMPLEADO, NOMBRE, APELLIDO1, APELLIDO2, FECENTRADA, DESPEDIDO, SUELDOBASE, HORAS, PUESTO, RETENCIONES)
        values ( TO_CHAR(Total_Empleados) , NOMBRE, APELLIDO1, APELLIDO2, FECHA_ENTRADA, DESPEDIDO, SUELDOBASE, HORAS, PUESTO, RETENCIONES);

        CREATE user NOMBRE||TO_CHAR(Total_Empleados) identified by autouse;

        


    END;


    PROCEDURE BORRA_EMPLEADO(ID_EMPLEADO empleado.IDEMPLEADO%type) as
    

        Nom Varchar(64);
        BEGIN
        
        Select NOMBRE into Nom from empleado where IDEMPLEADO = ID_EMPLEADO;
        delete from empleado where IDEMPLEADO = ID_EMPLEADO;

        -- Bloquear el usuario
        ALTER USER Nom||ID_EMPLEADO ACCOUNT LOCK;

    END;


    procedure MODIFICA_EMPLEADO(ID_EMPLEADO empleado.IDEMPLEADO%type, NOMBRE empleado.nombre%type, APELLIDO1 Iempleado.apellido1%type, APELLIDO2 empleado.apellido2%type, FECHA_ENTRADA empleado.fecentrada%type, 
                            DESPEDIDO empleado.despedido%type, SUELDOBASE empleado.sueldobase%type, HORAS empleado.horas%type, PUESTO empleado.puesto%type, 
                            RETENCIONES empleado.retenciones%type) is
    

        USER VARCHAR(64);
    
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
        Select USERNAME into USER from all_users where USERNAME = NOMBRE||ID_EMPLEADO;

        IF USER = null 
        Create user NOMBRE||ID_EMPLEADO identified by autouser
        temporary tablespace TS_AUTORACLE
        default tablespace TS_AUTORACLE;
        END IF;



    END;

    
    procedure BLOQUEAR_EMPLEADO(ID_EMPLEADO empleado.IDEMPLEADO%type) is
    
    BEGIN

            Nom Varchar(64);
        BEGIN

        Select NOMBRE into Nom from empleado where IDEMPLEADO = ID_EMPLEADO;

        -- Bloquear el usuario
        ALTER USER Nom||ID_EMPLEADO ACCOUNT LOCK;



    END;


    procedure DESBLOQUEAR_EMPLEADO(ID_EMPLEADO empleado.IDEMPLEADO%type) is
    

                Nom Varchar(64);
        BEGIN

        Select NOMBRE into Nom from empleado where IDEMPLEADO = ID_EMPLEADO;

        -- Bloquear el usuario
        ALTER USER Nom||ID_EMPLEADO ACCOUNT UNLOCK;



    END;


    procedure BLOQUEAR_TODOS is
    
    BEGIN

            Cursor c_cursor is select * from empleados;
        BEGIN
            FOR datos in c_cursor LOOP
                ALTER USER datos.NOMBRE||datos.IDEMPLEADO ACCOUNT LOCK;
            END LOOP;


    END;


    procedure DESBLOQUEAR_TODOS is
    

            Cursor c_cursor is select * from empleados;
        BEGIN
            FOR datos in c_cursor LOOP
                ALTER USER datos.NOMBRE||datos.IDEMPLEADO ACCOUNT UNLOCK;
            END LOOP;


    END;


END AUTORACLE_GESTION_EMPLEADOS;
/
