const express = require('express');
const axios = require('axios');
const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

app.post('/proxy', async (req, res) => {
    const { url, data } = req.body; // Ожидаем URL и данные (userIds) в теле запроса
    console.log('Запрос:', url, 'Данные:', data); // Для отладки
    if (!url || !data) {
        return res.status(400).json({ error: 'URL and data are required' });
    }
    try {
        const response = await axios.post(url, data, {
            headers: {
                'User-Agent': 'Roblox/Studio',
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            }
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

// Для обратной совместимости оставим GET, если нужно
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
    console.log(`Proxy server running on port ${port}`);
});
