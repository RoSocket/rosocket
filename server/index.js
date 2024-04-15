const express = require('express');
const WebSocket = require('ws');

const app = express();
app.use(express.json());
const port = 6214;

const connections = {};

function isValidWebSocketURL(url) {
    return url.startsWith("wss://");
}

function generateUUID() {
    return Math.random().toString(36).substring(2, 10);
} // TODO: remove this and use uuid npm package

function handleWebSocketConnection(UUID, socket) {
    socket.on('message', (message) => {
        if (connections[UUID]) {
            const messageString = message.toString();
            connections[UUID].messages.push({
                id: generateUUID(),
                message: messageString,
                step: connections[UUID].messages.length + 1
            });
        }
    });
   socket.on('error', (error) => {
        console.error(`WebSocket error for UUID: ${UUID}`, error);
        if (connections[UUID]) {
            connections[UUID].errors.push({
                id: generateUUID(),
                message: error,
                step: connections[UUID].errors.length + 1
            });
        }
    });
}


app.post('/connect', async (req, res) => {
    const { Socket } = req.body;
    if (!Socket) {
        return res.status(400).json({ success: false, error: "No WebSocket URL provided!" });
    }
    if (!isValidWebSocketURL(Socket)) {
        return res.status(400).json({ success: false, error: "Invalid WebSocket URL" });
    }

    const UUID = generateUUID();
    const socket = new WebSocket(Socket);

    try {
        await new Promise((resolve, reject) => {
            socket.on('error', (error) => {
                console.error(`WebSocket error for UUID: ${UUID}`, error);
                reject(error);
            });
            socket.on('open', () => {
                resolve();
            });
        });
    } catch (error) {
        return res.status(500).json({ success: false, error: "WebSocket connection error" });
    }

    connections[UUID] = { socket: socket, messages: [] };
    handleWebSocketConnection(UUID, socket);

    res.json({ UUID, Socket, success: true });
});


app.post('/disconnect', (req, res) => {
    const { UUID } = req.body;
    if (!UUID) {
        return res.status(400).json({ success: false, error: "No UUID provided!" });
    }
    if (!connections[UUID]) {
        return res.status(404).json({ success: false, error: "UUID not found" });
    }

    connections[UUID].socket.close();
    delete connections[UUID];

    res.json({ UUID, success: true });
});

app.post('/send', (req, res) => {
    const { UUID, Message } = req.body;
    if (!UUID || !Message) {
        return res.status(400).json({ success: false, error: "UUID or Message not provided!" });
    }
    if (!connections[UUID] || connections[UUID].socket.readyState !== WebSocket.OPEN) {
        return res.status(404).json({ success: false, error: "Invalid UUID or WebSocket connection closed" });
    }

    connections[UUID].socket.send(Message);
    res.json(true);
});

app.post('/get', (req, res) => {
    const { UUID } = req.body;
    if (!UUID) {
        return res.status(400).json({ success: false, error: "No UUID provided!" });
    }
    if (!connections[UUID]) {
        return res.status(404).json({ success: false, error: "Invalid UUID" });
    }

    res.json(connections[UUID].messages);
});
app.post('/errors', (req, res) => {
    const { UUID } = req.body;
    if (!UUID) {
        return res.status(400).json({ success: false, error: "No UUID provided!" });
    }
    if (!connections[UUID]) {
        return res.status(404).json({ success: false, error: "Invalid UUID" });
    }

    res.json(connections[UUID].errors);
});

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
