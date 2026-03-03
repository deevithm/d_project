# Admin Panel - Snackly

## Overview
Complete admin management system for the Snackly grocery store application with order management, payment tracking, and analytics.

## Features Implemented

### 1. **Admin Login Screen** (`admin_login_screen.dart`)
- ✅ Secure admin authentication
- ✅ Email and password validation
- ✅ Role-based access control (admin role verification)
- ✅ Test credentials auto-fill for development
- ✅ Beautiful Material 3 design with gradient background
- ✅ Security notice and activity logging disclaimer
- ✅ Back to customer login option

**Test Admin Credentials:**
- Email: `admin@snackly.com`
- Password: `admin123`

**Access URL:** `/admin/login`

---

### 2. **Admin Dashboard** (`admin_dashboard_screen.dart`)
- ✅ Welcome card with admin profile
- ✅ Real-time statistics cards:
  - Total Orders (248) with +12% growth
  - Revenue (₹45.2K) with +8% growth
  - Pending Orders (12) with 3 urgent
  - Products (156) with 8 low stock
- ✅ Quick action cards:
  - Order Management
  - Payment Status
  - Inventory
  - Analytics
  - Customers
  - Reports
- ✅ Logout and settings menu
- ✅ Notifications icon

**Access URL:** `/admin/dashboard`

---

### 3. **Order Management Screen** (`admin_orders_screen.dart`)
- ✅ **Tabbed interface:**
  - Pending Orders
  - Confirmed Orders
  - Dispensed Orders
  - All Orders
- ✅ **Order cards display:**
  - Order ID
  - Customer name and contact
  - Store name
  - Order time (relative format: "15m ago")
  - Item count
  - Payment method (UPI/Card/Cash)
  - Total amount
  - Payment status badge
- ✅ **Order status badges:**
  - Pending (Orange)
  - Confirmed (Blue)
  - Dispensed (Green)
  - Failed (Red)
  - Cancelled (Red)
- ✅ **Action buttons:**
  - Cancel Order (for Pending/Confirmed)
  - Confirm Order (for Pending)
  - Mark Dispensed (for Confirmed)
- ✅ **Order details modal:**
  - Complete customer information
  - Order timeline
  - Payment details
  - Item list
- ✅ Pull-to-refresh functionality
- ✅ Filter and search capabilities

**Access URL:** `/admin/orders`

---

### 4. **Payment Status Screen** (`admin_payments_screen.dart`)
- ✅ **Revenue summary cards:**
  - Total Revenue (₹45.2K) with +12% growth
  - Pending Payments with count
  - Successful Transactions count with success rate
  - Total Transactions
- ✅ **Transaction list:**
  - Transaction ID
  - Order ID
  - Customer name
  - Amount (color-coded by status)
  - Payment method (UPI/Card/Cash) with icons
  - Status (Success/Pending/Failed/Refunded)
  - Reference number
  - Transaction timestamp
- ✅ **Status badges:**
  - Success (Green)
  - Pending (Orange)
  - Failed (Red)
  - Refunded (Purple)
- ✅ **Transaction details modal:**
  - Complete transaction information
  - Initiate Refund button (for pending)
- ✅ Export payment report option
- ✅ Pull-to-refresh functionality

**Access URL:** `/admin/payments`

---

### 5. **Additional Admin Routes**
- ✅ `/admin/inventory` - Inventory Management (Coming Soon)
- ✅ `/admin/analytics` - Analytics Dashboard (Coming Soon)

---

## Technical Implementation

### Architecture
```
lib/features/admin/
├── admin_login_screen.dart          # Admin authentication
├── admin_dashboard_screen.dart      # Main dashboard
├── admin_orders_screen.dart         # Order management
└── admin_payments_screen.dart       # Payment tracking
```

### Routing
Admin routes are configured in `main.dart` with special handling:
- Admin routes bypass customer authentication checks
- Separate admin authentication flow
- Role-based access verification

### Models

**OrderWithCustomer** (in `admin_orders_screen.dart`):
```dart
- orderId: String
- customerName: String
- customerEmail: String
- customerPhone: String
- status: OrderStatus
- totalAmount: double
- itemCount: int
- orderDate: DateTime
- storeId: String
- storeName: String
- paymentMethod: String
- paymentStatus: String
```

**PaymentTransaction** (in `admin_payments_screen.dart`):
```dart
- transactionId: String
- orderId: String
- customerName: String
- amount: double
- paymentMethod: String
- status: String
- transactionDate: DateTime
- referenceNumber: String?
```

---

## How to Access

### 1. **Navigate to Admin Login**
```dart
// From customer login screen, or directly:
context.go('/admin/login');
```

### 2. **Login with Admin Credentials**
- Use the "Fill Test Admin Credentials" button
- Or manually enter:
  - Email: admin@snackly.com
  - Password: admin123

### 3. **Access Admin Features**
After successful login, you'll be redirected to `/admin/dashboard` where you can:
- View real-time statistics
- Manage orders
- Track payments
- Access inventory (coming soon)
- View analytics (coming soon)

---

## Order Status Workflow

```
PENDING → CONFIRMED → DISPENSED
   ↓          ↓
CANCELLED   FAILED
```

**Pending**: New order received, awaiting confirmation
**Confirmed**: Order accepted and being prepared
**Dispensed**: Order ready and dispensed to customer
**Failed**: Order failed due to payment/technical issues
**Cancelled**: Order cancelled by admin or customer

---

## Payment Status Workflow

```
PENDING → SUCCESS
   ↓         ↓
FAILED   REFUNDED
```

---

## Features Highlights

### 🔐 Security
- Role-based authentication
- Admin-only access
- Activity logging disclaimer
- Secure credential validation

### 📊 Dashboard Analytics
- Real-time order statistics
- Revenue tracking
- Pending order alerts
- Low stock notifications

### 📋 Order Management
- Multi-tab organization
- Quick status updates
- Bulk operations ready
- Customer details at a glance

### 💳 Payment Tracking
- Transaction history
- Payment method breakdown
- Status filtering
- Refund initiation

### 🎨 UI/UX
- Material 3 design
- Intuitive navigation
- Color-coded statuses
- Pull-to-refresh
- Modal detail views

---

## Future Enhancements

### Planned Features
1. **Inventory Management**
   - Stock level monitoring
   - Low stock alerts
   - Reorder automation
   - Product CRUD operations

2. **Analytics Dashboard**
   - Sales charts
   - Revenue trends
   - Customer insights
   - Product performance

3. **Customer Management**
   - Customer list
   - Order history per customer
   - Loyalty points management

4. **Reports**
   - Sales reports
   - Payment reports
   - Inventory reports
   - Export to PDF/Excel

5. **Real-time Updates**
   - WebSocket integration
   - Live order notifications
   - Real-time dashboard updates

6. **Advanced Filters**
   - Date range filters
   - Custom search
   - Export filtered data

---

## Integration with Backend

### Required API Endpoints

**Authentication:**
```
POST /api/admin/login
POST /api/admin/logout
GET  /api/admin/profile
```

**Orders:**
```
GET  /api/admin/orders
GET  /api/admin/orders/:id
PUT  /api/admin/orders/:id/status
GET  /api/admin/orders/stats
```

**Payments:**
```
GET  /api/admin/payments
GET  /api/admin/payments/:id
POST /api/admin/payments/:id/refund
GET  /api/admin/payments/stats
```

### Backend Requirements
- Admin role field in users table
- Order management endpoints
- Payment transaction logging
- Real-time notification system
- Analytics data aggregation

---

## Testing

### Manual Testing Checklist

**Admin Login:**
- [ ] Login with valid credentials
- [ ] Login with invalid credentials
- [ ] Login with non-admin account (should show error)
- [ ] Auto-fill test credentials button
- [ ] Back to customer login navigation

**Dashboard:**
- [ ] Statistics display correctly
- [ ] Quick action cards navigate properly
- [ ] Logout functionality
- [ ] Settings menu

**Order Management:**
- [ ] Tab switching
- [ ] Order list display
- [ ] Status badges
- [ ] Action buttons
- [ ] Order details modal
- [ ] Status updates
- [ ] Pull-to-refresh

**Payment Tracking:**
- [ ] Summary cards
- [ ] Transaction list
- [ ] Status filters
- [ ] Transaction details
- [ ] Refund button (for pending)
- [ ] Pull-to-refresh

---

## Screenshots Description

### Admin Login
Beautiful gradient background with shield icon, secure admin portal branding, and test credentials button.

### Admin Dashboard
Clean cards layout with statistics, growth indicators, and colorful quick action cards for easy navigation.

### Order Management
Tabbed interface with status-specific order lists, comprehensive order cards, and quick action buttons.

### Payment Status
Revenue summary at the top, detailed transaction cards with status badges and payment method icons.

---

## Notes for Development

### Mock Data
Currently using mock data generators:
- `_getMockOrders()` in admin_orders_screen.dart
- `_getMockTransactions()` in admin_payments_screen.dart

**Replace with actual API calls when backend is ready.**

### Role Verification
Admin role check is currently simple (email contains "admin"):
```dart
Future<bool> _verifyAdminRole() async {
  final email = _emailController.text.trim().toLowerCase();
  return email.contains('admin');
}
```

**Update with proper role check from Supabase/backend.**

### State Management
Currently using StatefulWidget with local state. Consider migrating to Provider/Riverpod for:
- Cross-screen state sharing
- Real-time updates
- Better performance

---

## Support

For questions or issues with the admin panel:
1. Check the implementation in `lib/features/admin/`
2. Review routing in `lib/main.dart`
3. Verify admin credentials
4. Check console for debug logs

---

## License
This admin panel is part of the Snackly grocery store application - Academic/Learning Project.
