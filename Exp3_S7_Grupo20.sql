-- caso 1 --

-- insert
INSERT INTO DETALLE_BONIFICACIONES_TRABAJADOR (
    NUM,
    RUT,
    NOMBRE_TRABAJADOR,
    SUELDO_BASE,
    NUM_TICKET,
    DIRECCION,
    SISTEMA_SALUD,
    MONTO,
    BONIF_X_TICKET,
    SIMULACION_X_TICKET,
    SIMULACION_ANTIGUEDAD
)
select
    SEQ_DET_BONIF.nextval,
    t.NUMRUT || '-' || t.DVRUT as "RUT",
       INITCAP(t.NOMBRE || ' ' || t.APPATERNO || ' ' || t.APMATERNO) as "NOMBRE_TRABAJADOR",
       TO_CHAR(t.SUELDO_BASE, '$999G999G999') as "SUELDO_BASE",
       NVL(TO_CHAR(tc.NRO_TICKET), 'No hay info') "NUM_TICKET",
       INITCAP(t.DIRECCION) as "DIRECCION",
       UPPER(isp.NOMBRE_ISAPRE) as "SISTEMA_SALUD",
       TO_CHAR(NVL(tc.MONTO_TICKET, 0), '$999G999G999') as "MONTO",
    TO_CHAR(
       CASE
           WHEN NVL(tc.MONTO_TICKET, 0) <= 50000 THEN 0
           WHEN tc.MONTO_TICKET BETWEEN 50000 AND 100000 THEN tc.MONTO_TICKET * 0.05
           WHEN tc.MONTO_TICKET > 100000 THEN tc.MONTO_TICKET * 0.07
        END, '$999G999G999') as "BONIF_X_TICKET",

    TO_CHAR(
       CASE
            WHEN NVL(tc.MONTO_TICKET, 0) <= 50000 THEN t.SUELDO_BASE
            WHEN tc.MONTO_TICKET BETWEEN 50000 AND 100000 THEN t.SUELDO_BASE + (tc.MONTO_TICKET * 0.05)
            WHEN tc.MONTO_TICKET > 100000 THEN t.SUELDO_BASE + (tc.MONTO_TICKET * 0.07)
            ELSE 0
        END, '$999G999G999')  as "SIMULACION_X_TICKET",

    TO_CHAR(
        NVL((t.SUELDO_BASE + (t.SUELDO_BASE * ba.PORCENTAJE)), t.SUELDO_BASE), '$999G999G999') as "SIMULACION_ANTIGUEDAD"

from TRABAJADOR t
left join ISAPRE isp on t.COD_ISAPRE = isp.COD_ISAPRE
left join TICKETS_CONCIERTO tc on t.NUMRUT = tc.NUMRUT_T
left join BONO_ANTIGUEDAD ba on TRUNC(MONTHS_BETWEEN(SYSDATE, t.fecing) / 12)
       BETWEEN ba.LIMITE_INFERIOR AND ba.LIMITE_SUPERIOR
where isp.PORC_DESCTO_ISAPRE > 4 AND TRUNC(MONTHS_BETWEEN(SYSDATE,t.FECNAC) / 12 ) < 50;

-- select
select * from DETALLE_BONIFICACIONES_TRABAJADOR
    order by MONTO desc, NOMBRE_TRABAJADOR;

-- caso 2 --

-- view
create or replace view V_AUMENTOS_ESTUDIOS as
select
    TO_CHAR(t.NUMRUT, '99G999G999') as "RUT",
    INITCAP(t.NOMBRE || ' ' || t.APPATERNO || ' ' || t.APMATERNO) as "NOMBRE_TRABAJADOR",
    be.DESCRIP as "DESCRIP",
    TO_CHAR(be.PORC_BONO, '0000009') as "PCT_ESTUDIOS",
    t.SUELDO_BASE as "SUELDO_ACTUAL",
    TRUNC((t.SUELDO_BASE * be.PORC_BONO / 100)) as "AUMENTO",
    TO_CHAR(TRUNC(t.SUELDO_BASE + (t.SUELDO_BASE * be.PORC_BONO / 100)), '$999G999G999') as "SUELDO_AUMENTADO"
from TRABAJADOR t
join TIPO_TRABAJADOR tt on t.ID_CATEGORIA_T = tt.ID_CATEGORIA
join BONO_ESCOLAR be on t.ID_ESCOLARIDAD_T = be.ID_ESCOLAR
where UPPER(tt.DESC_CATEGORIA) = 'CAJERO' or (select count(*) from ASIGNACION_FAMILIAR af
                                            where af.NUMRUT_T = t.NUMRUT)
                                            in (1, 2)
order by be.PORC_BONO ASC, "NOMBRE_TRABAJADOR" ASC
with read only
;

-- sinonimos
create or replace synonym VISTA_AUMENTO_ESTUDIOS for V_AUMENTOS_ESTUDIOS;
create or replace synonym VISTA_BONO_ESTUDIOS FOR V_AUMENTOS_ESTUDIOS;

-- select de sinonimo
select * from VISTA_AUMENTO_ESTUDIOS;

-- caso 3 --

-- indices
create index idx_trab_apm_upper on TRABAJADOR(UPPER(apmaterno));
create index idx_trab_apm_lower on TRABAJADOR(LOWER(apmaterno));

-- select, con indices (?
select numrut, fecnac, t.nombre, appaterno, t.apmaterno
from trabajador T join isapre i
    on i.COD_ISAPRE = t.COD_ISAPRE
where lower(t.APMATERNO) = 'castillo';