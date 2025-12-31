# Why adapters are required in Hive
## What is an `adapter`?
An adapter is a small piece of code that tells Hive:
- How to convert your custom Dart object (like User, Profile, Quiz) into saved data (bytes)
- And how to convert it back when you read from Hive

Hive can automatically store basic types like:

- `int, double, bool, String`
- `List` / `Map` (with supported types)

But Hive cannot understand your custom classes by itself.

## Example (adapter in simple words)
1. Create adapter
    ```dart
    class UserAdapter extends TypeAdapter<User> {

    @override
    final int typeId = 1;   // must be unique per model.
    // After you publish your app, do not change typeId (or old saved data can break)

    @override
    User read(BinaryReader reader) {
        final id = reader.readInt();
        final name = reader.readString();
        return User(id: id, name: name);
    }

    @override
    void write(BinaryWriter writer, User obj) {
        writer.writeInt(obj.id);
        writer.writeString(obj.name);
    }
    }
    ```
2. Register adapter before opening box
    ```dart
    Hive.registerAdapter(UserAdapter());
    await Hive.openBox("userBox");
    ```
3. Store and read
    ```dart
    final box = Hive.box("userBox");

    await box.put("user", User(id: 1, name: "Ali"));
    final user = box.get("user") as User;
    ```
--- 

# How to store List, Map, Images, Tokens in Hive

## Storing a List
- **When to store a List?**
    - API responses (e.g. list of quizzes, courses)
    - Cached items
    - Offline content
        ```dart
        box.put("numbers", [1, 2, 3, 4]);

        final list = box.get("numbers") as List;
        ```
- **List of objects**
    ```dart
    List<User>
    ```
    - You must have an adapter for User
    ```dart
    box.put("users", userList);
    ```
## Storing a Map
- When to store a Map?
    - Raw API JSON
    - Settings
    - Key-value grouped data
    - Example:
        ```dart
        box.put("profile", {
        "id": 1,
        "name": "Ali",
        "class": "9th",
        });

        final profile = box.get("profile") as Map;
        ```
    - Good for API cache
    - Avoid deeply nested maps for long-term data
## Storing Images
- Hive does NOT store image files directly.
- You store:
    1. Image path
    2. Image URL (UI loads image from network or cache.)
    3. Bytes (Uint8List) (Not recommended for large images)
- Store image path (Recommended)
    - Picked images
    - Camera images
    ```dart
    box.put("profileImagePath", "/storage/emulated/0/profile.png");
    ```
## Storing Tokens (auth tokens)
- Yes, but it is NOT recommended for sensitive tokens.
- **Production recommendation**
    - Use `flutter_secure_storage` for:
        - Access token
        - Refresh token
- **Hive is better for:**
    - App data
    - Cached responses
    - Non-sensitive values

--- 

# How to store simple key-value data in Hive

## Basic steps
1. Open a box
    ```dart
    final box = await Hive.openBox("appBox");
    ```
2. Save data (put)
    ```dart
    box.put("username", "Ali");
    box.put("age", 14);
    box.put("isLoggedIn", true);
    ```
3. Read data (get)
    ```dart
    final name = box.get("username");
    final age = box.get("age");
    final isLoggedIn = box.get("isLoggedIn");
    ```
4. Use default values (important)
    ```dart
    final theme = box.get("theme", defaultValue: "light");
    ```
5. Update value
```dart
box.put("age", 15);
```
6. Delete value
```dart
box.delete("age");
```
7. Clear all data (danger)
    - Use only on logout or reset.
    ```dart
    box.clear();
    ```
---

# Handle offline mode gracefully
**It means:**
- App does not crash when internet is off
- App still shows useful data
- User understands what’s happening

## Core idea
- Never depend only on API.
    ```pgsql
    Open screen
        ↓
    Show cached data (Hive)
        ↓
    Check internet
        ↓
    If offline → show cached data
    If online → fetch fresh data → Update Hive + UI
    ```
## Simple Example (API + Hive)
```dart
Future<List<Item>> getItems() async {
  if (isOnline) {
    final data = await api.fetchItems();
    hiveBox.put("items", data);   // cache
    return data;
  } else {
    return hiveBox.get("items", defaultValue: []);
  }
}
```

--- 
# Use `connectivity_plus` to detect offline

## What is `connectivity_plus`?
It is a **Flutter plugin** that tells you:
- Is the device connected or not
- Connection type: Wi-Fi, mobile data, or none

It does not check if the internet actually works,

it only checks network availability.

## Check current connection
```dart
final result = await Connectivity().checkConnectivity();

bool isOnline = result != ConnectivityResult.none;
```
## Listen to connection changes (important)
- This updates app state when internet goes on/off.
```dart
Connectivity().onConnectivityChanged.listen((result) {
  final isOnline = result != ConnectivityResult.none;
});
```
--- 
# Use Caching with Hive
## What is caching?
- Save API data locally
- Reuse it later instead of calling API again
    > **Remember the last answer so I don’t ask again.**

## Why caching?
- App loads faster
- Less internet usage
- Works offline
- Better user experience

## Caching Flow
```pgsql
Call API
    ↓
Save response in Hive  
    ↓
Read from Hive next time
```
## Example
```dart
Future<List<Item>> getItems() async {
  final data = await api.fetchItems();
  hiveBox.put("items", data); // cache
  return data;
}
```
---
# Cache with Hive `(reads: serve cached, writes: queue)`

## What does this mean in simple words?
- Reads → Show data from Hive immediately
- Writes → If offline, save actions in Hive and send them later

User can continue using the app, even without internet.

## Writes: `queue` data when offline
**`queue` mean:**
- Save user actions locally,
- send them to server when internet returns.
    - Example 
        ```dart
        if (isOnline) {
        await api.submit(data);
        } else {
        hiveBox.add({
            "type": "submit_form",
            "payload": data,
        });
        }
        ```
---
# SWR (Stale While Revalidate) Pattern

`Show cached → refresh when back online`
**In simple words:**
- Show **old (cached)** data first
- Fetch **new data in background**
- Update UI when fresh data arrives
    ```dart
    Future<List<Item>> loadItems() async {
    final cached = hiveBox.get("items", defaultValue: []);
    updateUI(cached); // show first

    if (isOnline) {
        final fresh = await api.fetchItems();
        hiveBox.put("items", fresh);
        updateUI(fresh); // refresh
    }

    return cached;
    }
    ```
## When NOT to use SWR
- Payments
- Live data
- One-time critical actions

--- 

# Retry with backoff

## Simple meaning
- If an API call fails:
    - Don’t retry immediately
    - Wait a bit
    - Retry again
    - Increase wait time each retry
- This avoids:
    - Server overload
    - Battery drain
    - Infinite loops
## Example
```dart
Future<void> fetchWithRetry() async {
  int retries = 0;

  while (retries < 3) {
    try {
      await api.fetchData();
      return;
    } catch (_) {
      retries++;
      await Future.delayed(Duration(seconds: retries * 2));
    }
  }
}
```

--- 
# Clear UX for Offline & Sync States

Good UX means the user always knows what’s happening.

- Offline banner (top message)
- Status chips (small indicators)
- Pull-to-refresh (user control)
    - User manually refreshes when internet is back.
        ```dart
        RefreshIndicator(
        onRefresh: () async {
            if (isOnline) await refreshData();
        },
        child: ListView(...),
        );
        ```
--- 
# Production architecture (Hive + Cache + Offline)

```dart
lib/
├── main.dart
│   // ENTRY POINT
│   // - Ensure Flutter binding
│   // - Init services (Hive, Firebase, etc.)
│   // - Start Riverpod ProviderScope
│   //
│   // main() async {
│   //   WidgetsFlutterBinding.ensureInitialized();
│   //   await LocalDbService.init();        // Hive init + adapters + open boxes
│   //   await FirebaseService.init();       // optional
│   //   runApp(const ProviderScope(child: App()));
│   // }
│
├── app/
│   ├── app.dart
│   │   // ROOT APP WIDGET
│   │   // - MaterialApp.router
│   │   // - Uses appRouterProvider
│   │   // - Applies themes
│   │
│   ├── router/
│   │   ├── app_router.dart
│   │   │   // GO_ROUTER SETUP (as Riverpod provider)
│   │   │   // - All routes (user/admin/auth/onboarding)
│   │   │   // - Redirects via authGuard
│   │   │
│   │   ├── guards/
│   │   │   └── auth_guard.dart
│   │   │       // ROUTE PROTECTION
│   │   │       // - Redirect to login if not authenticated
│   │   │       // - Role checks (user/admin)
│   │   │
│   │   ├── shells/
│   │   │   ├── user_shell.dart
│   │   │   │   // USER SHELL (layout wrapper)
│   │   │   │   // - AppBar/BottomNav/Drawer for /u/*
│   │   │   │
│   │   │   └── admin_shell.dart
│   │   │       // ADMIN SHELL (layout wrapper)
│   │   │       // - AppBar/BottomNav/Drawer for /admin/*
│   │   │
│   │   ├── user_coordinator.dart
│   │   │   // USER NAV COORDINATOR
│   │   │   // - UI calls nav.openProfile() instead of context.go()
│   │   │
│   │   └── admin_coordinator.dart
│   │       // ADMIN NAV COORDINATOR
│   │
│   ├── themes/
│   │   ├── light_theme.dart
│   │   └── dark_theme.dart
│   │
│   └── constants/
│       ├── colors.dart
│       ├── sizes.dart
│       └── strings.dart
│
├── core/
│   // SHARED APP LOGIC (used by all features)
│   ├── network/
│   │   ├── api_client.dart
│   │   │   // DIO CLIENT
│   │   │   // - Base URL, headers, interceptors, logging
│   │   │   // - Used by RemoteDataSources
│   │   └── endpoints.dart
│   │       // REST PATHS
│   │
│   ├── auth/
│   │   ├── auth_service.dart
│   │   │   // AUTH OPERATIONS
│   │   │   // - login/logout/refresh token
│   │   └── auth_provider.dart
│   │       // AUTH RIVERPOD PROVIDERS
│   │       // - authState, currentUser, role
│   │
│   ├── connectivity/
│   │   ├── connectivity_service.dart
│   │   │   // ONLINE/OFFLINE DETECTION
│   │   │   // - Uses connectivity_plus
│   │   │   // - Exposes stream/status
│   │   └── connectivity_provider.dart
│   │       // RIVERPOD ONLINE PROVIDER
│   │       // - Used by repositories/controllers/UI
│   │
│   ├── error/
│   │   ├── app_exception.dart
│   │   └── error_mapper.dart
│   │
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── logger.dart
│   │   └── date_format.dart
│   │
│   └── extensions/
│       └── string_extensions.dart
│
├── services/
│   // APP-WIDE INTEGRATIONS (keep your Hive init here)
│   ├── local_db_service.dart
│   │   // HIVE GLOBAL SETUP (KEEP THIS FILE)
│   │   // Responsibilities:
│   │   // - init Hive
│   │   // - register adapters once
│   │   // - open boxes once
│   │   //
│   │   // Boxes (recommended):
│   │   // - settingsBox (small flags)
│   │   // - userBox     (profile/session-related non-sensitive)
│   │   // - cacheBox    (API cache)
│   │   // - outboxBox   (queued offline writes)
│   │
│   ├── outbox_service.dart
│   │   // OFFLINE WRITE QUEUE + SYNC
│   │   // - enqueue(action) when offline
│   │   // - flush() on reconnect (retry/backoff)
│   │
│   └── firebase_service.dart
│       // FIREBASE INIT + helpers (optional)
│
├── models/
│   // SHARED MODELS (cross-feature)
│   ├── user_model.dart
│   └── alphabet_model.dart
│   // Note: If stored in Hive as objects → need adapters
│
├── features/
│   // FEATURE MODULES (MVVM)
│   ├── user/
│   │   ├── home/
│   │   │   ├── data/
│   │   │   │   ├── home_remote_data_source.dart
│   │   │   │   │   // API ONLY (Dio)
│   │   │   │   ├── home_local_data_source.dart
│   │   │   │   │   // HIVE CACHE ONLY (read/write cache)
│   │   │   │   └── home_repository.dart
│   │   │   │       // DATA STRATEGY
│   │   │   │       // - Serve cached first (Hive)
│   │   │   │       // - If online → fetch fresh → update cache (SWR)
│   │   │   │       // - If offline → return cache
│   │   │   │
│   │   │   ├── application/
│   │   │   │   └── home_controller.dart
│   │   │   │       // VIEWMODEL (Riverpod Notifier)
│   │   │   │       // - Calls repository
│   │   │   │       // - Exposes UI state (loading/data/error)
│   │   │   │       // - Refresh on reconnect (invalidate)
│   │   │   │
│   │   │   └── presentation/
│   │   │       ├── home_screen.dart
│   │   │       │   // UI
│   │   │       │   // - Show offline banner/chip
│   │   │       │   // - Pull-to-refresh
│   │   │       └── widgets/
│   │   │
│   │   ├── login/
│   │   │   ├── data/
│   │   │   │   └── login_repository.dart
│   │   │   ├── application/
│   │   │   │   └── login_controller.dart
│   │   │   └── presentation/
│   │   │       ├── login_screen.dart
│   │   │       └── widgets/
│   │   │
│   │   └── dashboard/
│   │       // same pattern: data/application/presentation
│   │
│   └── admin/
│       // same pattern as user features
│
├── widgets/
│   // GLOBAL UI COMPONENTS (design system)
│   ├── custom_button.dart
│   ├── custom_textfield.dart
│   └── app_logo.dart
│
├── data/
│   // OPTIONAL MOCK/SEED DATA (dev/testing)
│   ├── alphabet_data.dart
│   ├── user/user_data.dart
│   └── admin/admin_data.dart
│
└── config/
    ├── env.dart
    └── app_config.dart
```