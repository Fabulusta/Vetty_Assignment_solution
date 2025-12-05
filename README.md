# Vetty_Assignment_solution
This is my Vetty Assignment Solution.
# Vettty SQL Assignment – Complete Solutions (MySQL)

This repository contains my SQL solutions for the Vettty Technical Assessment.  
All queries are written and tested in *MySQL 8+* using the snapshot dataset provided in the assignment.

---

## 📂 Dataset Description

The assessment provided two tables:

### *1️⃣ transactions*
| Column | Description |
|--------|-------------|
| buyer_id | Buyer ID |
| purchase_time | Purchase timestamp |
| refund_time | Refund timestamp (NULL if not refunded) |
| refund_item | Snapshot column label (contains refund timestamp text) |
| store_id | Store identifier |
| item_id | Item identifier |
| gross_transaction_value | Transaction amount |

### *2️⃣ items*
| Column | Description |
|--------|-------------|
| store_id | Store identifier |
| item_id | Item identifier |
| item_category | Category of the item |
| item_name | Name of the item |

The dataset was recreated exactly as shown in the snapshot.

---

## 📝 Assumptions
- refund_time IS NOT NULL indicates a refunded transaction.  
- MySQL version *8+* is used for ROW_NUMBER() and window functions.  
- Refund validity condition:  
  > refund_time − purchase_time ≤ 72 hours  
- No external data sources used; only snapshot rows.

---

