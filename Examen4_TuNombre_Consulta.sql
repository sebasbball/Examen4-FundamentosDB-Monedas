-- ============================================
-- Fundamentos y Diseño de Bases de Datos
-- ============================================

WITH 
-- CTE 1: Contar países por moneda
PaisesPorMoneda AS (
    SELECT 
        IdMoneda,
        COUNT(*) AS TotalPaises
    FROM pais
    GROUP BY IdMoneda
),

-- CTE 2: Obtener el último cambio de cada moneda
UltimoCambioPorMoneda AS (
    SELECT 
        cm.IdMoneda,
        cm.Fecha AS UltimaFecha,
        cm.Cambio AS UltimoCambio
    FROM cambiomoneda cm
    INNER JOIN (
        -- Subconsulta: Obtener la fecha máxima por moneda
        SELECT 
            IdMoneda,
            MAX(Fecha) AS FechaMaxima
        FROM cambiomoneda
        GROUP BY IdMoneda
    ) AS UltimaFechaPorMoneda
    ON cm.IdMoneda = UltimaFechaPorMoneda.IdMoneda 
    AND cm.Fecha = UltimaFechaPorMoneda.FechaMaxima
),

-- CTE 3: Calcular promedio de cambio en los últimos 30 días
Promedio30Dias AS (
    SELECT 
        IdMoneda,
        AVG(Cambio) AS Promedio30Dias
    FROM cambiomoneda
    WHERE Fecha >= DATEADD(DAY, -30, GETDATE())
    GROUP BY IdMoneda
),

-- CTE 4: Calcular desviación estándar para clasificar volatilidad
VolatilidadMoneda AS (
    SELECT 
        IdMoneda,
        STDEV(Cambio) AS DesviacionEstandar,
        AVG(Cambio) AS PromedioGeneral
    FROM cambiomoneda
    WHERE Fecha >= DATEADD(DAY, -30, GETDATE())
    GROUP BY IdMoneda
)

-- CONSULTA PRINCIPAL
SELECT 
    m.Id,
    m.Moneda,
    m.Sigla,
    ISNULL(ppm.TotalPaises, 0) AS TotalPaises,
    ucm.UltimaFecha,
    ucm.UltimoCambio,
    p30.Promedio30Dias,
    -- Clasificación de volatilidad basada en coeficiente de variación
    CASE 
        WHEN vm.DesviacionEstandar IS NULL THEN 'Estable'
        WHEN (vm.DesviacionEstandar / NULLIF(vm.PromedioGeneral, 0)) < 0.02 THEN 'Estable'
        WHEN (vm.DesviacionEstandar / NULLIF(vm.PromedioGeneral, 0)) < 0.05 THEN 'Moderada'
        ELSE 'Volátil'
    END AS Volatilidad,
    -- Ranking por cantidad de países (DENSE_RANK para manejar empates)
    DENSE_RANK() OVER (ORDER BY ISNULL(ppm.TotalPaises, 0) DESC) AS RankingUso
FROM moneda m
-- LEFT JOIN para incluir todas las monedas aunque no tengan países
LEFT JOIN PaisesPorMoneda ppm ON m.Id = ppm.IdMoneda
LEFT JOIN UltimoCambioPorMoneda ucm ON m.Id = ucm.IdMoneda
LEFT JOIN Promedio30Dias p30 ON m.Id = p30.IdMoneda
LEFT JOIN VolatilidadMoneda vm ON m.Id = vm.IdMoneda
-- Ordenar por ranking de uso
ORDER BY RankingUso, m.Moneda;