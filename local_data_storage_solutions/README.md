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