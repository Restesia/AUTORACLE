-- Escribir un trigger que cuando se eliminen los datos de un cliente
-- fidelizado se eliminen a su vez toda su
-- informacion de fidelizacion y los datos de su vehiculo.

CREATE OR REPLACE TRIGGER TR_ELIMINA_CLIENTE_FIDELIZADO
BEFORE DELETE ON CLIENTE FOR EACH ROW
BEGIN
	DELETE FROM FIDELIZACION WHERE CLIENTE_IDCLIENTE = :old.IDCLIENTE;
	DELETE FROM VEHICULO WHERE CLIENTE_IDCLIENTE = :old.IDCLIENTE;
END TR_ELIMINA_CLIENTE_FIDELIZADO;
/

-- PRUEBA

--- Creamos un cliente
select * from cliente;

insert into cliente values (1924,81281057,'Marcello','Mastroianni',NULL,'marcello@fellini.com',NULL);

--- Le asignamos un vehiculo
insert into vehiculo values (040807,'0008MEZ',NULL,22,3,1924,8);

--- Lo fidelizamos

insert into fidelizacion values(1,1924,2020);

-- Borramos
delete from cliente where idcliente = 1924;

-- Comprobamos la eliminacion
select * from fidelizacion where CLIENTE_IDCLIENTE = 1924;
select * from vehiculo where CLIENTE_IDCLIENTE = 1924;
select * from cliente where IDCLIENTE = 1924;

