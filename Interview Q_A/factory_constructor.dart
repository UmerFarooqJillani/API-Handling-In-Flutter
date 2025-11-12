// Factory Constructor
/*
-> Factory Constructor?
  - A factory constructor is a special kind of constructor that doesn’t always create a new object,
    it can return an existing object, a subclass object, or even cache instances.
  - Factory constructors control how objects are created, unlike normal constructors which always 
    make a new instance.
-> Why we use factory constructors?
  We use factory when:
    1. You want to return an existing instance (Singleton pattern).
    2. You want to return a subclass object instead of the same class.
    3. You want conditional object creation (logic before creating).
    4. You want to cache and reuse objects.
-> Syntax:
    class ClassName {
      factory ClassName() {
        // logic before returning an object
        return ClassName._internal(); // can return same or new object
      }

      ClassName._internal(); // private named constructor
    }

-> Summary:
  - A factory constructor in Dart is used when you need more control over object creation.
  - It can return an existing instance, a subclass, or a cached object instead of always creating a new one.
  - We declare it using the factory keyword before the constructor.
*/

// -------------Example 1 – Singleton Pattern (Return Same Object)-----------------------------
// Use case: 
//    To ensure only one instance exists in memory (common in apps for managing API, DB, etc.)

// class Database {
//   static final Database _instance = Database._internal();

//   factory Database() {
//     return _instance; // always returns same instance
//   }

//   Database._internal(); // private constructor

//   void connect() => print("Database connected!");
// }

// void main() {
//   var db1 = Database();
//   var db2 = Database();

//   print(db1 == db2); // true ✅ same object
// }

// -------------Example 2 – Conditional Object Creation-----------------------------
// Use case:
//    Useful for returning different subclass objects based on some condition (like “factory design pattern”).

// class Shape {
//   factory Shape(String type) {
//     if (type == 'circle') return Circle();
//     if (type == 'square') return Square();
//     throw ArgumentError('Invalid shape type');
//   }
// }

// class Circle extends Shape {
//   Circle() : super('circle');
// }
// class Square extends Shape {
//   Square() : super('square');
// }

// void main() {
//   var shape = Shape('circle'); // returns Circle()
//   print(shape.runtimeType); // Circle
// }
// -------------Example 3 – Object Caching-----------------------------
// Use case:
//    To avoid duplicate objects and improve memory efficiency.

class User {
  static final Map<String, User> _cache = {};

  final String name;

  factory User(String name) {
    // return from cache if already created
    if (_cache.containsKey(name)) return _cache[name]!;
    final user = User._internal(name);
    _cache[name] = user;
    return user;
  }

  User._internal(this.name);
}

void main() {
  var u1 = User("Ali");
  var u2 = User("Ali");

  print(identical(u1, u2)); // true ✅ (cached)
}
// -----------------------------(factory constructors in widgets)--------------------------------
// 
/*
In Flutter, you’ll often see factory constructors in widgets, e.g.:

  const factory Icon(IconData icon, {Key? key, double? size}) = _Icon;
  
This allows Flutter to optimize widget creation and reuse immutable instances.
*/
