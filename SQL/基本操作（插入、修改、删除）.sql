-- 基本操作功能

-- 1.插入一本新书
-- （1）插入表books，已有作者ID = 1，类型ID = 2，出版社ID = 3
INSERT INTO Books (BookID, Title, AuthorID, TypeID, PublisherID, PublishYear, ISBN, Price)
VALUES (300, '机器学习导论', 1, 2, 3, 2023, '978-2-227-79235-3', 88.00);

-- （2）插入该图书的两个副本至bookcopies表
INSERT INTO BookCopies (CopyID, BookID, Location, Status)
VALUES 
  (2010, 300, '3楼C区-2架', 'Available'),
  (2011, 300, '3楼C区-2架', 'Available');

-- 2.注册一个新读者
INSERT INTO Readers (ReaderID, Name, Gender, Phone, Address, Email, CreatedAt)
VALUES (5010, '李雷', '1', '13888888888', '北京市海淀区', 'lilei@exampe.com', CURDATE());

-- 3.录入预约 → 借阅 → 归还 → 罚款的全过程
-- （1）读者预约一本书的副本（CopyID = 2010）
INSERT INTO Reservations (ReservationID, ReaderID, CopyID, ReservationDate, Status)
VALUES (3010, 5010, 2010, CURDATE(), 'Pending');

-- （2）图书借出，更新副本状态，同时插入借阅记录
-- 更新预约状态为已处理
UPDATE Reservations 
SET Status = 'Completed'
WHERE ReservationID = 3010;

-- 借出图书（设定应还时间为30天后）
INSERT INTO BorrowRecords (BorrowID, ReaderID, CopyID, BorrowDate, DueDate, ReturnDate)
VALUES (4010, 5010, 2010, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 30 DAY), NULL);

-- 更新副本状态为“借出”
UPDATE BookCopies 
SET Status = 'Borrowed'
WHERE CopyID = 2010;

-- （3）归还图书（设定归还时间为30天后，即超期）
-- 模拟读者归还图书
UPDATE BorrowRecords
SET ReturnDate = DATE_ADD(BorrowDate, INTERVAL 31 DAY)
WHERE BorrowID = 4010;

-- 更新副本状态为“Available”
UPDATE BookCopies
SET Status = 'Available'
WHERE CopyID = 2010;

-- （4）系统添加逾期罚款（假设罚金：超期1天 × 每天1元）
-- 计算逾期罚款并插入到 Fines 表中
INSERT INTO Fines (BorrowID, FineAmount, Paid, PaymentDate)
SELECT 
    br.BorrowID,
    CASE 
        WHEN br.ReturnDate > br.DueDate THEN DATEDIFF(br.ReturnDate, br.DueDate) * 1.00  -- 逾期天数 × 1元/天
        ELSE 0  -- 未逾期则罚款为0
    END AS FineAmount,
    0 AS Paid,  -- 默认未支付
    NULL AS PaymentDate  -- 默认无支付日期
FROM BorrowRecords br
WHERE br.BorrowID = 4010;  -- 仅处理特定借阅记录

-- 4. 标记某条罚款记录为已缴纳
UPDATE Fines
SET Paid = 1,
    PaymentDate = CURDATE()
WHERE FineID = 6010;

-- 5.删除一本图书的所有副本*
-- 删除 BookID = 1010 的所有副本
DELETE FROM BookCopies
WHERE BookID = 1010;
-- （如需同时删除书本本体）
DELETE FROM Books
WHERE BookID = 1010;

