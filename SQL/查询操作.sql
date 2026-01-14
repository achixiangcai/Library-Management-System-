-- 1.查询所有图书的基本信息
SELECT 
    b.BookID,
    b.Title,
    a.Name AS Author,
    bt.TypeName AS Category,
    p.Name AS Publisher,
    b.PublishYear,
    b.ISBN,
    b.Price
FROM Books b
JOIN Authors a ON b.AuthorID = a.AuthorID
JOIN BookTypes bt ON b.TypeID = bt.TypeID
JOIN Publishers p ON b.PublisherID = p.PublisherID;

-- 2.查询未归还读者的借阅记录
SELECT 
    br.BorrowID,
    r.Name AS ReaderName,
    b.Title,
    br.BorrowDate,
    br.DueDate
FROM BorrowRecords br
JOIN Readers r ON br.ReaderID = r.ReaderID
JOIN BookCopies bc ON br.CopyID = bc.CopyID
JOIN Books b ON bc.BookID = b.BookID
WHERE br.ReturnDate IS NULL
  AND r.Name = ''; 
  
  -- 3.查询所有当前可借的图书副本（Status = 'Available'）
  SELECT 
    bc.CopyID,
    b.Title,
    bc.Location,
    bc.Status
FROM BookCopies bc
JOIN Books b ON bc.BookID = b.BookID
WHERE bc.Status = 'Available';

-- 4. 查询当前所有逾期未归还的借阅记录
SELECT 
    br.BorrowID,
    r.Name AS ReaderName,
    b.Title,
    br.BorrowDate,
    br.DueDate,
    DATEDIFF(CURDATE(), br.DueDate) AS DaysOverdue
FROM BorrowRecords br
JOIN Readers r ON br.ReaderID = r.ReaderID
JOIN BookCopies bc ON br.CopyID = bc.CopyID
JOIN Books b ON bc.BookID = b.BookID
WHERE br.ReturnDate IS NULL
  AND br.DueDate < CURDATE();

-- 5.查询近一个月借阅最多的图书类别
SELECT 
    bt.TypeName,
    COUNT(*) AS BorrowCount
FROM BorrowRecords br
JOIN BookCopies bc ON br.CopyID = bc.CopyID
JOIN Books b ON bc.BookID = b.BookID
JOIN BookTypes bt ON b.TypeID = bt.TypeID
WHERE br.BorrowDate >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
GROUP BY bt.TypeName
ORDER BY BorrowCount DESC
LIMIT 1;

-- 6.查询预约中仍未处理的记录（Status = 'Reserved'）
SELECT 
    res.ReservationID,
    r.Name AS ReaderName,
    b.Title,
    res.ReservationDate,
    res.Status
FROM Reservations res
JOIN Readers r ON res.ReaderID = r.ReaderID
JOIN BookCopies bc ON res.CopyID = bc.CopyID
JOIN Books b ON bc.BookID = b.BookID
WHERE res.Status = '未处理';

-- 7.查询在馆图书的副本数量
SELECT 
    b.Title,
    COUNT(*) AS TotalCopies,
    SUM(CASE WHEN bc.Status = 'Available' THEN 1 ELSE 0 END) AS AvailableCopies
FROM Books b
JOIN BookCopies bc ON b.BookID = bc.BookID
GROUP BY b.Title;

-- 8.查询每本图书的副本数量与在馆副本数量
SELECT 
    b.Title,
    COUNT(*) AS TotalCopies,
    SUM(CASE WHEN bc.Status = '在馆' THEN 1 ELSE 0 END) AS AvailableCopies
FROM Books b
JOIN BookCopies bc ON b.BookID = bc.BookID
GROUP BY b.Title;



  
  
