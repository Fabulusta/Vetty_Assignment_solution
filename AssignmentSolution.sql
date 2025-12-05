/* =====================================================================
   SQL Test – Final Answers (MySQL 8+)
   Author: <Varun Kumar>
   Description: This file contains all solutions (Q1–Q8) along with 
   brief explanations for each approach, as required in the assignment.
   ===================================================================== */


/* =====================================================================
   Q1. Count of purchases per month (excluding refunded purchases)
   Approach:
   - Exclude refunded purchases (refund_time IS NOT NULL)
   - Group remaining rows by year-month
   - Count total purchases per month
   ===================================================================== */
SELECT
  DATE_FORMAT(purchase_time, '%Y-%m-01') AS month_start,
  COUNT(*) AS purchases_count
FROM transactions
WHERE refund_time IS NULL
GROUP BY DATE_FORMAT(purchase_time, '%Y-%m')
ORDER BY month_start;



/* =====================================================================
   Q2. Number of stores with ≥5 transactions in October 2020
   Approach:
   - Filter rows occurring in October 2020
   - Group by store_id
   - Count total transactions per store
   - Return stores with count >= 5
   ===================================================================== */
SELECT
  COUNT(*) AS stores_with_min_5_orders_in_oct_2020
FROM (
  SELECT store_id, COUNT(*) AS tx_count
  FROM transactions
  WHERE purchase_time >= '2020-10-01'
    AND purchase_time < '2020-11-01'
  GROUP BY store_id
  HAVING COUNT(*) >= 5
) AS filtered_stores;



/* =====================================================================
   Q3. Shortest interval (in minutes) from purchase to refund per store
   Approach:
   - Consider only refunded rows (refund_time IS NOT NULL)
   - Compute TIMESTAMP difference in minutes
   - Take MIN per store
   ===================================================================== */
SELECT
  store_id,
  MIN(TIMESTAMPDIFF(MINUTE, purchase_time, refund_time)) AS min_minutes_to_refund
FROM transactions
WHERE refund_time IS NOT NULL
GROUP BY store_id
ORDER BY store_id;



/* =====================================================================
   Q4. Gross transaction value of each store’s first order
   Approach:
   - Rank purchases within each store by purchase_time (oldest first)
   - Select rn = 1 → first-ever order for each store
   ===================================================================== */
WITH ranked_store_orders AS (
  SELECT
    store_id,
    purchase_time,
    gross_transaction_value,
    ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY purchase_time ASC) AS rn
  FROM transactions
)
SELECT
  store_id,
  purchase_time AS first_purchase_time,
  gross_transaction_value AS first_order_gross_value
FROM ranked_store_orders
WHERE rn = 1
ORDER BY store_id;



/* =====================================================================
   Q5. Most popular item name that buyers order on their first purchase
   Approach:
   - Rank purchases per buyer (rn = 1 → first purchase)
   - Join items to obtain item_name
   - Count most frequently purchased item_name among first purchases
   ===================================================================== */
WITH buyer_first_purchase AS (
  SELECT
    t.*,
    ROW_NUMBER() OVER (PARTITION BY buyer_id ORDER BY purchase_time ASC) AS rn
  FROM transactions t
),
fp AS (
  SELECT * FROM buyer_first_purchase WHERE rn = 1
)
SELECT
  COALESCE(i.item_name, 'UNKNOWN') AS item_name,
  COUNT(*) AS times_ordered_on_first_purchase
FROM fp
LEFT JOIN items i
  ON fp.store_id = i.store_id
 AND fp.item_id = i.item_id
GROUP BY item_name
ORDER BY times_ordered_on_first_purchase DESC
LIMIT 1;



/* =====================================================================
   Q6. Create a flag indicating whether the refund can be processed
   Condition: refund_time must be within 72 hours of purchase_time
   Approach:
   - If refund_time IS NULL → cannot be processed
   - If TIMESTAMPDIFF(HOUR, purchase_time, refund_time) <= 72 → allowed
   ===================================================================== */
SELECT
  *,
  CASE
    WHEN refund_time IS NULL THEN 0
    WHEN TIMESTAMPDIFF(HOUR, purchase_time, refund_time) <= 72 THEN 1
    ELSE 0
  END AS refund_allowed_within_72hrs
FROM transactions
ORDER BY purchase_time;



/* =====================================================================
   Q7. Rank purchases per buyer and return ONLY the second purchase
      (Ignore refunded purchases)
   Approach:
   - Filter out refunded transactions
   - Rank purchases per buyer using ROW_NUMBER()
   - Select rn = 2 → second purchase
   ===================================================================== */
WITH ranked_non_refunded AS (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY buyer_id ORDER BY purchase_time ASC) AS purchase_rank
  FROM transactions
  WHERE refund_time IS NULL
)
SELECT
  buyer_id,
  purchase_time,
  store_id,
  item_id,
  gross_transaction_value
FROM ranked_non_refunded
WHERE purchase_rank = 2
ORDER BY buyer_id;



/* =====================================================================
   Q8. Find the second transaction time per buyer
       (Do NOT use MIN or MAX)
   Approach:
   - Use ROW_NUMBER() to sort purchases chronologically
   - Select rn = 2 → second transaction timestamp
   ===================================================================== */
WITH txn_rank AS (
  SELECT
    buyer_id,
    purchase_time,
    ROW_NUMBER() OVER (PARTITION BY buyer_id ORDER BY purchase_time ASC) AS rn
  FROM transactions
)
SELECT
  buyer_id,
  purchase_time AS second_purchase_time
FROM txn_rank
WHERE rn = 2
ORDER BY buyer_id;


/* ====================== END OF FILE ====================== */
