WITH partitioned AS (
  SELECT *,
	ProductCode - ROW_NUMBER() OVER (PARTITION BY StatusCode ORDER BY StatusCode) AS grp
  FROM [DataWarehouse_PIM].[dbo].[PIM_ProductCodesReservation]
  WHERE StatusCode = 0
),  -- group consecutive numbers
counted AS (
  SELECT *,
	COUNT(*) OVER (PARTITION BY StatusCode, grp) AS cnt
  FROM partitioned
), -- count how many consecutive product codes for each group
ranked AS (
  SELECT *,
	RANK() OVER (ORDER BY StatusCode, grp) AS rnk
  FROM counted
  WHERE cnt >= 3
)  -- rank each consecutive product code group with a set number
SELECT ProductCode
FROM ranked
WHERE rnk = 1  -- return only one set
ORDER BY ProductCode