/* ---- CASO 1 ---- */
SELECT TO_CHAR(NUMRUT_CLI, '99G999G999') || '-' || TO_CHAR(dvrut_cli) AS "RUT Cliente",
    INITCAP(nombre_cli) || ' ' || INITCAP(appaterno_cli) || ' ' || INITCAP(apmaterno_cli) AS "Nombre Completo Cliente",
    INITCAP(direccion_cli) AS "Direccion Cliente",
    '$' || TO_CHAR(renta_cli, '99G999G999') AS "Renta Cliente",
    SUBSTR(LPAD(celular_cli, 9, '0'), 1, 2) || '-' ||
    SUBSTR(LPAD(celular_cli, 9, '0'), 3, 3) || '-' ||
    SUBSTR(LPAD(celular_cli, 9, '0'), 6, 4) AS "Celular Cliente",
    CASE
        WHEN renta_cli > 500000 THEN 'TRAMO 1'
        WHEN renta_cli BETWEEN 400000 AND 500000 THEN 'TRAMO 2'
        WHEN renta_cli BETWEEN 200000 AND 399999 THEN 'TRAMO 3'
        WHEN renta_cli < 200000 THEN 'TRAMO 4'
    END AS "Tramo Renta Cliente"

FROM CLIENTE WHERE celular_cli IS NOT NULL AND renta_cli BETWEEN &&RENTA_MINIMA AND &&RENTA_MAXIMA;

/* ---- CASO 2 ---- */
SELECT id_categoria_emp AS "CODIGO_CATEGORIA",
        CASE
           WHEN id_categoria_emp = 1 THEN 'Gerente'
           WHEN id_categoria_emp = 2 THEN 'Supervisor'
           WHEN id_categoria_emp = 3 THEN 'Ejecutivo de Arriendo'
           WHEN id_categoria_emp = 4 THEN 'Auxiliar'
        END AS "DESCRIPCION_CATEGORIA",
        COUNT(NUMRUT_EMP) AS "CANTIDAD_EMPLEADOS",
        CASE
            WHEN id_sucursal = 10 THEN 'Sucursal Las Condes'
            WHEN id_sucursal = 20 THEN 'Sucursal Santiago Centro'
            WHEN id_sucursal = 30 THEN 'Sucursal Providencia'
            WHEN id_sucursal = 40 THEN 'Sucursal Vitacura'
        END AS "SUCURSAl",
        TO_CHAR(AVG(sueldo_emp), '$99G999G999') AS "SUELDO_PROMEDIO"
FROM EMPLEADO HAVING AVG(sueldo_emp) > &&SUELDO_PROMEDIO_MINIMO
GROUP BY id_sucursal, id_categoria_emp
ORDER BY "SUELDO_PROMEDIO" DESC;

/* ---- CASO 3 ---- */

SELECT * FROM propiedad;

SELECT ID_TIPO_PROPIEDAD AS "CODIGO_TIPO",
        CASE
            WHEN id_tipo_propiedad = 'A' THEN 'CASA'
            WHEN id_tipo_propiedad = 'B' THEN 'DEPARTAMENTO'
            WHEN id_tipo_propiedad = 'C' THEN 'LOCAL'
            WHEN id_tipo_propiedad = 'D' THEN 'PARCELA SIN CASA'
            WHEN id_tipo_propiedad = 'E' THEN 'PARCELA CON CASA'
        END AS "DESCRIPCION_TIPO",
        COUNT(nro_propiedad) AS "TOTAL_PROPIEDADES",
        TO_CHAR(AVG(valor_arriendo), '$99G999G999') AS "PROMEDIO_ARRIENDO",
        TO_CHAR(AVG(superficie), '999D99') AS "PROMEDIO_SUPERFICIE",
        TO_CHAR(AVG(VALOR_ARRIENDO / superficie), '$99G999G999') AS "VALOR_ARRIENDO_M2",
        CASE
            WHEN AVG(VALOR_ARRIENDO / superficie) < 5000 THEN 'Economico'
            WHEN AVG(VALOR_ARRIENDO / superficie) BETWEEN 5000 AND 10000 THEN 'Medio'
            ELSE 'Alto'
        END AS "CLASIFICACION"
FROM PROPIEDAD
HAVING AVG(VALOR_ARRIENDO / superficie) > 1000
GROUP BY id_tipo_propiedad
ORDER BY "PROMEDIO_ARRIENDO" DESC;