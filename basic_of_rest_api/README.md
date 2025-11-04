# <p align="center"> basic_of_rest_api </p>

## What is a REST API?
- REST API (Representational State Transfer API) is a set of rules that define how two systems (your Flutter app and a server) can talk to each other using HTTP.
- It uses URLs + HTTP Methods (GET, POST, PUT, DELETE) to perform operations on resources like users, posts, products, etc.<br>
**Example:**
    ```dart
    GET https://api.example.com/users      → Get all users
    GET https://api.example.com/users/1    → Get one user
    POST https://api.example.com/users     → Add new user
    PUT https://api.example.com/users/1    → Update user 1
    DELETE https://api.example.com/users/1 → Delete user 1
    ```
## REST API = Client + Server Architecture
- **Client (Frontend)**	Your Flutter app (sends requests)
- **Server (Backend)** The API hosted on a web server (responds)
- **Database** Where real data is stored (MySQL, MongoDB, etc.)
- Communication Flow:
    1. User performs action → Flutter app sends an HTTP request.
    2. Server processes the request.
    3. Server sends a response (usually in JSON).
    4. Flutter displays the data.
## REST API URL Structure<br>
**https** Protocol (secure web request)<br>
**api.example.com**	Domain (server host)<br>
**/users** Resource (what data you want)<br>
**/1** Specific resource ID<br>
**Example:**
```dart
https://api.example.com/users/1
```
## REST API vs GraphQL vs SOAP
- Data format	
    - REST & GraphQL	
        - JSON	
    - SOAP
        - XML
- Request type
    - REST
        - Multiple endpoints	
	- GraphQL
        - Single endpoint with queries	
	- SOAP
        - Single
- Flexibility
    - REST
        - Fixed response
    - GraphQL
        - Client defines data	
    - SOAP
        - Rigid
- Common in Flutter?	
	- REST
        - Yes	
    - GraphQL
        - Sometimes
    - SOAP
        - Rare
## REST API Integration Flow in Flutter
1. Create a model (representing JSON)
2. Create a service/repository (calls API)
3. Manage state with Riverpod / FutureProvider
4. Show results in UI
## REST API Security (Important)
- APIs must be secure, especially when dealing with user info.
- Technique:
    - Bearer Token
        - **Header:** Authorization (Bearer xyz123)
    - API Key
        - **Header:** x-api-key (x-api-key: abcd1234)
    - OAuth2
        - **Header:** Access + Refresh tokens (Google login)
    - HTTPS
        - **Header:** Encrypted connection (https://)
