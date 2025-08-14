const express = require('express');
const cors = require('cors');
const fetch = require('node-fetch');

const app = express();
const PORT = 3001;

// 启用CORS
app.use(cors());
app.use(express.json());

// 通义千问API代理
app.post('/api/tongyi', async (req, res) => {
  try {
    const { message, apiKey } = req.body;
    
    if (!apiKey) {
      return res.status(400).json({ error: 'API密钥不能为空' });
    }

    const response = await fetch('https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`,
        'X-DashScope-SSE': 'disable',
      },
      body: JSON.stringify({
        model: 'qwen-turbo',
        input: {
          messages: [
            {
              role: 'system',
              content: '你是一个专业的旅游助手，专门为北京中轴线旅游提供帮助。你可以帮助用户规划旅行、推荐景点、提供文化背景信息等。请用简洁明了的中文回答，每次回答控制在200字以内。'
            },
            {
              role: 'user',
              content: message
            }
          ]
        },
        parameters: {
          temperature: 0.7,
          max_tokens: 500,
          result_format: 'message',
        }
      })
    });

    const data = await response.json();
    
    if (response.ok) {
      res.json(data);
    } else {
      res.status(response.status).json(data);
    }
  } catch (error) {
    console.error('代理服务器错误:', error);
    res.status(500).json({ error: '代理服务器内部错误' });
  }
});

app.listen(PORT, () => {
  console.log(`代理服务器运行在 http://localhost:${PORT}`);
});
