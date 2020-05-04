BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name => 'Llamada_P_Revisa',
        job_type => 'PLSQL_BLOCK',
        job_action => 'BEGIN PROCEDURE P_REVISA END;',
        start_date => SYSDATE,
        repeat_interval => 'FREQ = DAILY;BYHOUR=21',
        enabled => TRUE,
        comments => 'Llamada al procedimiento P_Recompensa anualmente, cada 31 de Diciembre a las 23:55');
END;

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name => 'Llamada_P_Recompensa',
        job_type => 'PLSQL_BLOCK',
        job_action => 'BEGIN PROCEDURE P_Recompensa END;',
        start_date => TO_DATE('2020-12-31 23:55:00' , 'YYYY-MM-DD HH24:MI:SS'),
        repeat_interval => 'FREQ = YEARLY; INTERVAL=1',
        enabled => TRUE,
        comments => 'Llamada al procedimiento P_Recompensa anualmente, cada 31 de Diciembre a las 23:55');
END;

