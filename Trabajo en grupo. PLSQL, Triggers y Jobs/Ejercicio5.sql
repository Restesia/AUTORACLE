-- 5. Crear un paquete en PL/SQL de an�lisis de datos.

SET SERVEROUTPUT ON

-- Creamos el paquete desde autoracle:
CREATE OR REPLACE PACKAGE AUTORACLE_ANALISIS IS
    --�Tipos como object o record?
    TYPE T_MEDIA_MIN_MAX IS RECORD(MEDIA NUMBER, MINIMO NUMBER, MAXIMO NUMBER);
    TYPE T_TIEMPOS IS RECORD (DIAS NUMBER, HORAS NUMBER);
    
    FUNCTION  F_CALCULAR_PIEZAS(COD IN VARCHAR2, ANYO in VARCHAR2) RETURN T_MEDIA_MIN_MAX;
    FUNCTION  F_CALCULAR_TIEMPOS RETURN T_TIEMPOS;
    PROCEDURE P_RECOMPENSA;
END;
/

CREATE OR REPLACE PACKAGE BODY AUTORACLE_ANALISIS AS

---- 1. La funci�n F_Calcular_Piezas devolver� la media, m�nimo y m�ximo n�mero 
---- de  unidades  compradas(en cada lote) de una determinada pieza en un a�o
---- concreto. 

FUNCTION F_CALCULAR_PIEZAS (COD IN VARCHAR2, ANYO IN VARCHAR2) RETURN T_MEDIA_MIN_MAX AS
    resultado T_MEDIA_MIN_MAX;
BEGIN
    SELECT AVG(LOTE."N�MERO_DE_PIEZAS"),MIN(LOTE."N�MERO_DE_PIEZAS"),MAX(LOTE."N�MERO_DE_PIEZAS") 
    INTO resultado 
    FROM COMPRA 
    INNER JOIN LOTE
    ON COMPRA.IDCOMPRA = LOTE.COMPRA_IDCOMPRA
    WHERE EXTRACT(YEAR FROM FECEMISION) = ANYO AND PIEZA_CODREF = COD;
    DBMS_OUTPUT.PUT_LINE('MIN'||resultado.minimo);
    RETURN resultado;
END F_CALCULAR_PIEZAS;

---- 2. La funci�n F_Calcular_Tiempos devolver� la media de d�as en las que se 
---- termina un servicio (Fecha de realizaci�n � Fecha de entrada en taller)
---- as� como la media de las horas de mano de obra de los servicios 
---- de Reparaci�n

FUNCTION F_CALCULAR_TIEMPOS RETURN T_TIEMPOS AS
    resultado T_TIEMPOS;
BEGIN
        SELECT (SUM((s.FECREALIZACION - s.FECRECEPCION)) / COUNT(*)), SUM(HORAS)/COUNT(*)
        INTO resultado
        FROM servicio s
        INNER JOIN reparacion r ON s.IDSERVICIO = r.IDSERVICIO
        WHERE FECREALIZACION IS NOT NULL AND FECRECEPCION IS NOT NULL;
        RETURN resultado;
END F_CALCULAR_TIEMPOS;

-- TODO: ULTIMO APARTADO
---- 3. El procedimiento P_Recompensaencuentra el servicio proporcionado
---- m�s r�pido y m�s lento(en d�as) y a los empleados involucrados los 
---- recompensa con un +/-5% en su sueldo base respectivamente...
PROCEDURE P_RECOMPENSA AS
 idIncrementa NUMBER;
 idDecrementa NUMBER;
BEGIN
        DBMS_OUTPUT.PUT_LINE(''); 
END P_RECOMPENSA;

END;
/