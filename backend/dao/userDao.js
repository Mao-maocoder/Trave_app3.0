const { db } = require('../database');

class UserDao {
  // 创建用户
  static createUser(userData) {
    return new Promise((resolve, reject) => {
      const { username, email, password, role = 'tourist' } = userData;
      const sql = `
        INSERT INTO users (username, email, password, role)
        VALUES (?, ?, ?, ?)
      `;
      
      db.run(sql, [username, email, password, role], function(err) {
        if (err) {
          reject(err);
          return;
        }
        
        // 返回新创建的用户信息
        UserDao.getUserById(this.lastID).then(resolve).catch(reject);
      });
    });
  }

  // 根据用户名和密码查找用户
  static findUserByCredentials(username, password) {
    return new Promise((resolve, reject) => {
      const sql = `
        SELECT id, username, email, avatar, role, has_completed_survey, is_active, created_at, updated_at
        FROM users 
        WHERE username = ? AND password = ?
      `;
      
      db.get(sql, [username, password], (err, row) => {
        if (err) {
          reject(err);
          return;
        }
        resolve(row);
      });
    });
  }

  // 根据ID获取用户
  static getUserById(id) {
    return new Promise((resolve, reject) => {
      const sql = `
        SELECT id, username, email, avatar, role, has_completed_survey, is_active, created_at, updated_at
        FROM users 
        WHERE id = ?
      `;
      
      db.get(sql, [id], (err, row) => {
        if (err) {
          reject(err);
          return;
        }
        resolve(row);
      });
    });
  }

  // 检查用户名是否存在
  static checkUsernameExists(username) {
    return new Promise((resolve, reject) => {
      const sql = `SELECT COUNT(*) as count FROM users WHERE username = ?`;
      
      db.get(sql, [username], (err, row) => {
        if (err) {
          reject(err);
          return;
        }
        resolve(row.count > 0);
      });
    });
  }

  // 检查邮箱是否存在
  static checkEmailExists(email) {
    return new Promise((resolve, reject) => {
      const sql = `SELECT COUNT(*) as count FROM users WHERE email = ?`;
      
      db.get(sql, [email], (err, row) => {
        if (err) {
          reject(err);
          return;
        }
        resolve(row.count > 0);
      });
    });
  }

  // 获取所有用户
  static getAllUsers() {
    return new Promise((resolve, reject) => {
      const sql = `
        SELECT id, username, email, avatar, role, has_completed_survey, is_active, created_at, updated_at
        FROM users 
        ORDER BY created_at DESC
      `;
      
      db.all(sql, [], (err, rows) => {
        if (err) {
          reject(err);
          return;
        }
        resolve(rows);
      });
    });
  }

  // 获取用户统计
  static getUserStats() {
    return new Promise((resolve, reject) => {
      const sql = `
        SELECT 
          COUNT(*) as total,
          SUM(CASE WHEN is_active = 1 THEN 1 ELSE 0 END) as active,
          SUM(CASE WHEN is_active = 0 THEN 1 ELSE 0 END) as inactive,
          SUM(CASE WHEN role = 'tourist' THEN 1 ELSE 0 END) as tourists,
          SUM(CASE WHEN role = 'guide' THEN 1 ELSE 0 END) as guides,
          SUM(CASE WHEN created_at > datetime('now', '-7 days') THEN 1 ELSE 0 END) as recentRegistrations
        FROM users
      `;
      
      db.get(sql, [], (err, row) => {
        if (err) {
          reject(err);
          return;
        }
        resolve(row);
      });
    });
  }

  // 更新用户信息
  static updateUser(id, userData) {
    return new Promise((resolve, reject) => {
      const { username, email, avatar, role, is_active } = userData;
      const sql = `
        UPDATE users 
        SET username = ?, email = ?, avatar = ?, role = ?, is_active = ?, updated_at = CURRENT_TIMESTAMP
        WHERE id = ?
      `;
      
      db.run(sql, [username, email, avatar, role, is_active, id], function(err) {
        if (err) {
          reject(err);
          return;
        }
        
        UserDao.getUserById(id).then(resolve).catch(reject);
      });
    });
  }

  // 删除用户
  static deleteUser(id) {
    return new Promise((resolve, reject) => {
      const sql = `DELETE FROM users WHERE id = ?`;
      
      db.run(sql, [id], function(err) {
        if (err) {
          reject(err);
          return;
        }
        resolve({ deletedRows: this.changes });
      });
    });
  }

  // 游客发起绑定导游请求
  static bindGuide(touristId, guideId) {
    return new Promise((resolve, reject) => {
      // 先查是否已存在pending/approved绑定
      const checkSql = `SELECT * FROM user_guide_bindings WHERE tourist_id = ? AND guide_id = ? AND status IN ('pending', 'approved')`;
      db.get(checkSql, [touristId, guideId], (err, row) => {
        if (err) return reject(err);
        if (row) return reject(new Error('已存在待审批或已绑定的记录'));
        // 不存在则插入
        const sql = `INSERT INTO user_guide_bindings (tourist_id, guide_id, status) VALUES (?, ?, 'pending')`;
        db.run(sql, [touristId, guideId], function(err) {
          if (err) return reject(err);
          resolve({ id: this.lastID });
        });
      });
    });
  }

  // 导游审批绑定请求
  static reviewBindRequest(bindingId, status) {
    return new Promise((resolve, reject) => {
      const sql = `UPDATE user_guide_bindings SET status = ?, updated_at = datetime('now', 'localtime') WHERE id = ?`;
      db.run(sql, [status, bindingId], function(err) {
        if (err) return reject(err);
        resolve();
      });
    });
  }

  // 游客解绑
  static unbindGuide(touristId) {
    return new Promise((resolve, reject) => {
      const sql = `DELETE FROM user_guide_bindings WHERE tourist_id = ?`;
      db.run(sql, [touristId], function(err) {
        if (err) return reject(err);
        resolve();
      });
    });
  }

  // 查询游客当前绑定的导游
  static getBindingByTourist(touristId) {
    return new Promise((resolve, reject) => {
      const sql = `SELECT * FROM user_guide_bindings WHERE tourist_id = ? AND status = 'approved'`;
      db.get(sql, [touristId], (err, row) => {
        if (err) return reject(err);
        resolve(row);
      });
    });
  }

  // 查询导游待审批的绑定请求
  static getPendingBindingsByGuide(guideId) {
    return new Promise((resolve, reject) => {
      const sql = `SELECT * FROM user_guide_bindings WHERE guide_id = ? AND status = 'pending'`;
      db.all(sql, [guideId], (err, rows) => {
        if (err) return reject(err);
        resolve(rows);
      });
    });
  }

  // 查询导游已绑定的游客
  static getApprovedTouristsByGuide(guideId) {
    return new Promise((resolve, reject) => {
      const sql = `SELECT DISTINCT u.* FROM users u JOIN user_guide_bindings b ON u.id = b.tourist_id WHERE b.guide_id = ? AND b.status = 'approved' ORDER BY u.created_at DESC`;
      db.all(sql, [guideId], (err, rows) => {
        if (err) return reject(err);
        resolve(rows);
      });
    });
  }

  // 根据邮箱查找用户
  static findUserByEmail(email) {
    return new Promise((resolve, reject) => {
      const sql = `
        SELECT id, username, email, avatar, role, is_active, created_at, updated_at
        FROM users 
        WHERE email = ?
      `;
      
      db.get(sql, [email], (err, row) => {
        if (err) {
          reject(err);
          return;
        }
        resolve(row);
      });
    });
  }

  // 更新用户凭据
  static updateUserCredentials(id, userData) {
    return new Promise((resolve, reject) => {
      const { username, email, password } = userData;
      const sql = `
        UPDATE users 
        SET username = ?, email = ?, password = ?, updated_at = CURRENT_TIMESTAMP
        WHERE id = ?
      `;
      
      db.run(sql, [username, email, password, id], function(err) {
        if (err) {
          reject(err);
          return;
        }
        
        if (this.changes > 0) {
          UserDao.getUserById(id).then(resolve).catch(reject);
        } else {
          reject(new Error('用户不存在'));
        }
      });
    });
  }

  // 更新用户问卷完成状态
  static updateSurveyCompletionStatus(userId, hasCompleted) {
    return new Promise((resolve, reject) => {
      const sql = `
        UPDATE users 
        SET has_completed_survey = ?, updated_at = CURRENT_TIMESTAMP
        WHERE id = ?
      `;
      
      db.run(sql, [hasCompleted ? 1 : 0, userId], function(err) {
        if (err) {
          reject(err);
          return;
        }
        
        if (this.changes > 0) {
          UserDao.getUserById(userId).then(resolve).catch(reject);
        } else {
          reject(new Error('用户不存在'));
        }
      });
    });
  }
}

module.exports = UserDao;
