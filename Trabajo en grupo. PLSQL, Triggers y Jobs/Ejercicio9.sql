-- Crear un JOB que ejecute el procedimiento P_REVISA todos los díasa las 21:00.

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name => 'Llamada_P_Revisa',
        job_type => 'STORED_PROCEDURE',
        job_action => 'AUTORACLE.P_REVISA',
        start_date => SYSDATE,
        repeat_interval => 'FREQ = DAILY; BYHOUR=21',
        enabled => TRUE,
        auto_drop => FALSE,
        comments => 'Llamada al procedimiento P_REVISA Diariamente a las 21:00');
END;

-- Crear otro JOB que anualmente (el 31 de diciembre a las 23.55) llame a P_Recompensa

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name => 'Llamada_P_Recompensa',
        job_type => 'STORED_PROCEDURE',
        job_action => 'AUTORACLE.P_Recompensa',
        start_date => TO_DATE('2020-12-31 23:55:00' , 'YYYY-MM-DD HH24:MI:SS'),
        repeat_interval => 'FREQ = YEARLY; INTERVAL=1',
        enabled => TRUE,
        auto_drop => FALSE,
        comments => 'Llamada al procedimiento P_Recompensa anualmente, cada 31 de Diciembre a las 23:55');
END;

