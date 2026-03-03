# Fix: Enable Admin Access to Orders in Supabase

## Problem
The admin portal cannot view orders because Supabase's Row Level Security (RLS) policies block unauthenticated queries. The admin login uses hardcoded credentials (`admin@snackly.com`/`admin123`) which doesn't authenticate with Supabase, so `auth.uid()` is NULL and RLS blocks access.

## Solution
Run the following SQL in your Supabase Dashboard → SQL Editor:

### Option 1: Allow Anonymous Read Access (Quick Fix - Not for Production)
```sql
-- Allow anyone to view all orders (FOR DEVELOPMENT/DEMO ONLY)
CREATE POLICY "Allow anonymous read all orders" ON orders
  FOR SELECT USING (true);

-- Also allow viewing order items
CREATE POLICY "Allow anonymous read all order items" ON order_items
  FOR SELECT USING (true);
```

### Option 2: Create Admin Role (Recommended for Production)
```sql
-- First, create an admin user in Supabase Auth dashboard
-- Email: admin@snackly.com, Password: admin123

-- Then add admin role check to policies
-- Add is_admin column to users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT FALSE;

-- Create policy for admins to view all orders
CREATE POLICY "Admins can view all orders" ON orders
  FOR SELECT USING (
    auth.uid() IS NOT NULL AND 
    EXISTS (
      SELECT 1 FROM users 
      WHERE users.id = auth.uid() 
      AND users.is_admin = TRUE
    )
  );

-- Create policy for admins to view all order items  
CREATE POLICY "Admins can view all order items" ON order_items
  FOR SELECT USING (
    auth.uid() IS NOT NULL AND
    EXISTS (
      SELECT 1 FROM users 
      WHERE users.id = auth.uid() 
      AND users.is_admin = TRUE
    )
  );
```

## How to Apply
1. Go to your Supabase Dashboard: https://app.supabase.com/project/kojaaeqjupvnpuorcuno
2. Navigate to **SQL Editor**
3. Paste the SQL from Option 1 (for quick fix) or Option 2 (for production)
4. Click **Run**
5. Restart the Flutter app

## Verify
After applying the SQL:
1. Login as admin (`admin@snackly.com` / `admin123`)
2. Go to Orders in admin dashboard
3. Orders should now appear

## Current RLS Policies
The existing policy only allows users to see their own orders:
```sql
CREATE POLICY "Users can view own orders" ON orders
  FOR SELECT USING (auth.uid() = user_id);
```

This blocks admin access because the admin isn't authenticated with Supabase.
