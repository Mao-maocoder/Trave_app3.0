require('dotenv').config();
const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
const sqlite3 = require('sqlite3').verbose();
const db = new sqlite3.Database(path.join(__dirname, 'travel_app.db'));
const multer = require('multer');
const { initializeDatabase } = require('./database');
const UserDao = require('./dao/userDao');
const axios = require('axios');
const crypto = require('crypto');
const app = express();
const jwt = require('jsonwebtoken');
const JWT_SECRET = process.env.JWT_SECRET || 'your_jwt_secret_key';
const fetch = require('node-fetch');

// 全局CORS中间件，允许所有来源
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET,POST,PUT,DELETE,OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type,Authorization');
  next();
});

app.use(express.json());

// 静态文件服务 - 提供上传的图片
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// 添加请求日志中间件
app.use((req, res, next) => {
  const timestamp = new Date().toLocaleString('zh-CN');
  console.log(`[${timestamp}] ${req.method} ${req.url}`);
  if (req.method === 'POST' && req.body) {
    console.log('请求数据:', JSON.stringify(req.body, null, 2));
  }
  next();
});

// 配置文件上传
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadDir = 'uploads/photos';
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({ 
  storage: storage,
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB限制
  },
  fileFilter: function (req, file, cb) {
    // 修复中文文件名编码问题
    try {
      file.originalname = Buffer.from(file.originalname, 'latin1').toString('utf8');
    } catch (e) {
      // 如果转换失败，保持原文件名
      console.log('文件名编码转换失败，保持原文件名');
    }

    console.log('🔍 文件过滤器检查:');
    console.log('- 文件名:', file.originalname);
    console.log('- MIME类型:', file.mimetype);
    console.log('- 字段名:', file.fieldname);

    // 检查MIME类型或文件扩展名
    const isImage = file.mimetype.startsWith('image/') ||
                   /\.(jpg|jpeg|png|gif|webp|bmp)$/i.test(file.originalname);

    if (isImage) {
      console.log('✅ 文件类型验证通过');
      cb(null, true);
    } else {
      console.log('❌ 文件类型验证失败');
      cb(new Error('只允许上传图片文件'), false);
    }
  }
});

// 问卷提交接口
app.post('/api/survey/submit', async (req, res) => {
  const submission = req.body;
  const userId = req.body.userId; // 从请求中获取用户ID
  
  console.log('📝 收到新的问卷提交:');
  console.log('- 用户ID:', userId);
  console.log('- 兴趣爱好:', submission.interests);
  console.log('- 饮食偏好:', submission.diets);
  console.log('- 健康状况:', submission.health);
  console.log('- 期望体验:', submission.expect);
  console.log('- 性别:', submission.gender);
  console.log('- 年龄组:', submission.ageGroup);
  console.log('- 月收入:', submission.monthlyIncome);
  console.log('- 文化认同:', submission.culturalIdentity);
  console.log('- 心理特征:', submission.psychologicalTraits);
  console.log('- 旅行频率:', submission.travelFrequency);
  console.log('- 建议:', submission.suggestion);

  try {
    // 保存问卷数据到数据库
    const sql = `
      INSERT INTO survey_submissions (user_id, interests, diets, health, expect, gender, age_group, monthly_income, cultural_identity, psychological_traits, travel_frequency, suggestion)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;
    
    const interests = Array.isArray(submission.interests) ? submission.interests.join(',') : submission.interests;
    const diets = Array.isArray(submission.diets) ? submission.diets.join(',') : submission.diets;
    const psychologicalTraits = Array.isArray(submission.psychologicalTraits) ? submission.psychologicalTraits.join(',') : submission.psychologicalTraits;
    
    db.run(sql, [
      userId,
      interests,
      diets,
      submission.health,
      submission.expect,
      submission.gender,
      submission.ageGroup,
      submission.monthlyIncome,
      submission.culturalIdentity,
      psychologicalTraits,
      submission.travelFrequency,
      submission.suggestion
    ], async function(err) {
      if (err) {
        console.error('❌ 保存问卷失败:', err);
        res.status(500).json({ success: false, message: '问卷保存失败' });
        return;
      }
      
      // 更新用户的问卷完成状态
      try {
        await UserDao.updateSurveyCompletionStatus(userId, true);
        console.log('✅ 用户问卷完成状态已更新');
      } catch (updateErr) {
        console.error('❌ 更新用户问卷状态失败:', updateErr);
      }
      
      console.log(`✅ 问卷已保存到数据库，ID: ${this.lastID}`);
      res.json({ success: true, message: '问卷提交成功' });
    });
    
  } catch (error) {
    console.error('❌ 问卷提交处理失败:', error);
    res.status(500).json({ success: false, message: '问卷提交失败' });
  }
});

// 问卷统计接口
app.get('/api/survey/stats', (req, res) => {
  let submissions = [];
  try {
    submissions = JSON.parse(fs.readFileSync('survey_submissions.json'));
  } catch (e) {}

  console.log(`📊 生成问卷统计，共 ${submissions.length} 份提交`);

  // 统计各项数据
  const interest = {};
  const diets = {};
  const expect = {};
  const gender = {};
  const ageGroup = {};
  const monthlyIncome = {};
  const culturalIdentity = {};
  const psychologicalTraits = {};
  const travelFrequency = {};

  submissions.forEach(s => {
    // 兴趣爱好
    (s.interests || []).forEach(i => interest[i] = (interest[i] || 0) + 1);

    // 饮食偏好
    (s.diets || []).forEach(d => diets[d] = (diets[d] || 0) + 1);

    // 期望体验
    if (s.expect) expect[s.expect] = (expect[s.expect] || 0) + 1;

    // 性别
    if (s.gender) gender[s.gender] = (gender[s.gender] || 0) + 1;

    // 年龄组
    if (s.ageGroup) ageGroup[s.ageGroup] = (ageGroup[s.ageGroup] || 0) + 1;

    // 月收入
    if (s.monthlyIncome) monthlyIncome[s.monthlyIncome] = (monthlyIncome[s.monthlyIncome] || 0) + 1;

    // 文化认同
    if (s.culturalIdentity) culturalIdentity[s.culturalIdentity] = (culturalIdentity[s.culturalIdentity] || 0) + 1;

    // 心理特征
    (s.psychologicalTraits || []).forEach(p => psychologicalTraits[p] = (psychologicalTraits[p] || 0) + 1);

    // 旅行频率
    if (s.travelFrequency) travelFrequency[s.travelFrequency] = (travelFrequency[s.travelFrequency] || 0) + 1;
  });

  const stats = {
    total: submissions.length,
    interest,
    diets,
    expect,
    gender,
    ageGroup,
    monthlyIncome,
    culturalIdentity,
    psychologicalTraits,
    travelFrequency
  };

  console.log('📈 统计结果:', JSON.stringify(stats, null, 2));
  res.json(stats);
});

// 提交评价接口
app.post('/api/feedback/submit', async (req, res) => {
  try {
    const { userId, username, rating, content, category = 'general' } = req.body;

    console.log('⭐ 收到评价提交:');
    console.log('- 用户ID:', userId);
    console.log('- 用户名:', username);
    console.log('- 评分:', rating);
    console.log('- 内容:', content);
    console.log('- 类别:', category);

    // 验证评分范围
    if (rating < 1 || rating > 5) {
      return res.status(400).json({
        success: false,
        message: '评分必须在1-5之间'
      });
    }

    // 创建评价记录
    const feedback = {
      id: Date.now().toString(),
      userId: userId,
      username: username,
      rating: rating,
      content: content,
      category: category,
      submittedAt: new Date().toISOString(),
      status: 'pending', // 待导游审核
      reward: null // 奖励信息
    };

    // 保存评价到文件
    let feedbacks = [];
    try {
      feedbacks = JSON.parse(fs.readFileSync('feedbacks.json'));
    } catch (e) {}

    feedbacks.push(feedback);
    fs.writeFileSync('feedbacks.json', JSON.stringify(feedbacks, null, 2));

    console.log(`✅ 评价提交成功，评价ID: ${feedback.id}`);

    res.json({
      success: true,
      message: '评价提交成功，感谢您的反馈！',
      feedbackId: feedback.id
    });

  } catch (error) {
    console.error('❌ 评价提交失败:', error);
    res.status(500).json({
      success: false,
      message: '评价提交失败，请稍后重试'
    });
  }
});

// 获取评价列表接口（导游查看）
app.get('/api/feedback/list', (req, res) => {
  try {
    let feedbacks = [];
    try {
      feedbacks = JSON.parse(fs.readFileSync('feedbacks.json'));
    } catch (e) {}

    const { status, page = 1, limit = 20 } = req.query;
    
    // 过滤评价
    let filteredFeedbacks = feedbacks;
    if (status) {
      filteredFeedbacks = filteredFeedbacks.filter(feedback => feedback.status === status);
    }
    
    // 按时间倒序排列
    filteredFeedbacks.sort((a, b) => new Date(b.submittedAt) - new Date(a.submittedAt));
    
    // 分页
    const startIndex = (page - 1) * limit;
    const endIndex = startIndex + parseInt(limit);
    const paginatedFeedbacks = filteredFeedbacks.slice(startIndex, endIndex);
    
    res.json({
      success: true,
      feedbacks: paginatedFeedbacks,
      total: filteredFeedbacks.length,
      page: parseInt(page),
      limit: parseInt(limit),
      totalPages: Math.ceil(filteredFeedbacks.length / limit)
    });
  } catch (error) {
    console.error('❌ 获取评价列表失败:', error);
    res.status(500).json({
      success: false,
      message: '获取评价列表失败'
    });
  }
});

// 处理评价接口（导游审核和奖励）
app.post('/api/feedback/:feedbackId/process', (req, res) => {
  try {
    const { feedbackId } = req.params;
    const { action, reward, message } = req.body;

    console.log('🔧 处理评价:');
    console.log('- 评价ID:', feedbackId);
    console.log('- 操作:', action);
    console.log('- 奖励:', reward);
    console.log('- 消息:', message);

    let feedbacks = [];
    try {
      feedbacks = JSON.parse(fs.readFileSync('feedbacks.json'));
    } catch (e) {}

    const feedbackIndex = feedbacks.findIndex(f => f.id === feedbackId);
    if (feedbackIndex === -1) {
      return res.status(404).json({
        success: false,
        message: '评价不存在'
      });
    }

    const feedback = feedbacks[feedbackIndex];
    
    if (action === 'approve') {
      feedback.status = 'approved';
      feedback.processedAt = new Date().toISOString();
      feedback.reward = reward || null;
      feedback.guideMessage = message || null;
      
      console.log(`✅ 评价已批准，用户: ${feedback.username}`);
    } else if (action === 'reject') {
      feedback.status = 'rejected';
      feedback.processedAt = new Date().toISOString();
      feedback.guideMessage = message || '评价不符合要求';
      
      console.log(`❌ 评价已拒绝，用户: ${feedback.username}`);
    }

    fs.writeFileSync('feedbacks.json', JSON.stringify(feedbacks, null, 2));

    res.json({
      success: true,
      message: action === 'approve' ? '评价已批准' : '评价已拒绝',
      feedback: feedback
    });

  } catch (error) {
    console.error('❌ 处理评价失败:', error);
    res.status(500).json({
      success: false,
      message: '处理评价失败'
    });
  }
});

// 反馈统计接口
app.get('/api/feedback/stats', (req, res) => {
  try {
    let feedbacks = [];
    try {
      feedbacks = JSON.parse(fs.readFileSync('feedbacks.json'));
    } catch (e) {}

    // 计算评分分布
    const ratings = {};
    const comments = [];
    
    feedbacks.forEach(feedback => {
      if (feedback.status === 'approved') {
        // 统计评分
        ratings[feedback.rating] = (ratings[feedback.rating] || 0) + 1;
        
        // 收集评论
        comments.push({
          user: feedback.username,
          score: feedback.rating,
          content: feedback.content,
          submittedAt: feedback.submittedAt
        });
      }
    });

    const feedbackData = {
      ratings: ratings,
      comments: comments
    };
    
    console.log('📊 返回反馈统计数据:', JSON.stringify(feedbackData, null, 2));
    res.json(feedbackData);
  } catch (error) {
    console.error('❌ 反馈统计接口错误:', error.message);
    res.status(500).json({
      success: false,
      message: '获取反馈统计失败',
      error: error.message
    });
  }
});

// 获取用户奖励接口
app.get('/api/feedbacks/user/:userId/rewards', (req, res) => {
  try {
    const { userId } = req.params;
    console.log(`🎁 查询用户奖励，用户ID: ${userId}`);

    let feedbacks = [];
    try {
      feedbacks = JSON.parse(fs.readFileSync('feedbacks.json'));
    } catch (e) {}

    // 获取该用户的所有反馈（包括待处理和已处理的）
    const userFeedbacks = feedbacks.filter(feedback => feedback.userId === userId);
    
    // 转换为奖励格式
    const rewards = userFeedbacks.map(feedback => ({
      id: feedback.id,
      feedbackContent: feedback.content,
      rating: feedback.rating,
      status: feedback.status,
      reward: feedback.reward,
      message: feedback.guideMessage,
      createdAt: feedback.submittedAt,
      processedAt: feedback.processedAt
    }));

    console.log(`✅ 用户 ${userId} 的奖励查询完成，共 ${rewards.length} 条记录`);
    
    res.json({
      success: true,
      rewards: rewards
    });
  } catch (error) {
    console.error('❌ 获取用户奖励失败:', error.message);
    res.status(500).json({
      success: false,
      message: '获取用户奖励失败',
      error: error.message
    });
  }
});

// 照片上传接口
app.post('/api/photos/upload', upload.array('photos', 10), (req, res) => {
  try {
    console.log('📸 收到照片上传请求:');
    console.log('- 文件数量:', req.files?.length || 0);
    console.log('- 景点名称:', req.body.spotName);
    console.log('- 上传者:', req.body.uploader);
    console.log('- 用户角色:', req.body.userRole);
    console.log('- 标题:', req.body.title);
    console.log('- 描述:', req.body.description);

    const uploadedPhotos = [];
    const userRole = req.body.userRole || 'tourist';
    const spotName = req.body.spotName || '未知景点';
    
    req.files.forEach(file => {
      const photoData = {
        id: Date.now() + Math.random().toString(36).substr(2, 9),
        filename: file.filename,
        originalName: file.originalname,
        path: `/uploads/photos/${file.filename}`,
        spotName: spotName,
        uploader: req.body.uploader || 'anonymous',
        userRole: userRole,
        uploadTime: new Date().toISOString(),
        status: userRole === 'guide' ? 'approved' : 'pending', // 导游上传直接审核通过
        title: req.body.title || file.originalname,
        description: req.body.description || ''
      };
      
      uploadedPhotos.push(photoData);
    });
    
    // 保存照片信息到文件
    let photos = [];
    try {
      photos = JSON.parse(fs.readFileSync('photos.json'));
    } catch (e) {}
    
    photos.push(...uploadedPhotos);
    fs.writeFileSync('photos.json', JSON.stringify(photos, null, 2));

    console.log(`✅ 照片上传成功! 上传了 ${uploadedPhotos.length} 张照片`);
    uploadedPhotos.forEach((photo, index) => {
      console.log(`   ${index + 1}. ${photo.originalName} -> ${photo.filename}`);
    });
    console.log(`📊 照片库总数: ${photos.length}`);

    res.json({
      success: true,
      message: '照片上传成功',
      photos: uploadedPhotos
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: '照片上传失败',
      error: error.message
    });
  }
});

// 获取照片列表接口
app.get('/api/photos', (req, res) => {
  try {
    let photos = [];
    try {
      photos = JSON.parse(fs.readFileSync('photos.json'));
    } catch (e) {}
    
    const { status, spotName, uploader, page = 1, limit = 20 } = req.query;
    
    // 过滤照片
    let filteredPhotos = photos;
    if (status) {
      filteredPhotos = filteredPhotos.filter(photo => photo.status === status);
    }
    if (spotName) {
      filteredPhotos = filteredPhotos.filter(photo => photo.spotName === spotName);
    }
    if (uploader) {
      filteredPhotos = filteredPhotos.filter(photo => photo.uploader === uploader);
    }
    
    // 分页
    const startIndex = (page - 1) * limit;
    const endIndex = startIndex + parseInt(limit);
    const paginatedPhotos = filteredPhotos.slice(startIndex, endIndex);
    
    res.json({
      success: true,
      photos: paginatedPhotos,
      total: filteredPhotos.length,
      page: parseInt(page),
      limit: parseInt(limit),
      totalPages: Math.ceil(filteredPhotos.length / limit)
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: '获取照片列表失败',
      error: error.message
    });
  }
});

// 照片审核接口
app.post('/api/photos/:photoId/review', (req, res) => {
  try {
    const { photoId } = req.params;
    const { status, reason } = req.body;
    
    let photos = [];
    try {
      photos = JSON.parse(fs.readFileSync('photos.json'));
    } catch (e) {}
    
    const photoIndex = photos.findIndex(photo => photo.id === photoId);
    if (photoIndex === -1) {
      return res.status(404).json({
        success: false,
        message: '照片不存在'
      });
    }
    
    photos[photoIndex].status = status;
    photos[photoIndex].reviewTime = new Date().toISOString();
    photos[photoIndex].reviewReason = reason;
    
    fs.writeFileSync('photos.json', JSON.stringify(photos, null, 2));
    
    res.json({
      success: true,
      message: '审核完成',
      photo: photos[photoIndex]
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: '审核失败',
      error: error.message
    });
  }
});

// 删除照片接口
app.delete('/api/photos/:photoId', (req, res) => {
  try {
    const { photoId } = req.params;
    
    let photos = [];
    try {
      photos = JSON.parse(fs.readFileSync('photos.json'));
    } catch (e) {}
    
    const photoIndex = photos.findIndex(photo => photo.id === photoId);
    if (photoIndex === -1) {
      return res.status(404).json({
        success: false,
        message: '照片不存在'
      });
    }
    
    const photo = photos[photoIndex];
    
    // 删除文件
    try {
      const filePath = path.join(__dirname, photo.path);
      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
      }
    } catch (e) {
      console.log('文件删除失败:', e.message);
    }
    
    // 从列表中移除
    photos.splice(photoIndex, 1);
    fs.writeFileSync('photos.json', JSON.stringify(photos, null, 2));
    
    res.json({
      success: true,
      message: '照片删除成功'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: '删除失败',
      error: error.message
    });
  }
});

// 照片统计接口
app.get('/api/photos/stats', (req, res) => {
  try {
    let photos = [];
    try {
      photos = JSON.parse(fs.readFileSync('photos.json'));
    } catch (e) {}
    
    const stats = {
      total: photos.length,
      pending: photos.filter(p => p.status === 'pending').length,
      approved: photos.filter(p => p.status === 'approved').length,
      rejected: photos.filter(p => p.status === 'rejected').length,
      bySpot: {},
      byUploader: {}
    };
    
    // 按景点统计
    photos.forEach(photo => {
      stats.bySpot[photo.spotName] = (stats.bySpot[photo.spotName] || 0) + 1;
      stats.byUploader[photo.uploader] = (stats.byUploader[photo.uploader] || 0) + 1;
    });
    
    res.json({
      success: true,
      stats: stats
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: '获取统计失败',
      error: error.message
    });
  }
});

// 用户注册接口
app.post('/api/auth/register', async (req, res) => {
  try {
    const { username, email, password, role = 'tourist' } = req.body;

    console.log('👤 收到用户注册请求:');
    console.log('- 用户名:', username);
    console.log('- 邮箱:', email);
    console.log('- 角色:', role);

    // 检查用户名是否已存在
    const usernameExists = await UserDao.checkUsernameExists(username);
    if (usernameExists) {
      return res.status(400).json({
        success: false,
        message: '用户名已存在'
      });
    }

    // 检查邮箱是否已存在
    const emailExists = await UserDao.checkEmailExists(email);
    if (emailExists) {
      return res.status(400).json({
        success: false,
        message: '邮箱已存在'
      });
    }

    // 创建新用户
    const newUser = await UserDao.createUser({
      username,
      email,
      password, // 实际项目中应该加密密码
      role
    });

    console.log(`✅ 用户注册成功! 用户ID: ${newUser.id}`);

    // 返回用户信息（不包含密码）
    const { password: _, ...userWithoutPassword } = newUser;
    const responseUser = {
      id: userWithoutPassword.id.toString(),
      username: userWithoutPassword.username,
      email: userWithoutPassword.email,
      avatar: userWithoutPassword.avatar,
      role: userWithoutPassword.role,
      hasCompletedSurvey: Boolean(userWithoutPassword.has_completed_survey),
      isActive: Boolean(userWithoutPassword.is_active),
      createdAt: userWithoutPassword.created_at ? new Date(userWithoutPassword.created_at + 'Z').toISOString() : new Date().toISOString()
    };

    console.log('📤 返回用户数据:', responseUser);

    res.json({
      success: true,
      message: '注册成功',
      user: responseUser
    });

  } catch (error) {
    console.error('❌ 用户注册失败:', error);
    res.status(500).json({
      success: false,
      message: '注册失败'
    });
  }
});

// 用户登录接口
app.post('/api/auth/login', async (req, res) => {
  try {
    const { username, password } = req.body;

    console.log('🔐 收到用户登录请求:');
    console.log('- 用户名:', username);

    // 查找用户
    const user = await UserDao.findUserByCredentials(username, password);

    if (!user) {
      console.log('❌ 登录失败: 用户名或密码错误');
      return res.status(401).json({
        success: false,
        message: '用户名或密码错误'
      });
    }

    if (!user.is_active) {
      console.log('❌ 登录失败: 用户已被禁用');
      return res.status(401).json({
        success: false,
        message: '用户已被禁用'
      });
    }

    console.log(`✅ 用户登录成功! 用户: ${user.username}, 角色: ${user.role}`);

    // 生成 JWT token
    const token = jwt.sign({ id: user.id, username: user.username, role: user.role }, JWT_SECRET, { expiresIn: '7d' });

    // 返回用户信息和 token
    const responseUser = {
      id: user.id.toString(),
      username: user.username,
      email: user.email,
      avatar: user.avatar,
      role: user.role,
      hasCompletedSurvey: Boolean(user.has_completed_survey),
      isActive: Boolean(user.is_active),
      createdAt: user.created_at ? new Date(user.created_at + 'Z').toISOString() : new Date().toISOString()
    };

    console.log('📤 返回用户数据:', responseUser);

    res.json({
      success: true,
      message: '登录成功',
      user: responseUser,
      token
    });

  } catch (error) {
    console.error('❌ 用户登录失败:', error);
    res.status(500).json({
      success: false,
      message: '登录失败'
    });
  }
});

// JWT 校验中间件
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) return res.status(401).json({ success: false, message: '未提供 token' });
  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ success: false, message: 'token 无效或已过期' });
    req.user = user;
    next();
  });
}

// 获取用户列表接口（仅导游可访问）
app.get('/api/users', authenticateToken, async (req, res) => {
  try {
    console.log('👥 获取用户列表请求');

    const users = await UserDao.getAllUsers();

    // 格式化用户数据
    const formattedUsers = users.map(user => ({
      id: user.id.toString(),
      username: user.username,
      email: user.email,
      avatar: user.avatar,
      role: user.role,
      isActive: Boolean(user.is_active),
      createdAt: user.created_at ? new Date(user.created_at + 'Z').toISOString() : new Date().toISOString()
    }));

    console.log(`📊 返回用户列表，共 ${formattedUsers.length} 个用户`);

    res.json({
      success: true,
      users: formattedUsers,
      total: formattedUsers.length
    });

  } catch (error) {
    console.error('❌ 获取用户列表失败:', error);
    res.status(500).json({
      success: false,
      message: '获取用户列表失败'
    });
  }
});

// 用户统计接口
app.get('/api/users/stats', async (req, res) => {
  try {
    console.log('📊 获取用户统计请求');

    const stats = await UserDao.getUserStats();

    console.log('📈 用户统计数据:', stats);

    res.json({
      success: true,
      stats: stats
    });

  } catch (error) {
    console.error('❌ 获取用户统计失败:', error);
    res.status(500).json({
      success: false,
      message: '获取用户统计失败'
    });
  }
});

// 忘记密码请求接口
app.post('/api/auth/forgot-password', async (req, res) => {
  try {
    const { email } = req.body;

    console.log('🔑 收到忘记密码请求:');
    console.log('- 邮箱:', email);

    // 检查邮箱是否存在
    const user = await UserDao.findUserByEmail(email);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: '该邮箱地址未注册'
      });
    }

    // 创建重置请求记录
    const resetRequest = {
      id: Date.now().toString(),
      email: email,
      userId: user.id,
      status: 'pending',
      createdAt: new Date().toISOString(),
      expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString() // 24小时后过期
    };

    // 保存重置请求到文件
    let resetRequests = [];
    try {
      resetRequests = JSON.parse(fs.readFileSync('reset_requests.json'));
    } catch (e) {}

    // 删除该邮箱的旧请求
    resetRequests = resetRequests.filter(req => req.email !== email);
    resetRequests.push(resetRequest);

    fs.writeFileSync('reset_requests.json', JSON.stringify(resetRequests, null, 2));

    console.log(`✅ 重置请求已创建，请求ID: ${resetRequest.id}`);

    res.json({
      success: true,
      message: '重置请求已发送，请等待导游处理',
      requestId: resetRequest.id
    });

  } catch (error) {
    console.error('❌ 忘记密码请求失败:', error);
    res.status(500).json({
      success: false,
      message: '请求失败，请稍后重试'
    });
  }
});

// 获取重置请求列表（仅导游可访问）
app.get('/api/auth/reset-requests', async (req, res) => {
  try {
    console.log('📋 获取重置请求列表');

    let resetRequests = [];
    try {
      resetRequests = JSON.parse(fs.readFileSync('reset_requests.json'));
    } catch (e) {}

    // 过滤掉过期的请求
    const now = new Date();
    resetRequests = resetRequests.filter(req => new Date(req.expiresAt) > now);

    console.log(`📊 返回重置请求列表，共 ${resetRequests.length} 个请求`);

    res.json({
      success: true,
      requests: resetRequests
    });

  } catch (error) {
    console.error('❌ 获取重置请求列表失败:', error);
    res.status(500).json({
      success: false,
      message: '获取重置请求列表失败'
    });
  }
});

// 处理重置请求（仅导游可访问）
app.post('/api/auth/process-reset', async (req, res) => {
  try {
    const { requestId, newUsername, newPassword, action } = req.body;

    console.log('🔧 处理重置请求:');
    console.log('- 请求ID:', requestId);
    console.log('- 新用户名:', newUsername);
    console.log('- 操作:', action);

    // 读取重置请求
    let resetRequests = [];
    try {
      resetRequests = JSON.parse(fs.readFileSync('reset_requests.json'));
    } catch (e) {}

    const request = resetRequests.find(req => req.id === requestId);
    if (!request) {
      return res.status(404).json({
        success: false,
        message: '重置请求不存在'
      });
    }

    if (action === 'approve') {
      // 批准重置请求
      if (!newUsername || !newPassword) {
        return res.status(400).json({
          success: false,
          message: '新用户名和密码不能为空'
        });
      }

      // 检查新用户名是否已存在
      const usernameExists = await UserDao.checkUsernameExists(newUsername);
      if (usernameExists) {
        return res.status(400).json({
          success: false,
          message: '新用户名已存在'
        });
      }

      // 更新用户信息
      await UserDao.updateUserCredentials(request.userId, {
        username: newUsername,
        password: newPassword
      });

      console.log(`✅ 用户重置成功，用户ID: ${request.userId}`);
    }

    // 删除已处理的请求
    resetRequests = resetRequests.filter(req => req.id !== requestId);
    fs.writeFileSync('reset_requests.json', JSON.stringify(resetRequests, null, 2));

    res.json({
      success: true,
      message: action === 'approve' ? '重置成功' : '请求已拒绝'
    });

  } catch (error) {
    console.error('❌ 处理重置请求失败:', error);
    res.status(500).json({
      success: false,
      message: '处理失败，请稍后重试'
    });
  }
});

// 自动从 Dart constants.dart 读取百度语音配置（仅开发环境）
function getBaiduConfig() {
  try {
    const dartConstants = fs.readFileSync(path.join(__dirname, '../lib/constants.dart'), 'utf8');
    const baiduSection = dartConstants.split('class BaiduVoiceConfig')[1];
    if (baiduSection) {
      const apiKeyMatch = baiduSection.match(/apiKey\s*=\s*['\"]([^'\"]+)['\"]/);
      const secretKeyMatch = baiduSection.match(/secretKey\s*=\s*['\"]([^'\"]+)['\"]/);
      const appIdMatch = baiduSection.match(/appId\s*=\s*['\"]([^'\"]+)['\"]/);
      if (apiKeyMatch && secretKeyMatch && appIdMatch) {
        return {
          apiKey: apiKeyMatch[1],
          secretKey: secretKeyMatch[1],
          appId: appIdMatch[1]
        };
      }
    }
  } catch (e) {
    // 忽略读取失败
  }
  return {
    apiKey: process.env.BAIDU_API_KEY || 'GD5XCi0eK4xS3jqsLhLQmUdXpWVNZYyC',
    secretKey: process.env.BAIDU_SECRET_KEY || 'kxwTL9BbAIs7h82NKv3Ni0lFWOePGySE',
    appId: process.env.BAIDU_APP_ID || '116990948'
  };
}

// 获取百度API访问令牌
async function getBaiduToken() {
  try {
    const config = getBaiduConfig();
    const url = `https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=${config.apiKey}&client_secret=${config.secretKey}`;
    
    const response = await axios.post(url);
    
    if (response.data && response.data.access_token) {
      console.log('✅ 百度API令牌获取成功');
      return response.data.access_token;
    } else {
      throw new Error('百度API令牌获取失败');
    }
  } catch (error) {
    console.error('❌ 百度API令牌获取错误:', error.message);
    throw error;
  }
}

// 自动从 Dart constants.dart 读取有道配置（仅开发环境）
function getYoudaoConfig() {
  try {
    const dartConstants = fs.readFileSync(path.join(__dirname, '../lib/constants.dart'), 'utf8');
    const appKeyMatch = dartConstants.match(/appKey\s*=\s*['\"]([^'\"]+)['\"]/);
    const appSecretMatch = dartConstants.match(/appSecret\s*=\s*['\"]([^'\"]+)['\"]/);
    if (appKeyMatch && appSecretMatch) {
      return {
        appKey: appKeyMatch[1],
        appSecret: appSecretMatch[1]
      };
    }
  } catch (e) {
    // 忽略读取失败
  }
  return {
    appKey: process.env.YOUDAO_APP_KEY || '你的有道appKey',
    appSecret: process.env.YOUDAO_APP_SECRET || '你的有道appSecret'
  };
}
const { appKey: YOUDAO_APP_KEY, appSecret: YOUDAO_APP_SECRET } = getYoudaoConfig();

// 有道签名算法文本截断
function truncate(q) {
  if (q.length <= 20) return q;
  return q.substring(0, 10) + q.length + q.substring(q.length - 10);
}

// 翻译API
app.post('/api/translate', async (req, res) => {
  const { text, from, to } = req.body;
  if (!text || !from || !to) {
    return res.status(400).json({ success: false, message: '参数缺失' });
  }
  try {
    const salt = Math.floor(Math.random() * 100000).toString();
    const curtime = Math.floor(Date.now() / 1000).toString();
    const signStr = YOUDAO_APP_KEY + truncate(text) + salt + curtime + YOUDAO_APP_SECRET;
    const sign = crypto.createHash('sha256').update(signStr).digest('hex');
    const params = {
      q: text,
      from,
      to,
      appKey: YOUDAO_APP_KEY,
      salt,
      sign,
      signType: 'v3',
      curtime
    };
    console.log('[有道API请求参数]', params);
    const youdaoRes = await axios.post('https://openapi.youdao.com/api', null, { params });
    const data = youdaoRes.data;
    console.log('[有道API响应]', data);
    if (data.translation && data.translation.length > 0) {
      res.json({ success: true, translation: data.translation[0] });
    } else {
      console.error('[有道API错误]', data);
      res.status(500).json({ success: false, message: data.errorMsg || '翻译失败', errorCode: data.errorCode });
    }
  } catch (e) {
    console.error('[后端翻译服务异常]', e && e.response ? e.response.data : e);
    res.status(500).json({ success: false, message: '后端翻译服务异常', error: e.message, detail: e && e.response ? e.response.data : undefined });
  }
});

// 自动从 Dart constants.dart 读取高德地图 AmapConfig.apiKey，供后端代理高德API使用。
function getAmapConfig() {
  try {
    const dartConstants = fs.readFileSync(path.join(__dirname, '../lib/constants.dart'), 'utf8');
    // 只匹配 AmapConfig 里的 apiKey
    const amapSection = dartConstants.split('class AmapConfig')[1];
    if (amapSection) {
      const apiKeyMatch = amapSection.match(/apiKey\s*=\s*['\"]([^'\"]+)['\"]/);
      if (apiKeyMatch) {
        return { apiKey: apiKeyMatch[1] };
      }
    }
  } catch (e) {}
  return { apiKey: process.env.AMAP_API_KEY || '你的高德apiKey' };
}
const { apiKey: AMAP_API_KEY } = getAmapConfig();

console.log('[后端实际用的高德Key]', AMAP_API_KEY);

// 高德地图地理编码API代理
app.get('/api/amap/geocode', async (req, res) => {
  const { address } = req.query;
  if (!address) return res.status(400).json({ success: false, message: '缺少地址参数' });
  try {
    const url = `https://restapi.amap.com/v3/geocode/geo?address=${encodeURIComponent(address)}&key=${AMAP_API_KEY}`;
    const result = await axios.get(url);
    res.json(result.data);
  } catch (e) {
    console.error('[高德API错误]', e && e.response ? e.response.data : e);
    res.status(500).json({ success: false, message: '高德API请求失败', error: e.message, detail: e && e.response ? e.response.data : undefined });
  }
});

// 逆地理编码API代理
app.get('/api/amap/regeo', async (req, res) => {
  const { location } = req.query; // location: "经度,纬度"
  if (!location) return res.status(400).json({ success: false, message: '缺少 location 参数' });
  try {
    const url = `https://restapi.amap.com/v3/geocode/regeo?location=${encodeURIComponent(location)}&key=${AMAP_API_KEY}`;
    const result = await axios.get(url);
    res.json(result.data);
  } catch (e) {
    console.error('[高德逆地理API错误]', e && e.response ? e.response.data : e);
    res.status(500).json({ success: false, message: '高德逆地理API请求失败', error: e.message, detail: e && e.response ? e.response.data : undefined });
  }
});

// 天气查询API代理
app.get('/api/amap/weather', async (req, res) => {
  const { city, extensions = 'base' } = req.query; // extensions: base(实况) or all(预报)
  if (!city) return res.status(400).json({ success: false, message: '缺少 city 参数' });
  try {
    const url = `https://restapi.amap.com/v3/weather/weatherInfo?city=${encodeURIComponent(city)}&key=${AMAP_API_KEY}&extensions=${extensions}`;
    const result = await axios.get(url);
    res.json(result.data);
  } catch (e) {
    console.error('[高德天气API错误]', e && e.response ? e.response.data : e);
    res.status(500).json({ success: false, message: '高德天气API请求失败', error: e.message, detail: e && e.response ? e.response.data : undefined });
  }
});

// ... existing code ...
// 中轴线核心景点关键词
const centralAxisKeywords = [
  '永定门',
  '先农坛',
  '天坛',
  '前门',
  '故宫',
  '什刹海万宁桥',
  '钟鼓楼',
  'Bell & Drum Towers',
  'Temple of Heaven',
  'Forbidden City',
  'Yongdingmen',
  'Xiannongtan',
  'Qianmen',
  'Shichahai Wannian Bridge'
];

// 过滤POI，只保留中轴线相关
function filterCentralAxisSpots(pois) {
  return pois.filter(spot => {
    const name = spot.name || '';
    return centralAxisKeywords.some(keyword => name.includes(keyword));
  });
}

// 修改POI搜索API：只返回中轴线相关景点
app.get('/api/amap/poi', async (req, res) => {
  const { keywords, city, types, offset = 10, page = 1 } = req.query;
  if (!keywords) return res.status(400).json({ success: false, message: '缺少 keywords 参数' });
  try {
    const url = `https://restapi.amap.com/v3/place/text?keywords=${encodeURIComponent(keywords)}&city=${encodeURIComponent(city || '')}&types=${encodeURIComponent(types || '')}&offset=${offset}&page=${page}&key=${AMAP_API_KEY}`;
    const result = await axios.get(url);
    let pois = result.data.pois || [];
    // 只保留中轴线相关
    pois = filterCentralAxisSpots(pois);
    res.json({
      status: '1',
      pois
    });
  } catch (e) {
    console.error('[高德POI API错误]', e && e.response ? e.response.data : e);
    res.status(500).json({ success: false, message: '高德POI API请求失败', error: e.message, detail: e && e.response ? e.response.data : undefined });
  }
});
// ... existing code ...

// 游客发起绑定导游请求
app.post('/api/bind_guide', async (req, res) => {
  const { touristId, guideId } = req.body;
  if (!touristId || !guideId) {
    return res.status(400).json({ success: false, message: '参数缺失' });
  }
  try {
    const result = await UserDao.bindGuide(touristId, guideId);
    res.json({ success: true, bindingId: result.id });
  } catch (e) {
    res.status(500).json({ success: false, message: '绑定失败', error: e.message });
  }
});

// 导游审批绑定请求
app.post('/api/review_bind_request', async (req, res) => {
  const { bindingId, status } = req.body; // status: 'approved' or 'rejected'
  if (!bindingId || !['approved', 'rejected'].includes(status)) {
    return res.status(400).json({ success: false, message: '参数缺失或状态非法' });
  }
  try {
    await UserDao.reviewBindRequest(bindingId, status);
    res.json({ success: true });
  } catch (e) {
    res.status(500).json({ success: false, message: '审批失败', error: e.message });
  }
});

// 游客解绑导游
app.post('/api/unbind_guide', async (req, res) => {
  const { touristId } = req.body;
  if (!touristId) {
    return res.status(400).json({ success: false, message: '参数缺失' });
  }
  try {
    await UserDao.unbindGuide(touristId);
    res.json({ success: true });
  } catch (e) {
    res.status(500).json({ success: false, message: '解绑失败', error: e.message });
  }
});

// 查询游客当前绑定的导游
app.get('/api/binding/guide/:touristId', async (req, res) => {
  const { touristId } = req.params;
  try {
    const binding = await UserDao.getBindingByTourist(touristId);
    res.json({ success: true, binding });
  } catch (e) {
    res.status(500).json({ success: false, message: '查询失败', error: e.message });
  }
});

// 查询导游待审批的绑定请求
app.get('/api/binding/pending/:guideId', async (req, res) => {
  const { guideId } = req.params;
  try {
    const requests = await UserDao.getPendingBindingsByGuide(guideId);
    res.json({ success: true, requests });
  } catch (e) {
    res.status(500).json({ success: false, message: '查询失败', error: e.message });
  }
});

// 查询导游已绑定的游客
app.get('/api/binding/tourists/:guideId', async (req, res) => {
  const { guideId } = req.params;
  try {
    const tourists = await UserDao.getApprovedTouristsByGuide(guideId);
    res.json({ success: true, tourists });
  } catch (e) {
    res.status(500).json({ success: false, message: '查询失败', error: e.message });
  }
});

// 清理重复的绑定记录
app.post('/api/binding/cleanup', async (req, res) => {
  try {
    const db = require('./database').db;
    
    // 删除重复的绑定记录，保留最新的
    const cleanupSql = `
      DELETE FROM user_guide_bindings 
      WHERE id NOT IN (
        SELECT MAX(id) 
        FROM user_guide_bindings 
        GROUP BY tourist_id, guide_id, status
      )
    `;
    
    db.run(cleanupSql, function(err) {
      if (err) {
        console.error('清理重复绑定记录失败:', err);
        return res.status(500).json({ success: false, message: '清理失败', error: err.message });
      }
      
      console.log(`✅ 清理了 ${this.changes} 条重复的绑定记录`);
      res.json({ 
        success: true, 
        message: `清理了 ${this.changes} 条重复记录`,
        cleanedCount: this.changes 
      });
    });
  } catch (e) {
    console.error('清理重复绑定记录时发生错误:', e);
    res.status(500).json({ success: false, message: '清理失败', error: e.message });
  }
});

// 用户修改昵称和头像
app.post('/api/user/update_profile', async (req, res) => {
  const { userId, username, avatar } = req.body;
  console.log('🔄 收到用户资料更新请求:');
  console.log('- 用户ID:', userId);
  console.log('- 新昵称:', username);
  console.log('- 新头像:', avatar);
  
  if (!userId) {
    console.log('❌ 参数缺失: 用户ID');
    return res.status(400).json({ success: false, message: '参数缺失' });
  }
  try {
    const db = require('./database').db;
    const fields = [];
    const values = [];
    if (username) {
      fields.push('username = ?');
      values.push(username);
    }
    if (avatar) {
      fields.push('avatar = ?');
      values.push(avatar);
    }
    if (fields.length === 0) {
      console.log('❌ 无可更新字段');
      return res.status(400).json({ success: false, message: '无可更新字段' });
    }
    values.push(userId);
    const sql = `UPDATE users SET ${fields.join(', ')} WHERE id = ?`;
    console.log('📤 执行SQL:', sql);
    console.log('📤 SQL参数:', values);
    
    db.run(sql, values, function(err) {
      if (err) {
        console.log('❌ 数据库更新失败:', err.message);
        return res.status(500).json({ success: false, message: '更新失败', error: err.message });
      }
      console.log('✅ 用户资料更新成功，影响行数:', this.changes);
      res.json({ success: true });
    });
  } catch (e) {
    console.log('❌ 更新过程中发生错误:', e.message);
    res.status(500).json({ success: false, message: '更新失败', error: e.message });
  }
});

// 语音识别API - 通过后端代理百度语音识别
app.post('/api/voice/speech-to-text', upload.single('audio'), async (req, res) => {
  try {
    console.log('🎤 收到语音识别请求');
    
    if (!req.file) {
      return res.status(400).json({ success: false, message: '没有上传音频文件' });
    }

    // 读取音频文件
    const audioBuffer = fs.readFileSync(req.file.path);
    
    // 获取百度访问令牌
    const tokenResponse = await axios.post(
      'https://aip.baidubce.com/oauth/2.0/token',
      null,
      {
        params: {
          grant_type: 'client_credentials',
          client_id: 'YOUR_BAIDU_API_KEY', // 需要替换为实际的百度API密钥
          client_secret: 'YOUR_BAIDU_SECRET_KEY'
        }
      }
    );

    const token = tokenResponse.data.access_token;
    
    // 调用百度语音识别API
    const speechResponse = await axios.post(
      `https://vop.baidu.com/server_api?cuid=YOUR_APP_ID&token=${token}`,
      audioBuffer,
      {
        headers: {
          'Content-Type': 'audio/pcm;rate=16000',
        }
      }
    );

    // 删除临时音频文件
    fs.unlinkSync(req.file.path);

    if (speechResponse.data.result && speechResponse.data.result.length > 0) {
      console.log('✅ 语音识别成功:', speechResponse.data.result[0]);
      res.json({ 
        success: true, 
        text: speechResponse.data.result[0] 
      });
    } else {
      throw new Error('语音识别失败: ' + (speechResponse.data.err_msg || '未知错误'));
    }
  } catch (error) {
    console.error('❌ 语音识别错误:', error.message);
    res.status(500).json({ 
      success: false, 
      message: '语音识别服务暂时不可用，请稍后重试',
      error: error.message 
    });
  }
});

// AI助手API - 智能本地回复
app.post('/api/ai/chat', async (req, res) => {
  try {
    console.log('🤖 收到AI助手请求');
    
    const { message, apiKey } = req.body;
    
    if (!message) {
      return res.status(400).json({ 
        success: false, 
        message: '缺少消息内容' 
      });
    }

    console.log('📝 用户消息:', message);

    // 自动检测语言
    const isEnglish = /^[a-zA-Z\s.,!?;:'"()-]+$/.test(message.trim()) || 
                     message.toLowerCase().includes('hello') ||
                     message.toLowerCase().includes('hi') ||
                     message.toLowerCase().includes('how') ||
                     message.toLowerCase().includes('what') ||
                     message.toLowerCase().includes('where') ||
                     message.toLowerCase().includes('when') ||
                     message.toLowerCase().includes('why') ||
                     message.toLowerCase().includes('can you') ||
                     message.toLowerCase().includes('please') ||
                     message.toLowerCase().includes('thank you') ||
                     message.toLowerCase().includes('thanks');

    console.log('🌐 自动检测语言:', isEnglish ? '英文' : '中文');

    // 智能本地回复逻辑 - 更人性化的交互
    let aiResponse = '';
    const lowerMessage = message.toLowerCase();
    
    // 感谢和礼貌用语
    if (lowerMessage.includes('谢谢') || lowerMessage.includes('thank you') || lowerMessage.includes('thanks') || lowerMessage.includes('ok') || lowerMessage.includes('好的')) {
      aiResponse = isEnglish 
        ? "You're very welcome! 😊 I'm here to help make your Beijing Central Axis journey amazing. Is there anything else you'd like to know about the attractions, routes, or local culture?"
        : "不客气！😊 我很高兴能帮助您规划北京中轴线之旅。还有什么想了解的吗？比如景点详情、路线规划或者当地文化？";
    }
    // 问候语
    else if (lowerMessage.includes('你好') || lowerMessage.includes('hello') || lowerMessage.includes('hi')) {
      aiResponse = isEnglish 
        ? "Hi there! 👋 I'm your friendly Beijing Central Axis travel companion. I'd love to help you discover the amazing history and culture along this ancient route. What interests you most - the majestic Forbidden City, the serene Temple of Heaven, or the charming Shichahai area?"
        : "你好！👋 我是您的北京中轴线旅行伙伴。我很乐意帮您探索这条古老路线上的精彩历史和文化的。您最感兴趣的是雄伟的故宫、宁静的天坛，还是迷人的什刹海呢？";
    }
    // 天安门相关
    else if (lowerMessage.includes('天安门') || lowerMessage.includes('tiananmen') || lowerMessage.includes('tian\'anmen')) {
      aiResponse = isEnglish
        ? "Tiananmen Square is the heart of Beijing! 🇨🇳 It's one of the largest city squares in the world. You can reach it easily by taking Metro Line 1 to Tiananmen East or West Station. The best time to visit is early morning for the flag-raising ceremony, or evening for the beautiful lighting. Don't forget to bring your ID for security checks!"
        : "天安门广场是北京的心脏！🇨🇳 它是世界上最大的城市广场之一。您可以乘坐地铁1号线到天安门东站或西站。最佳游览时间是清晨看升旗仪式，或者晚上欣赏美丽的夜景。记得带身份证进行安检哦！";
    }
    // 故宫相关
    else if (lowerMessage.includes('故宫') || lowerMessage.includes('紫禁城') || lowerMessage.includes('forbidden city')) {
      aiResponse = isEnglish
        ? "The Forbidden City is absolutely magnificent! 🏛️ It's like stepping into a living history book. My tip: arrive early (around 8:30 AM) to beat the crowds. The ticket is 60 yuan, and you'll need 2-3 hours to explore properly. Don't miss the Hall of Supreme Harmony and the Imperial Garden. Want to know the best photo spots?"
        : "故宫真是太壮观了！🏛️ 就像走进了一本活的历史书。我的建议是早点到（大约8:30），避开人流高峰。门票60元，需要2-3小时好好游览。别忘了参观太和殿和御花园。想知道最佳拍照位置吗？";
    }
    // 天坛相关
    else if (lowerMessage.includes('天坛') || lowerMessage.includes('祈年殿') || lowerMessage.includes('temple of heaven')) {
      aiResponse = isEnglish
        ? "The Temple of Heaven is magical! 🌟 The Hall of Prayer for Good Harvests is simply stunning. It's perfect for a peaceful morning or romantic evening visit. Ticket is 35 yuan, and the park is open from 6 AM to 10 PM. Local people love doing tai chi here in the morning. Want to know about the best time for photos?"
        : "天坛真是太神奇了！🌟 祈年殿简直美得让人屏息。这里很适合清晨宁静的游览或浪漫的傍晚时光。门票35元，公园开放时间6:00-22:00。当地人喜欢在这里晨练太极。想知道最佳拍照时间吗？";
    }
    // 什刹海相关
    else if (lowerMessage.includes('什刹海') || lowerMessage.includes('后海') || lowerMessage.includes('shichahai')) {
      aiResponse = isEnglish
        ? "Shichahai is my favorite spot! 💕 It's where old Beijing meets modern charm. You can take a boat ride on the lake, explore traditional hutongs, or enjoy a coffee by the water. The best time is sunset - the reflections on the water are magical! There are also great bars and restaurants. Want restaurant recommendations?"
        : "什刹海是我最喜欢的地方！💕 这里是老北京与现代魅力的完美结合。您可以划船游湖、探索传统胡同，或者在水边喝咖啡。最佳时间是日落时分——水中的倒影美得让人陶醉！这里还有很棒的酒吧和餐厅。需要餐厅推荐吗？";
    }
    // 路线规划
    else if (lowerMessage.includes('路线') || lowerMessage.includes('怎么走') || lowerMessage.includes('怎么去') || lowerMessage.includes('route') || lowerMessage.includes('how to get') || lowerMessage.includes('arrive')) {
      aiResponse = isEnglish
        ? "Great question! 🗺️ Here's my recommended route: Start at Tiananmen Square (Metro Line 1), then walk to the Forbidden City. After that, head to Jingshan Park for amazing city views, then take a taxi or bus to Shichahai for evening fun. The whole route takes about 6-8 hours. Would you like specific transportation details for any part?"
        : "好问题！🗺️ 我推荐的路线是：从天安门广场开始（地铁1号线），然后步行到故宫。之后去景山公园看城市全景，最后打车或坐公交到什刹海享受夜晚时光。整个路线大约需要6-8小时。需要某个部分的详细交通信息吗？";
    }
    // 交通信息
    else if (lowerMessage.includes('地铁') || lowerMessage.includes('公交') || lowerMessage.includes('subway') || lowerMessage.includes('bus') || lowerMessage.includes('transportation')) {
      aiResponse = isEnglish
        ? "Getting around is super easy! 🚇 Metro Line 1 takes you to Tiananmen and Forbidden City, Line 5 goes to Temple of Heaven, and Line 6 reaches Shichahai. Buses are also convenient and cheap (2 yuan). Pro tip: Download the Beijing Metro app for real-time updates. Need help with specific routes?"
        : "交通非常方便！🚇 地铁1号线到天安门和故宫，5号线到天坛，6号线到什刹海。公交车也很方便便宜（2元）。小贴士：下载北京地铁APP查看实时信息。需要具体路线帮助吗？";
    }
    // 美食推荐
    else if (lowerMessage.includes('吃') || lowerMessage.includes('美食') || lowerMessage.includes('餐厅') || lowerMessage.includes('food') || lowerMessage.includes('restaurant')) {
      aiResponse = isEnglish
        ? "Oh, the food here is incredible! 🍜 You must try Beijing Roast Duck at Quanjude near the Forbidden City. In Shichahai, try the traditional Zhajiangmian (noodles with bean sauce) and Douzhir (fermented bean drink). Near Temple of Heaven, explore Nanluoguxiang for street food. My personal favorite is the jianbing (Chinese crepe) for breakfast!"
        : "哇，这里的美食太棒了！🍜 故宫附近的全聚德烤鸭一定要尝尝。什刹海有传统的炸酱面和豆汁儿。天坛附近的南锣鼓巷有各种小吃。我个人最喜欢早餐吃煎饼果子！";
    }
    // 文化知识
    else if (lowerMessage.includes('文化') || lowerMessage.includes('历史') || lowerMessage.includes('传统') || lowerMessage.includes('culture') || lowerMessage.includes('history') || lowerMessage.includes('traditional')) {
      aiResponse = isEnglish
        ? "The Beijing Central Axis is absolutely fascinating! 🏛️ It represents the ancient Chinese philosophy of 'harmony between heaven and earth.' This 7.8km axis connects everything from the Temple of Heaven (heaven) to the Forbidden City (earth) to the Bell Tower (human world). It's like walking through 600 years of Chinese history!"
        : "北京中轴线真是太迷人了！🏛️ 它体现了古代中国'天人合一'的哲学思想。这条7.8公里的轴线从天坛（天）连接到故宫（地）再到钟楼（人），就像穿越了600年的中国历史！";
    }
    // 天气信息
    else if (lowerMessage.includes('天气') || lowerMessage.includes('气温') || lowerMessage.includes('weather') || lowerMessage.includes('temperature')) {
      aiResponse = isEnglish
        ? "Beijing weather is quite seasonal! 🌤️ Spring (March-May) and autumn (September-November) are perfect for sightseeing - comfortable temperatures and clear skies. Summer can be hot and humid, while winter is cold but magical with snow. My advice: check the weather app before your visit and dress accordingly!"
        : "北京天气很有季节性！🌤️ 春秋两季（3-5月和9-11月）最适合观光——温度舒适，天空晴朗。夏天可能炎热潮湿，冬天寒冷但下雪时很梦幻。我的建议是：出发前查看天气APP，合理着装！";
    }
    // 门票信息
    else if (lowerMessage.includes('门票') || lowerMessage.includes('价格') || lowerMessage.includes('多少钱') || lowerMessage.includes('ticket') || lowerMessage.includes('price') || lowerMessage.includes('cost')) {
      aiResponse = isEnglish
        ? "Ticket prices are quite reasonable! 💰 Forbidden City: 60 yuan, Temple of Heaven: 35 yuan, Jingshan Park: 2 yuan, Shichahai: free! Pro tip: Book Forbidden City tickets online in advance - they often sell out. Students and seniors get discounts. Want to know about combo tickets or guided tours?"
        : "门票价格很合理！💰 故宫60元，天坛35元，景山公园2元，什刹海免费！小贴士：故宫门票建议提前网上预订，经常售罄。学生和老年人有优惠。想了解联票或导游服务吗？";
    }
    // 拍照建议
    else if (lowerMessage.includes('拍照') || lowerMessage.includes('摄影') || lowerMessage.includes('photo') || lowerMessage.includes('photography')) {
      aiResponse = isEnglish
        ? "Perfect timing for photos! 📸 Forbidden City: 9-11 AM for golden hour lighting. Temple of Heaven: sunset for dramatic skies. Shichahai: dusk for beautiful reflections. Don't forget to capture the traditional architecture details! Remember, some areas have photography restrictions, so check the signs."
        : "拍照时机很重要！📸 故宫建议9-11点，黄金时段光线最佳。天坛建议日落时分，天空很美。什刹海建议黄昏，倒影绝美。别忘了拍传统建筑细节！注意有些区域有拍照限制，要查看标识。";
    }
    // 默认回复 - 更智能的回复
    else {
      // 分析用户意图，提供更相关的回复
      if (lowerMessage.includes('can you') || lowerMessage.includes('could you')) {
        aiResponse = isEnglish
          ? "Of course! I'd be happy to help with that. Could you be more specific about what you'd like to know? I can help with attractions, routes, food, culture, or any other aspect of your Beijing Central Axis journey! 😊"
          : "当然可以！我很乐意帮助您。能具体说说您想了解什么吗？我可以帮您介绍景点、路线、美食、文化，或者北京中轴线之旅的任何方面！😊";
      } else if (lowerMessage.includes('what') || lowerMessage.includes('where') || lowerMessage.includes('when') || lowerMessage.includes('how')) {
        aiResponse = isEnglish
          ? "Great question! 🤔 I'd love to help you with that. Are you asking about attractions, transportation, food, or something else? Just let me know what specific information you need, and I'll give you the best recommendations!"
          : "好问题！🤔 我很乐意帮您解答。您是想了解景点、交通、美食，还是其他方面呢？告诉我您需要什么具体信息，我会给您最好的建议！";
      } else {
        aiResponse = isEnglish
          ? `I see you mentioned "${message}" - that sounds interesting! 🤔 As your Beijing Central Axis travel buddy, I can help with attractions, routes, food, culture, and more. What would you like to explore? I'm here to make your journey amazing!`
          : `我看到您提到了"${message}"——听起来很有趣！🤔 作为您的北京中轴线旅行伙伴，我可以帮您了解景点、路线、美食、文化等等。您想探索什么呢？我在这里让您的旅程更精彩！`;
      }
    }

    console.log('✅ AI回复:', aiResponse);
    res.json({ 
      success: true, 
      response: aiResponse 
    });
    
  } catch (error) {
    console.error('❌ AI助手错误:', error.message);
    res.status(500).json({ 
      success: false, 
      message: 'AI助手服务暂时不可用，请稍后重试',
      error: error.message 
    });
  }
});

// 语音合成API - 使用百度语音合成API
app.post('/api/voice/text-to-speech', async (req, res) => {
  try {
    console.log('🔊 收到语音合成请求');
    
    const { text, lang = 'zh' } = req.body;
    
    if (!text) {
      return res.status(400).json({ 
        success: false, 
        message: '缺少文本内容' 
      });
    }

    console.log('📝 要合成的文本:', text);

    // 获取百度语音API访问令牌
    const token = await getBaiduToken();
    console.log('🔑 获取到百度API令牌');

    // 调用百度语音合成API
    const config = getBaiduConfig();
    console.log('🔑 百度API配置:', {
      apiKey: config.apiKey.substring(0, 10) + '...',
      appId: config.appId
    });
    
    const params = new URLSearchParams({
      tex: text,
      tok: token,
      cuid: config.appId,
      ctp: '1',
      lan: lang === 'zh' ? 'zh' : 'en',
      spd: '5', // 语速，取值0-9，默认为5中等语速
      pit: '5', // 音调，取值0-9，默认为5中等音调
      vol: '5', // 音量，取值0-15，默认为5中等音量
      per: '0', // 发音人选择, 0为女声，1为男声，3为情感合成-度逍遥，4为情感合成-度丫丫
      aue: '3', // 3为mp3格式(默认)； 4为pcm-16k；5为pcm-8k；6为wav（内容同pcm-16k）
    });
    
    console.log('📤 百度TTS请求参数:', params.toString());
    
    const ttsResponse = await axios.post(
      'https://tsn.baidu.com/text2audio',
      params,
      {
        responseType: 'arraybuffer',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        timeout: 10000 // 10秒超时
      }
    );

    if (ttsResponse.status === 200 && ttsResponse.data) {
      // 生成唯一的文件名
      const timestamp = Date.now();
      const filename = `tts_${timestamp}.mp3`;
      const filepath = path.join(__dirname, 'uploads', 'audio', filename);
      
      // 确保音频目录存在
      const audioDir = path.join(__dirname, 'uploads', 'audio');
      if (!fs.existsSync(audioDir)) {
        fs.mkdirSync(audioDir, { recursive: true });
      }
      
      // 保存音频文件
      fs.writeFileSync(filepath, ttsResponse.data);
      
      console.log('✅ 百度语音合成成功，文件保存为:', filename);
      
      // 返回音频文件URL
      const audioUrl = `/uploads/audio/${filename}`;
      
      res.json({ 
        success: true, 
        audioUrl: audioUrl,
        message: '语音合成成功（百度API）'
      });
    } else {
      throw new Error('百度语音合成API返回错误');
    }
    
  } catch (error) {
    console.error('❌ 语音合成错误:', error.message);
    if (error.response) {
      console.error('❌ 百度API响应状态:', error.response.status);
      console.error('❌ 百度API响应数据:', error.response.data);
    }
    if (error.request) {
      console.error('❌ 网络请求错误:', error.request);
    }
    
    // 如果百度API失败，回退到模拟音频
    console.log('🔄 回退到模拟音频');
    const { text, lang = 'zh' } = req.body;
    // 使用 Buffer 来正确处理中文编码
    const encodedText = Buffer.from(text, 'utf8').toString('base64');
    const mockAudioUrl = `/api/voice/mock-audio?text=${encodedText}&lang=${lang}&encoding=base64`;
    
    res.json({ 
      success: true, 
      audioUrl: mockAudioUrl,
      message: '语音合成成功（模拟模式，百度API失败）'
    });
  }
});

// 模拟音频播放API
app.get('/api/voice/mock-audio', (req, res) => {
  const { text, lang, encoding } = req.query;
  
  // 处理文本编码
  let decodedText = text || '';
  if (encoding === 'base64') {
    try {
      decodedText = Buffer.from(text, 'base64').toString('utf8');
    } catch (e) {
      console.log('Base64解码失败，使用原始文本');
      decodedText = text || '';
    }
  }
  
  console.log('🎵 模拟音频播放:', decodedText);
  
  // 根据文本长度生成不同长度的音频
  const textLength = decodedText ? decodedText.length : 10;
  const durationSeconds = Math.max(1, Math.min(5, textLength * 0.3)); // 1-5秒
  const sampleRate = 44100;
  const numChannels = 1;
  const bitsPerSample = 16;
  const bytesPerSample = bitsPerSample / 8;
  const numSamples = Math.floor(sampleRate * durationSeconds);
  const dataSize = numSamples * bytesPerSample;
  const fileSize = 36 + dataSize; // WAV header (44 bytes) - 8 + data size
  
  // 创建WAV文件头
  const wavHeader = Buffer.alloc(44);
  
  // RIFF header
  wavHeader.write('RIFF', 0);
  wavHeader.writeUInt32LE(fileSize, 4);
  wavHeader.write('WAVE', 8);
  
  // fmt chunk
  wavHeader.write('fmt ', 12);
  wavHeader.writeUInt32LE(16, 16); // fmt chunk size
  wavHeader.writeUInt16LE(1, 20); // audio format (PCM)
  wavHeader.writeUInt16LE(numChannels, 22); // channels
  wavHeader.writeUInt32LE(sampleRate, 24); // sample rate
  wavHeader.writeUInt32LE(sampleRate * numChannels * bytesPerSample, 28); // byte rate
  wavHeader.writeUInt16LE(numChannels * bytesPerSample, 32); // block align
  wavHeader.writeUInt16LE(bitsPerSample, 34); // bits per sample
  
  // data chunk
  wavHeader.write('data', 36);
  wavHeader.writeUInt32LE(dataSize, 40);
  
  // 生成更复杂的音频数据（模拟语音）
  const audioData = Buffer.alloc(dataSize);
  const amplitude = 2000; // 音量
  
  for (let i = 0; i < numSamples; i++) {
    const time = i / sampleRate;
    const progress = i / numSamples;
    
    // 使用多个频率组合，模拟语音的复杂性
    const freq1 = 200 + progress * 100; // 基础频率变化
    const freq2 = 400 + progress * 200; // 谐波频率
    const freq3 = 600 + progress * 150; // 更高谐波
    
    // 添加一些随机性，模拟真实语音
    const noise = (Math.random() - 0.5) * 100;
    
    // 组合多个正弦波
    const sample1 = Math.sin(2 * Math.PI * freq1 * time) * 0.6;
    const sample2 = Math.sin(2 * Math.PI * freq2 * time) * 0.3;
    const sample3 = Math.sin(2 * Math.PI * freq3 * time) * 0.1;
    
    // 添加包络，模拟语音的开始和结束
    const envelope = Math.sin(progress * Math.PI) * 0.8 + 0.2;
    
    const combinedSample = (sample1 + sample2 + sample3 + noise / 1000) * amplitude * envelope;
    const sampleInt16 = Math.max(-32768, Math.min(32767, Math.round(combinedSample)));
    audioData.writeInt16LE(sampleInt16, i * bytesPerSample);
  }
  
  const fullWav = Buffer.concat([wavHeader, audioData]);
  
  console.log(`✅ 生成音频文件: ${durationSeconds}秒, ${fullWav.length}字节`);
  
  // 移动端兼容性优化
  res.setHeader('Content-Type', 'audio/wav');
  res.setHeader('Content-Length', fullWav.length);
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Range');
  res.setHeader('Accept-Ranges', 'bytes');
  res.setHeader('Connection', 'keep-alive');
  
  // 支持范围请求（移动端音频播放优化）
  const range = req.headers.range;
  if (range) {
    const parts = range.replace(/bytes=/, "").split("-");
    const start = parseInt(parts[0], 10);
    const end = parts[1] ? parseInt(parts[1], 10) : fullWav.length - 1;
    const chunksize = (end - start) + 1;
    
    res.status(206);
    res.setHeader('Content-Range', `bytes ${start}-${end}/${fullWav.length}`);
    res.setHeader('Content-Length', chunksize);
    res.send(fullWav.slice(start, end + 1));
  } else {
    res.send(fullWav);
  }
});

// ========== 行程管理API ==========

// 获取用户行程
app.get('/api/itinerary', async (req, res) => {
  try {
    const { userId } = req.query;
    
    if (!userId) {
      return res.status(400).json({
        success: false,
        message: '缺少用户ID'
      });
    }

    console.log(`📋 获取用户 ${userId} 的行程`);

    let itineraries = [];
    try {
      const data = fs.readFileSync('itineraries.json', 'utf8');
      itineraries = JSON.parse(data);
    } catch (e) {
      console.log('📝 itineraries.json 文件不存在或格式错误，使用空数组');
    }

    // 过滤出当前用户的行程
    const userItineraries = itineraries.filter(itinerary => itinerary.userId === userId);
    
    console.log(`✅ 找到 ${userItineraries.length} 个行程`);
    res.json({
      success: true,
      data: userItineraries
    });

  } catch (error) {
    console.error('❌ 获取行程失败:', error.message);
    res.status(500).json({
      success: false,
      message: '获取行程失败',
      error: error.message
    });
  }
});

// 保存/更新用户行程
app.post('/api/itinerary', async (req, res) => {
  try {
    const { userId, itineraryItems } = req.body;
    
    if (!userId || !itineraryItems) {
      return res.status(400).json({
        success: false,
        message: '缺少必要参数'
      });
    }

    console.log(`💾 保存用户 ${userId} 的行程`);
    console.log('📋 行程项数量:', itineraryItems.length);

    let itineraries = [];
    try {
      const data = fs.readFileSync('itineraries.json', 'utf8');
      itineraries = JSON.parse(data);
    } catch (e) {
      console.log('📝 itineraries.json 文件不存在或格式错误，使用空数组');
    }

    // 查找是否已存在该用户的行程
    const existingIndex = itineraries.findIndex(itinerary => itinerary.userId === userId);
    
    const itineraryData = {
      userId: userId,
      itineraryItems: itineraryItems,
      updatedAt: new Date().toISOString()
    };

    if (existingIndex >= 0) {
      // 更新现有行程
      itineraries[existingIndex] = itineraryData;
      console.log('✅ 更新现有行程');
    } else {
      // 创建新行程
      itineraryData.createdAt = new Date().toISOString();
      itineraries.push(itineraryData);
      console.log('✅ 创建新行程');
    }

    // 保存到文件
    fs.writeFileSync('itineraries.json', JSON.stringify(itineraries, null, 2));
    
    console.log('✅ 行程保存成功');
    res.json({
      success: true,
      message: '行程保存成功'
    });

  } catch (error) {
    console.error('❌ 保存行程失败:', error.message);
    res.status(500).json({
      success: false,
      message: '保存行程失败',
      error: error.message
    });
  }
});

// 删除用户行程
app.delete('/api/itinerary', async (req, res) => {
  try {
    const { userId } = req.query;
    
    if (!userId) {
      return res.status(400).json({
        success: false,
        message: '缺少用户ID'
      });
    }

    console.log(`🗑️ 删除用户 ${userId} 的行程`);

    let itineraries = [];
    try {
      const data = fs.readFileSync('itineraries.json', 'utf8');
      itineraries = JSON.parse(data);
    } catch (e) {
      console.log('📝 itineraries.json 文件不存在或格式错误，使用空数组');
    }

    // 过滤掉当前用户的行程
    const filteredItineraries = itineraries.filter(itinerary => itinerary.userId !== userId);
    
    // 保存到文件
    fs.writeFileSync('itineraries.json', JSON.stringify(filteredItineraries, null, 2));
    
    console.log('✅ 行程删除成功');
    res.json({
      success: true,
      message: '行程删除成功'
    });

  } catch (error) {
    console.error('❌ 删除行程失败:', error.message);
    res.status(500).json({
      success: false,
      message: '删除行程失败',
      error: error.message
    });
  }
});

// ========== 专有名词解释API ========== //
// 获取全部术语分类及术语列表
app.get('/api/terms', (req, res) => {
  try {
    const data = fs.readFileSync(path.join(__dirname, 'terms.json'), 'utf8');
    const terms = JSON.parse(data);
    res.json({ success: true, data: terms });
  } catch (e) {
    res.status(500).json({ success: false, message: '术语数据读取失败', error: e.message });
  }
});

// 根据术语名查询详细解释
app.get('/api/terms/:name', (req, res) => {
  try {
    const { name } = req.params;
    const data = fs.readFileSync(path.join(__dirname, 'terms.json'), 'utf8');
    const terms = JSON.parse(data);
    let found = null;
    for (const category of terms) {
      found = category.terms.find(term => term.name === name);
      if (found) break;
    }
    if (found) {
      res.json({ success: true, data: found });
    } else {
      res.status(404).json({ success: false, message: '未找到该术语' });
    }
  } catch (e) {
    res.status(500).json({ success: false, message: '术语查询失败', error: e.message });
  }
});

// 获取好友列表
app.get('/api/friends', (req, res) => {
  let friends = [];
  try { friends = JSON.parse(fs.readFileSync('backend/friends.json')); } catch (e) {}
  res.json({ success: true, friends });
});

// 添加好友（直接写入数据库 friends 表，避免重复添加）
app.post('/api/friends/add', (req, res) => {
  const { userId, friendId } = req.body;
  if (!userId || !friendId) return res.status(400).json({ success: false, message: '参数缺失' });

  // 检查是否已是好友
  const checkSql = 'SELECT 1 FROM friends WHERE user_id = ? AND friend_id = ?';
  db.get(checkSql, [userId, friendId], (err, row) => {
    if (err) return res.status(500).json({ success: false, message: '数据库错误', error: err.message });
    if (row) return res.json({ success: false, message: '已是好友' });

    // 插入好友关系（双向）
    const insertSql = 'INSERT INTO friends (user_id, friend_id, created_at) VALUES (?, ?, ?), (?, ?, ?)';
    const now = new Date().toISOString();
    db.run(insertSql, [userId, friendId, now, friendId, userId, now], function (err) {
      if (err) return res.status(500).json({ success: false, message: '添加好友失败', error: err.message });
      res.json({ success: true, message: '添加好友成功' });
    });
  });
});

// 获取当前用户相关的会话列表
app.get('/api/chats', (req, res) => {
  const { userId } = req.query;
  if (!userId) return res.status(400).json({ success: false, message: '参数缺失' });

  // 查询所有包含当前用户的会话，包括参与者信息
  const sql = `
    SELECT 
      c.id, 
      c.type,
      c.last_msg as lastMsg, 
      c.last_msg_time as lastMsgTime,
      c.created_at as createdAt,
      COUNT(m.id) as unreadCount
    FROM chats c
    JOIN chat_participants p ON c.id = p.chat_id
    LEFT JOIN messages m ON c.id = m.chat_id AND m.to_id = ? AND m.status = 'sent'
    WHERE p.user_id = ?
    GROUP BY c.id
    ORDER BY c.last_msg_time DESC
  `;
  
  db.all(sql, [userId, userId], (err, rows) => {
    if (err) return res.status(500).json({ success: false, message: '数据库错误', error: err.message });
    
    // 为每个会话获取参与者信息
    const chatsWithParticipants = rows.map(chat => {
      return new Promise((resolve) => {
        const participantSql = `
          SELECT u.id, u.username, u.avatar, u.role, u.created_at as createdAt
          FROM chat_participants p
          JOIN users u ON p.user_id = u.id
          WHERE p.chat_id = ? AND u.id != ?
        `;
        db.all(participantSql, [chat.id, userId], (err, participants) => {
          if (err) {
            resolve({
              id: chat.id,
              type: chat.type,
              participants: [],
              lastMsg: chat.lastMsg,
              lastMsgTime: chat.lastMsgTime,
              unreadCount: chat.unreadCount
            });
          } else {
            resolve({
              id: chat.id,
              type: chat.type,
              participants: participants,
              lastMsg: chat.lastMsg,
              lastMsgTime: chat.lastMsgTime,
              unreadCount: chat.unreadCount
            });
          }
        });
      });
    });

    Promise.all(chatsWithParticipants).then(chats => {
      res.json({ success: true, chats: chats });
    });
  });
});

// 获取指定会话的消息列表
app.get('/api/messages', (req, res) => {
  const { chatId, limit = 30, userId } = req.query;
  if (!chatId) return res.status(400).json({ success: false, message: '参数缺失' });
  
  const sql = `
    SELECT 
      m.id, 
      m.chat_id as chatId, 
      m.from_id as fromId, 
      m.to_id as toId, 
      m.content, 
      m.type, 
      m.image_url as imageUrl,
      m.voice_url as voiceUrl,
      m.file_url as fileUrl,
      m.timestamp,
      m.status,
      u1.username as fromUsername,
      u1.avatar as fromAvatar,
      u2.username as toUsername,
      u2.avatar as toAvatar
    FROM messages m
    JOIN users u1 ON m.from_id = u1.id
    JOIN users u2 ON m.to_id = u2.id
    WHERE m.chat_id = ? AND m.is_deleted = 0
    ORDER BY m.timestamp DESC
    LIMIT ?
  `;
  
  db.all(sql, [chatId, limit], (err, rows) => {
    if (err) return res.status(500).json({ success: false, message: '数据库错误', error: err.message });
    
    // 将消息转换为前端需要的格式
    const messages = rows.reverse().map(row => ({
      id: row.id,
      chatId: row.chatId,
      from: {
        id: row.fromId,
        username: row.fromUsername,
        avatar: row.fromAvatar
      },
      to: {
        id: row.toId,
        username: row.toUsername,
        avatar: row.toAvatar
      },
      content: row.content,
      type: row.type,
      imageUrl: row.imageUrl,
      voiceUrl: row.voiceUrl,
      fileUrl: row.fileUrl,
      timestamp: row.timestamp,
      status: row.status
    }));
    
    // 如果有用户ID，标记消息为已读
    if (userId) {
      const updateSql = `
        UPDATE messages 
        SET status = 'read' 
        WHERE chat_id = ? AND to_id = ? AND status = 'sent'
      `;
      db.run(updateSql, [chatId, userId]);
    }
    
    res.json({ success: true, messages: messages });
  });
});

// 发送消息
app.post('/api/messages/send', (req, res) => {
  const { chatId, from, to, type, content, imageUrl, voiceUrl, fileUrl } = req.body;
  if (!chatId || !from || !to || !type) return res.status(400).json({ success: false, message: '参数不完整' });

  const sql = `
    INSERT INTO messages (chat_id, from_id, to_id, content, type, image_url, voice_url, file_url, timestamp, status)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `;
  const now = new Date().toISOString();
  db.run(sql, [chatId, from, to, content, type, imageUrl || null, voiceUrl || null, fileUrl || null, now, 'sent'], function (err) {
    if (err) return res.status(500).json({ success: false, message: '发送消息失败', error: err.message });
    
    // 更新会话最后消息
    let lastMsg = content;
    if (type === 'image') lastMsg = '[图片]';
    else if (type === 'voice') lastMsg = '[语音]';
    else if (type === 'file') lastMsg = '[文件]';
    
    const updateChat = `
      UPDATE chats SET last_msg = ?, last_msg_time = ? WHERE id = ?
    `;
    db.run(updateChat, [lastMsg, now, chatId], () => {
      // 获取发送者信息
      const getUserSql = 'SELECT id, username, avatar FROM users WHERE id = ?';
      db.get(getUserSql, [from], (err, user) => {
        if (err) {
          res.json({
            success: true,
            message: {
              id: this.lastID,
              chatId,
              from: { id: from, username: 'Unknown', avatar: '' },
              to: { id: to, username: 'Unknown', avatar: '' },
              content,
              type,
              imageUrl,
              voiceUrl,
              fileUrl,
              timestamp: now,
              status: 'sent'
            }
          });
        } else {
          res.json({
            success: true,
            message: {
              id: this.lastID,
              chatId,
              from: user,
              to: { id: to, username: 'Unknown', avatar: '' },
              content,
              type,
              imageUrl,
              voiceUrl,
              fileUrl,
              timestamp: now,
              status: 'sent'
            }
          });
        }
      });
    });
  });
});

// 搜索用户（支持关键字和角色筛选）
app.get('/api/users/search', (req, res) => {
  const { keyword = '', role } = req.query;
  let sql = 'SELECT id, username, email, avatar, role, created_at as createdAt FROM users WHERE username LIKE ?';
  const params = [`%${keyword}%`];
  if (role) {
    sql += ' AND role = ?';
    params.push(role);
  }
  db.all(sql, params, (err, rows) => {
    if (err) {
      console.error('用户搜索失败:', err);
      return res.status(500).json({ success: false, message: '用户搜索失败', error: err.message });
    }
    res.json({ success: true, users: rows });
  });
});

// 发起好友请求
app.post('/api/friends/request', (req, res) => {
  const { fromId, toId } = req.body;
  if (!fromId || !toId) return res.status(400).json({ success: false, message: '参数缺失' });

  // 检查是否已存在待处理请求
  const checkSql = 'SELECT 1 FROM friend_requests WHERE from_id = ? AND to_id = ? AND status = ?';
  db.get(checkSql, [fromId, toId, 'pending'], (err, row) => {
    if (err) return res.status(500).json({ success: false, message: '数据库错误', error: err.message });
    if (row) return res.json({ success: false, message: '已发送请求，等待对方同意' });

    // 插入请求
    const insertSql = 'INSERT INTO friend_requests (from_id, to_id, status, created_at) VALUES (?, ?, ?, ?)';
    db.run(insertSql, [fromId, toId, 'pending', new Date().toISOString()], function (err) {
      if (err) return res.status(500).json({ success: false, message: '发起请求失败', error: err.message });
      res.json({ success: true, message: '好友请求已发送' });
    });
  });
});

// 获取当前用户收到的好友请求
app.get('/api/friends/requests', (req, res) => {
  const { userId } = req.query;
  if (!userId) return res.status(400).json({ success: false, message: '参数缺失' });
  const sql = 'SELECT id, from_id as fromId, to_id as toId, status, created_at as createdAt FROM friend_requests WHERE to_id = ? AND status = ?';
  db.all(sql, [userId, 'pending'], (err, rows) => {
    if (err) return res.status(500).json({ success: false, message: '数据库错误', error: err.message });
    res.json({ success: true, requests: rows });
  });
});

// 同意好友请求
app.post('/api/friends/accept', (req, res) => {
  const { requestId } = req.body;
  if (!requestId) return res.status(400).json({ success: false, message: '参数缺失' });

  // 查找请求
  const getSql = 'SELECT from_id, to_id FROM friend_requests WHERE id = ?';
  db.get(getSql, [requestId], (err, reqRow) => {
    if (err || !reqRow) return res.status(404).json({ success: false, message: '请求不存在' });

    // 检查是否已存在会话
    const checkChatSql = `
    SELECT c.id FROM chats c
    JOIN chat_participants p1 ON c.id = p1.chat_id AND p1.user_id = ?
    JOIN chat_participants p2 ON c.id = p2.chat_id AND p2.user_id = ?
    LIMIT 1
    `;
    db.get(checkChatSql, [reqRow.from_id, reqRow.to_id], (err, chatRow) => {
      if (err) return res.status(500).json({ success: false, message: '数据库错误', error: err.message });
      if (chatRow) {
        // 已有会话，无需重复创建
        // 只需更新请求状态和好友关系
        const updateSql = 'UPDATE friend_requests SET status = ? WHERE id = ?';
        db.run(updateSql, ['accepted', requestId], function (err) {
          if (err) return res.status(500).json({ success: false, message: '更新请求失败', error: err.message });
          const insertSql = 'INSERT OR IGNORE INTO friends (user_id, friend_id, created_at) VALUES (?, ?, ?), (?, ?, ?)';
          const now = new Date().toISOString();
          db.run(insertSql, [reqRow.from_id, reqRow.to_id, now, reqRow.to_id, reqRow.from_id, now], function (err) {
            if (err) return res.status(500).json({ success: false, message: '添加好友失败', error: err.message });
            res.json({ success: true, message: '已同意好友请求' });
          });
        });
        return;
      }
      // 创建新会话
      const createChatSql = 'INSERT INTO chats (last_msg, last_msg_time) VALUES (?, ?)';
      const now = new Date().toISOString();
      db.run(createChatSql, ['', now], function (err) {
        if (err) return res.status(500).json({ success: false, message: '创建会话失败', error: err.message });
        const chatId = this.lastID;
        // 插入参与者
        const insertPartSql = 'INSERT INTO chat_participants (chat_id, user_id) VALUES (?, ?), (?, ?)';
        db.run(insertPartSql, [chatId, reqRow.from_id, chatId, reqRow.to_id], function (err) {
          if (err) return res.status(500).json({ success: false, message: '添加会话成员失败', error: err.message });
          // 更新请求状态
          const updateSql = 'UPDATE friend_requests SET status = ? WHERE id = ?';
          db.run(updateSql, ['accepted', requestId], function (err) {
            if (err) return res.status(500).json({ success: false, message: '更新请求失败', error: err.message });
            // 双方加为好友
            const insertSql = 'INSERT OR IGNORE INTO friends (user_id, friend_id, created_at) VALUES (?, ?, ?), (?, ?, ?)';
            db.run(insertSql, [reqRow.from_id, reqRow.to_id, now, reqRow.to_id, reqRow.from_id, now], function (err) {
              if (err) return res.status(500).json({ success: false, message: '添加好友失败', error: err.message });
              res.json({ success: true, message: '已同意好友请求并创建会话' });
            });
          });
        });
      });
    });
  });
});

// 拒绝好友请求
app.post('/api/friends/reject', (req, res) => {
  const { requestId } = req.body;
  if (!requestId) return res.status(400).json({ success: false, message: '参数缺失' });
  const updateSql = 'UPDATE friend_requests SET status = ? WHERE id = ?';
  db.run(updateSql, ['rejected', requestId], function (err) {
    if (err) return res.status(500).json({ success: false, message: '拒绝请求失败', error: err.message });
    res.json({ success: true, message: '已拒绝好友请求' });
  });
});

// 获取好友列表
app.get('/api/friends', (req, res) => {
  const { userId } = req.query;
  if (!userId) return res.status(400).json({ success: false, message: '参数缺失' });
  
  const sql = `
    SELECT u.id, u.username, u.avatar, u.role, u.created_at as createdAt, f.created_at as friendSince
    FROM friends f
    JOIN users u ON f.friend_id = u.id
    WHERE f.user_id = ?
    ORDER BY f.created_at DESC
  `;
  
  db.all(sql, [userId], (err, rows) => {
    if (err) return res.status(500).json({ success: false, message: '数据库错误', error: err.message });
    res.json({ success: true, friends: rows });
  });
});

// 删除好友
app.delete('/api/friends/:friendId', (req, res) => {
  const { userId } = req.query;
  const { friendId } = req.params;
  if (!userId || !friendId) return res.status(400).json({ success: false, message: '参数缺失' });
  
  const sql = 'DELETE FROM friends WHERE (user_id = ? AND friend_id = ?) OR (user_id = ? AND friend_id = ?)';
  db.run(sql, [userId, friendId, friendId, userId], function (err) {
    if (err) return res.status(500).json({ success: false, message: '删除好友失败', error: err.message });
    res.json({ success: true, message: '已删除好友' });
  });
});

// 标记消息为已读
app.post('/api/messages/read', (req, res) => {
  const { chatId, userId } = req.body;
  if (!chatId || !userId) return res.status(400).json({ success: false, message: '参数缺失' });
  
  const sql = 'UPDATE messages SET status = ? WHERE chat_id = ? AND to_id = ? AND status = ?';
  db.run(sql, ['read', chatId, userId, 'sent'], function (err) {
    if (err) return res.status(500).json({ success: false, message: '标记已读失败', error: err.message });
    res.json({ success: true, message: '已标记为已读' });
  });
});

// 删除消息
app.delete('/api/messages/:messageId', (req, res) => {
  const { messageId } = req.params;
  const { userId } = req.query;
  if (!messageId || !userId) return res.status(400).json({ success: false, message: '参数缺失' });
  
  // 只能删除自己发送的消息
  const sql = 'UPDATE messages SET is_deleted = 1 WHERE id = ? AND from_id = ?';
  db.run(sql, [messageId, userId], function (err) {
    if (err) return res.status(500).json({ success: false, message: '删除消息失败', error: err.message });
    res.json({ success: true, message: '已删除消息' });
  });
});

// 获取未读消息数量
app.get('/api/messages/unread', (req, res) => {
  const { userId } = req.query;
  if (!userId) return res.status(400).json({ success: false, message: '参数缺失' });
  
  const sql = `
    SELECT COUNT(*) as count
    FROM messages m
    JOIN chat_participants p ON m.chat_id = p.chat_id
    WHERE p.user_id = ? AND m.to_id = ? AND m.status = 'sent' AND m.is_deleted = 0
  `;
  
  db.get(sql, [userId, userId], (err, row) => {
    if (err) return res.status(500).json({ success: false, message: '数据库错误', error: err.message });
    res.json({ success: true, unreadCount: row.count });
  });
});

// 创建或获取私聊会话
app.post('/api/chats/private', (req, res) => {
  const { userId1, userId2 } = req.body;
  if (!userId1 || !userId2) return res.status(400).json({ success: false, message: '参数缺失' });
  
  // 检查是否已存在会话
  const checkSql = `
    SELECT c.id FROM chats c
    JOIN chat_participants p1 ON c.id = p1.chat_id AND p1.user_id = ?
    JOIN chat_participants p2 ON c.id = p2.chat_id AND p2.user_id = ?
    WHERE c.type = 'private'
    LIMIT 1
  `;
  
  db.get(checkSql, [userId1, userId2], (err, row) => {
    if (err) return res.status(500).json({ success: false, message: '数据库错误', error: err.message });
    
    if (row) {
      // 会话已存在
      res.json({ success: true, chatId: row.id, isNew: false });
    } else {
      // 创建新会话
      const createChatSql = 'INSERT INTO chats (type, last_msg, last_msg_time) VALUES (?, ?, ?)';
      const now = new Date().toISOString();
      db.run(createChatSql, ['private', '', now], function (err) {
        if (err) return res.status(500).json({ success: false, message: '创建会话失败', error: err.message });
        
        const chatId = this.lastID;
        const insertParticipantsSql = 'INSERT INTO chat_participants (chat_id, user_id) VALUES (?, ?), (?, ?)';
        db.run(insertParticipantsSql, [chatId, userId1, chatId, userId2], function (err) {
          if (err) return res.status(500).json({ success: false, message: '添加会话成员失败', error: err.message });
          res.json({ success: true, chatId: chatId, isNew: true });
        });
      });
    }
  });
});

// ========== 静态托管Flutter Web前端和兜底路由 ==========
// 兼容移动端访问含中文文件名的静态资源：
// 一些构建环境会将文件名写成百分号编码（例如 %E6%95%85%E5%AE%AB.png），
// 而浏览器请求会在到达 Express 前被自动 decode 成中文（故宫.png），
// 导致默认的 express.static 找不到文件。在这里优先用 originalUrl 定位物理文件，
// 当磁盘存在对应的百分号编码文件时直接返回，避免 404。
app.get(/^\/assets\/.*/, (req, res, next) => {
  try {
    const originalPath = req.originalUrl.split('?')[0].replace(/^\//, '');
    const filePath = path.join(__dirname, 'web', originalPath);
    if (fs.existsSync(filePath)) {
      return res.sendFile(filePath);
    }
  } catch (e) {
    // 忽略，交给后续中间件处理
  }
  next();
});

app.use(express.static(path.join(__dirname, 'web')));
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'web/index.html'));
});

// 最后定义根路径欢迎信息，确保优先生效
app.get('/', (req, res) => {
  res.send('Hello, Travel App backend is running!');
});

// 获取端口配置
const PORT = process.env.PORT || 3000;

// 初始化数据库并启动服务器
initializeDatabase().then(() => {
  app.listen(PORT, '0.0.0.0',() => {
    console.log(`🚀 API server running at http://localhost:${PORT}`);
    console.log('📊 数据库已就绪');
    console.log('🌐 CORS已配置为允许所有localhost端口');
    console.log('📝 可通过环境变量PORT自定义端口');
  });
}).catch((error) => {
  console.error('❌ 数据库初始化失败:', error);
  process.exit(1);
});

// AI助手聊天接口 - 转发到 proxy_server.js 的 /api/tongyi
app.post('/ai/chat', async (req, res) => {
  try {
    const { message, apiKey: apiKeyFromBody } = req.body;
    const apiKey = process.env.DASHSCOPE_API_KEY || apiKeyFromBody;
    if (!apiKey) {
      return res.status(400).json({ success: false, message: '缺少 dashscope API Key' });
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
      const aiMsg = data.output?.choices?.[0]?.message?.content || data.choices?.[0]?.message?.content || data.output?.text || data.output || data.message || JSON.stringify(data);
      return res.json({ success: true, response: aiMsg });
    } else {
      res.status(response.status).json({ success: false, message: data.error || 'AI服务异常' });
    }
  } catch (error) {
    console.error('AI助手接口错误:', error);
    res.status(500).json({ success: false, message: 'AI助手服务异常', error: error.message });
  }
});