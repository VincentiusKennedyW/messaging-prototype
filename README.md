# Flutter Chat Application

Flutter chatting real-time using Laravel (backend API), Socket.IO (real-time communication) and Redis (message broker).

## App Structure

Two main endpoint:

| Service          | IP/Port              | Description                     |
|------------------|----------------------|--------------------------------|
| Laravel API      | `http://172.27.4.120:8000/api` | Endpoint HTTP for authentication, send message, get contact, etc|
| Socket.IO Server | `http://172.27.4.120:8001`     | Real-time communication via WebSocket (push message, subscribe channel) |

> ⚠️ **NOTICE:** Make sure the IP and Port match with Laravel server and Socket.IO.
---

## Real-Time Chat

In `ChatService` make sure the IP:Port is matching with Socket.IO.

### Connection to Socket.IO

```dart
socket = io.io('http://172.27.4.120:8001', {
  'transports': ['websocket'],
  'autoConnect': false,
});
