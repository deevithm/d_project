# Login & Registration Functionality Test Guide

## ✅ Current Status
- **Supabase Connection**: ✅ Online and Connected
- **App Running**: ✅ Running on Android Emulator
- **Auth System**: ✅ Ready to test

## 🧪 Test Scenarios

### 1. Test Login (Existing Account)

**Steps:**
1. On login screen, tap "Fill Test Credentials" button
2. Verify email: `test@snackly.com` and password: `test123` are filled
3. Tap "Sign In" button
4. Watch for loading indicator
5. Should navigate to Stores screen

**Expected Results:**
- ✅ Loading spinner appears
- ✅ Debug logs show login process
- ✅ Redirects to /stores on success
- ✅ Error message shown if credentials are wrong

**Debug Logs to Watch For:**
```
🔐 Starting login process for: test@snackly.com
📧 Calling Supabase signIn...
📬 Supabase response - User: test@snackly.com, Session: true
🔄 Syncing user data...
✅ User synced - Email: test@snackly.com, Authenticated: true
🎉 Login successful!
✅ Login successful, redirecting to stores...
```

---

### 2. Test Registration (New Account)

**Steps:**
1. On login screen, tap "Sign Up" link
2. Fill in the form:
   - **Full Name**: Test User
   - **Email**: your.email@example.com (use a real email)
   - **Phone**: (optional) 1234567890
   - **Password**: testpass123
   - **Confirm Password**: testpass123
3. Check "I agree to Terms of Service"
4. Tap "Create Account" button

**Expected Results:**
- ✅ Loading spinner appears
- ✅ Account created in Supabase
- ✅ One of two scenarios:
  - **Email Confirmation Required**: Dialog shown asking to check email
  - **Auto Login**: Redirects to /stores immediately

**Debug Logs to Watch For:**
```
📝 Starting registration for: your.email@example.com
🔐 Calling Supabase signUp...
📧 Supabase response - User: your.email@example.com, Session: [true/null]
💾 Creating user profile in database...
✅ User profile created
🔄 Syncing user data...
✅ Registration successful
```

---

### 3. Test Error Handling

**Test Invalid Login:**
1. Enter wrong email/password
2. Tap "Sign In"
3. Should show error: "Invalid email or password"

**Test Validation:**
1. Try to login with empty fields → Shows validation errors
2. Try invalid email format → Shows "Please enter a valid email"
3. Try password < 6 chars → Shows "Password must be at least 6 characters"

---

### 4. Test "Remember Me" Functionality

**Steps:**
1. Login with "Remember Me" checked
2. Close and reopen the app
3. Should automatically redirect to /stores (stay logged in)

**Steps to Clear Session:**
1. Navigate to Profile → Settings
2. Tap Logout
3. Should return to login screen

---

## 🔧 Quick Actions

### Clear Stored Auth (Start Fresh)
If you want to test login from scratch:
1. Go to app settings on device
2. Clear app data/storage
3. Restart app
4. OR: Add logout button in app

### Enable Internet on Emulator
If connection fails:
1. Check emulator has internet access
2. Try opening browser in emulator
3. Check proxy settings if behind corporate firewall

---

## 📱 What to Test Now

Since app is running and Supabase is connected:

### Option 1: Test with Existing Account
- Tap "Fill Test Credentials"
- Tap "Sign In"
- See if it logs in successfully

### Option 2: Create New Account
- Tap "Sign Up"
- Fill registration form
- Create a new account

### Option 3: Check Current Auth State
- The app shows "isLoggedIn: true"
- This means there's a cached session
- Navigate around the app to verify features work

---

## 🐛 Troubleshooting

### If Login Doesn't Work:
1. Check debug console for error messages
2. Verify Supabase credentials in config
3. Check internet connection
4. Try with different credentials

### If Registration Doesn't Work:
1. Check if email confirmation is enabled in Supabase
2. Verify user table exists in database
3. Check console for specific error

### Network Issues:
```
Failed host lookup → No internet connection
AuthException → Supabase authentication error
```

---

## 🎯 Next Steps After Testing

Once login/registration works:
1. ✅ Test navigation between screens
2. ✅ Test logout functionality
3. ✅ Test product browsing
4. ✅ Test cart functionality
5. ✅ Test favorites (already fixed UI issues)
6. ✅ Test order placement

