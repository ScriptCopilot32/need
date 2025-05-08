// server.js
const express = require('express');
const axios = require('axios');
const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

app.get('/proxy', async (req, res) => {
    const url = req.query.url;
    console.log('Запрос:', url); // Для отладки
    if (!url) {
        return res.status(400).json({ error: 'URL is required' });
    }
    try {
        const response = await axios.get(url, {
            headers: { 'User-Agent': 'Roblox/Studio' }
        });
        res.json(response.data);
    } catch (error) {
        console.error('Ошибка:', error.message, error.response?.status); // Для отладки
        res.status(error.response?.status || 500).json({
            error: error.message,
            status: error.response?.status
        });
    }
});

app.listen(port, () => {
    console.log(Proxy server running on port ${port}); // Исправлено
});
