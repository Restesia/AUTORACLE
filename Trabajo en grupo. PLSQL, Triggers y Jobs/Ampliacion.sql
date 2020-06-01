-- Trigger para limitar el numero de puertas entre 3 o 5
CREATE OR REPLACE TRIGGER TR_PUERTAS_VEHICULO
BEFORE INSERT OR UPDATE ON MODELO FOR EACH ROW
BEGIN
    IF (:new.NUMPUERTAS != 3 AND :new.NUMPUERTAS != 5) THEN
        raise_application_error(-20001,'Numero de puertas distinto de 3 o 5');
    END IF;
END TR_PUERTAS_VEHICULO;
/

-- Prueba

SELECT * FROM MARCA;

    -- No funciona por tener 6 puertas
insert into modelo values(20,5,'M73',6,NULL,NULL);
    -- Funciona
insert into modelo values(20,5,'M73',5,NULL,NULL);



-- BITMAP INDEX para las marcas usadas en modelo
-- No creemos que la cardinalidad de marcas de coches sea elevada por lo que un bitmap index debería ser bastante eficiente
CREATE BITMAP INDEX indice_modelo_marca
ON MODELO(marca_idmarca);
