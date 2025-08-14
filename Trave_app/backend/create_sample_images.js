const fs = require('fs');
const path = require('path');

// 创建一个简单的1x1像素的PNG图片数据 (Base64编码)
const pngData = Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChAI9jU77zgAAAABJRU5ErkJggg==', 'base64');

// 确保目录存在
const uploadsDir = path.join(__dirname, 'uploads', 'photos');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// 创建示例图片文件
const sampleImages = [
  'gugong_001.jpg',
  'tiantan_001.jpg',
  'qianmen_001.jpg'
];

sampleImages.forEach(filename => {
  const filePath = path.join(uploadsDir, filename);
  if (!fs.existsSync(filePath)) {
    fs.writeFileSync(filePath, pngData);
    console.log(`✅ 创建示例图片: ${filename}`);
  } else {
    console.log(`📁 图片已存在: ${filename}`);
  }
});

console.log('🎉 示例图片创建完成');
