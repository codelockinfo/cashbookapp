# Token Authentication Implementation Guide

## ✅ Implementation Complete!

Your Flutter app now supports token-based authentication with SharedPreferences.

## 📁 Files Created/Modified

1. **`lib/services/token_manager.dart`** - Handles token storage/retrieval
2. **`lib/services/auth_service.dart`** - Example API service for login
3. **`lib/main.dart`** - Updated WebView to pass token in URL

## 🔧 How It Works

### Step 1: Token is Saved in SharedPreferences
When user logs in (via your PHP backend), save the token:

```dart
import 'services/token_manager.dart';

// Save token after successful login
await TokenManager.saveToken("your_token_here");
```

### Step 2: WebView Automatically Passes Token
The WebView now automatically:
- Retrieves token from SharedPreferences
- Appends it to the URL: `https://bookify.happyeventsurat.com/?token=YOUR_TOKEN`

### Step 3: PHP Backend Verifies Token
Your PHP backend should handle the token:

```php
<?php
// app-login.php or index.php
if(isset($_GET['token'])) {
    $token = $_GET['token'];
    
    // Verify token from database
    $stmt = $conn->prepare("SELECT * FROM users WHERE api_token = ?");
    $stmt->execute([$token]);
    $user = $stmt->fetch();
    
    if($user) {
        // Create PHP session
        $_SESSION['user_id'] = $user['id'];
        $_SESSION['user_email'] = $user['email'];
        
        // Redirect to dashboard
        header("Location: /dashboard.php");
        exit;
    } else {
        // Invalid token, show login page
        header("Location: /login.php");
        exit;
    }
}
?>
```

## 📝 Usage Examples

### Example 1: Save Token After Login API Call

```dart
import 'services/auth_service.dart';

// Login and save token
final result = await AuthService.login('user@example.com', 'password');
if (result['success']) {
    print('Token saved: ${result['token']}');
    // Navigate to WebView
}
```

### Example 2: Save Token Directly

```dart
import 'services/token_manager.dart';

// If you receive token from somewhere else
await TokenManager.saveToken("abc123xyz456");
```

### Example 3: Check if User is Logged In

```dart
import 'services/token_manager.dart';

bool hasToken = await TokenManager.hasToken();
if (hasToken) {
    // User is logged in
    String? token = await TokenManager.getToken();
    print('Current token: $token');
}
```

### Example 4: Logout (Remove Token)

```dart
import 'services/token_manager.dart';

await TokenManager.removeToken();
// Token removed, user logged out
```

## 🔐 Security Notes

1. **HTTPS Only**: Token is passed via HTTPS URL (secure)
2. **Token Expiry**: Consider implementing token expiry on backend
3. **Token Refresh**: You may want to add token refresh mechanism

## 🎯 Customization

### Change Token Parameter Name
In `lib/main.dart`, line ~45, change:
```dart
webViewUrl = "$baseUrl?token=$token";
```
To:
```dart
webViewUrl = "$baseUrl?app-login=$token";  // or any parameter name
```

### Change URL Path
If your backend expects token in a specific path:
```dart
webViewUrl = "$baseUrl/app-login?token=$token";
```

## 🧪 Testing

1. **Save a test token:**
   ```dart
   await TokenManager.saveToken("test_token_123");
   ```

2. **Check WebView URL:**
   - Open app
   - WebView should load: `https://bookify.happyeventsurat.com/?token=test_token_123`

3. **Verify PHP receives token:**
   - Check your PHP logs/console
   - Token should be in `$_GET['token']`

## 📱 Next Steps

1. **Update your PHP backend** to handle `?token=` parameter
2. **Test the flow**: Login → Save Token → Open WebView → Auto-login
3. **Add error handling** if token is invalid/expired
4. **Optional**: Add token refresh mechanism

## ❓ Troubleshooting

**Token not being passed?**
- Check if token exists: `await TokenManager.getToken()`
- Verify WebView URL in console logs

**PHP not receiving token?**
- Check URL format matches your backend expectations
- Verify parameter name (`token` vs `app-login`)

**Token not saving?**
- Check SharedPreferences permissions
- Verify token is not empty before saving

