-- caso 1 --
select pro.ID_PROFESIONAL as "ID",
       pro.APPATERNO  || ' ' || pro.APMATERNO || ' ' || pro.NOMBRE as "PROFESIONAL",
       SUM(CASE
           WHEN sec.COD_SECTOR = 3 THEN 1
           ELSE 0
           END) AS "NRO ASESORIA BANCA",

       TO_CHAR(SUM(CASE
           WHEN sec.COD_SECTOR = 3 THEN ase.HONORARIO
           ELSE 0
           END), '$999G999G999') AS "MONTO_TOTAL_BANCA",

       SUM(CASE
           WHEN sec.COD_SECTOR = 4 THEN 1
           ELSE 0
           END) AS "NRO ASESORIA RETAIL",

       TO_CHAR(SUM(CASE
           WHEN sec.COD_SECTOR = 4 THEN ase.HONORARIO
           ELSE 0
           END), '$999G999G999') AS "MONTO_TOTAL_RETAIL",

       SUM(CASE
           WHEN sec.COD_SECTOR = 3 then 1
           WHEN sec.COD_SECTOR = 4 then 1
           ELSE 0
           END) AS "TOTAL ASESORAS",

       TO_CHAR(SUM(CASE
           WHEN sec.COD_SECTOR = 4  THEN ase.HONORARIO
           when sec.COD_SECTOR = 3 then ase.HONORARIO
           ELSE 0
           END), '$999G999G999') AS "TOTAL_HONORARIOS"

from PROFESIONAL pro
join asesoria ase on pro.ID_PROFESIONAL = ase.ID_PROFESIONAL
join empresa emp on ase.COD_EMPRESA = emp.COD_EMPRESA
join sector sec on emp.COD_SECTOR = sec.COD_SECTOR

where pro.ID_PROFESIONAL in (
    select id_profesional
    from asesoria a
    join empresa e on a.cod_empresa = e.cod_empresa
    where e.cod_sector = 3

    intersect

    select id_profesional
    from asesoria a
    join empresa e on a.cod_empresa = e.cod_empresa
    where e.cod_sector = 4
)

group by pro.ID_PROFESIONAL, pro.NOMBRE, pro.APPATERNO, pro.APMATERNO
order by "ID";

-- caso 2 --
create table REPORTE_MES as
select p.ID_PROFESIONAL as "ID_PROF",
       p.APPATERNO  || ' ' || p.APMATERNO || ' ' || p.NOMBRE as "NOMBRE_COMPLETO",
       pr.NOMBRE_PROFESION as "NOMBRE_PROFESION",
       com.NOM_COMUNA as "NOM_COMUNA",
       COUNT(ase.ID_PROFESIONAL) AS "NRO_ASESORIAS",
       ROUND(NVL(SUM(ase.HONORARIO))) AS "MONTO_TOTAL_HONORARIOS",
       ROUND(NVL(AVG(ase.HONORARIO))) AS "PROMEDIO_HONORARIO",
       ROUND(NVL(MIN(ase.HONORARIO))) AS "HONORARIO_MINIMO",
       ROUND(NVL(MAX(ase.HONORARIO))) AS "HONORARIO_MAXIMO"



from PROFESIONAL p
join PROFESION pr on p.COD_PROFESION = pr.COD_PROFESION
join COMUNA com on p.COD_COMUNA = com.COD_COMUNA
join ASESORIA ase on p.ID_PROFESIONAL = ase.ID_PROFESIONAL
where EXTRACT(month from ase.FIN_ASESORIA) = 4
  and EXTRACT(year from ase.FIN_ASESORIA) = EXTRACT(year from SYSDATE) - 1
group by pr.NOMBRE_PROFESION, p.ID_PROFESIONAL, p.APPATERNO, p.APMATERNO, p.NOMBRE, com.NOM_COMUNA
order by "ID_PROF";

select * from REPORTE_MES;

-- caso 3 --

-- select normal, antes de modificar con UPDATE
select SUM(ase.HONORARIO) as "HONORARIO",
       p.ID_PROFESIONAL as "ID_PROFESIONAL",
       p.NUMRUN_PROF as "NUMRUN_PROF",
       p.SUELDO as "SUELDO"
from PROFESIONAL p
join ASESORIA ase on p.ID_PROFESIONAL = ase.ID_PROFESIONAL
where EXTRACT(month from ase.FIN_ASESORIA) = 3
  and EXTRACT(year from ase.FIN_ASESORIA) = EXTRACT(year from SYSDATE) - 1
group by p.ID_PROFESIONAL, p.NUMRUN_PROF, p.SUELDO
order by ID_PROFESIONAL;

savepoint salvacion;

-- update
UPDATE PROFESIONAL p
SET p.SUELDO = (
        select
            CASE
                WHEN NVL(SUM(ase.HONORARIO), 0) < 1000000 THEN p.SUELDO * 1.10
                ELSE p.SUELDO * 1.15
            END
        from ASESORIA ase
        where ase.ID_PROFESIONAL = p.ID_PROFESIONAL
          and EXTRACT(month from ase.FIN_ASESORIA) = 3
          and EXTRACT(year from ase.FIN_ASESORIA) = EXTRACT(year from SYSDATE) - 1
        group by ase.ID_PROFESIONAL)
        where EXISTS(
            select 1
            from ASESORIA a
            where a.ID_PROFESIONAL = p.ID_PROFESIONAL
              and EXTRACT(month from a.FIN_ASESORIA) = 3
              and EXTRACT(year from a.FIN_ASESORIA) = EXTRACT(year from SYSDATE) - 1
);

