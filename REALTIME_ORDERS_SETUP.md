# Real-Time Order Management Setup

## ✅ What's Been Implemented

### 1. Order Repository (`lib/shared/repositories/order_repository.dart`)
A complete repository that handles:
- **Real-time order synchronization** using Supabase streams
- **CRUD operations** for orders
- **Automatic updates** when orders change
- **Status updates** (pending → confirmed → dispensed)

### 2. Admin Orders Screen Integration
The admin orders screen now:
- **Fetches real orders** from Supabase instead of mock data
- **Updates in real-time** when customers place orders
- **Persists status changes** to the database
- **Shows live order count** and details

### 3. Real-Time Features
- Orders appear **instantly** in admin panel when customers order
- Status updates sync **automatically** across all connected clients
- No page refresh needed - uses Supabase real-time subscriptions

## 🗄️ Database Setup Required

### Step 1: Create Tables in Supabase

Run these SQL commands in your Supabase SQL Editor:

```sql
-- Orders table
CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  store_id UUID REFERENCES stores(id) ON DELETE SET NULL,
  total_amount DECIMAL(10, 2) NOT NULL,
  total_savings DECIMAL(10, 2) DEFAULT 0,
  payment_method TEXT NOT NULL CHECK (payment_method IN ('upi', 'card', 'wallet', 'qr')),
  payment_id TEXT,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'dispensed', 'failed', 'cancelled')),
  qr_code TEXT,
  otp TEXT,
  failure_reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

-- Order items table
CREATE TABLE IF NOT EXISTS order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE SET NULL,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  price DECIMAL(10, 2) NOT NULL,
  subtotal DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for better performance
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_store_id ON orders(store_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);

-- Enable real-time for orders table
ALTER PUBLICATION supabase_realtime ADD TABLE orders;
ALTER PUBLICATION supabase_realtime ADD TABLE order_items;

-- Trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_orders_updated_at 
  BEFORE UPDATE ON orders 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();
```

### Step 2: Enable Row Level Security (RLS)

```sql
-- Enable RLS
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own orders
CREATE POLICY "Users can view own orders" ON orders
  FOR SELECT USING (auth.uid() = user_id);

-- Policy: Users can create their own orders
CREATE POLICY "Users can create own orders" ON orders
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Policy: Admins can view all orders
CREATE POLICY "Admins can view all orders" ON orders
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE users.id = auth.uid() 
      AND users.role = 'admin'
    )
  );

-- Policy: Admins can update all orders
CREATE POLICY "Admins can update all orders" ON orders
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE users.id = auth.uid() 
      AND users.role = 'admin'
    )
  );

-- Policy: Users can view order items for their orders
CREATE POLICY "Users can view own order items" ON order_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM orders 
      WHERE orders.id = order_items.order_id 
      AND orders.user_id = auth.uid()
    )
  );

-- Policy: Admins can view all order items
CREATE POLICY "Admins can view all order items" ON order_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE users.id = auth.uid() 
      AND users.role = 'admin'
    )
  );
```

## 📱 How to Use

### For Customers (Placing Orders)

```dart
// In your checkout screen
final orderRepo = OrderRepository();

// Create order when customer completes checkout
final order = await orderRepo.createOrder(
  storeId: selectedStore.id,
  userId: currentUser.id,
  items: cartItems,
  totalAmount: calculateTotal(),
  paymentMethod: 'upi',
  paymentId: razorpayPaymentId,
);

if (order != null) {
  // Order created successfully!
  // Admin will see it instantly in their dashboard
}
```

### For Admins (Viewing Orders)

The admin orders screen already has everything set up:

1. **Open Admin Portal** → Orders
2. **See real-time orders** from all customers
3. **Update status** by clicking action buttons
4. **Changes sync instantly** to customer app

### Status Flow

```
PENDING → (Admin clicks "Confirm") → CONFIRMED 
       → (Admin clicks "Mark Dispensed") → DISPENSED

PENDING → (Admin clicks "Cancel") → CANCELLED
```

## 🔔 Real-Time Events

The system listens for these real-time events:

1. **New Order Created** (Customer places order)
   - Instantly appears in admin dashboard
   - Notification can be shown

2. **Order Status Updated** (Admin changes status)
   - Updates in customer's order history
   - Real-time status badges change

3. **Order Items Added/Removed**
   - Keeps item list synchronized

## 🧪 Testing the Setup

### 1. Test Order Creation (Customer Side)

```dart
// Add to your checkout completion
final orderRepo = OrderRepository();
await orderRepo.initialize();

final testOrder = await orderRepo.createOrder(
  storeId: 'test-store-001',
  userId: currentUserId,
  items: [
    CartItem(
      product: selectedProduct,
      quantity: 2,
      currentPrice: 50.0,
    ),
  ],
  totalAmount: 100.0,
  paymentMethod: 'upi',
  paymentId: 'pay_test123',
);

print('Order created: ${testOrder?.id}');
```

### 2. Test Real-Time Updates (Admin Side)

```dart
// In admin orders screen - already implemented!
// Just open the screen and you'll see:
// - Real orders from database
// - Live updates when new orders arrive
// - Status changes sync automatically
```

### 3. Verify Real-Time Connection

Check console logs for:
```
📡 Setting up real-time order subscription...
✅ Fetched X orders from Supabase
🔔 Real-time order update received: X orders
```

## 🚀 Next Steps

1. **Run SQL Setup** in Supabase SQL Editor
2. **Test Order Creation** from customer app
3. **Verify Real-Time Sync** in admin dashboard
4. **Add Notification System** (optional - Firebase Cloud Messaging)
5. **Add Order Filtering** (by date, status, customer)
6. **Add Export Reports** (CSV/PDF downloads)

## 🐛 Troubleshooting

### Orders not showing in admin panel?
- Check if RLS policies are set correctly
- Verify admin user has role='admin' in users table
- Check Supabase logs for errors

### Real-time not working?
- Ensure `ALTER PUBLICATION supabase_realtime ADD TABLE orders;` was run
- Check browser console for WebSocket connection errors
- Verify Supabase project has real-time enabled

### Status updates not persisting?
- Check RLS policies allow admins to UPDATE
- Verify order IDs match between frontend and database
- Check Supabase logs for constraint violations

## 📚 Additional Resources

- [Supabase Real-time Docs](https://supabase.com/docs/guides/realtime)
- [Flutter Supabase Package](https://pub.dev/packages/supabase_flutter)
- [Order Model Documentation](lib/core/models/order.dart)
- [Order Repository Documentation](lib/shared/repositories/order_repository.dart)
