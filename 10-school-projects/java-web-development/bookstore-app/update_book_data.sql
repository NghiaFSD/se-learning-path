-- Script them du lieu author va edition vao bang Book
-- Chay script nay tren SQL Server

-- Cap nhat du lieu cho cac sach co san
UPDATE Book SET author = N'J.K. Rowling', edition = 'Lan 1' WHERE id = 1;
UPDATE Book SET author = N'George R. R. Martin', edition = 'Lan 2' WHERE id = 2;
UPDATE Book SET author = N'J.R.R. Tolkien', edition = 'Lan 3' WHERE id = 3;
UPDATE Book SET author = N'Harper Lee', edition = 'Lan 1' WHERE id = 4;
UPDATE Book SET author = N'Stephen King', edition = 'Lan 2' WHERE id = 5;
UPDATE Book SET author = N'Isaac Asimov', edition = 'Lan 1' WHERE id = 6;
UPDATE Book SET author = N'Arthur Conan Doyle', edition = 'Lan 5' WHERE id = 7;
UPDATE Book SET author = N'Jules Verne', edition = 'Lan 2' WHERE id = 8;
UPDATE Book SET author = N'Jane Austen', edition = 'Lan 3' WHERE id = 9;
UPDATE Book SET author = N'Mary Shelley', edition = 'Lan 4' WHERE id = 10;

-- Them cac sach moi voi day du thong tin (neu can)
-- Uncomment dong duoi neu muon them sach moi:
-- INSERT INTO Book(title, price, image, cid, description, stock, author, edition)
-- VALUES(N'Ten sach', 99000, 'url_anh', 1, N'Mo ta', 10, N'Tac gia', 'Lan 1');
