/*3. Añadir dos campos a la tabla factura: iva calculado y total. 
    Implementar un procedimiento P_CALCULA_FACT que recorre los datos necesarios de las piezas utilizadas y
    el porcentaje de iva y calcula la cantidad en euros para estos dos campos.
    */
    

--Añadimos las columnas
ALTER TABLE factura  ADD (
    iva_calculado NUMBER,
    total NUMBER
);

--Creamos procedimiento p_calcula_fact
CREATE OR REPLACE PROCEDURE p_calcula_fact AS

    CURSOR c_res IS SELECT
        ( preciounidadventa * iva / 100 ) iva_calculado,
        preciounidadventa + ( preciounidadventa * iva / 100 ) total,
        idfactura
                    FROM
        factura
        JOIN contiene ON ( factura.idfactura = contiene.factura_idfactura )
        JOIN pieza ON ( contiene.pieza_codref = pieza.codref )
                    WHERE
        (
            iva_calculado IS NULL
            AND   total IS NULL
        );

BEGIN
    FOR v_cursor IN c_res LOOP
        UPDATE factura
            SET
                iva_calculado =
                    CASE
                        WHEN iva_calculado IS NULL THEN 0 + v_cursor.iva_calculado
                        ELSE iva_calculado + v_cursor.iva_calculado
                    END,
                total =
                    CASE
                        WHEN total IS NULL THEN 0 + v_cursor.total
                        ELSE total + v_cursor.total
                    END
        WHERE
            idfactura = v_cursor.idfactura;

    END LOOP;
END p_calcula_fact;
/
/*Explicacion procedure:
    Crea un cursor que recorre todas las filas de factura, obteniendo el precio de las piezas que aparecen en cada factura para calcular el iva y sumarselo al precio para obtener el total
    La implementacion modifica solo las filas donde iva y total son NULL (el estado inicial, suponemos que no habra errores que obliguen a recalcular la factura,
    la otra suposicion llevaria a recalcular todas las filas de nuevo lo cual es mucho menos eficiente).
*/


-------TESTING--------
--Para resetear los valores a NULL (Para poder ejecutar el testeo desde 0 sin hacer rollback)

DECLARE
    CURSOR c_res IS SELECT
        idfactura,
        iva_calculado,
        total
                    FROM
        factura;

BEGIN
    FOR v_res IN c_res LOOP
        UPDATE factura
            SET
                iva_calculado = NULL,
                total = NULL;

    END LOOP;
END;
/

--Los 3 SELECT necesarios para ver los valores que intervienen
SELECT * FROM factura ORDER BY idfactura;           -- Actualmente valores iva_calculado, total son NULL
SELECT * FROM contiene ORDER BY FACTURA_IDFACTURA;  -- Observamos las piezas que aparecen en una determinada factura
SELECT * FROM pieza ORDER BY CODREF;                -- Aqui podemos ver los precios de cada pieza

--Ejecutamos el procedimiento
EXEC p_calcula_fact;

--Comprobamos valores correctos
SELECT * FROM factura ORDER BY idfactura; --(Los valores que siguen a NULL no se han modificado porque en la base de datos faltan algunas filas en la tabla contiene)

--Segunda ejecucion para comprobar que no modifica valores ya calculados
EXEC p_calcula_fact;
SELECT * FROM factura ORDER BY idfactura;