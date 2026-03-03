# Admin Panel Testing Guide

## Quick Access

### From Customer Login Screen
1. Launch the app
2. You'll see the login screen
3. Look for the **"Admin Portal"** button at the bottom (with shield icon)
4. Click it to navigate to admin login

### Direct URL Navigation
- Admin Login: `/admin/login`
- Admin Dashboard: `/admin/dashboard`
- Order Management: `/admin/orders`
- Payment Status: `/admin/payments`

## Test Credentials

**Admin Account:**
```
Email: admin@snackly.com
Password: admin123
```

**Customer Account (for comparison):**
```
Email: test@snackly.com
Password: test123
```

## Testing Checklist

### ✅ Admin Login Screen
- [ ] Navigate from customer login using "Admin Portal" button
- [ ] See shield icon and gradient background
- [ ] Click "Fill Test Admin Credentials" button
- [ ] Verify credentials auto-fill (admin@snackly.com / admin123)
- [ ] Click "Sign In as Admin"
- [ ] Should redirect to `/admin/dashboard`

### ✅ Admin Dashboard
- [ ] See welcome message with admin name
- [ ] View 4 statistics cards:
  - Total Orders (248, +12%)
  - Revenue (₹45.2K, +8%)
  - Pending (12, 3 urgent)
  - Products (156, 8 low stock)
- [ ] See 6 quick action cards:
  - Order Management
  - Payment Status
  - Inventory (placeholder)
  - Analytics (placeholder)
  - Customers (placeholder)
  - Reports (placeholder)
- [ ] Click Order Management → should navigate to `/admin/orders`
- [ ] Click Payment Status → should navigate to `/admin/payments`
- [ ] Click logout in menu → should return to `/admin/login`

### ✅ Order Management Screen
- [ ] See 4 tabs: Pending, Confirmed, Dispensed, All
- [ ] Each tab shows order count
- [ ] See order cards with:
  - Order ID (e.g., ORD-2024-001)
  - Customer name
  - Store name
  - Time (e.g., "15m ago")
  - Item count
  - Payment method icon
  - Total amount
  - Payment status badge
  - Status badge (color-coded)
- [ ] For Pending orders:
  - See "Cancel" button (red)
  - See "Confirm Order" button (green)
  - Click "Confirm Order" → status changes to Confirmed
- [ ] For Confirmed orders:
  - See "Cancel" button
  - See "Mark Dispensed" button
  - Click "Mark Dispensed" → status changes to Dispensed
- [ ] Click on any order card → Opens detail modal
- [ ] Modal shows complete customer info
- [ ] Pull down to refresh
- [ ] Click refresh icon in app bar

### ✅ Payment Status Screen
- [ ] See 4 summary cards:
  - Total Revenue with growth percentage
  - Pending Payments with count
  - Successful Transactions with success rate
  - Total Transactions
- [ ] See transaction list with:
  - Transaction ID (e.g., TXN-2024-001)
  - Customer name
  - Amount (color-coded)
  - Payment method (UPI/Card/Cash with icons)
  - Status badge (Success/Pending/Failed/Refunded)
  - Reference number (if available)
  - Timestamp
- [ ] Click on transaction → Opens detail modal
- [ ] Modal shows all transaction details
- [ ] For Pending transactions, see "Initiate Refund" button
- [ ] Pull down to refresh
- [ ] Click refresh icon in app bar

### ✅ Navigation Tests
- [ ] From dashboard → Orders → Back button returns to dashboard
- [ ] From dashboard → Payments → Back button returns to dashboard
- [ ] From orders → Click device back → Returns to dashboard
- [ ] Logout from any screen → Returns to admin login
- [ ] Admin login "Back to Customer Login" → Returns to `/login`

### ✅ Role Verification
- [ ] Try logging in with customer credentials (test@snackly.com)
- [ ] Should show error: "Access denied. Admin privileges required."
- [ ] Should automatically logout and stay on admin login

### ✅ UI/UX Verification
- [ ] All screens use Material 3 design
- [ ] Status badges have proper colors:
  - Pending: Orange
  - Confirmed: Blue
  - Dispensed: Green
  - Failed/Cancelled: Red
  - Success: Green
  - Refunded: Purple
- [ ] Icons are clear and meaningful
- [ ] Cards have proper shadows and borders
- [ ] Text is readable and well-spaced
- [ ] Buttons respond to clicks
- [ ] Smooth transitions between screens

## Expected Behavior

### Order Status Flow
```
PENDING → CONFIRMED → DISPENSED
   ↓          ↓
CANCELLED   FAILED
```

### Payment Status Flow
```
PENDING → SUCCESS
   ↓         ↓
FAILED   REFUNDED
```

## Known Limitations (Mock Data)

⚠️ **Currently using mock data:**
- Orders are hardcoded (5 sample orders)
- Transactions are hardcoded (6 sample transactions)
- Statistics are calculated from mock data
- Changes to order status are local only (not persisted)

**To connect to real backend:**
1. Replace `_getMockOrders()` with API call in `admin_orders_screen.dart`
2. Replace `_getMockTransactions()` with API call in `admin_payments_screen.dart`
3. Implement actual role checking in `_verifyAdminRole()` in `admin_login_screen.dart`
4. Add WebSocket or polling for real-time updates

## Troubleshooting

### Issue: Can't see "Admin Portal" button
**Solution:** Make sure you're on the customer login screen (`/login`)

### Issue: Login fails even with correct credentials
**Solution:** Check console for error messages. Ensure Supabase is configured.

### Issue: Access denied error with admin credentials
**Solution:** The current implementation checks if email contains "admin". Use `admin@snackly.com`.

### Issue: Orders/Payments don't update
**Solution:** Mock data is static. Tap refresh or pull down to reload.

### Issue: Back button doesn't work
**Solution:** Use the back arrow in app bar or device back button.

## Console Debug Messages

Look for these messages in the console:

**Admin Login:**
```
🔐 Admin login attempt for: admin@snackly.com
✅ Admin login successful, redirecting to admin dashboard
```

**Navigation:**
```
🔀 GoRouter redirect - Path: /admin/dashboard, isLoggedIn: true
```

## Future Enhancements

When backend is ready, implement:
1. Real-time order notifications
2. Order search and filters
3. Date range filtering for payments
4. Export reports (PDF/Excel)
5. Inventory management screen
6. Analytics dashboard with charts
7. Customer management
8. Push notifications for new orders

## Support

If you encounter issues:
1. Check console logs
2. Verify credentials
3. Ensure you're using admin email
4. Check network connectivity
5. Review `ADMIN_PANEL_README.md` for detailed documentation
