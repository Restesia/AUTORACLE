--Ejecutar desde SYSTEM

--Creamos datafile para almacenar las tablas
CREATE TABLESPACE ts_autoracle DATAFILE
    'C:\USERS\APP\ALUMNOS\ORADATA\ORCL\autoracle.dbf' SIZE 16 m
        AUTOEXTEND ON NEXT 200 k MAXSIZE 128 m;

--Creamos usuario AUTORACLE y le asignamos privilegios básicos para poder ejecutar autoracle.sql

CREATE USER autoracle IDENTIFIED BY bd
    DEFAULT TABLESPACE ts_autoracle
    QUOTA UNLIMITED ON ts_autoracle;
    
GRANT connect,
    CREATE TABLE,
    CREATE VIEW,
    CREATE MATERIALIZED VIEW
TO autoracle;