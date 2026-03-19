from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import text
from database import get_db

app = FastAPI(
    title="Cricket Analytics API",
    description="The FBref/Opta for T20 Cricket",
    version="1.0.0"
)

@app.get("/")
def read_root():
    return {"status": "online", "message": "Welcome to the Cricket Analytics Engine"}

# --- GOLD LAYER ENDPOINTS ---

@app.get("/api/v1/players/search")
def search_players(name: str, db: Session = Depends(get_db)):
    """Search for a player by name to get their exact Cricsheet Surrogate Key"""
    # Note: Adjust 'gold' schema name if your dbt configured it differently (e.g., gold_analytics)
    query = text("""
        SELECT player_key, player_name 
        FROM gold.dim_player 
        WHERE player_name ILIKE :search_term
        LIMIT 10
    """)
    result = db.execute(query, {"search_term": f"%{name}%"}).mappings().all()
    if not result:
        raise HTTPException(status_code=404, detail="Player not found")
    return {"results": result}

# --- MARTS LAYER (ADVANCED ANALYTICS) ENDPOINTS ---

@app.get("/api/v1/analytics/dbpi/{player_key}")
def get_player_dbpi(player_key: str, db: Session = Depends(get_db)):
    """Get the Dot Ball Pressure Index (Clutch Score) for a specific player"""
    query = text("""
        SELECT player_name, total_balls_faced, pressure_situations_faced, dbpi_score
        FROM marts.mart_dot_ball_pressure
        WHERE batter_key = :player_key
    """)
    result = db.execute(query, {"player_key": player_key}).mappings().first()
    if not result:
        raise HTTPException(status_code=404, detail="No DBPI data for this player")
    return dict(result)

@app.get("/api/v1/analytics/true_strike_rate/{player_key}")
def get_player_tsr(player_key: str, db: Session = Depends(get_db)):
    """Get the Phase-Adjusted True Strike Rate for a player"""
    query = text("""
        SELECT match_phase, balls_faced, player_strike_rate, true_strike_rate_value
        FROM marts.mart_true_strike_rate
        WHERE batter_key = :player_key
        ORDER BY match_phase
    """)
    results = db.execute(query, {"player_key": player_key}).mappings().all()
    if not results:
        raise HTTPException(status_code=404, detail="No TSR data for this player")
    return {"player_key": player_key, "phase_stats": results}