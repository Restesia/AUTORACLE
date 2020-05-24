-- Escribir un trigger que cuando se eliminen los datos de un cliente
-- fidelizado se eliminen a su vez toda su
-- informacion de fidelizacion y los datos de su vehiculo.

CREATE OR REPLACE TRIGGER TR_ELIMINA_CLIENTE_FIDELIZADO
BEFORE DELETE ON CLIENTE FOR EACH ROW
BEGIN
	DELETE FROM FIDELIZACION WHERE CLIENTE = :old.IDCLIENTE;
	DELETE FROM VEHICULO WHERE CLIENTE_IDCLIENTE = :old.IDCLIENTE;
END TR_ELIMINA_CLIENTE_FIDELIZADO;