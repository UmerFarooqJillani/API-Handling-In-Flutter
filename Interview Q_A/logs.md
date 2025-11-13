# <p align="Center"> Logs </p>

## What are Logs?
- Logs are simply records or messages that your program prints out, they help developers understand what’s happening inside the app while it’s running.
- You can think of logs as your app talking to you, they tell you what’s going right, what’s going wrong, and what data is flowing between your app and the server.

### Simple Example (Flutter Console Logs)
- You'll see it in your Debug Console (VS Code) or Logcat (Android Studio).
```dart
print("Login button pressed");
```
### Types of Logs
1. Debug Logs
    - For debugging (development only). `print("API called successfully")`
2. Error Logs
    - Show exceptions or failures. `print("Login failed: ${response.statusCode}")`
3. Info Logs
    - Informational messages about app events. `print("User logged in")`
4. Network Logs
    - Record all API requests and responses. `Request URLs, headers, body, token, etc.`

## Why Logs Are Important
- To debug issues (e.g., why login failed)
- To monitor performance
- To see what data your app sends/receives
- To verify authentication (token, headers, etc.)
- To check errors from server (like 401 Unauthorized)

## What Are API Request/Response Logs?<br>
- When your Flutter app talks to a backend server (via HTTP), two main actions happen:
    - Request → App sends data to the server.
    - Response → Server sends data back to the app.
- **Logging** request and **response** means printing both sides so you can inspect what’s happening.