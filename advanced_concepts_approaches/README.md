# <p align="center"> advanced_concepts_approaches </p>

## Difference between `FutureBuilder` and `StreamBuilder`?

### FutureBuilder
- Used when we deal with a single future value, something that happens **once and then completes**.
- **Example:** Fetching data once from an API endpoint (API call, database fetch, single operation).
```dart
Future<List<User>> fetchUsers() async {
  final response = await http.get(Uri.parse('https://reqres.in/api/users'));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return (data['data'] as List).map((e) => User.fromJson(e)).toList();
  } else {
    throw Exception('Failed to load users');
  }
}

@override
Widget build(BuildContext context) {
  return FutureBuilder<List<User>>(
    future: fetchUsers(), // future is executed once
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (snapshot.hasData) {
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(snapshot.data![index].firstName),
            );
          },
        );
      } else {
        return Center(child: Text('No data found'));
      }
    },
  );
}
```
- When fetchUsers() is called, a Future starts (HTTP request sent).
- When the response arrives, Flutter rebuilds the widget with the fetched data.
### StreamBuilder
- Used when we deal with a stream of continuous data, data that keeps **changing or updating over time**.
- **Example:** Real-time chat messages, live sensor data, or a Firebase stream that updates automatically when the backend changes.
```dart
Stream<int> counterStream() async* {
  for (int i = 1; i <= 5; i++) {
    await Future.delayed(Duration(seconds: 1));
    yield i; // send data every second
  }
}

@override
Widget build(BuildContext context) {
  return StreamBuilder<int>(
    stream: counterStream(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: Text('Waiting for data...'));
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (snapshot.hasData) {
        return Center(child: Text('Current Value: ${snapshot.data}'));
      } else {
        return Center(child: Text('No Data'));
      }
    },
  );
}
```
- When the stream emits a new value (from server, socket, Firebase), Flutter automatically rebuilds the UI with the updated data.
- You don’t need to manually call setState().
