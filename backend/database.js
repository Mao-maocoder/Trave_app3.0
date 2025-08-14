const sqlite3 = require('sqlite3').verbose();
const path = require('path');

// 数据库文件路径
const dbPath = path.join(__dirname, 'travel_app.db');

// 创建数据库连接
const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('❌ 数据库连接失败:', err.message);
  } else {
    console.log('✅ 数据库连接成功:', dbPath);
  }
});

// 初始化数据库表
function initializeDatabase() {
  return new Promise((resolve, reject) => {
    // 创建用户表
    const createUsersTable = `
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        avatar TEXT,
        role TEXT NOT NULL DEFAULT 'tourist',
        has_completed_survey BOOLEAN NOT NULL DEFAULT 0,
        is_active BOOLEAN NOT NULL DEFAULT 1,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `;

    // 创建问卷提交表
    const createSurveysTable = `
      CREATE TABLE IF NOT EXISTS survey_submissions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        interests TEXT,
        diets TEXT,
        health TEXT,
        expect TEXT,
        gender TEXT,
        age_group TEXT,
        monthly_income TEXT,
        cultural_identity TEXT,
        psychological_traits TEXT,
        travel_frequency TEXT,
        suggestion TEXT,
        submitted_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    `;

    // 创建照片表
    const createPhotosTable = `
      CREATE TABLE IF NOT EXISTS photos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        filename TEXT NOT NULL,
        original_name TEXT NOT NULL,
        spot_name TEXT NOT NULL,
        title TEXT,
        description TEXT,
        uploader TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        uploaded_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        approved_at DATETIME,
        approved_by INTEGER,
        FOREIGN KEY (approved_by) REFERENCES users (id)
      )
    `;

    // 创建反馈表
    const createFeedbackTable = `
      CREATE TABLE IF NOT EXISTS feedback (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        rating INTEGER NOT NULL,
        comment TEXT,
        category TEXT,
        submitted_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    `;

    // 新增游客-导游绑定关系表
    const createUserGuideBindingsTable = `
      CREATE TABLE IF NOT EXISTS user_guide_bindings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tourist_id INTEGER NOT NULL,
        guide_id INTEGER NOT NULL,
        status TEXT DEFAULT 'pending', -- pending/approved/rejected
        created_at TEXT DEFAULT (datetime('now', 'localtime')),
        updated_at TEXT DEFAULT (datetime('now', 'localtime')),
        FOREIGN KEY (tourist_id) REFERENCES users(id),
        FOREIGN KEY (guide_id) REFERENCES users(id)
      )
    `;

    // 创建聊天会话表
    const createChatsTable = `
      CREATE TABLE IF NOT EXISTS chats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL DEFAULT 'private', -- private/group
        last_msg TEXT,
        last_msg_time DATETIME DEFAULT CURRENT_TIMESTAMP,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `;

    // 创建聊天参与者表
    const createChatParticipantsTable = `
      CREATE TABLE IF NOT EXISTS chat_participants (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        chat_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        joined_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (chat_id) REFERENCES chats(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE(chat_id, user_id)
      )
    `;

    // 创建消息表
    const createMessagesTable = `
      CREATE TABLE IF NOT EXISTS messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        chat_id INTEGER NOT NULL,
        from_id INTEGER NOT NULL,
        to_id INTEGER NOT NULL,
        content TEXT,
        type TEXT NOT NULL DEFAULT 'text', -- text/image/voice/file
        image_url TEXT,
        voice_url TEXT,
        file_url TEXT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        status TEXT NOT NULL DEFAULT 'sent', -- sent/delivered/read
        is_deleted BOOLEAN DEFAULT 0,
        FOREIGN KEY (chat_id) REFERENCES chats(id) ON DELETE CASCADE,
        FOREIGN KEY (from_id) REFERENCES users(id),
        FOREIGN KEY (to_id) REFERENCES users(id)
      )
    `;

    // 创建好友关系表
    const createFriendsTable = `
      CREATE TABLE IF NOT EXISTS friends (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        friend_id INTEGER NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (friend_id) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE(user_id, friend_id)
      )
    `;

    // 创建好友请求表
    const createFriendRequestsTable = `
      CREATE TABLE IF NOT EXISTS friend_requests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        from_id INTEGER NOT NULL,
        to_id INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending', -- pending/accepted/rejected
        message TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (from_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (to_id) REFERENCES users(id) ON DELETE CASCADE
      )
    `;

    // 执行表创建
    db.serialize(() => {
      db.run(createUsersTable, (err) => {
        if (err) {
          console.error('❌ 创建用户表失败:', err.message);
          reject(err);
          return;
        }
        console.log('✅ 用户表创建成功');
        
        // 检查并添加has_completed_survey字段（如果不存在）
        db.get("PRAGMA table_info(users)", (err, rows) => {
          if (err) {
            console.error('❌ 检查表结构失败:', err.message);
            return;
          }
          
          db.all("PRAGMA table_info(users)", (err, columns) => {
            if (err) {
              console.error('❌ 获取表结构失败:', err.message);
              return;
            }
            
            const hasColumn = columns.some(col => col.name === 'has_completed_survey');
            if (!hasColumn) {
              console.log('🔄 添加has_completed_survey字段...');
              db.run("ALTER TABLE users ADD COLUMN has_completed_survey BOOLEAN NOT NULL DEFAULT 0", (err) => {
                if (err) {
                  console.error('❌ 添加字段失败:', err.message);
                } else {
                  console.log('✅ has_completed_survey字段添加成功');
                }
              });
            } else {
              console.log('✅ has_completed_survey字段已存在');
            }
          });
        });
      });

      db.run(createSurveysTable, (err) => {
        if (err) {
          console.error('❌ 创建问卷表失败:', err.message);
          reject(err);
          return;
        }
        console.log('✅ 问卷表创建成功');
      });

      db.run(createPhotosTable, (err) => {
        if (err) {
          console.error('❌ 创建照片表失败:', err.message);
          reject(err);
          return;
        }
        console.log('✅ 照片表创建成功');
      });

      db.run(createFeedbackTable, (err) => {
        if (err) {
          console.error('❌ 创建反馈表失败:', err.message);
          reject(err);
          return;
        }
        console.log('✅ 反馈表创建成功');
      });

      db.run(createUserGuideBindingsTable, (err) => {
        if (err) {
          console.error('❌ 创建user_guide_bindings表失败:', err.message);
        } else {
          console.log('✅ 游客-导游绑定关系表创建成功');
        }
      });

      db.run(createChatsTable, (err) => {
        if (err) {
          console.error('❌ 创建聊天会话表失败:', err.message);
        } else {
          console.log('✅ 聊天会话表创建成功');
        }
      });

      db.run(createChatParticipantsTable, (err) => {
        if (err) {
          console.error('❌ 创建聊天参与者表失败:', err.message);
        } else {
          console.log('✅ 聊天参与者表创建成功');
        }
      });

      db.run(createMessagesTable, (err) => {
        if (err) {
          console.error('❌ 创建消息表失败:', err.message);
        } else {
          console.log('✅ 消息表创建成功');
        }
      });

      db.run(createFriendsTable, (err) => {
        if (err) {
          console.error('❌ 创建好友关系表失败:', err.message);
        } else {
          console.log('✅ 好友关系表创建成功');
        }
      });

      db.run(createFriendRequestsTable, (err) => {
        if (err) {
          console.error('❌ 创建好友请求表失败:', err.message);
        } else {
          console.log('✅ 好友请求表创建成功');
          
          // 插入初始用户数据
          insertInitialData().then(() => {
            console.log('🎉 数据库初始化完成');
            resolve();
          }).catch(reject);
        }
      });
    });
  });
}

// 插入初始数据
function insertInitialData() {
  return new Promise((resolve, reject) => {
    // 检查是否已有用户数据
    db.get("SELECT COUNT(*) as count FROM users", (err, row) => {
      if (err) {
        reject(err);
        return;
      }

      if (row.count > 0) {
        console.log('📊 数据库已有数据，跳过初始化');
        resolve();
        return;
      }

      // 插入初始用户
      const insertUsers = `
        INSERT INTO users (username, email, password, role, created_at) VALUES
        ('admin', 'admin@example.com', '123456', 'guide', '2024-01-01 00:00:00'),
        ('user', 'user@example.com', '123456', 'tourist', '2024-01-15 00:00:00'),
        ('guide1', 'guide1@example.com', '123456', 'guide', '2024-02-01 00:00:00')
      `;

      db.run(insertUsers, (err) => {
        if (err) {
          console.error('❌ 插入初始用户失败:', err.message);
          reject(err);
          return;
        }
        console.log('✅ 初始用户数据插入成功');
        resolve();
      });
    });
  });
}

// 导出数据库实例和初始化函数
module.exports = {
  db,
  initializeDatabase
};
