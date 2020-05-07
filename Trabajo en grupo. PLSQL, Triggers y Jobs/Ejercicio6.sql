/*Añadir al modelo una tabla FIDELIZACIÓN que permite almacenar un descuento por cliente y año. Crear un paquete en PL/SQL de gestión de descuentos.
1. El procedimiento P_Calcular_Descuento, tomará un cliente y un año y calculará el descuento del que podrá disfrutar el año siguiente. 
    Para ello, hasta un máximo del 10%, irá incrementando el descuento en un 1%, por cada una de las siguientes acciones:
        1. Por cada servicio pagado por el cliente
        2. Por cada ocasión en la que el cliente tuvo que esperar más de 5 días desde que solicitó la cita hasta que se concertó.
        3. Por cada servicio proporcionado en el que tuvo que esperar más de la media de todos los servicios.
        */
        
--Desde AUTORACLE
CREATE TABLE fidelizacion (
    descuento NUMBER,
    cliente_idcliente VARCHAR2(16 BYTE),
    fecha_yyyy NUMBER);     --Como solo se pide año no usamos tipo DATE
    
--Desde SYSTEM
GRANT CREATE PROCEDURE TO autoracle;

--Desde AUTORACLE
CREATE OR REPLACE PACKAGE Gestion_descuentos AS
PROCEDURE P_Calcular_Descuento(cliente VARCHAR2, fecha_yyyy NUMBER);
PROCEDURE P_Aplicar_descuento(cliente VARCHAR2, fecha_yyyy NUMBER);
END Gestion_descuentos;
/

ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-YYYY';   --Asegurarse de usar formato YYYYY para los años

CREATE OR REPLACE PROCEDURE P_Calcular_Descuento(cliente VARCHAR2, fecha_actual_yyyy NUMBER) AS
n_servicios NUMBER;
n_mas_cinco_dias NUMBER;
n_esperas_mas_de_la_media NUMBER;
n_descuentos_total NUMBER;
fecha_validez_yyyy NUMBER;
BEGIN
    SELECT COUNT(IDFACTURA) INTO n_servicios FROM FACTURA WHERE CLIENTE_IDCLIENTE = cliente;
    SELECT COUNT(IDCITA) INTO n_mas_cinco_dias FROM CITA WHERE (FECHA_CONCERTADA - FECHA_SOLICITUD > 5 AND CLIENTE_IDCLIENTE = cliente);
    SELECT ROUND(SUM(FECREALIZACION - FECAPERTURA)/COUNT(IDSERVICIO)) INTO n_esperas_mas_de_la_media FROM SERVICIO
    JOIN VEHICULO ON (SERVICIO.VEHICULO_NUMBASTIDOR = VEHICULO.NUMBASTIDOR )
    JOIN CLIENTE ON (VEHICULO.CLIENTE_IDCLIENTE = CLIENTE.IDCLIENTE);
    n_descuentos_total := n_servicios + n_mas_cinco_dias + n_esperas_mas_de_la_media;
    fecha_validez_yyyy := fecha_actual_yyyy + 1;
    IF n_descuentos_total > 10 THEN
        UPDATE fidelizacion
            SET descuento         = 10,
                cliente_idcliente = cliente,
                fecha_yyyy        = fecha_validez_yyyy
            WHERE cliente_idcliente = cliente;
    ELSE
        UPDATE fidelizacion
            SET descuento         = n_descuentos_total,
                cliente_idcliente = cliente,
                fecha_yyyy        = fecha_validez_yyyy
            WHERE cliente_idcliente = cliente;
    END IF;
END P_Calcular_Descuento;
/

/*2. El procedimiento P_Aplicar_descuento tomará el año y el cliente. Si en la tabla FIDELIZACIÓN hay un descuento calculado a aplicar ese año,
    lo hará para todas las facturas que encuentre (en ese año).
    */
    
CREATE OR REPLACE PROCEDURE P_Aplicar_descuento(cliente VARCHAR2, yyyy NUMBER) AS
var_descuento NUMBER;
CURSOR c_facturas IS (SELECT idfactura, descuento, total FROM factura WHERE cliente_idcliente = cliente AND fecemision LIKE ('%'||TO_CHAR(yyyy))) FOR UPDATE;
BEGIN
    SELECT descuento INTO var_descuento FROM fidelizacion WHERE cliente_idcliente = cliente AND fecha_yyyy = yyyy;
    FOR v_cursor IN c_facturas LOOP
    UPDATE factura SET
        descuento = var_descuento,
        total = (var_descuento/100) * total
    WHERE
        idfactura = v_cursor.idfactura;
    END LOOP;
    EXCEPTION
        WHEN no_data_found THEN
            dbms_output.put_line  ('Cliente sin descuentos');
END P_Aplicar_descuento;
/