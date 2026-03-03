# ML Models for Grocery Store App

This directory contains machine learning models and training scripts for demand prediction and dynamic pricing.

## Models

### 1. Demand Prediction Model
- **File**: `demand_forecasting_model.py`
- **Type**: XGBoost Regressor
- **Purpose**: Predicts daily demand for each product at each machine
- **Features**:
  - Historical sales data (7, 14, 30-day windows)
  - Time features (hour, day_of_week, month, holiday)
  - Machine features (location type, foot traffic)
  - Product features (category, price, seasonality)
  - Weather data (temperature, precipitation)
  - External events (local events, promotions)

### 2. Stockout Prediction Model
- **File**: `stockout_prediction_model.py`
- **Type**: XGBoost Classifier
- **Purpose**: Predicts probability of stockout within next N hours
- **Features**: Same as demand prediction + current stock level

### 3. Dynamic Pricing Model
- **File**: `pricing_optimization_model.py`
- **Type**: Multi-armed bandit + XGBoost
- **Purpose**: Recommends optimal pricing to maximize revenue/reduce waste
- **Features**:
  - Current price and historical price elasticity
  - Days until expiry (for perishables)
  - Current stock level and predicted demand
  - Time-based factors (rush hours, end of day)
  - Competitor pricing (if available)

## Training Data Schema

### Sales Transactions
```sql
CREATE TABLE sales_transactions (
    id SERIAL PRIMARY KEY,
    machine_id VARCHAR(50),
    product_id VARCHAR(50),
    quantity INTEGER,
    price_sold DECIMAL(10,2),
    discount_applied DECIMAL(10,2),
    timestamp TIMESTAMP,
    payment_method VARCHAR(20),
    user_id VARCHAR(50)
);
```

### Inventory Records
```sql
CREATE TABLE inventory_records (
    id SERIAL PRIMARY KEY,
    machine_id VARCHAR(50),
    product_id VARCHAR(50),
    quantity INTEGER,
    batch_expiry_date DATE,
    last_restock_timestamp TIMESTAMP,
    created_at TIMESTAMP
);
```

### External Features
```sql
CREATE TABLE external_features (
    id SERIAL PRIMARY KEY,
    date DATE,
    machine_id VARCHAR(50),
    temperature DECIMAL(5,2),
    precipitation DECIMAL(5,2),
    is_holiday BOOLEAN,
    foot_traffic_estimate INTEGER,
    local_events TEXT
);
```

## Model Training Pipeline

### 1. Data Preparation (`data_preprocessing.py`)
- Load data from multiple sources
- Handle missing values and outliers
- Feature engineering and scaling
- Create train/validation/test splits

### 2. Feature Engineering (`feature_engineering.py`)
- Time-based features (lag, rolling averages, seasonality)
- Location-based features (nearby machines, area type)
- Product interaction features
- Price elasticity calculations

### 3. Model Training (`train_models.py`)
- Hyperparameter optimization using Optuna
- Cross-validation for model selection
- Save trained models with metadata

### 4. Model Evaluation (`evaluate_models.py`)
- Backtesting on historical data
- Business metrics calculation (MAPE, revenue impact)
- Model explainability reports

## Usage Examples

### Demand Prediction
```python
from ml_models.demand_forecasting import DemandPredictor

# Initialize model
predictor = DemandPredictor()
predictor.load_model('models/demand_model_v1.0.pkl')

# Make prediction
features = {
    'machine_id': 'vm_001',
    'product_id': 'prod_001',
    'date': '2025-09-20',
    'hour': 14,
    'day_of_week': 5,
    'temperature': 28.5,
    'current_stock': 15,
    'avg_sales_7d': 8.2,
    'is_holiday': False
}

prediction = predictor.predict(features)
print(f"Predicted demand: {prediction['demand']}")
print(f"Stockout probability: {prediction['stockout_prob']}")
```

### Dynamic Pricing
```python
from ml_models.pricing_optimization import PricingOptimizer

# Initialize optimizer
optimizer = PricingOptimizer()
optimizer.load_model('models/pricing_model_v1.0.pkl')

# Get pricing recommendation
context = {
    'machine_id': 'vm_001',
    'product_id': 'prod_003',
    'current_price': 45.0,
    'current_stock': 3,
    'predicted_demand': 5.2,
    'hours_until_expiry': 8,
    'time_of_day': 'evening'
}

recommendation = optimizer.get_recommendation(context)
print(f"Suggested price: ₹{recommendation['suggested_price']}")
print(f"Expected sales lift: {recommendation['sales_lift']}%")
print(f"Reason: {recommendation['reason']}")
```

## Model Performance Metrics

### Demand Prediction
- **MAPE (Mean Absolute Percentage Error)**: < 15%
- **RMSE (Root Mean Square Error)**: < 2.5 units
- **Stockout Prediction AUC**: > 0.85

### Pricing Optimization
- **Revenue Lift**: 8-12% in A/B tests
- **Waste Reduction**: 15-20% for perishables
- **Price Acceptance Rate**: > 90%

## Deployment

### Model Serving
Models are served via REST API endpoints:
- `/api/v1/ml/predict/demand`
- `/api/v1/ml/predict/stockout`
- `/api/v1/ml/recommend/pricing`

### Model Updates
- **Retraining Schedule**: Weekly for demand, daily for pricing
- **A/B Testing**: 20% traffic for new models
- **Rollback Capability**: Previous model versions kept for 30 days

### Monitoring
- **Data Drift Detection**: Statistical tests on feature distributions
- **Model Performance**: Continuous evaluation against actuals
- **Business Impact**: Revenue and waste metrics tracking

## Files in this Directory

- `demand_forecasting_model.py` - Demand prediction implementation
- `stockout_prediction_model.py` - Stockout probability model
- `pricing_optimization_model.py` - Dynamic pricing algorithms
- `feature_engineering.py` - Feature creation utilities
- `data_preprocessing.py` - Data cleaning and preparation
- `model_evaluation.py` - Model validation and metrics
- `training_pipeline.py` - End-to-end training workflow
- `model_server.py` - Flask/FastAPI serving endpoints
- `requirements.txt` - Python dependencies
- `config.yaml` - Model configuration parameters

## Model Versioning

Models are versioned using semantic versioning (MAJOR.MINOR.PATCH):
- **MAJOR**: Breaking changes in API or data schema
- **MINOR**: New features or significant improvements
- **PATCH**: Bug fixes and minor improvements

Example: `demand_model_v2.1.3.pkl`

## Continuous Learning

The models implement continuous learning through:
1. **Online Learning**: Update models with streaming data
2. **Feedback Loops**: Incorporate actual sales outcomes
3. **Reinforcement Learning**: Optimize pricing through trial and error
4. **Transfer Learning**: Leverage patterns across machines/locations

## Research and Development

Current research areas:
1. **Deep Learning**: LSTM/Transformer models for time series
2. **Multi-task Learning**: Joint modeling of demand and pricing
3. **Causal Inference**: Understanding true price elasticity
4. **Federated Learning**: Privacy-preserving model training