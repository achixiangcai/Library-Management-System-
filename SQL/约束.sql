-- 一、使用外键约束保护数据完整性
-- 【1】禁止删除已有借阅记录的图书副本
ALTER TABLE BorrowRecords
ADD CONSTRAINT fk_borrow_copy_new
FOREIGN KEY (CopyID) REFERENCES BookCopies(CopyID)
ON DELETE RESTRICT;

-- 二、使用触发器实现自动操作
-- 【2】借出副本后，自动设置副本状态为“借出”
DELIMITER $$

CREATE TRIGGER trg_after_borrow
AFTER INSERT ON BorrowRecords
FOR EACH ROW
BEGIN
    UPDATE BookCopies
    SET Status = '借出'
    WHERE CopyID = NEW.CopyID;
END $$

DELIMITER ;

-- 【3】归还图书后（ReturnDate 非空），如果超期则自动添加罚款记录
DELIMITER $$

CREATE TRIGGER trg_after_return
AFTER UPDATE ON BorrowRecords
FOR EACH ROW
BEGIN
    IF NEW.ReturnDate IS NOT NULL AND NEW.ReturnDate > NEW.DueDate THEN
        INSERT INTO Fines (FineID, BorrowID, FineAmount, Paid, PaymentDate)
        VALUES (UUID_SHORT(), NEW.BorrowID, DATEDIFF(NEW.ReturnDate, NEW.DueDate) * 1.0, 0, NULL);
    END IF;
END $$

DELIMITER ;



