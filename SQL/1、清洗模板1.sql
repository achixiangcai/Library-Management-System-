

# 备注 提示Error Code: 1175 为Workbench工具安全限制，通过sql语句处理即可解决
SET SQL_SAFE_UPDATES = 0;

# 一 清洗 tbl_com_user 表数据
SELECT * FROM tbl_com_user;

#修改列名“链接路径”为id
alter table tbl_com_user
change  链接路径 id varchar(100);

# 1 增加一个自增数据列
ALTER TABLE tbl_com_user ADD COLUMN num INT(11) KEY AUTO_INCREMENT;

# 2 创建视图
CREATE VIEW v_com_user_redata
AS
SELECT num,id,count(id) AS ucount FROM tbl_com_user GROUP BY id;

SELECT * FROM v_com_user_redata;

# 3 删除重复的列中ID较大的那一个
DELETE FROM tbl_com_user WHERE num in(
    SELECT num FROM v_com_user_redata WHERE ucount > 1
);


# 二 清洗 tbl_com_act 表数据
SELECT * FROM tbl_com_act;

#修改列名“链接路径”为id
alter table tbl_com_user
change  链接路径 id varchar(100);

# 1 增加一个自增数据列
ALTER TABLE tbl_com_act ADD COLUMN num INT(11) KEY AUTO_INCREMENT;

# 2 创建视图
CREATE VIEW v_com_act_redata
AS
SELECT num,id,count(id) AS ucount FROM tbl_com_act GROUP BY id,act;

SELECT * FROM v_com_user_redata;

# 3 删除重复的列中ID较大的那一个
DELETE FROM tbl_com_act WHERE num in(
    SELECT num FROM v_com_act_redata WHERE ucount > 1
);


# 三 清洗 tbl_com_book 表数据
SELECT * FROM tbl_com_book;

#修改列名“链接路径”为id
alter table tbl_com_user
change  链接路径 id varchar(100);

# 1 增加一个自增数据列
ALTER TABLE tbl_com_book ADD COLUMN num INT(11) KEY AUTO_INCREMENT;

# 2 创建视图
CREATE VIEW v_com_book_redata
AS
SELECT num,id,count(id) AS ucount FROM tbl_com_book GROUP BY id,bok;

SELECT * FROM v_com_book_redata;

# 3 删除重复的列中ID较大的那一个
DELETE FROM tbl_com_book WHERE num in(
    SELECT num FROM v_com_book_redata WHERE ucount > 1
);


#四 清洗 tbl_com_group 表数据
SELECT * FROM tbl_com_group;

#修改列名“链接路径”为id
alter table tbl_com_user
change  链接路径 id varchar(100);

# 1 增加一个自增数据列
ALTER TABLE tbl_com_group ADD COLUMN num INT(11) KEY AUTO_INCREMENT;

# 2 创建视图
CREATE VIEW v_com_group_redata
AS
SELECT num,id,count(id) AS ucount FROM tbl_com_group GROUP BY id,comm;

SELECT * FROM v_com_group_redata;

# 3 删除重复的列中ID较大的那一个
DELETE FROM tbl_com_group WHERE num in(
    SELECT num FROM v_com_group_redata WHERE ucount > 1
);