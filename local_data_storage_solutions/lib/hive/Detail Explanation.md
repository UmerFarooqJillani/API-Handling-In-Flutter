# <p align="center"> Hive in Flutter </p>

Hive is a fast, lightweight local NoSQL database for Flutter.
- Works offline
- Written in pure Dart
- Stores data as key–value pairs
- Very fast compared to SQLite for simple reads/writes
- No SQL, no tables, no joins

`A set of labeled storage boxes, where each box stores related data.`

## When Hive should be used

**Use Hive when:**
- You want to cache API responses
- You want offline support
- You want to store objects/models
- You want high performance
- Your data is not relational

**Do NOT use Hive when:**
- You need SQL queries
- You need joins
- You need heavy filtering at DB level

## Hive core components

**These are the main building blocks you must understand:**
1. Hive
2. Box
3. Key-Value storage
4. LazyBox
5. TypeAdapter
6. HiveObject
7. Box lifecycle (open / close)
8. Error handling & versioning

### 1. Hive initialization (mandatory)
- **What it is:**
    - Hive must be initialized once before use.
- **Why:**
    - Hive needs a **directory path** to store data files on the device.
- **Production usage:**
    - You do this before `runApp()`.
        ```dart
        void main() async {
        WidgetsFlutterBinding.ensureInitialized();

        final dir = await getApplicationDocumentsDirectory();
        Hive.init(dir.path);

        runApp(MyApp());
        }
        ```
### 2. Box
- A Box is Hive’s main storage unit.
- **Example boxes:**
    - userBox
    - settingsBox
    - cacheBox
- A permanently stored container on the device that holds key–value data.
- Each box stores related data only.
- **Opening a Box**
    - Boxes must be opened before use.
        ```dart
        await Hive.openBox('userBox');
        ```
    - After opening, Hive keeps it in memory.

- **Accessing a Box**
    ```dart
    final box = Hive.box('userBox');
    ```
- **Production rule**
    - Open boxes once (app start)
    - Reuse them everywhere

### 3. Key–Value storage (basic operations)
- **Put (Save data)**
    ```dart
    box.put('name', 'Ali');
    ```
- **Get (Read data)**
    ```dart
    final name = box.get('name');
    ```
- **Delete**
    ```dart
    box.delete('name');
    ```
- **Clear entire box**
    ```dart
    box.clear();
    ```

### 4. LazyBox (for large data)
- Loads data only when needed.
- **When to use**
    - Large lists
    - Heavy cached data
    - Avoid memory pressure
        ```dart
        final box = await Hive.openLazyBox('bigCache');
        ```
### 5. TypeAdapter

### Storing lists and maps (API cache)
- **Example:** caching API response
    ```dart
    box.put('dashboardData', apiResponseJson);
    ```
- **Later:**
    ```dart
    final cached = box.get('dashboardData');
    ```
- **Why this is useful**
    - Instant UI load
    - Less API calls
    - Offline access

### Storing objects/models (production usage)
- This is where **TypeAdapter** comes in.

### TypeAdapter (MOST IMPORTANT FOR PRODUCTION)
- **Why TypeAdapter exists**
    - Hive cannot store custom objects directly.
- **Example model**
    ```dart
    class User {
    final int id;
    final String name;

    User(this.id, this.name);
    }
    ```
    - `Hive does NOT understand this yet.`
- **Create TypeAdapter**
    ```dart
    class UserAdapter extends TypeAdapter<User> {
    @override
    final int typeId = 1;

    @override
    User read(BinaryReader reader) {
        final id = reader.readInt();
        final name = reader.readString();
        return User(id, name);
    }

    @override
    void write(BinaryWriter writer, User obj) {
        writer.writeInt(obj.id);
        writer.writeString(obj.name);
    }
    }
    ```
- **Register adapter (once)**
    ```dart
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(ProfileAdapter());
    ```
    - This is done before opening boxes.
- **Store object**
    ```dart
    box.put('user', user);
    ```
- **Read object**
    ```dart
    final user = box.get('user') as User;
    ```
### typeId (CRITICAL RULE)
- A unique number that identifies your object type.
- **Rules:**
    - Must be unique
    - Never change once released
    - Use numbers like: `1, 2, 3, 4`
- Changing typeId in production = data corruption

### 6. HiveObject (optional but useful)
- Gives your object **database awareness**.
- **Example:**
    ```dart
    class User extends HiveObject {
    int id;
    String name;
    }
    ```
    - **Now you can:**
        ```dart
        user.save();
        user.delete();
        ```
    - **When to use**
        - When objects update themselves
        - Cleaner code
### Listening to changes (reactive UI)
- Auto-update UI when data changes.
    ```dart
    ValueListenableBuilder(
    valueListenable: box.listenable(),
    builder: (context, Box box, _) {
        return Text(box.get('name') ?? '');
    },
    );
    ```
    - Very useful in dashboards.

### 7. Box lifecycle (open / close)
```mathematica
App Start
    ↓
Hive init 
    ↓
Register adapters
    ↓
Open boxes (once)
    ↓
Read / Write / Listen
    ↓
(Optional) Close boxes
    ↓
App Termination
```
1. **Step 1:** Hive initialization
2. **Step 2:** Register adapters (before opening boxes)
    - **Rule:**
        - Adapters must be:
            - Registered once
            - Registered before opening any box that stores that type
3. **Step 3:** Opening a Box (CRITICAL STEP)
    - Opening a box means:
        - Hive loads metadata
        - Creates in-memory access
        - Prepares file locks
        - Makes box usable
            ```dart
            await Hive.openBox('userBox');
            ```
    - Important facts
        - Opening is async
        - Must complete before usage
        - Happens only once per box
    - **Production-safe approach**
        ```dart
        class HiveService {
        static Future<void> init() async {
            await Hive.openBox('userBox');
            await Hive.openBox('settingsBox');
            await Hive.openBox('cacheBox');
        }
        }
        ```
4. **Step 4:** Accessing an opened Box
    - **How to access**
        ```dart
        final userBox = Hive.box('userBox');
        ```
    - **Important**
        - Hive.box() does not open the box
        - It only retrieves an already opened box
    - **If box not opened**
        - ❌ Runtime error
5. **Step 5:** Using the Box (Read / Write phase)
    - **Write**
        ```dart
        userBox.put('name', 'Ali');
        ```
    - **Read**
        ```dart
        final name = userBox.get('name');
        ```
    - **Delete**
        ```dart
        userBox.delete('name');
        ```
    - **Clear entire box**
        ```dart
        userBox.clear();
        ```
6. **Step 6:** Listening to box changes
    - Enables reactive UI
    - Automatically updates widgets when data changes
        ```dart
        ValueListenableBuilder(
        valueListenable: userBox.listenable(),
        builder: (context, Box box, _) {
            return Text(box.get('name') ?? '');
        },
        );
        ```
    - Listening works only while box is open.
7. **Step 7:** LazyBox (special lifecycle)
    - What changes with LazyBox
        - Data is not fully loaded into memory
        - Values are loaded on demand
    - **Opening**
        ```dart
        await Hive.openLazyBox('bigCache');
        ```
    - **Access**
        ```dart
        final data = await box.get('largeItem');
        ```
    - **When to use**
        - Huge datasets
        - Avoid memory spikes
8. **Step 8:** Closing a Box (MOST CONFUSING PART)
    - **First:** Think of Hive like a cupboard
        - **Hive** = your house
        - **Box** = a cupboard in your house
        - **Data** = things inside the cupboard
    - When the app runs, you open the cupboard and use things from it.
    1. What does **OPEN a box** mean?
        ```dart
        await Hive.openBox('userBox');
        ```
        - **It means:**
            - `Open the cupboard so I can use things inside.`
        - After opening:
            - You can read data
            - You can save data
            - You can listen for changes
    2. What does **CLOSE a box** mean
        ```dart
        await box.close();
        ```
        - Lock the cupboard and put the key away
        - After closing:
            - ❌ You cannot read data
            - ❌ You cannot save data
            - ❌ Any screen using it will crash

        - So **closing is serious**.
    3. What really happens when you close a box? (Easy words)
        - When you close a box, Hive does 3 things:
            - Saves everything properly
            → `Make sure nothing is lost`
            - Frees memory
            → `Remove box from RAM`
            - Locks the file
            → `No one can touch it now`
    4. Should you close boxes in normal apps?
        - Short answer (remember this):
            - NO, usually you should NOT close boxes.
        - Why not?
            - Because mobile apps:
                - Don’t close properly like PC software
                - Stay running in background
                - Reopen screens again
            - If you close boxes:
                - App may still need data
                - Screen may still be listening
                - App will crash with Box is closed 
    5. ONLY close boxes in these situations
        1. **Case 1:** User LOGOUT
            - User logs out → we don’t need their data anymore.
                ```dart
                await userBox.clear(); // delete user data
                await userBox.close(); // lock cupboard
                ```
            - Why?
                - User session is finished
                - Next login should be clean
        2. **Case 2:** App Reset / Clear All Data
            - User presses:
                - “Reset App”
                - “Clear Offline Data”
            - You:
                - Delete all data
                - Close boxes
        3. **Case 3:** Sensitive data removal
            - If data is private (profile, cache):
                - Clear it
                - Close it
    6. What is **Hive.close()?** (GLOBAL CLOSE)
        ```dart
        await Hive.close();
        ```
        - **Lock ALL cupboards in the house.**
        - Used when:
            - App reset
            - Full logout
            - Debugging
            - Testing
        - Rare in normal app flow.
    7. What happens AFTER closing a box?
        - Once closed:
            - Box is DEAD
            - You must OPEN again to use
                ```dart
                await Hive.openBox('userBox');
                ```
        - If you don’t open again:
            - App will crash
    8. When should you NEVER close boxes? (COMMON MISTAKES)
        1. **Do NOT close after screen change**
            - Screens change but app is still running.
        2. **Do NOT close in dispose()**
            - Widget is destroyed, app is not.
        3. **Do NOT close after reading data**
            - Reading ≠ finishing work.
        4. **Do NOT close when app goes background**
            - App may come back in 1 second.
    9. GOLDEN RULE
        - `Open box once` → `Use everywhere` → `Close only on logout or reset`
### 8. Error handling & versioning
- **Why this matters:**
    - In development:
        - You clear app data
        - You reinstall the app
        - Everything works fine
    - In production:
        - Users already have data on their phones
        - You update the app
        - Old Hive data still exists

    - If Hive cannot read old data → **app crash at startup**
    - That’s why **error handling and versioning** are critical.
### PART A: `Error Handling in Hive`
1. Common Hive errors (what beginners usually face)
    - **Error 1:** Box not opened
        Cause
        ```dart
        Hive.box('userBox'); // but box was never opened
        ```
        - **Solution**
            - Always open boxes before access.
        - **Production pattern**
            - Open all boxes in one place (startup service).
    - **Error 2:** Adapter not registered
        - You forgot:
            ```dart
            Hive.registerAdapter(UserAdapter());
            ```
        - **Solution**
            - Register adapters before opening boxes
            - Do it once in main()
    - **Error 3:** typeId conflict
        - Two adapters use the same typeId.
        - **Solution**
            - Maintain a central list of typeIds
            - Never reuse an existing typeId
    - **Error 4:** Corrupted box data
        - Cause
            - App killed while writing  
            - Adapter structure changed incorrectly
            - Downgrade/upgrade issues
        - Symptom
            - Crash on openBox
            - Random read errors
2. Safe error handling (production-ready)
    - Wrap box opening in try–catch
        - App recovers instead of crashing
        - Worst case: cached data is lost (acceptable)
        ```dart
        Future<Box> safeOpenBox(String name) async {
        try {
            return await Hive.openBox(name);
        } catch (e) {
            await Hive.deleteBoxFromDisk(name);
            return await Hive.openBox(name);
        }
        }
        ```
3. Never crash the app for cache
    - **Golden rule**
        > Cache failure should never crash the app
    - If Hive fails:    
        - Clear cache
        - Re-fetch from API
        - Continue app

### PART B: `Versioning in Hive`
- Versioning means:
    > Managing data changes safely when your app updates
1. The biggest beginner mistake
    - Changing model fields without thinking:
        ```dart
        // OLD
        class User {
        int id;
        String name;
        }
        // NEW (BAD CHANGE)
        class User {
        int id;
        String fullName; // renamed
        }
        ```
    - This will **CRASH** on old devices.
2. How Hive stores data internally
    - Hive stores data in binary order, not by field name.
        - **So this:**
        ```dart
        writer.writeInt(obj.id);
        writer.writeString(obj.name);
        ```
        - **Must match exactly with:**
        ```dart
        reader.readInt();
        reader.readString();
        ```
3. Safe model evolution rules (MEMORIZE)
    - **Rule 1:** Never change write/read order
        - ❌ BAD
        ```dart
        writer.writeString(obj.name);
        writer.writeInt(obj.id);
        ```
    - **Rule 2:** Never delete fields abruptly
        - ❌ BAD<br>
            Remove:
        ```dart
        writer.writeString(obj.name);
        ```
    - **Rule 3:** Adding new fields is SAFE (with care)
        - **OLD**
        ```dart
        writer.writeInt(obj.id);
        writer.writeString(obj.name);
        ```
        - **NEW (SAFE)**
        ```dart
        writer.writeInt(obj.id);
        writer.writeString(obj.name);
        writer.writeString(obj.email); // new field
        ```
        - And while reading:
        ```dart
        final id = reader.readInt();
        final name = reader.readString();
        final email = reader.availableBytes > 0
            ? reader.readString()
            : '';
        ```
4. `typeId` versioning strategy (production)
    - Rule
        - typeId identifies the object type
        - NOT the version
    - Never do this
        ```dart
        // Keep typeId constant
        // Handle field evolution safely
        typeId = 1 → 2   // ❌
        ```