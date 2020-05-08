create or replace package AUTORACLE_GESTION_EMPLEADOS as
    procedure CREA_EMPLEADO(NOMBRE IN VARCHAR(64), APELLIDO1 IN VARCHAR(64), APELLIDO2 IN VARCHAR(64), FECHA_ENTRADA IN DATE, 
                            DESPEDIDO IN NUMBER(2), SUELDOBASE IN NUMBER(8,2), HORAS IN NUMBER(34,0), PUESTO IN VARCHAR(64), 
                            RETENCIONES IN NUMBER(38,0));

    procedure BORRA_EMPLEADO(ID_EMPLEADO IN VARCHAR(16)) ;

    procedure MODIFICA_EMPLEADO(ID_EMPLEADO IN VARCHAR(16), NOMBRE IN VARCHAR(64), APELLIDO1 IN VARCHAR(64), APELLIDO2 IN VARCHAR(64), FECHA_ENTRADA IN DATE,
                            DESPEDIDO IN NUMBER(2), SUELDOBASE IN NUMBER(8,2), HORAS IN NUMBER(34,0), PUESTO IN VARCHAR(64), 
                            RETENCIONES IN NUMBER(38,0));

    procedure BLOQUEAR_EMPLEADO(ID_EMPLEADO IN VARCHAR(16)) ;

    procedure DESBLOQUEAR_EMPLEADO(ID_EMPLEADO IN VARCHAR(16)) ;

    procedure BLOQUEAR_TODOS;

    procedure DESBLOQUEAR_TODOS;

End AUTORACLE_GESTION_EMPLEADOS ;

create or replace package body AUTORACLE_GESTION_EMPLEADOS as


    procedure CREA_EMPLEADO(NOMBRE IN VARCHAR(64), APELLIDO1 IN VARCHAR(64), APELLIDO2 IN VARCHAR(64), FECHA_ENTRADA IN DATE, 
                                DESPEDIDO IN NUMBER(2), SUELDOBASE IN NUMBER(8,2), HORAS IN NUMBER(34,0), PUESTO IN VARCHAR(64), 
                                RETENCIONES IN NUMBER(38,0)) as
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

        Create user NOMBRE||TO_CHAR(Total_Empleados) identified by autouser
        temporary tablespace TS_AUTORACLE
        default tablespace TS_AUTORACLE;

        COMMIT;

    end CREA_EMPLEADO;


    procedure BORRA_EMPLEADO(ID_EMPLEADO IN VARCHAR(16)) as

        Nom Varchar(64);
        BEGIN

        Select NOMBRE into Nom from empleado where IDEMPLEADO = ID_EMPLEADO;
        delete from empleado where IDEMPLEADO = ID_EMPLEADO;

        -- Bloquear el usuario
        ALTER USER Nom||ID_EMPLEADO ACCOUNT LOCK;
        COMMIT;

    end BORRAR_EMPLEADO;


    procedure MODIFICA_EMPLEADO(ID_EMPLEADO IN VARCHAR(16), NOMBRE IN VARCHAR(64), APELLIDO1 IN VARCHAR(64), APELLIDO2 IN VARCHAR(64), FECHA_ENTRADA IN DATE,
                            DESPEDIDO IN NUMBER, SUELDOBASE IN NUMBER(8,2), HORAS IN NUMBER(34,0), PUESTO IN VARCHAR(64), 
                            RETENCIONES IN NUMBER(38,0)) as

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

        COMMIT;

    end MODIFICAR_EMPLEADO;

    
    procedure BLOQUEAR_EMPLEADO(ID_EMPLEADO IN VARCHAR(16)) as

            Nom Varchar(64);
        BEGIN

        Select NOMBRE into Nom from empleado where IDEMPLEADO = ID_EMPLEADO;

        -- Bloquear el usuario
        ALTER USER Nom||ID_EMPLEADO ACCOUNT LOCK;

        COMMIT;

    end BLOQUEAR_EMPLEADO ;


    procedure DESBLOQUEAR_EMPLEADO(ID_EMPLEADO IN VARCHAR(16)) as

                Nom Varchar(64);
        BEGIN

        Select NOMBRE into Nom from empleado where IDEMPLEADO = ID_EMPLEADO;

        -- Bloquear el usuario
        ALTER USER Nom||ID_EMPLEADO ACCOUNT UNLOCK;

        COMMIT;

    end DESBLOQUEAR_EMPLEADO;


    procedure BLOQUEAR_TODOS as

            Cursor c_cursor is select * from empleados;
        BEGIN
            FOR datos in c_cursor LOOP
                ALTER USER datos.NOMBRE||datos.IDEMPLEADO ACCOUNT LOCK;
            END LOOP;
        COMMIT;

    end BLOQUEAR_TODOS;


    procedure DESBLOQUEAR_TODOS as

            Cursor c_cursor is select * from empleados;
        BEGIN
            FOR datos in c_cursor LOOP
                ALTER USER datos.NOMBRE||datos.IDEMPLEADO ACCOUNT UNLOCK;
            END LOOP;
        COMMIT;

    end DESBLOQUEAR_TODOS;


end AUTORACLE_GESTION_EMPLEADOS;
/
