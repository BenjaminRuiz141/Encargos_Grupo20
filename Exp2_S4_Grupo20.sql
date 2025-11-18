-- CASO 1 --

select

    t.nombre || ' ' || t.APPATERNO || ' ' || t.APMATERNO as "Nombre Completo Trabajador",
    TO_CHAR(t.NUMRUT, '99G999G999') || '-' ||TO_CHAR(t.DVRUT) as "RUT Trabajador",
    tt.DESC_CATEGORIA as "Tipo Trabajador",
    UPPER(cc.NOMBRE_CIUDAD) as "Ciudad Trabajador",
    TO_CHAR(t.SUELDO_BASE, '$999G999G999') as "Sueldo Base"

from TRABAJADOR t
join TIPO_TRABAJADOR tt on (t.ID_CATEGORIA_T = tt.ID_CATEGORIA)
join COMUNA_CIUDAD cc on (t.ID_CIUDAD = cc.ID_CIUDAD)
where t.SUELDO_BASE BETWEEN 650000 AND 3000000
order by "Ciudad Trabajador" desc, "Sueldo Base" asc;

-- CASO 2 --

select
    TO_CHAR(t.NUMRUT, '99G999G999') || '-' || t.DVRUT as "RUT Trabajador",
    INITCAP(t.NOMBRE) || ' ' || t.APPATERNO as "Nombre Trabajador",
    COUNT(tc.NUMRUT_T) as "Total Tickets",
    TO_CHAR(SUM(tc.MONTO_TICKET), '$999G999G999') as "Total Vendido",
    TO_CHAR(SUM(cot.VALOR_COMISION), '$999G999G999') as "Comision Total",
    tt.DESC_CATEGORIA "Tipo Trabajador",
    UPPER(cc.NOMBRE_CIUDAD) "Ciudad Trabajador"
from TRABAJADOR t
join TICKETS_CONCIERTO tc on (t.NUMRUT = tc.NUMRUT_T)
join COMISIONES_TICKET cot on (tc.NRO_TICKET = cot.NRO_TICKET)
join TIPO_TRABAJADOR tt on (t.ID_CATEGORIA_T = tt.ID_CATEGORIA)
join COMUNA_CIUDAD cc on (t.ID_CIUDAD = cc.ID_CIUDAD)
HAVING SUM(tc.MONTO_TICKET) > 50000
GROUP BY
    t.NUMRUT,
    t.DVRUT,
    t.NOMBRE,
    t.APPATERNO,
    tt.DESC_CATEGORIA,
    cc.NOMBRE_CIUDAD
ORDER BY "Total Vendido" DESC;

-- CASO 3 --

select
    TO_CHAR(t.NUMRUT, '99G999G999') as "RUT Trabajador",
    INITCAP(t.NOMBRE) || ' ' || INITCAP(t.APPATERNO) as "Trabajador Nombre",
    TO_CHAR(t.FECING, 'YYYY') as "Año Ingreso",
    TRUNC(MONTHS_BETWEEN(SYSDATE, t.FECING) / 12) as "Años Antiguedad",
    COUNT(af.NUMRUT_T) as "Num. Cargas Familiares",
    INITCAP(isa.NOMBRE_ISAPRE) as "Nombre Isapre",
    TO_CHAR(t.SUELDO_BASE, '$999G999G999') as "Sueldo Base",
    CASE
        WHEN LOWER(isa.NOMBRE_ISAPRE) = 'fonasa' THEN TO_CHAR(t.SUELDO_BASE * 0.01, '$999G999G999')
        ELSE '$0'
    END AS "Bono Fonasa",

    CASE
        WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, t.FECING) / 12) < 10 THEN TO_CHAR(t.SUELDO_BASE * 0.10, '$999G999G999')
        ELSE TO_CHAR(t.SUELDO_BASE * 0.15, '$999G999G999')
    END AS "Bono Antiguedad",
    INITCAP(afp.NOMBRE_AFP) as "Nombre AFP",
    UPPER(eec.DESC_ESTCIVIL) as "Estado Civil"

from TRABAJADOR t
left join ASIGNACION_FAMILIAR af on (t.NUMRUT = af.NUMRUT_T)
join ISAPRE isa on (t.COD_ISAPRE = isa.COD_ISAPRE)
join EST_CIVIL ec on (t.NUMRUT = ec.NUMRUT_T)
join ESTADO_CIVIL eec on (ec.ID_ESTCIVIL_EST = eec.ID_ESTCIVIL)
join AFP afp on (t.COD_AFP = afp.COD_AFP)
where ec.FECTER_ESTCIVIL IS NULL OR ec.FECTER_ESTCIVIL > SYSDATE
group by
    t.NUMRUT,
    t.NOMBRE,
    t.APPATERNO,
    t.FECING,
    isa.NOMBRE_ISAPRE,
    t.SUELDO_BASE,
    afp.NOMBRE_AFP,
    eec.DESC_ESTCIVIL
order by t.NUMRUT asc;

