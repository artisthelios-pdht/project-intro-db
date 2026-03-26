USE LibraryManagement;

-- YÊU CẦU 1: (Truy vấn lồng - Subquery)
-- Tìm danh sách những cuốn sách chưa từng được độc giả nào mượn.
SELECT 
    book_ID AS 'Mã sách', 
    book_Title AS 'Tên sách', 
    book_PublisherName AS 'Nhà xuất bản'
FROM tbl_books
WHERE book_ID NOT IN (
    SELECT DISTINCT ma_sach 
    FROM BookLoans
);

-- YÊU CẦU 2: (Gom nhóm & Truy vấn lồng tính trung bình trực tiếp)
-- Tìm danh sách các độc giả có số lượng mượn sách lớn hơn mức trung bình.
SELECT 
    dg.ma_doc_gia AS 'Mã Độc Giả',
    dg.ho_ten AS 'Tên Độc Giả',
    COUNT(bl.ma_muon) AS 'Tổng số sách đã mượn'
FROM Borrower dg
JOIN BookLoans bl ON dg.ma_doc_gia = bl.ma_doc_gia
GROUP BY dg.ma_doc_gia, dg.ho_ten
HAVING COUNT(bl.ma_muon) >= (
    -- Truy vấn lồng: Lấy trung bình số lượt mượn của tất cả độc giả
    SELECT AVG(so_luong) 
    FROM (
        SELECT COUNT(ma_muon) AS so_luong 
        FROM BookLoans 
        GROUP BY ma_doc_gia
    ) AS BangTrungBinh
)
ORDER BY COUNT(bl.ma_muon) DESC;

-- YÊU CẦU 3: (Gom nhóm & Thống kê)
-- Thống kê tổng số lượng bản sao (copies) sách hiện có theo từng Nhà xuất bản.
SELECT 
    b.book_PublisherName AS 'Nhà Xuất Bản',
    SUM(c.no_Of_Copies) AS 'Tổng số lượng bản sao đang lưu trữ'
FROM tbl_books b
JOIN tbl_book_copies c ON b.book_ID = c.book_ID
GROUP BY b.book_PublisherName
ORDER BY SUM(c.no_Of_Copies) DESC;

-- YÊU CẦU 4: (Gom nhóm, JOIN & Truy vấn lồng với toán tử ALL)
-- Tìm Tác giả có số lượng sách bị độc giả mượn "Trễ hạn" NHIỀU NHẤT.
SELECT 
    a.author_Name AS 'Tên Tác Giả',
    COUNT(bl.ma_muon) AS 'Số lượt trễ hạn cao nhất'
FROM tbl_book_authors a
JOIN tbl_books b ON a.book_ID = b.book_ID
JOIN BookLoans bl ON b.book_ID = bl.ma_sach
WHERE bl.ngay_tra_thuc_te IS NULL AND bl.han_tra < CURDATE()
GROUP BY a.author_Name
HAVING COUNT(bl.ma_muon) >= ALL (
    SELECT COUNT(bl2.ma_muon)
    FROM tbl_book_authors a2
    JOIN tbl_books b2 ON a2.book_ID = b2.book_ID
    JOIN BookLoans bl2 ON b2.book_ID = bl2.ma_sach
    WHERE bl2.ngay_tra_thuc_te IS NULL AND bl2.han_tra < CURDATE()
    GROUP BY a2.author_Name
);

-- YÊU CẦU 5: (Truy vấn lồng MAX & Gom nhóm)
-- Tìm cuốn sách (hoặc các cuốn sách) được mượn nhiều nhất lịch sử thư viện.
SELECT 
    b.book_ID AS 'Mã Sách',
    b.book_Title AS 'Tên Sách Hot Nhất',
    COUNT(bl.ma_muon) AS 'Tổng lượt mượn'
FROM tbl_books b
JOIN BookLoans bl ON b.book_ID = bl.ma_sach
GROUP BY b.book_ID, b.book_Title
HAVING COUNT(bl.ma_muon) >= ALL (
    -- Subquery: Trả về danh sách tổng lượt mượn của từng cuốn sách
    SELECT COUNT(ma_muon) 
    FROM BookLoans 
    GROUP BY ma_sach
);