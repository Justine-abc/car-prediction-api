from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
import joblib
import numpy as np
import pandas as pd
from fastapi.middleware.cors import CORSMiddleware
import os

# 1. Initialize the App
app = FastAPI()

# 2. Add CORS (Rubric Requirement)
# This allows your Flutter app to talk to this API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 3. Load the Model and Scaler
# We use try/except to give a clear error if files are missing
try:
    model = joblib.load('best_model.pkl')
    scaler = joblib.load('scaler.pkl')
    print("Model and Scaler loaded successfully!")
except Exception as e:
    print(f"Error loading model files: {e}")
    model = None
    scaler = None

# 4. Define Input Data Structure (Rubric Requirement: Pydantic & Constraints)
class CarInput(BaseModel):
    # Field(..., gt=0, le=10) ensures Engine Size is between 0 and 10 Liters
    engine_size: float = Field(..., gt=0, le=10, description="Engine Size in Liters (e.g., 2.4)")
    
    # Cylinders must be between 2 and 16
    cylinders: int = Field(..., gt=2, le=16, description="Number of Cylinders (e.g., 4)")
    
    # Fuel Consumption must be between 1 and 50 L/100km
    fuel_consumption: float = Field(..., gt=1, le=50, description="Fuel Consumption Combined (e.g., 8.5)")

# 5. Create the Prediction Endpoint
@app.post("/predict")
def predict_emissions(input_data: CarInput):
    if model is None or scaler is None:
        raise HTTPException(status_code=500, detail="Model not loaded. Check server logs.")

    try:
        # Convert input to the format the model expects: [[Engine, Cylinders, Fuel]]
        features = np.array([[input_data.engine_size, input_data.cylinders, input_data.fuel_consumption]])
        
        # Standardize the data using the loaded scaler (CRITICAL STEP)
        features_scaled = scaler.transform(features)
        
        # Make prediction
        prediction = model.predict(features_scaled)
        
        # Return the result
        return {
            "predicted_co2": float(prediction[0]),
            "message": "Prediction successful"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 6. Root endpoint for testing
@app.get("/")
def read_root():
    return {"message": "CO2 Prediction API is Running!"}