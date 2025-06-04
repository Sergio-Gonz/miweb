-- Establecer base de datos
USE AT_BCO;
GO

-- Declaración de fechas
DECLARE @FECHA_CIERRE AS DATE = GETDATE();
DECLARE @Fecha_Ant  AS DATE = EOMONTH(DATEADD(MONTH, -3, @FECHA_CIERRE));

-- =======================
-- TABLAS BASES INICIALES
-- =======================

-- Tabla: DBO.AGENCIAS_TMP
DROP TABLE IF EXISTS DBO.AGENCIAS_TMP;
SELECT *
INTO DBO.AGENCIAS_TMP
FROM dbo.CORPDW_AGENCIAS;

IF EXISTS (SELECT TOP 1 1 FROM DBO.AGENCIAS_TMP)
    PRINT 'AGENCIAS_TMP, tiene datos';
ELSE
    PRINT 'AGENCIAS_TMP, está vacía';

-- Tabla: DBO.V_OP_ACTIVO_PROCESADO_SAS_TMP
DROP TABLE IF EXISTS DBO.V_OP_ACTIVO_PROCESADO_SAS_TMP;
SELECT *
INTO DBO.V_OP_ACTIVO_PROCESADO_SAS_TMP
FROM DBO.CORPDW_OP_ACTIVO_PROCESADO_DIARIO
WHERE fecha_cierre = @FECHA_CIERRE;

IF EXISTS (SELECT TOP 1 1 FROM DBO.V_OP_ACTIVO_PROCESADO_SAS_TMP)
    PRINT 'V_OP_ACTIVO_PROCESADO_SAS_TMP, tiene datos';
ELSE
    PRINT 'V_OP_ACTIVO_PROCESADO_SAS_TMP, está vacía';

-- Tabla: DBO.V_OP_PASIVO_PROCESADO_SAS_TMP
DROP TABLE IF EXISTS DBO.V_OP_PASIVO_PROCESADO_SAS_TMP;
SELECT *
INTO DBO.V_OP_PASIVO_PROCESADO_SAS_TMP
FROM DBO.CORPDW_OP_PASIVO_PROCESADO_DIARIO
WHERE fecha_cierre = @FECHA_CIERRE;

IF EXISTS (SELECT TOP 1 1 FROM DBO.V_OP_PASIVO_PROCESADO_SAS_TMP)
    PRINT 'V_OP_PASIVO_PROCESADO_SAS_TMP, tiene datos';
ELSE
    PRINT 'V_OP_PASIVO_PROCESADO_SAS_TMP, está vacía';

-- Tabla: DBO.PARAMETROS_TMP
DROP TABLE IF EXISTS DBO.PARAMETROS_TMP;
SELECT *
INTO DBO.PARAMETROS_TMP
FROM DBO.CORPDW_PARAMETROS
WHERE fecha_cierre = @FECHA_CIERRE;

IF EXISTS (SELECT TOP 1 1 FROM DBO.PARAMETROS_TMP)
    PRINT 'PARAMETROS_TMP, tiene datos';
ELSE
    PRINT 'PARAMETROS_TMP, está vacía';

-- Tabla: DBO.CLIENTESIB_HIST_TMP
DROP TABLE IF EXISTS DBO.CLIENTESIB_HIST_TMP;
SELECT 
    c.nro_cliente,
    c.nombre_cliente,
    c.segmento_gerente,
    c.nombre_gerente,
    c.cod_gerente_num,
    c.agencia_gerente
INTO DBO.CLIENTESIB_HIST_TMP
FROM DBO.CORPDW_CLIENTESIB c

IF EXISTS (SELECT TOP 1 1 FROM DBO.CLIENTESIB_HIST_TMP)
    PRINT 'CLIENTESIB_HIST_TMP, tiene datos';
ELSE
    PRINT 'CLIENTESIB_HIST_TMP, está vacía';

-- =======================
-- TABLAS DEL MES ANTERIOR
-- =======================

-- Tabla: DBO.V_OP_ACTIVO_PROCESADO_SAS_ANT_TMP
DROP TABLE IF EXISTS DBO.V_OP_ACTIVO_PROCESADO_SAS_ANT_TMP;
SELECT *
INTO DBO.V_OP_ACTIVO_PROCESADO_SAS_ANT_TMP
FROM DBO.CORPDW_OP_ACTIVO_PROCESADO_DIARIO
WHERE fecha_cierre = @Fecha_Ant;

IF EXISTS (SELECT TOP 1 1 FROM DBO.V_OP_ACTIVO_PROCESADO_SAS_ANT_TMP)
    PRINT 'V_OP_ACTIVO_PROCESADO_SAS_ANT_TMP, tiene datos';
ELSE
    PRINT 'V_OP_ACTIVO_PROCESADO_SAS_ANT_TMP, está vacía';

-- Tabla: DBO.V_OP_PASIVO_PROCESADO_SAS_ANT_TMP
DROP TABLE IF EXISTS DBO.V_OP_PASIVO_PROCESADO_SAS_ANT_TMP;
SELECT *
INTO DBO.V_OP_PASIVO_PROCESADO_SAS_ANT_TMP
FROM DBO.CORPDW_OP_PASIVO_PROCESADO_DIARIO
WHERE fecha_cierre = @Fecha_Ant;

IF EXISTS (SELECT TOP 1 1 FROM DBO.V_OP_PASIVO_PROCESADO_SAS_ANT_TMP)
    PRINT 'V_OP_PASIVO_PROCESADO_SAS_ANT_TMP, tiene datos';
ELSE
    PRINT 'V_OP_PASIVO_PROCESADO_SAS_ANT_TMP, está vacía';

-- Tabla: DBO.PARAMETROS_ANT_TMP
DROP TABLE IF EXISTS DBO.PARAMETROS_ANT_TMP;
SELECT *
INTO DBO.PARAMETROS_ANT_TMP
FROM DBO.CORPDW_PARAMETROS
WHERE fecha_cierre = @Fecha_Ant;

IF EXISTS (SELECT TOP 1 1 FROM DBO.PARAMETROS_ANT_TMP)
    PRINT 'PARAMETROS_ANT_TMP, tiene datos';
ELSE
    PRINT 'PARAMETROS_ANT_TMP, está vacía';

-- Tabla: DBO.CLIENTESIB_HIST_ANT_TMP
DROP TABLE IF EXISTS DBO.CLIENTESIB_HIST_ANT_TMP;
SELECT 
    c.fecha_cierre,
    c.nro_cliente,
    c.nombre_cliente,
    c.segmento_gerente,
    c.nombre_gerente,
    c.cod_gerente_num,
    c.agencia_gerente
INTO DBO.CLIENTESIB_HIST_ANT_TMP
FROM DBO.CORPDW_CLIENTESIB_2025 c
WHERE c.fecha_cierre = @Fecha_Ant;

IF EXISTS (SELECT TOP 1 1 FROM DBO.CLIENTESIB_HIST_ANT_TMP)
    PRINT 'CLIENTESIB_HIST_ANT_TMP, tiene datos';
ELSE
    PRINT 'CLIENTESIB_HIST_ANT_TMP, está vacía';

-- ============================================
-- SALDO PUNTA ACTIVOS - MES ACTUAL
-- ============================================

DROP TABLE IF EXISTS DBO.PUNTA_ACTIVOS_ACT_TMP;
SELECT 
    t1.FECHA_CIERRE,
    t5.AGENCIA_GERENTE,
    t3.DLRAGN AS Agencia,
    t5.COD_GERENTE_NUM,
    t5.NOMBRE_GERENTE,
    t1.MONEDA,
    t1.NRO_CLIENTE,
    t5.NOMBRE_CLIENTE,
    t5.SEGMENTO_GERENTE,
    t4.TIPO_CAMBIO,
    t4.TIPO_CAMBIO_EU,
    SUM(t1.saldo_punta) AS Saldo_Original,
    t1.SEGMENTO_GERENTE AS Segmento_ACTPR,
	T2.SSEGNO AS TIPO_AGIR
INTO DBO.PUNTA_ACTIVOS_ACT_TMP
FROM DBO.V_OP_ACTIVO_PROCESADO_SAS_TMP t1
INNER JOIN DBO.CLIENTESIB_HIST_TMP t5 ON t1.nro_cliente = t5.nro_cliente
INNER JOIN DBO.AGENCIAS_TMP t3 ON t5.AGENCIA_GERENTE = t3.CDGAGN
INNER JOIN DBO.PARAMETROS_TMP t4 ON t1.Fecha_Cierre = t4.Fecha_Cierre
INNER JOIN CORPDW_SEGMENTOS T2 ON T1.SEGMENTO_GERENTE = T2.SSEGME
WHERE t1.Saldo_Punta > 0
  AND t1.MONEDA IN (1, 6900, 62)
  AND t1.cod_num_producto NOT IN (7, 8, 23)
GROUP BY 
    t1.FECHA_CIERRE, t5.AGENCIA_GERENTE, t3.DLRAGN, t5.COD_GERENTE_NUM,
    t5.NOMBRE_GERENTE, t1.MONEDA, t1.NRO_CLIENTE, t5.NOMBRE_CLIENTE,T2.SSEGNO,
    t5.SEGMENTO_GERENTE, t4.TIPO_CAMBIO, t4.TIPO_CAMBIO_EU, t1.SEGMENTO_GERENTE;

IF EXISTS (SELECT TOP 1 1 FROM DBO.PUNTA_ACTIVOS_ACT_TMP)
    PRINT 'PUNTA_ACTIVOS_ACT_TMP, tiene datos';
ELSE
    PRINT 'PUNTA_ACTIVOS_ACT_TMP, está vacía';

-- (La siguiente parte incluirá la conversión de moneda y clasificación AGIR en una tabla extendida)
-- Conversión de moneda y clasificación AGIR
DROP TABLE IF EXISTS DBO.PUNTA_ACTIVOS_ACT_GUA_TMP;
SELECT 
    Fecha_Cierre,
    'Punta_Activos' AS Cartera,
    Agencia_Gerente,
    Agencia,
    COD_GERENTE_NUM,
    NOMBRE_GERENTE,
    MONEDA,
    NRO_CLIENTE,
    NOMBRE_CLIENTE,
    SEGMENTO_GERENTE,
    TIPO_CAMBIO,
    TIPO_CAMBIO_EU,
    Saldo_Original,
    Segmento_ACTPR,
    -- Conversión a PYG según moneda
    CASE 
        WHEN MONEDA = 6900 THEN Saldo_Original
        WHEN MONEDA = 1 THEN Saldo_Original * TIPO_CAMBIO
        WHEN MONEDA = 62 THEN Saldo_Original * TIPO_CAMBIO_EU
        ELSE 0
    END AS Saldo_Punta_PYG,
    -- Clasificación AGIR
    TIPO_AGIR
INTO DBO.PUNTA_ACTIVOS_ACT_GUA_TMP
FROM DBO.PUNTA_ACTIVOS_ACT_TMP;

IF EXISTS (SELECT TOP 1 1 FROM DBO.PUNTA_ACTIVOS_ACT_GUA_TMP)
    PRINT 'PUNTA_ACTIVOS_ACT_GUA_TMP, tiene datos';
ELSE
    PRINT 'PUNTA_ACTIVOS_ACT_GUA_TMP, está vacía';

-- Tabla final de activos del mes actual
DROP TABLE IF EXISTS DBO.PUNTA_ACTIVOS_ACT_F_TMP;
SELECT 
    t1.Fecha_Cierre,
    t1.Cartera,
    t1.Tipo_AGIR,
    t1.Agencia,
    t1.COD_GERENTE_NUM,
    t1.NOMBRE_GERENTE,
    t1.Segmento_ACTPR,
    t1.SEGMENTO_GERENTE,
    t1.NRO_CLIENTE,
    t1.NOMBRE_CLIENTE,
    SUM(ISNULL(t1.Saldo_Punta_PYG, 0)) AS Saldo_Punta_PYG
INTO DBO.PUNTA_ACTIVOS_ACT_F_TMP
FROM DBO.PUNTA_ACTIVOS_ACT_GUA_TMP t1
GROUP BY 
    t1.Fecha_Cierre, t1.Cartera, t1.Tipo_AGIR, t1.Agencia, t1.COD_GERENTE_NUM,
    t1.NOMBRE_GERENTE, t1.Segmento_ACTPR, t1.SEGMENTO_GERENTE,
    t1.NRO_CLIENTE, t1.NOMBRE_CLIENTE
ORDER BY 
    t1.Fecha_Cierre, t1.Cartera, t1.Tipo_AGIR, t1.Agencia, t1.COD_GERENTE_NUM,
    t1.NOMBRE_GERENTE, t1.Segmento_ACTPR, t1.SEGMENTO_GERENTE,
    t1.NRO_CLIENTE, t1.NOMBRE_CLIENTE;

IF EXISTS (SELECT TOP 1 1 FROM DBO.PUNTA_ACTIVOS_ACT_F_TMP)
    PRINT 'PUNTA_ACTIVOS_ACT_F_TMP, tiene datos';
ELSE
    PRINT 'PUNTA_ACTIVOS_ACT_F_TMP, está vacía';


DROP TABLE IF EXISTS DBO.PUNTA_ACTIVOS_ANT_TMP;
SELECT 
    t1.FECHA_CIERRE,
    t5.AGENCIA_GERENTE,
    t3.DLRAGN AS Agencia,
    t5.COD_GERENTE_NUM,
    t5.NOMBRE_GERENTE,
    t1.MONEDA,
    t1.NRO_CLIENTE,
    t5.NOMBRE_CLIENTE,
    t5.SEGMENTO_GERENTE,
    t4.TIPO_CAMBIO,
    t4.TIPO_CAMBIO_EU,
    SUM(t1.saldo_punta) AS Saldo_Original,
    t1.SEGMENTO_GERENTE AS Segmento_ACTPR,
	T2.SSEGNO AS TIPO_AGIR
INTO DBO.PUNTA_ACTIVOS_ANT_TMP
FROM DBO.V_OP_ACTIVO_PROCESADO_SAS_ANT_TMP t1
INNER JOIN DBO.CLIENTESIB_HIST_ANT_TMP t5 ON t1.nro_cliente = t5.nro_cliente
INNER JOIN DBO.CORPDW_SEGMENTOS t2 ON t1.SEGMENTO_GERENTE = T2.SSEGME
INNER JOIN DBO.AGENCIAS_TMP t3 ON t5.AGENCIA_GERENTE = t3.CDGAGN
INNER JOIN DBO.PARAMETROS_ANT_TMP t4 ON t1.Fecha_Cierre = t4.Fecha_Cierre
WHERE t1.Saldo_Punta > 0
  AND t1.MONEDA IN (1, 6900, 62)
  AND t1.cod_num_producto NOT IN ( 7,8, 23)
GROUP BY 
    t1.FECHA_CIERRE, t5.AGENCIA_GERENTE, t3.DLRAGN, t5.COD_GERENTE_NUM,
    t5.NOMBRE_GERENTE, t1.MONEDA, t1.NRO_CLIENTE, t5.NOMBRE_CLIENTE,T2.SSEGNO,
    t5.SEGMENTO_GERENTE, t4.TIPO_CAMBIO, t4.TIPO_CAMBIO_EU, t1.SEGMENTO_GERENTE;

IF EXISTS (SELECT TOP 1 1 FROM DBO.PUNTA_ACTIVOS_ANT_TMP)
    PRINT 'PUNTA_ACTIVOS_ANT_TMP, tiene datos';
ELSE
    PRINT 'PUNTA_ACTIVOS_ANT_TMP, está vacía';

DROP TABLE IF EXISTS DBO.PUNTA_ACTIVOS_ANT_GUA_TMP;
SELECT 
    Fecha_Cierre,
    'Punta_Activos' AS Cartera,
    Agencia_Gerente,
    Agencia,
    COD_GERENTE_NUM,
    NOMBRE_GERENTE,
    MONEDA,
    NRO_CLIENTE,
    NOMBRE_CLIENTE,
    SEGMENTO_GERENTE,
    TIPO_CAMBIO,
    TIPO_CAMBIO_EU,
    Saldo_Original,
    Segmento_ACTPR,
    CASE 
        WHEN MONEDA = 6900 THEN Saldo_Original
        WHEN MONEDA = 1 THEN Saldo_Original * TIPO_CAMBIO
        WHEN MONEDA = 62 THEN Saldo_Original * TIPO_CAMBIO_EU
        ELSE 0
    END AS Saldo_Punta_PYG,
    Tipo_AGIR
INTO DBO.PUNTA_ACTIVOS_ANT_GUA_TMP
FROM DBO.PUNTA_ACTIVOS_ANT_TMP;

IF EXISTS (SELECT TOP 1 1 FROM DBO.PUNTA_ACTIVOS_ANT_GUA_TMP)
    PRINT 'PUNTA_ACTIVOS_ANT_GUA_TMP, tiene datos';
ELSE
    PRINT 'PUNTA_ACTIVOS_ANT_GUA_TMP, está vacía';

DROP TABLE IF EXISTS DBO.PUNTA_ACTIVOS_ANT_F_TMP;
SELECT 
    t1.Fecha_Cierre,
    t1.Cartera,
    t1.Tipo_AGIR,
    t1.Agencia,
    t1.COD_GERENTE_NUM,
    t1.NOMBRE_GERENTE,
    t1.Segmento_ACTPR,
    t1.SEGMENTO_GERENTE,
    t1.NRO_CLIENTE,
    t1.NOMBRE_CLIENTE,
    SUM(ISNULL(t1.Saldo_Punta_PYG, 0)) AS Saldo_Punta_PYG
INTO DBO.PUNTA_ACTIVOS_ANT_F_TMP
FROM DBO.PUNTA_ACTIVOS_ANT_GUA_TMP t1
GROUP BY 
    t1.Fecha_Cierre, t1.Cartera, t1.Tipo_AGIR, t1.Agencia, t1.COD_GERENTE_NUM,
    t1.NOMBRE_GERENTE, t1.Segmento_ACTPR, t1.SEGMENTO_GERENTE,
    t1.NRO_CLIENTE, t1.NOMBRE_CLIENTE
ORDER BY 
    t1.Fecha_Cierre, t1.Cartera, t1.Tipo_AGIR, t1.Agencia, t1.COD_GERENTE_NUM,
    t1.NOMBRE_GERENTE, t1.Segmento_ACTPR, t1.SEGMENTO_GERENTE,
    t1.NRO_CLIENTE, t1.NOMBRE_CLIENTE;

IF EXISTS (SELECT TOP 1 1 FROM DBO.PUNTA_ACTIVOS_ANT_F_TMP)
    PRINT 'PUNTA_ACTIVOS_ANT_F_TMP, tiene datos';
ELSE
    PRINT 'PUNTA_ACTIVOS_ANT_F_TMP, está vacía';

DROP TABLE IF EXISTS DBO.VAR_PUNTA_ACTIVOS_ACT_TMP;
SELECT 
    t1.FECHA_CIERRE,
    t3.FECHA_CIERRE AS FECHA_CIERRE_ANT,
    t1.Cartera,
    t1.Agencia,
    t1.COD_GERENTE_NUM AS COD_GTE_ACTUAL,
    t1.NOMBRE_GERENTE AS GERENTE_ACTUAL,
    t1.NRO_CLIENTE,
    t1.NOMBRE_CLIENTE,
    t1.SEGMENTO_GERENTE,
    t1.Saldo_Punta_PYG AS Saldo_Punta_PYG_Act,
    t1.Segmento_ACTPR,
    t3.COD_GERENTE_NUM AS COD_GERENTE_ANT,
    t3.NOMBRE_GERENTE AS GERENTE_ANT,
    t3.SEGMENTO_GERENTE AS SEGMENTO_ANT,
    t2.Segmento_ACTPR AS Segmento_ACTPR_ANT,
    t2.Saldo_Punta_PYG AS Saldo_Punta_PYG_Ant
INTO DBO.VAR_PUNTA_ACTIVOS_ACT_TMP
FROM DBO.PUNTA_ACTIVOS_ACT_F_TMP t1
LEFT JOIN DBO.PUNTA_ACTIVOS_ANT_F_TMP t2 ON t1.NRO_CLIENTE = t2.NRO_CLIENTE
LEFT JOIN DBO.CLIENTESIB_HIST_ANT_TMP t3 ON t1.NRO_CLIENTE = t3.NRO_CLIENTE
WHERE t1.Segmento_ACTPR IN ('Q') OR t2.Segmento_ACTPR IN ('Q');

IF EXISTS (SELECT TOP 1 1 FROM DBO.VAR_PUNTA_ACTIVOS_ACT_TMP)
    PRINT 'VAR_PUNTA_ACTIVOS_ACT_TMP, tiene datos';
ELSE
    PRINT 'VAR_PUNTA_ACTIVOS_ACT_TMP, está vacía';

DROP TABLE IF EXISTS DBO.VAR_PUNTA_ACTIVOS_ANT_TMP;
SELECT 
    t1.FECHA_CIERRE,
    t2.FECHA_CIERRE AS FECHA_CIERRE_ANT,
    t1.Cartera,
    t1.Agencia,
    t3.COD_GERENTE_NUM AS COD_GTE_ACTUAL,
    t3.NOMBRE_GERENTE AS GERENTE_ACTUAL,
    t2.NRO_CLIENTE,
    t2.NOMBRE_CLIENTE,
    t3.SEGMENTO_GERENTE,
    t1.Saldo_Punta_PYG AS Saldo_Punta_PYG_Act,
    t1.Segmento_ACTPR,
    t2.COD_GERENTE_NUM AS COD_GERENTE_ANT,
    t2.NOMBRE_GERENTE AS GERENTE_ANT,
    t2.SEGMENTO_GERENTE AS SEGMENTO_ANT,
    t2.Segmento_ACTPR AS Segmento_ACTPR_ANT,
    t2.Saldo_Punta_PYG AS Saldo_Punta_PYG_Ant
INTO DBO.VAR_PUNTA_ACTIVOS_ANT_TMP
FROM DBO.PUNTA_ACTIVOS_ACT_F_TMP t1
right JOIN DBO.PUNTA_ACTIVOS_ANT_F_TMP t2 ON t1.NRO_CLIENTE = t2.NRO_CLIENTE
LEFT JOIN DBO.CLIENTESIB_HIST_TMP t3 ON t2.NRO_CLIENTE = t3.NRO_CLIENTE
WHERE t1.Segmento_ACTPR not in ('Q') AND t2.Segmento_ACTPR IN ('Q')

IF EXISTS (SELECT TOP 1 1 FROM DBO.VAR_PUNTA_ACTIVOS_ANT_TMP)
    PRINT 'VAR_PUNTA_ACTIVOS_ANT_TMP, tiene datos';
ELSE
    PRINT 'VAR_PUNTA_ACTIVOS_ANT_TMP, está vacía';

DROP TABLE IF EXISTS DBO.A_VAR_PUNTA_ACTIVOS_TMP;
SELECT *
INTO DBO.A_VAR_PUNTA_ACTIVOS_TMP
FROM (
    SELECT * FROM DBO.VAR_PUNTA_ACTIVOS_ACT_TMP
    UNION ALL
    SELECT * FROM DBO.VAR_PUNTA_ACTIVOS_ANT_TMP
) AS Consolidado;

-- Asegurar que la columna Cartera no esté vacía
UPDATE DBO.A_VAR_PUNTA_ACTIVOS_TMP
SET Cartera = 'Punta_Activos'
WHERE ISNULL(Cartera, '') = '';
IF EXISTS (SELECT TOP 1 1 FROM DBO.A_VAR_PUNTA_ACTIVOS_TMP)
    PRINT 'A_VAR_PUNTA_ACTIVOS_TMP, tiene datos';
ELSE
    PRINT 'A_VAR_PUNTA_ACTIVOS_TMP, está vacía';


DROP TABLE IF EXISTS DBO.PUNTA_PASIVOS_ACT_TMP;
SELECT 
    t1.FECHA_CIERRE,
    t5.AGENCIA_GERENTE,
    t3.DLRAGN AS Agencia,
    t5.COD_GERENTE_NUM,
    t5.NOMBRE_GERENTE,
    t1.MONEDA,
    t1.NRO_CLIENTE,
    t5.NOMBRE_CLIENTE,
    t5.SEGMENTO_GERENTE,
    t4.TIPO_CAMBIO,
    t4.TIPO_CAMBIO_EU,
    SUM(t1.saldo_punta) AS Saldo_Original,
    t1.SEGMENTO_GERENTE AS Segmento_ACTPR,
	T2.SSEGNO AS TIPO_AGIR
INTO DBO.PUNTA_PASIVOS_ACT_TMP
FROM DBO.V_OP_PASIVO_PROCESADO_SAS_TMP t1
INNER JOIN DBO.CLIENTESIB_HIST_TMP t5 ON t1.nro_cliente = t5.nro_cliente
INNER JOIN DBO.CORPDW_SEGMENTOS t2 ON t1.SEGMENTO_GERENTE = t2.SSEGME
INNER JOIN DBO.AGENCIAS_TMP t3 ON t5.AGENCIA_GERENTE = t3.CDGAGN
INNER JOIN DBO.PARAMETROS_TMP t4 ON t1.Fecha_Cierre = t4.Fecha_Cierre
WHERE t1.Saldo_Punta > 0
  AND t1.MONEDA IN (1, 6900, 62)
GROUP BY 
    t1.FECHA_CIERRE, t5.AGENCIA_GERENTE, t3.DLRAGN, t5.COD_GERENTE_NUM,
    t5.NOMBRE_GERENTE, t1.MONEDA, t1.NRO_CLIENTE, t5.NOMBRE_CLIENTE, T2.SSEGNO,
    t5.SEGMENTO_GERENTE, t4.TIPO_CAMBIO, t4.TIPO_CAMBIO_EU, t1.SEGMENTO_GERENTE;

IF EXISTS (SELECT TOP 1 1 FROM DBO.PUNTA_PASIVOS_ACT_TMP)
    PRINT 'PUNTA_PASIVOS_ACT_TMP, tiene datos';
ELSE
    PRINT 'PUNTA_PASIVOS_ACT_TMP, está vacía';

DROP TABLE IF EXISTS DBO.PUNTA_PASIVOS_ACT_GUA_TMP;
SELECT 
    Fecha_Cierre,
    'Punta_Pasivos' AS Cartera,
    Agencia_Gerente,
    Agencia,
    COD_GERENTE_NUM,
    NOMBRE_GERENTE,
    MONEDA,
    NRO_CLIENTE,
    NOMBRE_CLIENTE,
    SEGMENTO_GERENTE,
    TIPO_CAMBIO,
    TIPO_CAMBIO_EU,
    Saldo_Original,
    Segmento_ACTPR,
    CASE 
        WHEN MONEDA = 6900 THEN Saldo_Original
        WHEN MONEDA = 1 THEN Saldo_Original * TIPO_CAMBIO
        WHEN MONEDA = 62 THEN Saldo_Original * TIPO_CAMBIO_EU
        ELSE 0
    END AS Saldo_Punta_PYG,
    Tipo_AGIR
INTO DBO.PUNTA_PASIVOS_ACT_GUA_TMP
FROM DBO.PUNTA_PASIVOS_ACT_TMP;

IF EXISTS (SELECT TOP 1 1 FROM DBO.PUNTA_PASIVOS_ACT_GUA_TMP)
    PRINT 'PUNTA_PASIVOS_ACT_GUA_TMP, tiene datos';
ELSE
    PRINT 'PUNTA_PASIVOS_ACT_GUA_TMP, está vacía';

DROP TABLE IF EXISTS DBO.PUNTA_PASIVOS_ACT_GUA_TMP;
SELECT 
    Fecha_Cierre,
    'Punta_Pasivos' AS Cartera,
    Agencia_Gerente,
    Agencia,
    COD_GERENTE_NUM,
    NOMBRE_GERENTE,
    MONEDA,
    NRO_CLIENTE,
    NOMBRE_CLIENTE,
    SEGMENTO_GERENTE,
    TIPO_CAMBIO,
    TIPO_CAMBIO_EU,
    Saldo_Original,
    Segmento_ACTPR,
    CASE 
        WHEN MONEDA = 6900 THEN Saldo_Original
        WHEN MONEDA = 1 THEN Saldo_Original * TIPO_CAMBIO
        WHEN MONEDA = 62 THEN Saldo_Original * TIPO_CAMBIO_EU
        ELSE 0
    END AS Saldo_Punta_PYG,
	Tipo_AGIR
INTO DBO.PUNTA_PASIVOS_ACT_GUA_TMP
FROM DBO.PUNTA_PASIVOS_ACT_TMP;

IF EXISTS (SELECT TOP 1 1 FROM DBO.PUNTA_PASIVOS_ACT_GUA_TMP)
    PRINT 'PUNTA_PASIVOS_ACT_GUA_TMP, tiene datos';
ELSE
    PRINT 'PUNTA_PASIVOS_ACT_GUA_TMP, está vacía';

DROP TABLE IF EXISTS DBO.PUNTA_PASIVOS_ACT_F_TMP;
SELECT 
    t1.Fecha_Cierre,
    t1.Cartera,
    t1.Tipo_AGIR,
    t1.Agencia,
    t1.COD_GERENTE_NUM,
    t1.NOMBRE_GERENTE,
    t1.Segmento_ACTPR,
    t1.SEGMENTO_GERENTE,
    t1.NRO_CLIENTE,
    t1.NOMBRE_CLIENTE,
    SUM(ISNULL(t1.Saldo_Punta_PYG, 0)) AS Saldo_Punta_PYG
INTO DBO.PUNTA_PASIVOS_ACT_F_TMP
FROM DBO.PUNTA_PASIVOS_ACT_GUA_TMP t1
GROUP BY 
    t1.Fecha_Cierre, t1.Cartera, t1.Tipo_AGIR, t1.Agencia, t1.COD_GERENTE_NUM,
    t1.NOMBRE_GERENTE, t1.Segmento_ACTPR, t1.SEGMENTO_GERENTE,
    t1.NRO_CLIENTE, t1.NOMBRE_CLIENTE
ORDER BY 
    t1.Fecha_Cierre, t1.Cartera, t1.Tipo_AGIR, t1.Agencia, t1.COD_GERENTE_NUM,
    t1.NOMBRE_GERENTE, t1.Segmento_ACTPR, t1.SEGMENTO_GERENTE,
    t1.NRO_CLIENTE, t1.NOMBRE_CLIENTE;

IF EXISTS (SELECT TOP 1 1 FROM DBO.PUNTA_PASIVOS_ACT_F_TMP)
    PRINT 'PUNTA_PASIVOS_ACT_F_TMP, tiene datos';
ELSE
    PRINT 'PUNTA_PASIVOS_ACT_F_TMP, está vacía';


DROP TABLE IF EXISTS DBO.PUNTA_PASIVOS_ANT_TMP;
SELECT 
    t1.FECHA_CIERRE,
    t5.AGENCIA_GERENTE,
    t3.DLRAGN AS Agencia,
    t5.COD_GERENTE_NUM,
    t5.NOMBRE_GERENTE,
    t1.MONEDA,
    t1.NRO_CLIENTE,
    t5.NOMBRE_CLIENTE,
    t5.SEGMENTO_GERENTE,
    t4.TIPO_CAMBIO,
    t4.TIPO_CAMBIO_EU,
    SUM(t1.saldo_punta) AS Saldo_Original,
    t1.SEGMENTO_GERENTE AS Segmento_ACTPR,
	T2.SSEGNO AS TIPO_AGIR
INTO DBO.PUNTA_PASIVOS_ANT_TMP
FROM DBO.V_OP_PASIVO_PROCESADO_SAS_ANT_TMP t1
INNER JOIN DBO.CLIENTESIB_HIST_ANT_TMP t5 ON t1.nro_cliente = t5.nro_cliente
INNER JOIN DBO.CORPDW_SEGMENTOS t2 ON t1.SEGMENTO_GERENTE = t2.SSEGME
INNER JOIN DBO.AGENCIAS_TMP t3 ON t5.AGENCIA_GERENTE = t3.CDGAGN
INNER JOIN DBO.PARAMETROS_ANT_TMP t4 ON t1.Fecha_Cierre = t4.Fecha_Cierre
WHERE t1.Saldo_Punta > 0
  AND t1.MONEDA IN (1, 6900, 62)
GROUP BY 
    t1.FECHA_CIERRE, t5.AGENCIA_GERENTE, t3.DLRAGN, t5.COD_GERENTE_NUM,
    t5.NOMBRE_GERENTE, t1.MONEDA, t1.NRO_CLIENTE, t5.NOMBRE_CLIENTE,T2.SSEGNO,
    t5.SEGMENTO_GERENTE, t4.TIPO_CAMBIO, t4.TIPO_CAMBIO_EU, t1.SEGMENTO_GERENTE;

IF EXISTS (SELECT TOP 1 1 FROM DBO.PUNTA_PASIVOS_ANT_TMP)
    PRINT 'PUNTA_PASIVOS_ANT_TMP, tiene datos';
ELSE
    PRINT 'PUNTA_PASIVOS_ANT_TMP, está vacía';

DROP TABLE IF EXISTS DBO.PUNTA_PASIVOS_ANT_GUA_TMP;
SELECT 
    Fecha_Cierre,
    'Punta_Pasivos' AS Cartera,
    Agencia_Gerente,
    Agencia,
    COD_GERENTE_NUM,
    NOMBRE_GERENTE,
    MONEDA,
    NRO_CLIENTE,
    NOMBRE_CLIENTE,
    SEGMENTO_GERENTE,
    TIPO_CAMBIO,
    TIPO_CAMBIO_EU,
    Saldo_Original,
    Segmento_ACTPR,
    CASE 
        WHEN MONEDA = 6900 THEN Saldo_Original
        WHEN MONEDA = 1 THEN Saldo_Original * TIPO_CAMBIO
        WHEN MONEDA = 62 THEN Saldo_Original * TIPO_CAMBIO_EU
        ELSE 0
    END AS Saldo_Punta_PYG,
	Tipo_AGIR
INTO DBO.PUNTA_PASIVOS_ANT_GUA_TMP
FROM DBO.PUNTA_PASIVOS_ANT_TMP;

IF EXISTS (SELECT TOP 1 1 FROM DBO.PUNTA_PASIVOS_ANT_GUA_TMP)
    PRINT 'PUNTA_PASIVOS_ANT_GUA_TMP, tiene datos';
ELSE
    PRINT 'PUNTA_PASIVOS_ANT_GUA_TMP, está vacía';

DROP TABLE IF EXISTS DBO.PUNTA_PASIVOS_ANT_F_TMP;
SELECT 
    t1.Fecha_Cierre,
    t1.Cartera,
    t1.Tipo_AGIR,
    t1.Agencia,
    t1.COD_GERENTE_NUM,
    t1.NOMBRE_GERENTE,
    t1.Segmento_ACTPR,
    t1.SEGMENTO_GERENTE,
    t1.NRO_CLIENTE,
    t1.NOMBRE_CLIENTE,
    SUM(ISNULL(t1.Saldo_Punta_PYG, 0)) AS Saldo_Punta_PYG
INTO DBO.PUNTA_PASIVOS_ANT_F_TMP
FROM DBO.PUNTA_PASIVOS_ANT_GUA_TMP t1
GROUP BY 
    t1.Fecha_Cierre, t1.Cartera, t1.Tipo_AGIR, t1.Agencia, t1.COD_GERENTE_NUM,
    t1.NOMBRE_GERENTE, t1.Segmento_ACTPR, t1.SEGMENTO_GERENTE,
    t1.NRO_CLIENTE, t1.NOMBRE_CLIENTE
ORDER BY 
    t1.Fecha_Cierre, t1.Cartera, t1.Tipo_AGIR, t1.Agencia, t1.COD_GERENTE_NUM,
    t1.NOMBRE_GERENTE, t1.Segmento_ACTPR, t1.SEGMENTO_GERENTE,
    t1.NRO_CLIENTE, t1.NOMBRE_CLIENTE;

IF EXISTS (SELECT TOP 1 1 FROM DBO.PUNTA_PASIVOS_ANT_F_TMP)
    PRINT 'PUNTA_PASIVOS_ANT_F_TMP, tiene datos';
ELSE
    PRINT 'PUNTA_PASIVOS_ANT_F_TMP, está vacía';

DROP TABLE IF EXISTS DBO.VAR_PUNTA_PASIVOS_ACT_TMP;
SELECT 
    t1.FECHA_CIERRE,
    t3.FECHA_CIERRE AS FECHA_CIERRE_ANT,
    t1.Cartera,
    t1.Agencia,
    t1.COD_GERENTE_NUM AS COD_GTE_ACTUAL,
    t1.NOMBRE_GERENTE AS GERENTE_ACTUAL,
    t1.NRO_CLIENTE,
    t1.NOMBRE_CLIENTE,
    t1.SEGMENTO_GERENTE,
    t1.Saldo_Punta_PYG AS Saldo_Punta_PYG_Act,
    t1.Segmento_ACTPR,
    t3.COD_GERENTE_NUM AS COD_GERENTE_ANT,
    t3.NOMBRE_GERENTE AS GERENTE_ANT,
    t3.SEGMENTO_GERENTE AS SEGMENTO_ANT,
    t2.Segmento_ACTPR AS Segmento_ACTPR_ANT,
    t2.Saldo_Punta_PYG AS Saldo_Punta_PYG_Ant
INTO DBO.VAR_PUNTA_PASIVOS_ACT_TMP
FROM DBO.PUNTA_PASIVOS_ACT_F_TMP t1
LEFT JOIN DBO.PUNTA_PASIVOS_ANT_F_TMP t2 ON t1.NRO_CLIENTE = t2.NRO_CLIENTE
LEFT JOIN DBO.CLIENTESIB_HIST_ANT_TMP t3 ON t1.NRO_CLIENTE = t3.NRO_CLIENTE
WHERE t1.Segmento_ACTPR IN (/*'E','P',*/'Q'/*,'S','Y'*/) OR t2.Segmento_ACTPR IN (/*'E','P',*/'Q'/*,'S','Y'*/);

IF EXISTS (SELECT TOP 1 1 FROM DBO.VAR_PUNTA_PASIVOS_ACT_TMP)
    PRINT 'VAR_PUNTA_PASIVOS_ACT_TMP, tiene datos';
ELSE
    PRINT 'VAR_PUNTA_PASIVOS_ACT_TMP, está vacía';

DROP TABLE IF EXISTS DBO.VAR_PUNTA_PASIVOS_ANT_TMP;
SELECT 
    t1.FECHA_CIERRE,
    t2.FECHA_CIERRE AS FECHA_CIERRE_ANT,
    t1.Cartera,
    t1.Agencia,
    t3.COD_GERENTE_NUM AS COD_GTE_ACTUAL,
    t3.NOMBRE_GERENTE AS GERENTE_ACTUAL,
    t2.NRO_CLIENTE,
    t2.NOMBRE_CLIENTE,
    t3.SEGMENTO_GERENTE,
    t1.Saldo_Punta_PYG AS Saldo_Punta_PYG_Act,
    t1.Segmento_ACTPR,
    t2.COD_GERENTE_NUM AS COD_GERENTE_ANT,
    t2.NOMBRE_GERENTE AS GERENTE_ANT,
    t2.SEGMENTO_GERENTE AS SEGMENTO_ANT,
    t2.Segmento_ACTPR AS Segmento_ACTPR_ANT,
    t2.Saldo_Punta_PYG AS Saldo_Punta_PYG_Ant
INTO DBO.VAR_PUNTA_PASIVOS_ANT_TMP
FROM DBO.PUNTA_PASIVOS_ACT_F_TMP t1
RIGHT JOIN DBO.PUNTA_PASIVOS_ANT_F_TMP t2 ON t1.NRO_CLIENTE = t2.NRO_CLIENTE
LEFT JOIN DBO.CLIENTESIB_HIST_TMP t3 ON t2.NRO_CLIENTE = t3.NRO_CLIENTE
WHERE (t1.Segmento_ACTPR NOT IN (/*'E','P',*/'Q'/*,'S','Y'*/) AND t2.Segmento_ACTPR IN (/*'E','P',*/'Q'/*,'S','Y'*/))
-- AND t1.Agencia IS NULL;

IF EXISTS (SELECT TOP 1 1 FROM DBO.VAR_PUNTA_PASIVOS_ANT_TMP)
    PRINT 'VAR_PUNTA_PASIVOS_ANT_TMP, tiene datos';
ELSE
    PRINT 'VAR_PUNTA_PASIVOS_ANT_TMP, está vacía';

DROP TABLE IF EXISTS DBO.A_VAR_PUNTA_PASIVOS_TMP;
SELECT *
INTO DBO.A_VAR_PUNTA_PASIVOS_TMP
FROM (
    SELECT * FROM DBO.VAR_PUNTA_PASIVOS_ACT_TMP
    UNION ALL
    SELECT * FROM DBO.VAR_PUNTA_PASIVOS_ANT_TMP
) AS Consolidado;

-- Asegurar que la columna Cartera no esté vacía
UPDATE DBO.A_VAR_PUNTA_PASIVOS_TMP
SET Cartera = 'Punta_Pasivos'
WHERE ISNULL(Cartera, '') = '';

IF EXISTS (SELECT TOP 1 1 FROM DBO.A_VAR_PUNTA_PASIVOS_TMP)
    PRINT 'A_VAR_PUNTA_PASIVOS_TMP, tiene datos';
ELSE
    PRINT 'A_VAR_PUNTA_PASIVOS_TMP, está vacía';
-- =========================================
-- 2. Carga CDA actual
-- =========================================
DROP TABLE IF EXISTS DBO.A_Cant_CDA_TMP;
SELECT 
t1.fecha_cierre,
t1.nro_cliente,
t2.nombre_cliente,
t1.plazo_dias_cda,
t1.fecha_alta,
t2.agencia_gerente,
t4.DLRAGN AS agencia,
t2.cod_gerente_num,
t1.id_moneda,
t1.nro_operacion,
t3.GNOMBG AS nombre_gerente,
t5.tipo_cambio,
t5.tipo_cambio_eu,
SUM(t1.importe_cda) AS t_saldo_punta,
t1.fecha_vto,
t1.cda_estado
INTO DBO.A_Cant_CDA_TMP
FROM DBO.CORPDW_CDA_MAESTRO2 t1
LEFT JOIN DBO.CORPDW_CLIENTESIB t2 ON t1.nro_cliente = t2.nro_cliente
LEFT JOIN DBO.CORPDW_GERENTES t3 ON t2.cod_gerente_num = t3.cod_gerente_num
LEFT JOIN DBO.CORPDW_AGENCIAS t4 ON t2.agencia_gerente = t4.cdgagn
LEFT JOIN DBO.CORPDW_PARAMETROS t5 ON t1.fecha_cierre = t5.fecha_cierre
WHERE t1.cda_estado IN (2, 3, 10)
AND t1.fecha_cierre = @FECHA_CIERRE
AND t1.cda_estado <> 9
AND t2.segmento_gerente IN ('Q', 'S', 'P', 'E', 'K')
GROUP BY t1.fecha_cierre, t1.nro_cliente, t2.nombre_cliente, t1.plazo_dias_cda,
t1.fecha_alta, t2.agencia_gerente, t4.DLRAGN, t2.cod_gerente_num, t1.id_moneda,
t1.nro_operacion, t3.GNOMBG, t5.tipo_cambio, t5.tipo_cambio_eu,
t1.fecha_vto, t1.cda_estado;

-- Conversión a guaraníes y marca vencido
DROP TABLE IF EXISTS DBO.A_Cant_CDA_FINAL;
SELECT *,
CASE 
WHEN id_moneda = 6900 THEN t_saldo_punta
WHEN id_moneda = 1 THEN t_saldo_punta * tipo_cambio
WHEN id_moneda = 62 THEN t_saldo_punta * tipo_cambio_eu
ELSE 0
END AS saldo_punta_act_pyg,
CASE 
WHEN fecha_vto <= @FECHA_CIERRE THEN 'SI'
ELSE 'NO'
END AS suma
INTO DBO.A_Cant_CDA_FINAL
FROM DBO.A_Cant_CDA_TMP;

-- =========================================
-- 3. Carga CDA mes anterior
-- =========================================
DROP TABLE IF EXISTS DBO.A_Cant_CDA_TMP_ANT;
SELECT 
t1.fecha_cierre,
t1.nro_cliente,
t2.nombre_cliente,
t1.plazo_dias_cda,
t1.fecha_alta,
t2.agencia_gerente,
t4.DLRAGN AS agencia,
t2.cod_gerente_num,
t1.id_moneda,
t1.nro_operacion,
t3.GNOMBG AS nombre_gerente,
t5.tipo_cambio,
t5.tipo_cambio_eu,
SUM(t1.importe_cda) AS t_saldo_punta,
t1.fecha_vto,
t1.cda_estado
INTO DBO.A_Cant_CDA_TMP_ANT
FROM DBO.CORPDW_CDA_MAESTRO2 t1
LEFT JOIN DBO.CORPDW_CLIENTESIB t2 ON t1.nro_cliente = t2.nro_cliente
LEFT JOIN DBO.CORPDW_GERENTES t3 ON t2.cod_gerente_num = t3.cod_gerente_num
LEFT JOIN DBO.CORPDW_AGENCIAS t4 ON t2.agencia_gerente = t4.cdgagn
LEFT JOIN DBO.CORPDW_PARAMETROS t5 ON t1.fecha_cierre = t5.fecha_cierre
WHERE t1.cda_estado IN (2, 3, 10)
AND t1.fecha_cierre = @Fecha_Ant
AND t1.cda_estado <> 9
AND t2.segmento_gerente IN ('Q', 'S', 'P', 'E', 'K')
GROUP BY t1.fecha_cierre, t1.nro_cliente, t2.nombre_cliente, t1.plazo_dias_cda,
t1.fecha_alta, t2.agencia_gerente, t4.DLRAGN, t2.cod_gerente_num, t1.id_moneda,
t1.nro_operacion, t3.GNOMBG, t5.tipo_cambio, t5.tipo_cambio_eu,
t1.fecha_vto, t1.cda_estado;

-- Conversión anterior
DROP TABLE IF EXISTS DBO.A_Cant_CDA_FINAL_ANT;
SELECT *,
CASE 
WHEN id_moneda = 6900 THEN t_saldo_punta
WHEN id_moneda = 1 THEN t_saldo_punta * tipo_cambio
WHEN id_moneda = 62 THEN t_saldo_punta * tipo_cambio_eu
ELSE 0
END AS saldo_punta_act_pyg,
CASE 
WHEN fecha_vto <= @Fecha_Ant THEN 'SI'
ELSE 'NO'
END AS suma
INTO DBO.A_Cant_CDA_FINAL_ANT
FROM DBO.A_Cant_CDA_TMP_ANT;

-- =========================================
-- 4. Comparativo y variación
-- =========================================
DROP TABLE IF EXISTS DBO.VAR_CDA_TMP;
SELECT 
COALESCE(act.nro_cliente, ant.nro_cliente) AS nro_cliente,
COALESCE(act.nombre_cliente, ant.nombre_cliente) AS nombre_cliente,
COALESCE(act.nro_operacion, ant.nro_operacion) AS nro_operacion,
COALESCE(act.cod_gerente_num, ant.cod_gerente_num) AS cod_gte_actual,
COALESCE(act.nombre_gerente, ant.nombre_gerente) AS gerente_actual,
ant.cod_gerente_num AS cod_gerente_ant,
ant.nombre_gerente AS gerente_ant,
ISNULL(act.saldo_punta_act_pyg, 0) AS saldo_punta_act_pyg,
ISNULL(ant.saldo_punta_act_pyg, 0) AS saldo_punta_ant_pyg,
ISNULL(act.saldo_punta_act_pyg, 0) - ISNULL(ant.saldo_punta_act_pyg, 0) AS variacion,
CASE 
WHEN ISNULL(act.saldo_punta_act_pyg, 0) - ISNULL(ant.saldo_punta_act_pyg, 0) > 0 THEN 'Aumentó'
WHEN ISNULL(act.saldo_punta_act_pyg, 0) - ISNULL(ant.saldo_punta_act_pyg, 0) < 0 THEN 'Disminuyó'
ELSE 'Mantiene'
END AS desc_variacion,
CASE 
WHEN ant.cod_gerente_num IS NULL THEN 'N'
WHEN act.cod_gerente_num = ant.cod_gerente_num THEN 'N'
ELSE 'S'
END AS migracion_cartera,
act.fecha_cierre AS fecha_cierre_act,
ant.fecha_cierre AS fecha_cierre_ant,
act.fecha_vto AS fecha_vto_act,
ant.fecha_vto AS fecha_vto_ant,
act.suma AS suma_act,
ant.suma AS suma_ant
INTO DBO.VAR_CDA_TMP
FROM DBO.A_Cant_CDA_FINAL act
FULL OUTER JOIN DBO.A_Cant_CDA_FINAL_ANT ant
ON act.nro_cliente = ant.nro_cliente AND act.nro_operacion = ant.nro_operacion;

-- =========================================
-- 5. Reporte final de saldos vencidos por cliente
-- =========================================
DROP TABLE IF EXISTS DBO.REPORTE_CDA_TMP;
SELECT 
nro_cliente,
SUM(CASE WHEN suma_act = 'SI' THEN saldo_punta_act_pyg ELSE 0 END) AS saldo_punta_act_vencido,
SUM(CASE WHEN suma_ant = 'SI' THEN saldo_punta_ant_pyg ELSE 0 END) AS saldo_punta_ant_vencido
INTO DBO.REPORTE_CDA_TMP
FROM DBO.VAR_CDA_TMP
GROUP BY nro_cliente;

-- =========================================
-- 6. Consolidado final de activos y pasivos (una fila por cartera)
-- =========================================
DROP TABLE IF EXISTS DBO.VARIACION_SALDOS_TMP;
SELECT 
    FECHA_CIERRE,
    FECHA_CIERRE_ANT,
    Cartera,
    NRO_CLIENTE,
    NOMBRE_CLIENTE,
    GERENTE_ACTUAL,
    GERENTE_ANT,
    Saldo_Punta_PYG_Act,
    Saldo_Punta_PYG_Ant,
    Saldo_Punta_PYG_Act - Saldo_Punta_PYG_Ant AS Variacion,
    CASE 
        WHEN Saldo_Punta_PYG_Act - Saldo_Punta_PYG_Ant > 0 THEN 'Aumentó'
        WHEN Saldo_Punta_PYG_Act - Saldo_Punta_PYG_Ant < 0 THEN 'Disminuyó'
        ELSE 'Mantiene'
    END AS Desc_Variacion,
    CASE 
        WHEN COD_GERENTE_ANT IS NULL THEN 'N'
        WHEN COD_GTE_ACTUAL = COD_GERENTE_ANT THEN 'N'
        ELSE 'S'
    END AS Migración_Cartera,
    Agencia,
    COD_GTE_ACTUAL,
    SEGMENTO_GERENTE,
    Segmento_ACTPR,
    COD_GERENTE_ANT,
    SEGMENTO_ANT,
    Segmento_ACTPR_ANT
INTO DBO.VARIACION_SALDOS_TMP
FROM (
    SELECT * FROM DBO.A_VAR_PUNTA_ACTIVOS_TMP
    UNION ALL
    SELECT * FROM DBO.A_VAR_PUNTA_PASIVOS_TMP
) AS Consolidado;

IF EXISTS (SELECT TOP 1 1 FROM DBO.VARIACION_SALDOS_TMP)
    PRINT 'VARIACION_SALDOS_TMP, tiene datos';
ELSE
    PRINT 'VARIACION_SALDOS_TMP, está vacía';

--SELECT 
--FECHA_CIERRE
--,FECHA_CIERRE_ANT
--,CARTERA
--,NRO_CLIENTE
--,NOMBRE_CLIENTE
--,GERENTE_ACTUAL
--,GERENTE_ANT
--,Saldo_Punta_PYG_Act
--,Saldo_Punta_PYG_Ant
--,Desc_Variacion
--,Migración_Cartera
--,AGENCIA
--,COD_GTE_ACTUAL
--,SEGMENTO_GERENTE
--,Segmento_ACTPR
--,COD_GERENTE_ANT
--,SEGMENTO_ANT
--FROM
--VARIACION_SALDOS_TMP --WHERE NRO_CLIENTE = 2394


select * from VAR_PUNTA_ACTIVOS_ACT_TMP


select * into #t1 from (
SELECT * FROM PUNTA_ACTIVOS_ACT_GUA_TMP
union all
select * from PUNTA_ACTIVOS_ANT_GUA_TMP) as consolidado

select * from #t1
