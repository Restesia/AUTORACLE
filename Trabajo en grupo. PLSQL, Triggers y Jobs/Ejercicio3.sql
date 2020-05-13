/*3. Añadir dos campos a la tabla factura: iva calculado y total. 
    Implementar un procedimiento P_CALCULA_FACT que recorre los datos necesarios de las piezas utilizadas y
    el porcentaje de iva y calcula la cantidad en euros para estos dos campos.
    */

ALTER TABLE factura  ADD (
    iva_calculado NUMBER,
    total NUMBER
);

CREATE OR REPLACE PROCEDURE P_CALCULA_FACT(id_factura NUMBER) AS
res_iva_calculado NUMBER;
res_total NUMBER;
-- Hacer un select en vez de todo el cursor
CURSOR c_res IS SELECT SUM(preciounidadventa * iva/100) iva_calculado, SUM(preciounidadventa + preciounidadventa * iva/100) total FROM factura 
    JOIN contiene ON (factura.idfactura = contiene.factura_idfactura) 
    JOIN pieza ON (contiene.pieza_codref = pieza.codref) WHERE factura.idfactura = id_factura;
BEGIN
    OPEN c_res;
        FETCH c_res INTO res_iva_calculado, res_total;
        UPDATE factura
            SET iva_calculado = res_iva_calculado,
                total         = res_total
        WHERE idfactura = id_factura;
    CLOSE c_res;
END P_CALCULA_FACT;
/