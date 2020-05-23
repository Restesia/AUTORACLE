-- 5. Crear un paquete en PL/SQL de análisis de datos.

SET SERVEROUTPUT ON

-- Creamos el paquete desde autoracle:
CREATE OR REPLACE PACKAGE AUTORACLE_ANALISIS IS
    -- Definimos el tipo de datos que retiene la media, minimo y maximo de la consulta
    TYPE T_MEDIA_MIN_MAX IS RECORD(MEDIA NUMBER, MINIMO NUMBER, MAXIMO NUMBER);
    -- Definimos el tipo de datos que retiene el numero de dias y horas
    TYPE T_TIEMPOS IS RECORD (DIAS NUMBER, HORAS NUMBER);
    
    -- Definimos las funciones y el procedimiento
    FUNCTION  F_CALCULAR_PIEZAS(COD IN VARCHAR2, ANYO in VARCHAR2) RETURN T_MEDIA_MIN_MAX;
    FUNCTION  F_CALCULAR_TIEMPOS RETURN T_TIEMPOS;
    PROCEDURE P_RECOMPENSA;
END;
/

CREATE OR REPLACE PACKAGE BODY AUTORACLE_ANALISIS AS

---- 1. La función F_Calcular_Piezas devolverá la media, mínimo y máximo número 
---- de  unidades  compradas(en cada lote) de una determinada pieza en un año
---- concreto. 

FUNCTION F_CALCULAR_PIEZAS (COD IN VARCHAR2, ANYO IN VARCHAR2) RETURN T_MEDIA_MIN_MAX AS
    resultado T_MEDIA_MIN_MAX;
BEGIN
    -- Realizamos la consulta
    SELECT AVG(LOTE."NÚMERO_DE_PIEZAS"),MIN(LOTE."NÚMERO_DE_PIEZAS"),MAX(LOTE."NÚMERO_DE_PIEZAS") 
    INTO resultado 
    FROM COMPRA 
    INNER JOIN LOTE
    ON COMPRA.IDCOMPRA = LOTE.COMPRA_IDCOMPRA
    WHERE EXTRACT(YEAR FROM FECEMISION) = ANYO AND PIEZA_CODREF = COD;
    -- Mostramos los valores
    DBMS_OUTPUT.PUT_LINE('MIN '||resultado.minimo);
    DBMS_OUTPUT.PUT_LINE('MAX '||resultado.maximo);
    DBMS_OUTPUT.PUT_LINE('MEAN '||resultado.media);
    RETURN resultado;
END F_CALCULAR_PIEZAS;

---- 2. La función F_Calcular_Tiempos devolverá la media de días en las que se 
---- termina un servicio (Fecha de realización – Fecha de entrada en taller)
---- así como la media de las horas de mano de obra de los servicios 
---- de Reparación

FUNCTION F_CALCULAR_TIEMPOS RETURN T_TIEMPOS AS
    resultado T_TIEMPOS;
BEGIN
        -- Realizamos la consulta
        SELECT (SUM((s.FECREALIZACION - s.FECRECEPCION)) / COUNT(*)), SUM(HORAS)/COUNT(*)
        INTO resultado
        FROM servicio s
        INNER JOIN reparacion r ON s.IDSERVICIO = r.IDSERVICIO
        -- Evitamos las fechas que estan vacias
        WHERE FECREALIZACION IS NOT NULL AND FECRECEPCION IS NOT NULL;
        -- Mostramos los valores
        DBMS_OUTPUT.PUT_LINE('DIAS '||resultado.dias);
        DBMS_OUTPUT.PUT_LINE('HORAS '||resultado.horas);
        RETURN resultado;
END F_CALCULAR_TIEMPOS;

-- TODO: ULTIMO APARTADO
---- 3. El procedimiento P_Recompensa encuentra el servicio proporcionado
---- más rápido y más lento(en días) y a los empleados involucrados los 
---- recompensa con un +/-5% en su sueldo base respectivamente...
PROCEDURE P_RECOMPENSA AS

    -- Valores para guardar los id de los empleados
    idIncrementa NUMBER;
    idDecrementa NUMBER;
    
    -- Inicializamos las variables para comparar
    mas_rapido NUMBER := POWER(2,418)-1;
    mas_lento NUMBER := 0;
    
    -- Cursor sobre el que iterar con los servicios, empleados y fechas
     CURSOR cur IS
     SELECT s.IDSERVICIO as id_servicio,
       t.EMPLEADO_IDEMPLEADO as id_empleado,
       ((s.FECREALIZACION - s.FECRECEPCION)) as dias
    FROM AUTORACLE.SERVICIO s
        JOIN AUTORACLE.TRABAJA t ON s.IDSERVICIO = t.SERVICIO_IDSERVICIO
        WHERE FECREALIZACION IS NOT NULL AND FECRECEPCION IS NOT NULL;
 
BEGIN
        for r in cur loop
        -- Buscamos el mas rapido
            IF r.dias < mas_rapido THEN
                idIncrementa := r.id_empleado;
                mas_rapido := r.dias;
            END IF;
        -- Buscamos el mas lento
            IF r.dias > mas_lento THEN
                idDecrementa := r.id_empleado;
                mas_lento := r.dias;
            END IF;
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('Incrementar ' || idIncrementa || ' por servicio de  ' || mas_rapido);
        DBMS_OUTPUT.PUT_LINE('Decrementar ' || idDecrementa || ' por servicio de  ' || mas_lento);

        -- Aplicamos la penalizacion sobre el lento
        UPDATE AUTORACLE.EMPLEADO
            SET SUELDOBASE = SUELDOBASE - (0.05 * SUELDOBASE)
            WHERE IDEMPLEADO = idDecrementa;
        
        -- Aplicamos la recompensa sobre el rapido
        UPDATE AUTORACLE.EMPLEADO
            SET SUELDOBASE = SUELDOBASE + (0.05 * SUELDOBASE)
            WHERE IDEMPLEADO = idIncrementa;
            
        COMMIT;            
        
END P_RECOMPENSA;

END;