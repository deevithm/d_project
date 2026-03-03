# Snackly

A smart grocery store mobile application with ML-powered demand prediction and dynamic pricing.

## Features

### 🛒 Customer App
- **Smart Store Discovery**: Find nearby Snackly grocery stores with location services
- **Product Browsing**: Browse products with real-time inventory and dynamic pricing
- **Smart Cart**: Intelligent shopping cart with quantity limits and recommendations
- **Payment Integration**: Secure payments via Razorpay (UPI, Card, Wallet, QR)
- **Order Tracking**: Real-time order status and history

### 👨‍💼 Admin Dashboard
- **Inventory Management**: Real-time stock monitoring and alerts
- **Analytics**: Sales analytics with charts and insights
- **Store Monitoring**: Status tracking for multiple grocery stores
- **Revenue Insights**: Dynamic pricing impact and revenue optimization

### 🤖 ML-Powered Features
- **Demand Prediction**: XGBoost models predict product demand
- **Dynamic Pricing**: AI-optimized pricing based on demand, inventory, and time
- **Stock Alerts**: Predictive inventory management
- **Customer Behavior**: Analytics for purchasing patterns

### 🔧 Technical Stack
- **Frontend**: Flutter 3.32.7 with Material 3 design
- **State Management**: Provider pattern
- **Navigation**: GoRouter for declarative routing
- **Backend**: Node.js REST API with PostgreSQL
- **ML Pipeline**: XGBoost for demand prediction and pricing
- **Payment**: Razorpay integration
- **Location**: GPS-based store discovery with Google Maps
- **QR Codes**: Quick store identification

## Getting Started

### Prerequisites
- Flutter SDK 3.8.1+
- Dart SDK 3.8.1+
- Android Studio or VS Code
- Node.js 16+ (for backend)
- PostgreSQL (for database)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd grocery_store_app
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up backend (optional for development)**
   ```bash
   cd backend
   npm install
   ```

4. **Configure environment**
   - Update `lib/core/constants.dart` with your API endpoints
   - Configure Razorpay keys for payment integration
   - Set up location permissions in `android/app/src/main/AndroidManifest.xml`
   - Configure Google Maps API key for store location services

### Running the App

#### Using VS Code Tasks
1. Open Command Palette (`Ctrl+Shift+P`)
2. Run `Tasks: Run Task`
3. Select from available tasks:
   - **Flutter Run**: Launch the app with hot reload
   - **Flutter Build APK**: Build release APK
   - **Flutter Test**: Run unit tests
   - **Start Backend Server**: Launch backend services

#### Using Terminal
```bash
# Run in debug mode with hot reload
flutter run

# Build release APK
flutter build apk --release

# Run tests
flutter test

# Clean build files
flutter clean
```

#### Device Setup
- **Android**: Enable USB debugging and connect device
- **iOS**: Set up development team in Xcode
- **Web**: Use `flutter run -d chrome`
- **Desktop**: Use `flutter run -d windows/macos/linux`

### Development Workflow

1. **Start Backend Services** (if available)
   ```bash
   cd backend
   npm start
   ```

2. **Launch Flutter App**
   ```bash
   flutter run
   ```

3. **Hot Reload**: Save files to trigger automatic reload
4. **Hot Restart**: Press `R` in terminal for full restart

## Project Structure

```
lib/
├── core/                    # Core application components
│   ├── constants.dart       # App constants and configuration
│   └── models/             # Data models
├── features/               # Feature-based organization
│   ├── store_selection/    # Grocery store discovery and selection
│   ├── product_browsing/   # Product catalog and browsing
│   ├── shopping_cart/      # Cart management
│   ├── checkout/           # Payment and order processing
│   ├── order_history/      # Order tracking and history
│   └── admin_dashboard/    # Admin interface
├── shared/                 # Shared components
│   ├── services/           # State management and services
│   └── widgets/            # Reusable UI components
└── main.dart              # Application entry point

backend/                   # Backend API services
ml_models/                # Machine learning models and scripts
```

## Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

## Building for Production

### Android
```bash
# Build release APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

### iOS
```bash
# Build for iOS
flutter build ios --release
```

### Web
```bash
# Build for web
flutter build web --release
```

## Backend Services

The app connects to a Node.js backend that provides:
- **REST API**: Product catalog, inventory, orders
- **ML Services**: Demand prediction and pricing optimization
- **Real-time Updates**: WebSocket connections for live data
- **Payment Processing**: Secure payment handling
- **Store Management**: Grocery store locations and inventory

See `backend/README.md` for detailed setup instructions.

## ML Models

The application uses machine learning for:
- **Demand Forecasting**: Predicts product demand using historical data
- **Dynamic Pricing**: Optimizes prices based on demand and inventory
- **Inventory Management**: Predictive restocking recommendations

See `ml_models/README.md` for model details and training procedures.

## Configuration

### Environment Variables
Update `lib/core/constants.dart`:
```dart
static const String baseUrl = 'https://your-api-domain.com/api/v1';
static const String razorpayKeyId = 'YOUR_RAZORPAY_KEY_ID';
```

### Permissions
Ensure required permissions in `android/app/src/main/AndroidManifest.xml`:
- `ACCESS_FINE_LOCATION`: For grocery store discovery
- `CAMERA`: For QR code scanning
- `INTERNET`: For API communication
- `ACCESS_NETWORK_STATE`: For network status

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Support

For support and questions:
- Check the documentation in `backend/README.md` and `ml_models/README.md`
- Review the Flutter documentation: https://docs.flutter.dev/
- Open an issue for bugs or feature requests

## License

This project is licensed under the MIT License - see the LICENSE file for details.
