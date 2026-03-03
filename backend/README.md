# Grocery Store ML Backend

This directory contains the backend services for the smart grocery store application with ML-powered demand prediction and dynamic pricing.

## Structure

```
backend/
├── api/                    # REST API server
│   ├── routes/            # API route handlers
│   ├── middleware/        # Authentication, validation
│   ├── models/           # Database models
│   └── controllers/      # Business logic
├── ml/                    # Machine Learning services
│   ├── demand_prediction/ # Demand forecasting models
│   ├── pricing/          # Dynamic pricing algorithms
│   ├── training/         # Model training scripts
│   └── inference/        # Model serving endpoints
├── database/              # Database setup and migrations
├── config/               # Configuration files
└── docker/               # Docker configurations
```

## Setup Instructions

1. **Install Dependencies**
   ```bash
   cd backend
   pip install -r requirements.txt
   ```

2. **Database Setup**
   ```bash
   # Start PostgreSQL (using Docker)
   docker-compose up -d postgres
   
   # Run migrations
   python manage.py migrate
   ```

3. **ML Model Setup**
   ```bash
   # Download pre-trained models (if available)
   python ml/download_models.py
   
   # Or train from scratch
   python ml/training/train_demand_model.py
   python ml/training/train_pricing_model.py
   ```

4. **Start Services**
   ```bash
   # Start API server
   python api/server.py
   
   # Start ML inference service
   python ml/inference/serve_models.py
   ```

## API Endpoints

### Machines
- `GET /api/v1/stores` - List all grocery stores
- `GET /api/v1/machines/{id}` - Get machine details
- `GET /api/v1/machines/{id}/products` - Get products in machine

### Products
- `GET /api/v1/products` - List all products
- `GET /api/v1/products/{id}` - Get product details

### Orders
- `POST /api/v1/orders` - Create new order
- `GET /api/v1/orders/{id}` - Get order details
- `POST /api/v1/orders/{id}/confirm` - Confirm payment

### ML Predictions
- `GET /api/v1/ml/predictions/demand` - Get demand forecasts
- `GET /api/v1/ml/predictions/pricing` - Get pricing suggestions
- `POST /api/v1/ml/predictions/feedback` - Submit actual sales data

### Admin
- `GET /api/v1/admin/dashboard` - Get dashboard KPIs
- `GET /api/v1/admin/machines/{id}/analytics` - Machine analytics
- `POST /api/v1/admin/restock` - Create restock recommendations

## Environment Variables

Create a `.env` file in the backend directory:

```env
# Database
DATABASE_URL=postgresql://user:password@localhost:5432/grocery_store_ml

# API
API_HOST=0.0.0.0
API_PORT=3000
SECRET_KEY=your-secret-key

# ML Models
MODEL_PATH=./ml/models
PREDICTION_BATCH_SIZE=100

# Payment Integration
RAZORPAY_KEY_ID=your-razorpay-key
RAZORPAY_KEY_SECRET=your-razorpay-secret

# Redis (for caching)
REDIS_URL=redis://localhost:6379

# Monitoring
SENTRY_DSN=your-sentry-dsn
```

## ML Features

### Demand Prediction
- Uses XGBoost for short-term demand forecasting
- Features: historical sales, time patterns, weather, events
- Outputs: daily demand prediction, stockout probability

### Dynamic Pricing
- Rule-based system with ML optimization
- Considers: current stock, expiry dates, demand forecast
- Safety constraints: minimum margins, approval requirements

### Model Training
- Automated retraining pipeline
- A/B testing framework for pricing experiments
- Performance monitoring and drift detection

## Docker Support

```bash
# Build and run all services
docker-compose up --build

# Run specific services
docker-compose up api ml-service postgres redis
```

## Testing

```bash
# Run API tests
pytest api/tests/

# Run ML model tests
pytest ml/tests/

# Run integration tests
pytest tests/integration/
```

## Monitoring

- API metrics via Prometheus
- Model performance tracking
- Business KPI monitoring
- Error tracking with Sentry

## Development

1. **Code Style**
   - Use Black for Python formatting
   - Follow PEP 8 guidelines
   - Use type hints

2. **Git Workflow**
   - Feature branches for new development
   - Pull requests for code review
   - Automated CI/CD pipeline

3. **Testing**
   - Unit tests for all functions
   - Integration tests for APIs
   - ML model validation tests

## Production Deployment

1. **Infrastructure**
   - Kubernetes cluster recommended
   - Separate databases for production
   - Load balancers for API scaling

2. **ML Pipeline**
   - Scheduled model retraining
   - A/B testing infrastructure
   - Model versioning and rollback

3. **Security**
   - API authentication and authorization
   - Data encryption at rest and in transit
   - Regular security audits

## Troubleshooting

### Common Issues

1. **Model Loading Errors**
   - Check model file paths
   - Verify model compatibility
   - Check dependencies

2. **Database Connection Issues**
   - Verify database is running
   - Check connection string
   - Validate credentials

3. **API Performance**
   - Check database queries
   - Monitor Redis cache hit rates
   - Profile API endpoints

For more detailed information, see individual README files in each subdirectory.