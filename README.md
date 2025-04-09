# Flutter Chat Application (Client)

Ini adalah aplikasi mobile Flutter untuk chatting real-time menggunakan Laravel (sebagai backend API), Socket.IO (untuk real-time komunikasi), dan Redis (sebagai message broker). 

## 📦 Struktur Layanan

Aplikasi ini bergantung pada dua endpoint utama:

| Service          | IP/Port              | Keterangan                     |
|------------------|----------------------|--------------------------------|
| Laravel API      | `http://172.27.4.120:8000/api` | Endpoint HTTP biasa untuk login, register, kirim pesan, dan ambil data kontak |
| Socket.IO Server | `http://172.27.4.120:8001`     | Komunikasi real-time via WebSocket (push message, subscribe channel) |

> ⚠️ **Catatan penting:** Pastikan alamat IP dan port tersebut sesuai dengan server Laravel dan Socket.IO yang sedang berjalan.

---

## 🔐 Autentikasi

Autentikasi ditangani oleh `AuthService`. Terdapat beberapa endpoint penting:

- **Login**: `POST /login`  
- **Register**: `POST /register`  
- **Me (Ambil data user)**: `GET /me`  
- **Logout**: `POST /logout`

Setelah login berhasil, token akan disimpan di local storage menggunakan `SharedPreferences`.

---

## 💬 Real-Time Chat

Chat real-time dikelola oleh `ChatService` dengan menggunakan `socket_io_client`.

### Koneksi

```dart
socket = io.io('http://172.27.4.120:8001', {
  'transports': ['websocket'],
  'autoConnect': false,
});
