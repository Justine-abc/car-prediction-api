# car-prediction-api
# Vehicle CO2 Emission Predictor

## Mission & Problem
This project aims to help conscious car buyers estimate the environmental impact of vehicles before purchase. By analyzing engine size, cylinders, and fuel consumption, the system predicts CO2 emissions (g/km) to encourage the selection of more eco-friendly transportation options.

## API Endpoint (Swagger UI)
**Public URL:** https://car-prediction-api.onrender.com/docs
*Use this link to test the API predictions and validation constraints.*

## Mobile App Instructions
To run the Flutter mobile application:
1. Ensure you have Flutter installed on your machine.
2. Navigate to the `car_emission_app` directory.
3. Run `flutter pub get` to install dependencies (specifically the "http" package).
4. Run the app using the command: `flutter run -d windows` (recommended for testing) or `flutter run -d chrome` or use flutter run, and choose 1 for windows, 2 for chrome.
5. Enter the Engine Size (e.g., 2.4), Cylinders (e.g., 4), and Fuel Consumption (e.g., 8.5) and click "Predict".

## Video Demo

## Project Structure
* **linear_regression/**: Contains the `multivariate.ipynb` notebook used for data cleaning, visualization, and model training.
* **API/**: Contains the FastAPI backend code (`prediction.py`), the trained model (`best_model.pkl`), and the scaler (`scaler.pkl`).
* **FlutterApp/**: Contains the source code for the mobile application.
