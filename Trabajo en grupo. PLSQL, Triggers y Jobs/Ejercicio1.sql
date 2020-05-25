/*1. Modificar el modelo (si es necesario) para almacenar el usuario de Oracle que cada empleado o cliente pueda
utilizar para conectarse a la base de datos. Adem�s habr� de crear roles dependiendo del tipo de usuario:
Administrativo, con acceso a toda la BD; Empleado, con acceso s�lo a aquellos objetos que precise para su
trabajo (y nunca podr� acceder a los datos de otros empleados); y Cliente, con acceso s�lo a los datos propios,
de su veh�culo y de sus servicios. Los roles se llamar�n R_ADMINISTRATIVO, R_MECANICO, R_CLIENTE.
*/

-- CREAMOS LOS ROLES:

CREATE ROLE R_ADMINISTRATIVO;
CREATE ROLE R_MECANICO;
CREATE ROLE R_CLIENTE;

-- DAMOS PERMISOS A LOS ROLES:

    -- PERMISOS COMUNES:
    GRANT CONNECT TO R_ADMINISTRATIVO, R_MECANICO, R_CLIENTE;
    
    -- PERMISOS A R_ADMINISTRADOR (TODA LA BD).
    /* NO USAR ANY, NO TENEMOS PRIVILEGIOS PARA ELLO EN AUTORACLE, ADEM�S ES PELIGROSO.
       RECORDAR QUE CADA VEZ QUE SE INTRODUZCA ALGO NUEVO A LA BD HAY QUE DARLE PERMISOS
       AL R_ADMINISTRADOR
    */
    
    GRANT SELECT, INSERT, UPDATE, DELETE ON CATEGORIA TO R_ADMINISTRATIVO;
    GRANT SELECT, INSERT, UPDATE, DELETE ON CITA TO R_ADMINISTRATIVO;
    GRANT SELECT, INSERT, UPDATE, DELETE ON CLIENTE TO R_ADMINISTRATIVO;
    GRANT SELECT ON CLIENTE_EXTERNO TO R_ADMINISTRATIVO; -- TABLA EXTERNA, SOLO SELECT
    GRANT SELECT, INSERT, UPDATE, DELETE ON COMPATIBLE TO R_ADMINISTRATIVO;
    GRANT SELECT, INSERT, UPDATE, DELETE ON COMPRA TO R_ADMINISTRATIVO;
    GRANT SELECT, INSERT, UPDATE, DELETE ON CONTIENE TO R_ADMINISTRATIVO;
    GRANT SELECT, INSERT, UPDATE, DELETE ON EMPLEADO TO R_ADMINISTRATIVO;
    GRANT SELECT, INSERT, UPDATE, DELETE ON EXAMEN TO R_ADMINISTRATIVO;
    GRANT SELECT, INSERT, UPDATE, DELETE ON FACTURA TO R_ADMINISTRATIVO;
    GRANT SELECT, INSERT, UPDATE, DELETE ON LOTE TO R_ADMINISTRATIVO;
    GRANT SELECT, INSERT, UPDATE, DELETE ON MANTENIMIENTO TO R_ADMINISTRATIVO;
    GRANT SELECT, INSERT, UPDATE, DELETE ON MARCA TO R_ADMINISTRATIVO;
    GRANT SELECT, INSERT, UPDATE, DELETE ON MODELO TO R_ADMINISTRATIVO;
    GRANT SELECT, INSERT, UPDATE, DELETE ON MV_FACTURAS20 TO R_ADMINISTRATIVO;
    GRANT SELECT, INSERT, UPDATE, DELETE ON NECESITA TO R_ADMINISTRATIVO;
    GRANT SELECT, INSERT, UPDATE, DELETE ON PIEZA TO R_ADMINISTRATIVO;
    GRANT SELECT, INSERT, UPDATE, DELETE ON PROVEE TO R_ADMINISTRATIVO;
    GRANT SELECT, INSERT, UPDATE, DELETE ON PROVEEDOR TO R_ADMINISTRATIVO;
    GRANT SELECT, INSERT, UPDATE, DELETE ON REPARACION TO R_ADMINISTRATIVO;
    GRANT SELECT, INSERT, UPDATE, DELETE ON REQUIERE TO R_ADMINISTRATIVO;
    GRANT SELECT, INSERT, UPDATE, DELETE ON SERVICIO TO R_ADMINISTRATIVO;
    GRANT SELECT, INSERT, UPDATE, DELETE ON TRABAJA TO R_ADMINISTRATIVO;
    GRANT SELECT, INSERT, UPDATE, DELETE ON VACACIONES TO R_ADMINISTRATIVO;
    GRANT SELECT, INSERT, UPDATE, DELETE ON VEHICULO TO R_ADMINISTRATIVO;
    

    -- PERMISOS NECESARIOS A R_MECANICO (NO ACCEDER A LOS DATOS DE OTRO MECANICO)
    /* VER LO DE NO OTRO MECANICO Y SI NECESITA M�S PRIVILEGIOS*/
    
    GRANT SELECT ON FACTURA TO R_MECANICO;
    GRANT SELECT ON SERVICIO TO R_MECANICO;
    GRANT SELECT ON VACACIONES TO R_MECANICO;
    
    -- DUDA, CLASES HIJAS DE SERVICIO (�DAR PERMISO EXPL�CITO?)
    GRANT SELECT ON MANTENIMIENTO TO R_MECANICO;
    GRANT SELECT ON REPARACION TO R_MECANICO;
    
    -- PERMISO CLIENTES
    
    -- VISTA A DATOS PROPIOS.
    ALTER TABLE CLIENTE ADD USERNAME VARCHAR(32);
    
    CREATE OR REPLACE VIEW VDATOS AS (SELECT "IDCLIENTE","TELEFONO","NOMBRE","APELLIDO1","APELLIDO2","EMAIL" 
    FROM AUTORACLE.CLIENTE WHERE USERNAME = USER); -- username = user
    
    -- VISTA A SERVICIOS PROPIOS 
    
   CREATE OR REPLACE VIEW VSERVICIO AS
   (select * from servicio s join vehiculo v on (s.vehiculo_numbastidor=v.numbastidor) join cliente c on (v.cliente_idcliente=c.idcliente) where c.username = user);
    
    -- VISTA A VEHICULO PROPIO
     ALTER TABLE EMPLEADO ADD USERNAME VARCHAR(32);
     
    CREATE OR REPLACE VIEW VVEHICULO AS (SELECT * FROM vehiculo v join CLIENTE c on (v.CLIENTE_IDCLIENTE=c.IDCLIENTE) WHERE C.USERNAME = USER);
    
    -- Dar permisos de la vista
    
    GRANT SELECT ON VDATOS TO R_CLIENTE;
    GRANT SELECT ON VSERVICIO TO R_CLIENTE;
    GRANT SELECT ON VVEHICULO TO R_CLIENTE;
    
    GRANT SELECT ON VDATOS TO R_ADMINISTRATIVO; -- Admin puede verlo todo
    GRANT SELECT ON VSERVICIO TO R_ADMINISTRATIVO; --Admin puede verlo todo
    GRANT SELECT ON VVEHICULO TO R_ADMINISTRATIVO; -- Admin puede verlo todo
    
    
    /* TESTEO */
    select * from VVEHICULO;
    
    select * from cliente;
    