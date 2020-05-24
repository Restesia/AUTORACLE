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
        SELECT (SUM((s.FECREALIZACION - s.FECRECEPCION)) / COUNT(*)), SUM(HORAS)/COUNT(horas)
        INTO resultado
        FROM servicio s
        FULL JOIN reparacion r ON s.IDSERVICIO = r.IDSERVICIO
        -- Evitamos las fechas que estan vacias
        WHERE FECREALIZACION IS NOT NULL AND FECRECEPCION IS NOT NULL;
        -- Mostramos los valores
        DBMS_OUTPUT.PUT_LINE('DIAS '||resultado.dias);
        DBMS_OUTPUT.PUT_LINE('HORAS '||resultado.horas);
        RETURN resultado;
END F_CALCULAR_TIEMPOS;

---- 3. El procedimiento P_Recompensa encuentra el servicio proporcionado
---- más rápido y más lento(en días) y a los empleados involucrados los 
---- recompensa con un +/-5% en su sueldo base respectivamente...
PROCEDURE P_RECOMPENSA AS

    -- Valores para guardar los id de los empleados
    idIncrementa NUMBER;
    idDecrementa NUMBER;
         
BEGIN
        -- Buscamos el mas rapido
        SELECT t.EMPLEADO_IDEMPLEADO as id_empleado
        into idIncrementa
        FROM AUTORACLE.SERVICIO s
        JOIN AUTORACLE.TRABAJA t ON s.IDSERVICIO = t.SERVICIO_IDSERVICIO
        WHERE FECREALIZACION IS NOT NULL AND FECRECEPCION IS NOT NULL
        ORDER By ((s.FECREALIZACION - s.FECRECEPCION)) ASC,
         s.FECREALIZACION DESC, s.FECRECEPCION DESC, s.FECAPERTURA DESC
        fetch first 1 rows only;
        -- Buscamos el mas lento
        SELECT t.EMPLEADO_IDEMPLEADO as id_empleado
        into idDecrementa
        FROM AUTORACLE.SERVICIO s
        JOIN AUTORACLE.TRABAJA t ON s.IDSERVICIO = t.SERVICIO_IDSERVICIO
        WHERE FECREALIZACION IS NOT NULL AND FECRECEPCION IS NOT NULL
        ORDER By ((s.FECREALIZACION - s.FECRECEPCION)) DESC,
        s.FECREALIZACION DESC, s.FECRECEPCION DESC, s.FECAPERTURA DESC
        fetch first 1 rows only;
        
        
        DBMS_OUTPUT.PUT_LINE('Incrementar ' || idIncrementa);
        DBMS_OUTPUT.PUT_LINE('Decrementar ' || idDecrementa);

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
/

-- PRUEBAS 

--- 1.
DECLARE
  COD VARCHAR2(200);
  ANYO VARCHAR2(200);
  v_Return AUTORACLE.AUTORACLE_ANALISIS.T_MEDIA_MIN_MAX;
BEGIN
  COD := '1234';
  ANYO := '2020';

  v_Return := AUTORACLE_ANALISIS.F_CALCULAR_PIEZAS(
    COD => COD,
    ANYO => ANYO
  );
  
  -- Insertamos un nuevo pedido 
  
  insert into compra values (15,TO_DATE('08/05/2020', 'DD/MM/YYYY'),'c56984',TO_DATE('10/05/2020', 'DD/MM/YYYY'));
  insert into lote values (25,'1234',15,21);
  
  -- Vemos como cambia el valor

  v_Return := AUTORACLE_ANALISIS.F_CALCULAR_PIEZAS(
    COD => COD,
    ANYO => ANYO
  );
  
  
END;
/


--- 2.
DECLARE
  v_Return AUTORACLE.AUTORACLE_ANALISIS.T_TIEMPOS;
BEGIN

  v_Return := AUTORACLE_ANALISIS.F_CALCULAR_TIEMPOS();
  
  -- Insertamos un nuevo servicio de reparacion
  
  insert into servicio values(2,'Reparar',TO_DATE('08/05/2020', 'DD/MM/YYYY'),TO_DATE('08/05/2020', 'DD/MM/YYYY'),TO_DATE('10/05/2020', 'DD/MM/YYYY'),'Correcta','234321',NULL);
  insert into reparacion values(2,'Junta de la trocola',30);
  
  -- Vemos como afecta a los tiempos
  
  v_Return := AUTORACLE_ANALISIS.F_CALCULAR_TIEMPOS();
    
END;
/

--- 3.

SELECT IDEMPLEADO,SUELDOBASE FROM EMPLEADO;

/
BEGIN
  
  
  AUTORACLE_ANALISIS.P_RECOMPENSA();
  
  -- Insertamos una nueva reaparación para penalizar

  
  insert into servicio values (10,'Reparar',TO_DATE('08/05/2020', 'DD/MM/YYYY'),TO_DATE('08/05/2020', 'DD/MM/YYYY'),TO_DATE('26/08/2020', 'DD/MM/YYYY'),'Correcta',234321,NULL);
  insert into trabaja values (15,10);
  
  -- Vemos como cambia el empleado penalizado
  
  AUTORACLE_ANALISIS.P_RECOMPENSA();
  
  -- Insertamos una nueva reparación para premiar
  
  insert into servicio values (50,'Reparar',TO_DATE('08/05/2020', 'DD/MM/YYYY'),TO_DATE('08/05/2020', 'DD/MM/YYYY'),TO_DATE('08/05/2020', 'DD/MM/YYYY'),'Correcta',234321,NULL);
  insert into trabaja values (2,50);
  
  -- Vemos como cambia el empleado premiado

  AUTORACLE_ANALISIS.P_RECOMPENSA();
  
END;
/

SELECT IDEMPLEADO,SUELDOBASE FROM EMPLEADO;
