-- 创建数据库
CREATE DATABASE IF NOT EXISTS LibraryDB;
USE LibraryDB;

-- 作者表
CREATE TABLE Authors (
    AuthorID INT AUTO_INCREMENT PRIMARY KEY COMMENT '作者ID',
    Name VARCHAR(100) NOT NULL COMMENT '作者姓名',
    Nationality VARCHAR(50) COMMENT '国籍',
    BirthYear YEAR COMMENT '出生年份'
) COMMENT = '作者信息表';

CREATE TABLE BookTypes (
    TypeID INT AUTO_INCREMENT PRIMARY KEY COMMENT '类别ID',
    TypeName VARCHAR(50) UNIQUE NOT NULL COMMENT '类别名称'
) COMMENT = '图书类别表';

CREATE TABLE Books (
    BookID INT AUTO_INCREMENT PRIMARY KEY COMMENT '图书ID',
    Title VARCHAR(200) NOT NULL COMMENT '书名',
    AuthorID INT COMMENT '作者ID',
    PublisherID INT COMMENT '出版社ID',
    TypeID INT COMMENT '类别ID',
    PublishYear YEAR COMMENT '出版年份',
    ISBN VARCHAR(20) UNIQUE NOT NULL COMMENT '国际标准书号', -- 改为NOT NULL
    Price DECIMAL(8,2) COMMENT '价格',
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID),
    FOREIGN KEY (PublisherID) REFERENCES Publishers(PublisherID),
    FOREIGN KEY (TypeID) REFERENCES BookTypes(TypeID)
) COMMENT = '图书基本信息表';

CREATE TABLE BookCopies (
    CopyID INT AUTO_INCREMENT PRIMARY KEY COMMENT '副本ID',
    BookID INT NOT NULL COMMENT '图书ID',
    Location VARCHAR(100) COMMENT '存放位置',
    Status ENUM('Available', 'Borrowed', 'Reserved', 'Lost') DEFAULT 'Available' COMMENT '副本状态',
    FOREIGN KEY (BookID) REFERENCES Books(BookID)
) COMMENT = '图书副本信息表';

CREATE TABLE Reservations (
    ReservationID INT AUTO_INCREMENT PRIMARY KEY COMMENT '预约ID',
    ReaderID INT COMMENT '读者ID',
    CopyID INT COMMENT '副本ID',
    ReservationDate DATE NOT NULL COMMENT '预约日期',
    Status ENUM('Pending', 'Completed', 'Cancelled') DEFAULT 'Pending' COMMENT '预约状态',
    FOREIGN KEY (ReaderID) REFERENCES Readers(ReaderID),
    FOREIGN KEY (CopyID) REFERENCES BookCopies(CopyID)
) COMMENT = '预约表';

CREATE TABLE BorrowRecords (
    BorrowID INT AUTO_INCREMENT PRIMARY KEY COMMENT '借阅记录ID',
    ReaderID INT COMMENT '读者ID',
    CopyID INT COMMENT '副本ID',
    BorrowDate DATE NOT NULL COMMENT '借阅日期',
    DueDate DATE NOT NULL COMMENT '应归还日期',
    ReturnDate DATE COMMENT '实际归还日期',
    FOREIGN KEY (ReaderID) REFERENCES Readers(ReaderID),
    FOREIGN KEY (CopyID) REFERENCES BookCopies(CopyID)
) COMMENT = '借阅记录表';

CREATE TABLE Fines (
    FineID INT AUTO_INCREMENT PRIMARY KEY COMMENT '罚款ID',
    BorrowID INT UNIQUE NOT NULL COMMENT '借阅记录ID', -- 确保一条借阅记录只有一个罚款
    FineAmount DECIMAL(8,2) DEFAULT 0.00 COMMENT '罚款金额',
    Paid BOOLEAN DEFAULT FALSE COMMENT '是否已支付',
    PaymentDate DATE COMMENT '支付日期',
    FOREIGN KEY (BorrowID) REFERENCES BorrowRecords(BorrowID)
) COMMENT = '逾期罚款信息表';

CREATE TABLE Admins (
    AdminID INT AUTO_INCREMENT PRIMARY KEY COMMENT '管理员ID',
    Username VARCHAR(50) UNIQUE NOT NULL COMMENT '用户名',
    PasswordHash VARCHAR(100) NOT NULL COMMENT '加密密码', -- 改为密码哈希
    FullName VARCHAR(100) COMMENT '姓名',
    LastLogin TIMESTAMP COMMENT '最后登录时间'
) COMMENT = '管理员表';

CREATE TABLE Readers (
    ReaderID INT AUTO_INCREMENT PRIMARY KEY COMMENT '读者ID',
    Name VARCHAR(100) NOT NULL COMMENT '读者姓名',
    Gender ENUM('Male', 'Female') NOT NULL COMMENT '读者性别',
    Phone VARCHAR(20) UNIQUE COMMENT '联系电话', -- 添加唯一性约束
    Address VARCHAR(255) COMMENT '联系地址',
    Email VARCHAR(100) UNIQUE COMMENT '电子邮箱', -- 添加唯一性约束
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    Status ENUM('Active', 'Suspended', 'Inactive') DEFAULT 'Active' COMMENT '读者状态'
) COMMENT = '读者表';

CREATE TABLE Publishers (
    PublisherID INT AUTO_INCREMENT PRIMARY KEY COMMENT '出版社ID',
    Name VARCHAR(100) UNIQUE NOT NULL COMMENT '出版社名称', -- 添加唯一性约束
    Address VARCHAR(255) COMMENT '联系地址',
    Phone VARCHAR(20) COMMENT '联系电话',
    Email VARCHAR(100) COMMENT '电子邮箱'
) COMMENT = '出版社信息表';

ALTER TABLE Publishers ADD COLUMN Email VARCHAR(255); 



-- 清洗读者表 readers
DELETE r1 FROM readers r1
JOIN readers r2
ON r1.IdentityNumber = r2.IdentityNumber
AND r1.ReaderID > r2.ReaderID;

DELETE FROM readers
WHERE FullName IS NULL OR FullName = ''
   OR IdentityNumber IS NULL OR IdentityNumber = '';

DELETE FROM readers
WHERE Phone NOT REGEXP '^[0-9]{11}$';

UPDATE readers
SET FullName = TRIM(FullName);

-- 清洗作者表 authors
DELETE FROM authors
WHERE Name IS NULL OR Name = ''
   OR Nationality IS NULL OR Nationality = '';

DELETE FROM authors
WHERE BirthYear > YEAR(CURDATE());

-- 清洗图书类型表 book_types（通常无问题，仅保留格式标准）
UPDATE book_types
SET TypeName = TRIM(TypeName)
WHERE TypeName IS NOT NULL;

-- 清洗图书信息表 books
DELETE FROM books
WHERE Title IS NULL OR Title = ''
   OR ISBN IS NULL OR ISBN = '';

DELETE FROM books
WHERE Price < 0 OR Price > 1000;

DELETE FROM books
WHERE LENGTH(ISBN) < 10 OR LENGTH(ISBN) > 20;

-- 确保图书名唯一（保留最小 BookID）
DELETE b1 FROM books b1
JOIN books b2
ON b1.Title = b2.Title AND b1.BookID > b2.BookID;

-- 清洗出版社表 publishers
DELETE FROM publishers
WHERE Name IS NULL OR Name = ''
   OR Email IS NULL OR Email NOT LIKE '%@%';

UPDATE publishers
SET Address = TRIM(Address), Phone = TRIM(Phone), Email = LOWER(Email);

-- 清洗管理员表 admins
DELETE FROM admins
WHERE Username IS NULL OR Username = ''
   OR PasswordHash IS NULL OR LENGTH(PasswordHash) != 64;

UPDATE admins
SET Username = TRIM(Username), FullName = TRIM(FullName);

-- 清洗预约表 reservations
DELETE FROM reservations
WHERE ReservationDate IS NULL
   OR Status NOT IN ('等待中', '已确认', '已取消');

-- 清洗借阅记录表 borrow_records
DELETE FROM borrow_records
WHERE BorrowDate IS NULL OR DueDate IS NULL;

DELETE FROM borrow_records
WHERE ReturnDate IS NOT NULL AND (
      ReturnDate < BorrowDate
   OR ReturnDate > DueDate + INTERVAL 30 DAY
);

-- 清洗罚款信息表 fines
DELETE FROM fines
WHERE FineAmount < 0 OR FineAmount > 100;

DELETE FROM fines
WHERE Paid = '是' AND PaymentDate IS NULL;

DELETE FROM fines
WHERE Paid = '否' AND PaymentDate IS NOT NULL;

-- 清洗图书副本信息表 book_copies
DELETE FROM book_copies
WHERE Status NOT IN ('可借', '借出', '损坏', '遗失');

UPDATE book_copies
SET Status = TRIM(Status);
