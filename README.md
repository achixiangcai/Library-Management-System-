# 图书馆管理系统（数据库课程设计）

## 一、项目简介

本项目是一个基于 MySQL 数据库的图书馆管理系统课程设计，包含：

- 完整的图书馆业务数据库设计（ER 图 + 建表 SQL）
- 一套用于练习/演示的 SQL 脚本（查询、增删改、约束等）
- 一批示例数据（CSV/Excel），可导入数据库进行测试
- 一个基于 Flask + PyMySQL 的简易 Web 管理前端（借还书、读者注册、罚款、预约等）

适合作为数据库课程作业、实验或期末课程设计使用。


## 二、目录结构
- `SQL/`  
  - `library.mwb`：MySQL Workbench 的数据库建模文件  
  - `booktype.sql`：图书类别等相关建表/数据脚本  
  - `基本操作（插入、修改、删除）.sql`：基础 DML 操作示例  
  - `查询操作.sql`：典型查询语句示例  
  - `约束.sql`：约束（主键、外键等）相关脚本  
  - `总操作.sql`：综合 SQL 操作脚本（可用于初始化/演示）  
  - `清洗模板.sql`：数据清洗/预处理示例脚本
- `data/`  
  存放示例数据文件，可导入到数据库中：
  - `admins.csv` 管理员
  - `authors.csv` 作者
  - `book_copies.csv` 图书副本
  - `book_types.csv` 图书类别
  - `books.csv` 图书基本信息
  - `borrow_records*.csv` 借阅记录
  - `fines.csv` 罚款记录
  - `publishers.csv` 出版社
  - `readers.csv` 读者信息
  - `reservations.csv` 预约信息
- `libraryweb/`  
  简易 Web 管理系统（Flask 应用）：
  - `app.py`：Flask 后端主程序
  - `templates/`：Jinja2 HTML 模板
    - `base.html`：基础布局
    - `index.html`：首页
    - `add_book.html`：新增图书
    - `register_reader.html`：读者注册
    - `borrow_book.html`：借书
    - `return_book.html`：还书
    - `unreturned_books.html`：未归还图书列表
    - `fines.html`：罚款查询与缴纳
    - `reservations.html`：预约查询
- `ER-libaray.png`  
  数据库 ER 图（实体-联系图），展示主要表及其关系。


## 三、技术栈与运行环境

- 数据库：MySQL（推荐 5.7 或 8.0）
- 后端：Python 3.x + Flask
- 数据库访问：PyMySQL
- 前端：HTML + Jinja2 模板（可按需要自行美化）


## 八、注意事项

- 请勿在公开仓库中提交真实数据库密码，可以使用环境变量或配置文件管理敏感信息。
- SQL 脚本与示例数据的执行/导入顺序，可能需要根据课程要求或教师说明进行调整。
- 本项目主要用于学习和教学示例，未对安全性、并发、权限等进行严格处理，若用于实际生产环境需进行大量增强与加固。
- 若在运行过程中遇到编码问题，建议统一使用 `utf8mb4` 编码，并确保 MySQL、Python 及终端环境的编码设置一致。
