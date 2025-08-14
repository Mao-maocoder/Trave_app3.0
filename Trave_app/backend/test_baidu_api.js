const axios = require('axios');
const fs = require('fs');
const path = require('path');

// 百度语音API配置
const BAIDU_CONFIG = {
  apiKey: 'GD5XCi0eK4xS3jqsLhLQmUdXpWVNZYyC',
  secretKey: 'kxwTL9BbAIs7h82NKv3Ni0lFWOePGySE',
  appId: '116990948'
};

// 获取百度API访问令牌
async function getBaiduToken() {
  try {
    const url = `https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=${BAIDU_CONFIG.apiKey}&client_secret=${BAIDU_CONFIG.secretKey}`;
    
    console.log('🔑 正在获取百度API令牌...');
    const response = await axios.post(url);
    
    if (response.data && response.data.access_token) {
      console.log('✅ 百度API令牌获取成功:', response.data.access_token.substring(0, 20) + '...');
      return response.data.access_token;
    } else {
      throw new Error('百度API令牌获取失败: ' + JSON.stringify(response.data));
    }
  } catch (error) {
    console.error('❌ 百度API令牌获取错误:', error.message);
    if (error.response) {
      console.error('响应状态:', error.response.status);
      console.error('响应数据:', error.response.data);
    }
    throw error;
  }
}

// 测试百度语音合成
async function testBaiduTTS() {
  try {
    console.log('🎤 开始测试百度语音合成API...');
    
    const token = await getBaiduToken();
    const text = '这是一个测试语音合成';
    
    const params = new URLSearchParams({
      tex: text,
      tok: token,
      cuid: BAIDU_CONFIG.appId,
      ctp: '1',
      lan: 'zh',
      spd: '5',
      pit: '5',
      vol: '5',
      per: '0',
      aue: '3'
    });
    
    console.log('📤 发送TTS请求...');
    const ttsResponse = await axios.post(
      'https://tsn.baidu.com/text2audio',
      params,
      {
        responseType: 'arraybuffer',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        timeout: 10000
      }
    );
    
    if (ttsResponse.status === 200 && ttsResponse.data) {
      console.log('✅ 百度TTS成功！音频数据大小:', ttsResponse.data.length, '字节');
      
      // 保存测试音频文件
      const testFile = path.join(__dirname, 'test_audio.mp3');
      fs.writeFileSync(testFile, ttsResponse.data);
      console.log('💾 测试音频已保存到:', testFile);
      
      return true;
    } else {
      throw new Error('百度TTS返回错误状态');
    }
    
  } catch (error) {
    console.error('❌ 百度TTS测试失败:', error.message);
    if (error.response) {
      console.error('响应状态:', error.response.status);
      console.error('响应数据:', error.response.data);
    }
    return false;
  }
}

// 运行测试
async function runTest() {
  console.log('🚀 开始百度语音API测试...\n');
  
  try {
    const success = await testBaiduTTS();
    if (success) {
      console.log('\n🎉 百度语音API测试成功！');
    } else {
      console.log('\n💥 百度语音API测试失败！');
      console.log('可能的原因：');
      console.log('1. API密钥无效或过期');
      console.log('2. 网络连接问题');
      console.log('3. 百度API服务暂时不可用');
    }
  } catch (error) {
    console.error('\n💥 测试过程中发生错误:', error.message);
  }
}

runTest(); 