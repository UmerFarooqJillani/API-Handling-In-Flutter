# <p align="center"> local_data_storage_solutions </p>

## Local storage means:
- Data is saved inside the user’s device
- Works offline
- Persists even after app restart
- They are used when you want to store:
    - Login/session info
    - User preferences
    - App state
    - Cached API data
    - Offline content
- They differ mainly in:
    - Data complexity
    - Performance
    - Use cases
- `Hive`, `SharedPreferences`, and `SQLite` are local data storage solutions.

## Why do we need local storage in apps?

Real-world reasons:

- Keep user logged in
- Save dark mode / language
- Cache API data to reduce network calls
- Support offline usage
- Improve app performance

**Example:**
```
User logs in → closes app → opens again
Without local storage → user must login again
With local storage → session is restored
```

## When to use which one?
- Save small key-value data (token, theme)
    - `SharedPreferences`
- Fast local storage for objects, models
    - `Hive`
- Complex relational data (tables, queries)
    - `SQLite`

## `Hive` vs `SharedPreferences` vs `SQLite`
- **Data Type:**
    - `SharedPreferences`
        - Simple key-value
    - `Hive`
        - Objects, models
    - `SQLite`  
        - Tables & rows
- **Complexity:**
    - `SharedPreferences`
        - Very low
    - `Hive`
        - Low–Medium
    - `SQLite`  
        - High
- **Performance:**
    - `SharedPreferences`
        - Fast
    - `Hive`
        - Very fast
    - `SQLite`  
        - Slower
- **Offline:**
    - `SharedPreferences`
        - Yes
    - `Hive`
        - Yes
    - `SQLite`  
        - Yes
- **Relations:**
    - `SharedPreferences`
        - No
    - `Hive`
        - No
    - `SQLite`  
        - Yes
- **Beginner Friendly:**
    - `SharedPreferences`
        - Very
    - `Hive`
        - Yes
    - `SQLite`  
        - Hard
- **Common Usage:**
    - `SharedPreferences`
        - Settings, tokens
    - `Hive`
        - Cache, local DB
    - `SQLite`  
        - Large structured data

## Short Explanation of local data storage solutions:

### **SharedPreferences:**

A simple key-value storage for very small data.<br>
`A tiny notebook for app settings`
- **What you store**
    - Login token
    - User ID
    - Dark mode (true/false)
    - Language preference
- **When to use**
    - Data is small
    - No lists or objects
    - No complex logic
- **When NOT to use**
    - Large data
    - Lists of objects
    - Offline databases

More details [click Here](https://github.com/UmerFarooqJillani/API-Handling-In-Flutter/tree/main/manage_sessions_in_app)

### **Hive:**

A fast, lightweight local database written in pure Dart.<br>
`A fast local storage box for app data`

- **What you store**
    - User profile
    - API responses
    - Cached lists
    - App data models
- **Why developers like `Hive`**
    - No SQL / Key-Value
    - Very fast
    - Simple syntax
    - Works great offline
- **When to use**
    - You want local storage bigger than `SharedPreferences`
    - No complex table relations
    - Performance matters

### **SQLite:**

A relational database using SQL queries.<br>
`Excel sheets with rows, columns, and relations`

- **What you store**
    - Large datasets
    - Data with relations (orders → users)
    - Offline-first apps
    - History, logs, transactions
- **When to use**
    - Complex data structure
    - Relationships between data
    - Heavy querying
- **Why beginners avoid it**
    - Relational (SQL) required
    - More boilerplate
    - Harder to maintain