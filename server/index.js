// FILE: server.js
const express = require('express');
const app = express();
const bodyParser = require('body-parser');
const { v4: uuidv4 } = require('uuid');

app.use(bodyParser.json());

// In-memory datastore
let bookings = [];

//conflict helper
function hasConflict(startTime, endTime) {
    return bookings.some(booking => {
        return (
            (new Date(startTime) < new Date(booking.endTime)) &&
            (new Date(endTime) > new Date(booking.startTime))
        );
    });
}

// GET /bookings 
app.get('/bookings', (req, res) => {
    console.log("i am being hit!!!")
    res.json(bookings);
});

// GET /bookings/:bookingId 
app.get('/bookings/:bookingId', (req, res) => {
    const booking = bookings.find(b => b.id == req.params.bookingId);

    if (!booking) {
        return res.status(404).json({ error: 'Booking not found' });
    }
    res.json(booking);
});

// POST /bookings 
app.post('/bookings', (req, res) => {
    const { userId, startTime, endTime } = req.body;
    if (!userId || !startTime || !endTime) {
        return res.status(400).json({ error: 'Missing required fields' });
    }

    const start = new Date(startTime);
    const end = new Date(endTime);

    if (isNaN(start) || isNaN(end)) {
        return res.status(400).json({ error: 'Invalid date format' });
    }

    if (start >= end) {
        return res.status(400).json({ error: 'startTime must be before endTime' });
    }

    if (hasConflict(startTime, endTime)) {
        return res.status(403).json({ error: 'Booking conflict detected' });
    }

    const newBooking = {
        id: uuidv4(),
        userId,
        startTime,
        endTime
    };

    bookings.push(newBooking);
    console.log(newBooking)
    res.status(201).json(newBooking);
});

//DELETE /bookings/:bookingId 
app.delete('/bookings/:bookingId', (req, res) => {
    const index = bookings.findIndex(b => b.id === req.params.bookingId);
    if (index === -1) {
        return res.status(404).json({ error: 'Booking not found' });
    }
    bookings.splice(index, 1);
    res.status(204).send();
});


const PORT = process.env.PORT || 3000;
app.listen(PORT,'0.0.0.0' , () => {
    console.log(`Server running on port ${PORT}`);
});
