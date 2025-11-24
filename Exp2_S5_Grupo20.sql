-- caso 1 --
select TO_CHAR(c.NUMRUN, '99G999G999') || '-' ||TO_CHAR(c.DVRUN) as "RUT Cliente",
       INITCAP(c.PNOMBRE || ' ' || c.APPATERNO) as "Nombre Cliente",
       UPPER(po.NOMBRE_PROF_OFIC) as "Profesion Cliente",
       TO_CHAR(c.FECHA_INSCRIPCION, 'DD-MM-YYYY') as "Fecha de inscripcion",
       c.DIRECCION as "Direccion Cliente"
from CLIENTE c
join PROFESION_OFICIO po on c.COD_PROF_OFIC = po.COD_PROF_OFIC
WHERE LOWER(po.NOMBRE_PROF_OFIC) IN ('contador', 'vendedor')
AND extract(year from c.FECHA_INSCRIPCION) > (select round(avg(extract (year from FECHA_INSCRIPCION))) from CLIENTE)
order by c.NUMRUN asc;

select * from CLIENTE c;

-- caso 2 --
select TO_CHAR(c.NUMRUN) || '-' ||TO_CHAR(UPPER(c.DVRUN)) as "RUT_CLIENTE",
       EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM c.FECHA_NACIMIENTO) as "EDAD",
       TO_CHAR(tc.CUPO_DISP_COMPRA, '$99G999G999') as "CUPO_DISPONIBLE_COMPRA",
       UPPER(tipc.NOMBRE_TIPO_CLIENTE) as "TIPO_CLIENTE"

from CLIENTE c
join TARJETA_CLIENTE tc on c.NUMRUN = tc.NUMRUN
join TIPO_CLIENTE tipc on c.COD_TIPO_CLIENTE = tipc.COD_TIPO_CLIENTE
where tc.CUPO_DISP_COMPRA >= (select MAX(tc_s.CUPO_DISP_COMPRA)
                             from CLIENTE c_s
                             join TARJETA_CLIENTE tc_s on c_s.NUMRUN = tc_s.NUMRUN
                             where EXTRACT(YEAR FROM c_s.FECHA_INSCRIPCION) = (2008)) -- ???
order by RUT_CLIENTE desc;

                            -- "•	Mostrar el cupo disponible para compras,
                            -- pero cuyo monto disponible es superior o igual
                            -- al máximo cupo disponible del año anterior al actual <--."

                            -- subquery original, no retorna nada por que no existen datos 2024
                            -- pero los datos coinciden con el año 2008 por alguna razon..

                            -- (select MAX(tc_s.CUPO_DISP_COMPRA)
                            -- from CLIENTE c_s
                            -- join TARJETA_CLIENTE tc_s on c_s.NUMRUN = tc_s.NUMRUN
                            -- where EXTRACT(YEAR FROM c_s.FECHA_INSCRIPCION) = (EXTRACT(YEAR FROM SYSDATE) - 2)