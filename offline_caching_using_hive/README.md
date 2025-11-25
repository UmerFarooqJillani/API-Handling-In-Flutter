# <p align="center"> Offline Cache System (Hive + Riverpod) </p>

## Offline caching means:
- Your app can show local saved data even when internet is OFF, and will update only when internet is available.
- This improves:
    - Speed (no need to call API every time)
    - Lower API cost
    - Better user experience
    - Offline support

## Why caching is important? (Real world example)
- **A User List App**
- **First time:** fetch from API
- **Next times:** show stored data quickly, no loading indicator
- **If internet OFF:** still show last saved users
    - **Without caching:** your app shows empty screen when offline
    - **With caching:** app WORKS offline

## Why use Hive for caching?
- Extremely fast (Native binary storage)
- Supports custom model (adapters)
- Supports offline persistence
- Works great with Riverpod
- Easy to use

## 