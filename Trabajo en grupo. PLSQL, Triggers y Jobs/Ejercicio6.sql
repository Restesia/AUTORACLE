/*Añadir al modelo una tabla FIDELIZACION que permite almacenar un descuento por cliente y año. Crear un paquete en PL/SQL de gestion de descuentos.
1. El procedimiento P_Calcular_Descuento, tomaria un cliente y un año y calculara el descuento del que podra disfrutar el año siguiente. 
    Para ello, hasta un maximo del 10%, ira incrementando el descuento en un 1%, por cada una de las siguientes acciones:
        1. Por cada servicio pagado por el cliente
        2. Por cada ocasion en la que el cliente tuvo que esperar mas de 5 dias desde que solicito la cita hasta que se concerto.
        3. Por cada servicio proporcionado en el que tuvo que esperar mas de la media de todos los servicios.
        */
        
--Desde AUTORACLE creamos la tabla fidelizacion
CREATE TABLE fidelizacion (
    descuento NUMBER,
    cliente_idcliente VARCHAR2(16 BYTE),
    fecha_yyyy NUMBER);     --Como solo se pide año no usamos tipo DATE sino NUMBER

--Desde SYSTEM le permitimos a autoracle crear procedures
GRANT CREATE PROCEDURE TO autoracle;

--Desde AUTORACLE creamos el paquete Gestion_descuentos
CREATE OR REPLACE PACKAGE Gestion_descuentos AS
PROCEDURE P_Calcular_Descuento(cliente VARCHAR2, fecha_yyyy NUMBER);
PROCEDURE P_Aplicar_descuento(cliente VARCHAR2, fecha_yyyy NUMBER);
END Gestion_descuentos;
/

ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-YYYY';   --Asegurarse de usar formato YYYYY para los años

CREATE OR REPLACE PROCEDURE P_Calcular_Descuento(cliente VARCHAR2, fecha_actual_yyyy NUMBER) AS
n_servicios NUMBER;
n_mas_cinco_dias NUMBER;
espera_media NUMBER;
n_esperas_mas_de_la_media NUMBER;
n_descuentos_total NUMBER;
fecha_validez_yyyy NUMBER;
BEGIN
    SELECT COUNT(IDFACTURA) INTO n_servicios FROM FACTURA WHERE CLIENTE_IDCLIENTE = cliente AND TO_CHAR(fecemision, 'YYYY') = fecha_actual_yyyy;    -- numero servicios de cliente en el año dado
    SELECT COUNT(IDCITA) INTO n_mas_cinco_dias FROM CITA WHERE (FECHA_CONCERTADA - FECHA_SOLICITUD > 5 AND CLIENTE_IDCLIENTE = cliente AND TO_CHAR(fecha_concertada, 'YYYY') = fecha_actual_yyyy);  -- veces en los que la diferencia desde la solicitud a fecha concertada es mayor a 5 dias para el cliente y fecha dados
    SELECT ROUND(SUM(FECREALIZACION - FECRECEPCION)/COUNT(IDSERVICIO)) INTO espera_media FROM SERVICIO; -- espera media de todos los servicios
    SELECT COUNT(*) INTO n_esperas_mas_de_la_media FROM servicio JOIN VEHICULO ON (vehiculo_numbastidor = numbastidor) 
        JOIN cliente ON (cliente_idcliente = idcliente) 
        WHERE cliente_idcliente = cliente AND (FECREALIZACION - FECRECEPCION) > espera_media AND TO_CHAR(fecapertura, 'YYYY') = fecha_actual_yyyy;   -- numero de veces en los que la diferencia entre la recepcion y realizacion es mayor a la media, para los servicios abiertos para el cliente en la fecha dada
    n_descuentos_total := n_servicios + n_mas_cinco_dias + n_esperas_mas_de_la_media;
        DBMS_OUTPUT.PUT_LINE('n_servicios: ' || n_servicios);
        DBMS_OUTPUT.PUT_LINE('n_mas_cinco_dias: ' || n_mas_cinco_dias);
        DBMS_OUTPUT.PUT_LINE('espera_media: ' || espera_media);
        DBMS_OUTPUT.PUT_LINE('n_esperas_mas_de_la_media: ' || n_esperas_mas_de_la_media);
        DBMS_OUTPUT.PUT_LINE('n_descuentos_total: ' || n_descuentos_total);
    fecha_validez_yyyy := fecha_actual_yyyy + 1;
    IF n_descuentos_total > 10 THEN
    MERGE INTO fidelizacion USING dual ON (cliente_idcliente=cliente AND fecha_yyyy=fecha_validez_yyyy)
        WHEN MATCHED THEN UPDATE SET descuento=10
        WHEN NOT MATCHED THEN INSERT VALUES (10, cliente, fecha_validez_yyyy);
    ELSE
    MERGE INTO fidelizacion USING dual ON (cliente_idcliente=cliente AND fecha_yyyy=fecha_validez_yyyy)
        WHEN MATCHED THEN UPDATE SET descuento=n_descuentos_total
        WHEN NOT MATCHED THEN INSERT VALUES (n_descuentos_total, cliente, fecha_validez_yyyy);
    END IF;
END P_Calcular_Descuento;
/
/*Explicacion procedure:
    El procedimiento recibe el id de un cliente y una fecha, calcula por separado cada una de las 3 condiciones para obtener descuento, despues las suma en un descuento total,
    si es mayor a 10 el descuento aplicado sera exactamente 10, tras esto, si no existe el par (cliente, año), hace un insert de descuento, cliente_idcliente y fecha_yyyy (un año despues del dado),
    si ya existe esa fila en la tabla hace un update solo del precio.
*/



/*2. El procedimiento P_Aplicar_descuento tomarÃ¡ el aÃ±o y el cliente. Si en la tabla FIDELIZACIÃ“N hay un descuento calculado a aplicar ese aÃ±o,
    lo harÃ¡ para todas las facturas que encuentre (en ese aÃ±o).
    */
    
create or replace PROCEDURE P_Aplicar_descuento(cliente VARCHAR2, yyyy NUMBER) AS
var_descuento NUMBER;   -- variable con el descuento a aplicar
ya_descontado NUMBER;   -- variable para guardar el valor descuento de factura
CURSOR c_facturas IS (SELECT idfactura, descuento, total FROM factura WHERE cliente_idcliente = cliente AND fecemision LIKE ('%'||TO_CHAR(yyyy))) FOR UPDATE;   -- cursor recorre facturas de cliente en el año dado
BEGIN
    SELECT descuento INTO var_descuento FROM fidelizacion WHERE cliente_idcliente = cliente AND fecha_yyyy = yyyy;
    FOR v_cursor IN c_facturas LOOP
    SELECT descuento INTO ya_descontado FROM factura WHERE idfactura = v_cursor.idfactura;
    IF ya_descontado = 0 THEN   --Si en factura ya hay descuento mayor que cero se entiende que ya se ha aplicado un descuento por lo que no se aplicará
        UPDATE factura SET
            descuento = var_descuento,
            total = total - total*(var_descuento/100)
        WHERE
            idfactura = v_cursor.idfactura;
    ELSE
        dbms_output.put_line  ('Descuento aplicado anteriormente en factura de id = ' || TO_CHAR(v_cursor.idfactura));
    END IF;
    END LOOP;
    EXCEPTION
        WHEN no_data_found THEN
            dbms_output.put_line  ('Cliente sin descuentos');
END P_Aplicar_descuento;
/
/*Explicacion procedure:
    El procedimiento recibe el id de un cliente y una fecha, en var_descuento guarda el descuento a aplicar y mediante el cursor c_facturas modifica las facturas para el cliente dado en el año dado
    insertando el descuento aplicado y modifica el total de acuerdo a este descuento. Si el cliente no tiene descuento un mensaje lo notificara.
    Si en la tabla factura ya aparece un descuento > 0 entendemos que ya se ha aplicado ese descuento por lo que no volvera a actualizarlo, solo indicara de la situacion.
*/

---------TESTING P_Calcular_descuento---------
--Reinicializacion
DROP TABLE fidelizacion;
CREATE TABLE fidelizacion (
    descuento NUMBER,
    cliente_idcliente VARCHAR2(16 BYTE),
    fecha_yyyy NUMBER);

--Ejemplo cliente 44
SELECT * FROM factura WHERE cliente_idcliente = 44;
SELECT * FROM cita WHERE cliente_idcliente = 44;
SELECT * FROM servicio JOIN VEHICULO ON (vehiculo_numbastidor = numbastidor) JOIN cliente ON (cliente_idcliente = idcliente) WHERE cliente_idcliente = 44;
/*
El cliente 44 solo tiene 1 entrada en facturas por lo que su numero de servicios pagados es 1
El cliente 44 solo tiene una entrada en la tabla CITA con menos de 5 de diferencia entre solicitud y concertada por lo que aqui no gana descuento
La media de espera es redondeando 8 dias, el cliente 44 ha recibido 2 servicios, uno con 0 dias de diferencia entre recepcion y realizacion y otro con 41 dias de diferencia,
    por lo tanto solo recibe descuento por uno de ellos
*/

--Tabla fidelizacion inicialmente vacia
SELECT * FROM fidelizacion;

--Permitimos la visualizacion de mensajes, haran mas facil comprobar el correcto funcionamiento
set serveroutput on;
--Ejecutamos varios P_Calcular_Descuento, con el cliente 44 hemos hecho una visualizacion mas detallada, para el resto podemos bastarnos con el dbms_output del propio procedure
EXEC P_Calcular_Descuento(44, 2019)
EXEC P_Calcular_Descuento(44, 2020)
EXEC P_Calcular_Descuento(545, 2020)
EXEC P_Calcular_Descuento(404, 2020)
--Hay un caso no recogido aqui (el de numero de descuentos mayor a 10) pero viendo el codigo se hace obvio que jamas se actualizara a un valor > 10

--Comprobamos correcto funcionamiento
SELECT * FROM fidelizacion;
--Ejecutando otra vez los procedimientos podemos observar que el merge funciona correctamente.


---------TESTING P_Aplicar_descuento---------
--Insertamos factura en el año 2021 (donde existe descuento para el cliente 44) Inicialmente el total será 100, el descuento a aplicar es 2% por lo que total deberia pasar a 98
INSERT INTO "AUTORACLE"."FACTURA" (IDFACTURA, CLIENTE_IDCLIENTE, IVA, FECEMISION, DESCUENTO, EMPLEADO_IDEMPLEADO) VALUES ('13', '44', '21', TO_DATE('2021-01-04 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), '0', '1');
UPDATE "AUTORACLE"."FACTURA" SET DESCUENTO = '0', IVA_CALCULADO = '20', TOTAL = '100' WHERE IDFACTURA=13;

--Comprobamos datos iniciales
SELECT * FROM factura WHERE cliente_idcliente = 44;
--Ejecutamos procedure
EXEC P_Aplicar_descuento(44, 2021);
--Comprobamos resultado, observamos que ademas se ha actualizado la columna de descuento a 2, el valor correcto
SELECT * FROM factura WHERE cliente_idcliente = 44;

--Doble descuento sobre misma fila, notifica de que ya se habia aplicado un descuento sobre ella
EXEC P_Aplicar_descuento(44, 2021);

--Ejemplo para el año anterior, con descuento = 0
EXEC P_Aplicar_descuento(44, 2020);
SELECT * FROM factura WHERE cliente_idcliente = 44;

--Ejemplo cliente sin descuentos (DBMS_OUTPUT informando del error)
EXEC P_Aplicar_descuento(12, 2020);