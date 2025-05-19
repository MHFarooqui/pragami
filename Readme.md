# Calendar Booking App

This is a full-stack Calendar Booking application developed using **Flutter** for the frontend and **Node.js + Express + PostgreSQL** for the backend. It allows users to create, list, and delete room bookings with proper conflict checks to prevent overlapping.

---

## 🚀 Features

* Create bookings with user ID, start time, and end time
* View all existing bookings
* Delete bookings
* Automatic refresh after booking creation or deletion
* Responsive and simple Flutter UI
* Booking conflict detection in backend

---

## 📚 Tech Stack

### Frontend:

* **Flutter**
* HTTP client (`package:http`)

### Backend:

* **Node.js**
* **Express**
* **PostgreSQL**

---

## 📂 API Endpoints

### Base URL

```
http://<your-local-ip>:3000
```

### GET `/bookings`

**Description**: Fetch all bookings.

**Response:**

```json
[
  {
    "id": "uuid",
    "userId": "user123",
    "startTime": "2024-06-01T10:00:00.000Z",
    "endTime": "2024-06-01T11:00:00.000Z"
  },
  ...
]
```

---

### POST `/bookings`

**Description**: Create a new booking.

**Body:**

```json
{
  "userId": "user123",
  "startTime": "2024-06-01T10:00:00.000Z",
  "endTime": "2024-06-01T11:00:00.000Z"
}
```

**Responses:**

* `201 Created`: Booking successful
* `403 Forbidden`: Booking conflict

---

### DELETE `/bookings/:id`

**Description**: Delete a booking by ID.

**Response:**

* `200 OK`: Booking deleted
* `404 Not Found`: Booking ID not found

---

## 🎓 How to Run

### Backend

```bash
cd backend
npm install
node index.js
```

Make sure PostgreSQL is set up and configured with a `bookings` table:

```sql
CREATE TABLE bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  userId TEXT NOT NULL,
  startTime TIMESTAMP NOT NULL,
  endTime TIMESTAMP NOT NULL
);
```

### Frontend

```bash
cd frontend
flutter pub get
flutter run
```

Make sure the base URL in your Flutter app matches the backend server IP.

---

## 📦 Folder Structure

```
project-root/
  ├── backend/
  │   ├── index.js
  │   └── ...
  ├── frontend/
  │   ├── lib/
  │   │   ├── main.dart
  │   │   └── Screens/
  │   │       └── CreateBooking.dart
  └── README.md
```

---


