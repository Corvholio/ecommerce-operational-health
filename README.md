# ecommerce-operational-health

## Overview
This project demonstrates how to monitor and prioritize operational health in an e-commerce environment using focused, grain-specific analytics views.

Rather than building a single catch-all dashboard, the project intentionally separates **system-level monitoring** from **category-level prioritization**. Each dashboard is designed around a specific analytical question and operates at the grain most appropriate to that question.

The goal is not to diagnose root causes or calculate profitability, but to surface **where attention is most justified** based on customer exposure and operational signals.

---

## Dataset
The project uses the Olist e-commerce dataset, which includes:
- Orders and order items
- Product and category information
- Delivery timestamps
- Customer review scores

The data is stored in SQLite and transformed using SQL views.

---

## Dashboards

### 1. Executive Commerce Health
**Purpose**  
Monitor overall platform health by tracking order volume, fulfillment performance, and customer sentiment over time.

**Grain**  
- Monthly (system-level aggregation)

**Key Metrics**
- Valid order volume
- Gross merchandise value (GMV)
- Delivery completion rate
- On-time delivery rate
- Average review score

**Design Notes**
- This dashboard is designed for **monitoring**, not diagnosis.
- GMV is used as a proxy for customer value exposure, not profit.
- The view prioritizes early signals over detailed explanations.

**Question Answered**
> “Are there system-level signals indicating a change in operational health?”

---

### 2. Product Category Health
**Purpose**  
Prioritize which product categories warrant attention by comparing customer exposure with relative fulfillment performance.

**Grain**
- Product category (one row per category, aggregated across all associated orders)

**Scope**
- View is filtered to the highest-volume product categories to maintain focus.
- Ranking is computed across all categories to preserve global context.

**Key Metrics**
- Total orders
- Total GMV
- On-time delivery rate
- Average review score

**Design Notes**
- Relative performance is emphasized over absolute thresholds.
- Review scores are included as contextual validation, not primary alarms.
- The dashboard highlights where small fulfillment gaps may have outsized customer impact.

**Question Answered**
> “Among the categories that matter most, where should we look first?”

---

## Design Principles
- **Single-grain dashboards:** Each view operates at a consistent grain to avoid ambiguity.
- **Focused scope:** Dashboards are not catch-all reporting tools.
- **Separation of concerns:** Monitoring and prioritization are intentionally separated.
- **Impact-weighted analysis:** Attention follows customer exposure, not raw counts.
- **Honest limitations:** No assumptions are made about profit, causality, or root causes.

---

## Tools Used
- SQLite
- SQL (CTEs, aggregations, window functions)
- Tableau Public

---

## Limitations
- GMV does not account for costs, margins, refunds, or penalties.
- Review scores represent sentiment but not causal explanations.
- Root cause analysis (logistics, sellers, geography) is out of scope by design.

---

## Why This Matters
In real production environments, dashboards are most effective when they are focused, interpretable, and aligned to specific decisions.

This project reflects how analytics teams typically operate:
- monitor first,
- prioritize second,
- diagnose separately.

---

## Project Structure
├── data/

│ ├── raw/

│ └── exports/

├── sql/

│ ├── executive_health_view.sql

│ └── product_category_health_view.sql

├── dashboards/

│ ├── executive_health_dashboard.png

│ └── product_category_health_dashboard.png

└── README.md
