# 🏏 Cricket Intelligence Platform (The "Opta" of T20 Cricket)

![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![dbt](https://img.shields.io/badge/dbt-FF694B?style=for-the-badge&logo=dbt&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=FastAPI&logoColor=white)
![XGBoost](https://img.shields.io/badge/XGBoost-172B4D?style=for-the-badge&logo=xgboost&logoColor=white)

An end-to-end Machine Learning and Data Engineering monorepo designed to provide broadcast-quality, ball-by-ball cricket analytics. This platform ingests raw Cricsheet JSON data, transforms it through a modern ELT pipeline, engineers advanced sabermetric features, and serves them via a lightning-fast REST API.

## 🏗️ System Architecture

This project is built using a decoupled microservices architecture:

1. **`data_ingestion/`**: Custom Python extractors and PostgreSQL loaders that process raw nested JSONs into a local S3-style Data Lake and load them into a `bronze` schema.
2. **`data_warehouse/`**: A `dbt` project handling ELT. It utilizes defensive surrogate key hashing (`cricsheet_id`) for identity resolution and builds advanced `marts` using complex SQL window functions.
3. **`api/`**: A **FastAPI** application that connects directly to the dbt warehouse, exposing the Gold dimensions and advanced analytics as fully documented REST endpoints.
4. **`ml_pipeline/`**: *(In Progress)* An isolated environment to train an XGBoost model on the `feature_store.fct_delivery_state` table to predict live, ball-by-ball Win Probability.

---

## ☁️ Enterprise Cloud Migration Strategy 

To match the low-latency, high-availability standards of live sports data providers (like Opta/Sportradar), this local architecture is designed to be easily lifted and shifted to the cloud.

* **Data Lake (AWS S3 / GCS):** Transition the local `data/lake/` folder to partitioned cloud storage buckets (`s3://cricket-data-lake/bronze/season=2026/`).
* **Orchestration (Apache Airflow):** Replace local terminal execution with Airflow DAGs to trigger ingestion, dbt models, and model retraining automatically upon the completion of a match.
* **Cloud Data Warehouse (Amazon Redshift / Snowflake):** Migrate the local PostgreSQL engine to a scalable columnar data warehouse for faster analytical queries.
* **Serving Layer (AWS ECS / Fargate):** Containerize the FastAPI application using Docker and deploy it to a serverless compute engine to handle traffic spikes during live IPL matches.

---

## ⚡ API Reference & Live Documentation

The platform serves analytical data via FastAPI. When running locally, full interactive documentation (Swagger UI) is automatically generated and available at `http://127.0.0.1:8000/docs`.

### Featured Endpoints:

#### 1. Identity Resolution
```http
GET /api/v1/players/search?name=Dhoni
```
*Returns the globally unique surrogate key for a player, resolving name discrepancies across historical data.*

#### 2. Dot Ball Pressure Index (DBPI)
```http
GET /api/v1/analytics/dbpi/{player_key}
```
*Returns the DBPI score—a custom metric measuring a batter's boundary-to-wicket ratio when facing 3+ consecutive dot balls (identifying "Ice Men" vs. "Front-Runners").*

#### 3. Phase-Adjusted True Strike Rate
```http
GET /api/v1/analytics/true_strike_rate/{player_key}
```
*Returns a player's strike rate differential against the historical global average for specific match phases (Powerplay, Middle Overs, Death Overs).*

---

## 🚀 Local Setup & Quick Start

Because this is a decoupled monorepo, each microservice manages its own virtual environment to prevent dependency conflicts.

**1. Clone the repository**
```bash
git clone https://github.com/YOUR_USERNAME/cricket-intelligence-platform.git
cd cricket-intelligence-platform
```

**2. Set up the Database & dbt**
```bash
cd data_warehouse
python -m venv venv
source venv/bin/activate  # (Or .\venv\Scripts\activate on Windows)
pip install -r requirements.txt
dbt deps
dbt build
deactivate
```

**3. Launch the API**
```bash
cd ../api
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload
```
Navigate to `http://127.0.0.1:8000/docs` in your browser to test the API endpoints.

---

## 🧠 Core Features Engineered

* **Cricsheet JSON Identity Extraction:** Bypassed expensive text-matching joins by extracting immutable registry IDs directly from the raw JSON payload using Postgres JSONB indexing.
* **Temporal Target Leakage Prevention:** Built anti-leakage rolling windows (`rows between 5 preceding and 1 preceding`) to calculate historical player form prior to model training.
* **Idempotent Batch Design:** The architecture supports seamless daily batch ingestion for new IPL seasons without requiring downtime for the API serving layer.

---

## 🗺️ Project Roadmap

- [x] **Phase 1:** Core ELT pipeline and API serving layer.
- [x] **Phase 2:** Advanced sabermetric feature engineering (DBPI, TSR).
- [ ] **Phase 3 (Current):** Train XGBoost Live Win Probability model on delivery-state data.
- [ ] **Phase 4:** Deploy automated daily batch ingestion via Airflow.
- [ ] **Phase 5:** Build a Streamlit frontend dashboard for live match tracking.