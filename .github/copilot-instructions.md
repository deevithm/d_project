# Vending ML App - Copilot Instructions

## Project Overview
This is a comprehensive Flutter mobile application for smart vending machines with ML-powered demand prediction and dynamic pricing. The project includes:

### 🛒 Customer Mobile App
- Smart machine discovery with location services
- Product browsing with real-time inventory
- Dynamic pricing based on demand prediction
- Secure payment integration (Razorpay)
- Order tracking and history

### 👨‍💼 Admin Dashboard
- Real-time inventory management
- Sales analytics and insights
- Machine status monitoring
- Revenue optimization tools

### 🤖 ML-Powered Backend
- XGBoost demand prediction models
- Dynamic pricing algorithms
- Inventory management automation
- Customer behavior analytics

## Project Structure

### Frontend (Flutter)
- **Framework**: Flutter 3.32.7 with Material 3 design
- **State Management**: Provider pattern with ChangeNotifier
- **Navigation**: GoRouter for declarative routing
- **Architecture**: Feature-based modular organization

### Key Features Implemented
- Machine selection and discovery
- Product browsing with filtering
- Shopping cart management
- Payment processing workflow
- Admin dashboard with analytics
- Order history and tracking

### Backend Services
- Node.js REST API with PostgreSQL database
- ML inference services for demand prediction
- Real-time inventory management
- Payment processing integration

### ML Components
- Demand forecasting with XGBoost
- Dynamic pricing optimization
- Predictive inventory management
- Customer behavior analysis

## Development Guidelines

### Code Organization
```
lib/
├── core/                    # Core app components and models
├── features/               # Feature-based modules
├── shared/                 # Shared services and widgets
└── main.dart              # Application entry point
```

### State Management
- Use Provider pattern for app-wide state
- ChangeNotifier for reactive updates
- AppState service for centralized state management

### Navigation
- GoRouter for type-safe navigation
- Path parameters for dynamic routing
- Named routes for maintainability

### UI/UX Principles
- Material 3 design system
- Responsive layouts for multiple screen sizes
- Accessibility support
- Loading states and error handling

## Technical Stack

### Dependencies
- **UI**: material_design_icons_flutter, flutter_svg, cached_network_image
- **State**: provider
- **Navigation**: go_router
- **Networking**: http, dio, connectivity_plus
- **Storage**: shared_preferences, sqflite
- **Location**: geolocator, permission_handler
- **Payment**: razorpay_flutter
- **QR/Camera**: qr_code_scanner, qr_flutter, image_picker
- **Charts**: fl_chart
- **ML**: tflite_flutter
- **Utils**: intl, uuid, logger

### Development Tools
- Flutter/Dart extensions for VS Code
- tasks.json for build/run automation
- Comprehensive test suite

## Setup and Launch Instructions

### Quick Start
1. Run `flutter pub get` to install dependencies
2. Use VS Code Command Palette → "Tasks: Run Task" → "Flutter Run"
3. For backend services: "Start Backend Server" task

### Available VS Code Tasks
- **Flutter Run**: Launch app with hot reload
- **Flutter Build APK**: Create release build
- **Flutter Test**: Run test suite
- **Flutter Clean**: Clean build artifacts
- **Flutter Pub Get**: Install dependencies
- **Start Backend Server**: Launch backend services

### Development Workflow
1. Start backend services (if available)
2. Launch Flutter app in debug mode
3. Use hot reload for rapid development
4. Run tests regularly during development

## Project Status: ✅ COMPLETE

### ✅ Completed Components
- [x] Project scaffolding and structure
- [x] Core models and constants
- [x] State management implementation
- [x] All feature screens implemented
- [x] Navigation routing configured
- [x] Dependencies installed and configured
- [x] VS Code tasks and launch configuration
- [x] Comprehensive documentation
- [x] Backend API documentation
- [x] ML pipeline documentation

### 🚀 Ready for Development
The project is fully set up and ready for:
- Feature development and enhancement
- Backend integration
- ML model integration
- Payment gateway configuration
- Production deployment

### 📚 Documentation
- Complete README.md with setup instructions
- Backend API documentation in `backend/README.md`
- ML pipeline documentation in `ml_models/README.md`
- Code comments and inline documentation

## Next Steps for Development
1. Configure API endpoints in `lib/core/constants.dart`
2. Set up backend services following `backend/README.md`
3. Configure payment gateway credentials
4. Set up ML model endpoints
5. Test on physical devices
6. Configure app signing for release builds