/* 2. Crea una tabla denominada COMPRA_FUTURA que incluya el NIF, tel�fono, nombre e email del proveedor,
Referencia de pieza y cantidad. Necesitamos un procedimiento P_REVISA que cuando se ejecute compruebe si
las piezas han caducado. De esta forma, insertar� en COMPRA_FUTURA aquellas piezas caducadas junto a los
datos necesarios para realizar en el futuro la compra.
*/

CREATE TABLE COMPRA_FUTURA(
    NIF VARCHAR(9), 
    TELEFONO NUMBER(38,0), -- Proveedor tiene telefono (38,0)
    NOMBRE VARCHAR(50), 
    EMAIL_PROVEEDOR VARCHAR(50), 
    REF_PIEZA VARCHAR(50), 
    CANTIDAD NUMBER);
    
    
CREATE OR REPLACE PROCEDURE P_REVISA IS
    CURSOR C_PIEZA IS (SELECT PROVEEDOR_NIF, CODREF, NOMBRE, CANTIDAD, FECCADUCIDAD FROM PIEZA);
    TLF number;
    EMAIL VARCHAR2(50);
BEGIN
    FOR I IN C_PIEZA LOOP
        IF(I.FECCADUCIDAD < SYSDATE) THEN
            SELECT TELEFONO INTO TLF FROM PROVEEDOR P WHERE I.PROVEEDOR_NIF = P.NIF;
            SELECT EMAIL INTO EMAIL FROM PROVEEDOR P WHERE I.PROVEEDOR_NIF = P.NIF;
            INSERT INTO COMPRA_FUTURA VALUES (I.PROVEEDOR_NIF, TLF, I.NOMBRE, EMAIL, I.CODREF, I.CANTIDAD);
        END IF;
    END LOOP;
    
END P_REVISA;
/

-- TESTEO 

update PIEZA set FECCADUCIDAD = NULL; -- No ponemos clausula where porque queremos reiniciar el proceso.
delete from COMPRA_FUTURA where REF_PIEZA = '123498'; -- Reseteamos tabla para hacer el proceso desde 0.
delete from COMPRA_FUTURA where REF_PIEZA = '227562'; -- Reseteamos tabla para hacer el proceso desde 0.

select * from PIEZA; -- Tenemos muchas piezas, todas con FECCADUCIDAD A NULL


update PIEZA set FECCADUCIDAD = sysdate-2 where CODREF = '227562';
update PIEZA set FECCADUCIDAD = sysdate-2 where CODREF = '123498';
select * from PIEZA; -- Vemos como se modifican las filas con las fechas
exec p_revisa;
select * from compra_futura;

/*
Para comprobar:
1� Introducir datos (ficticios)
2� exec p_revisa;
3� select * from compra_futura;
*/