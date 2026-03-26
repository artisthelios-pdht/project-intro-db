DROP DATABASE IF EXISTS LibraryManagement;
CREATE DATABASE LibraryManagement CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE LibraryManagement;
-- 1. Tạo bảng tbl_publisher (Nhà xuất bản)
CREATE TABLE tbl_publisher (
    publisher_Name VARCHAR(255) PRIMARY KEY,
    publisher_Address VARCHAR(500) NOT NULL,
    publisher_Phone VARCHAR(20)
);

-- 2. Tạo bảng tbl_library_branch (Chi nhánh thư viện)
CREATE TABLE tbl_library_branch (
    branch_ID INT PRIMARY KEY,
    branch_Name VARCHAR(255) NOT NULL,
    branch_Address VARCHAR(500) NOT NULL
);

-- 3. Tạo bảng tbl_borrower (Người mượn)
CREATE TABLE tbl_borrower (
    card_No INT PRIMARY KEY,
    borrower_Name VARCHAR(255) NOT NULL,
    borrower_Address VARCHAR(500),
    borrower_Phone VARCHAR(20),
    borrower_Type VARCHAR(50)
);

-- 4. Tạo bảng tbl_book (Sách)
CREATE TABLE tbl_book (
    book_ID INT PRIMARY KEY,
    book_Title VARCHAR(255) NOT NULL,
    book_PublisherName VARCHAR(255),
    CONSTRAINT fk_book_publisher FOREIGN KEY (book_PublisherName) 
        REFERENCES tbl_publisher(publisher_Name) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 5. Tạo bảng tbl_book_authors (Tác giả)
CREATE TABLE tbl_book_authors (
    author_ID INT PRIMARY KEY,
    book_ID INT NOT NULL,
    author_Name VARCHAR(255) NOT NULL,
    CONSTRAINT fk_author_book FOREIGN KEY (book_ID) 
        REFERENCES tbl_book(book_ID) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 6. Tạo bảng tbl_book_copies (Bản sao sách tại các chi nhánh)
CREATE TABLE tbl_book_copies (
    copies_ID INT PRIMARY KEY,
    book_ID INT NOT NULL,
    branch_ID INT NOT NULL,
    no_Of_Copies INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_copies_book FOREIGN KEY (book_ID) 
        REFERENCES tbl_book(book_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_copies_branch FOREIGN KEY (branch_ID) 
        REFERENCES tbl_library_branch(branch_ID) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 7. Tạo bảng tbl_book_loans (Giao dịch mượn sách)
CREATE TABLE tbl_book_loans (
    loan_ID INT PRIMARY KEY,
    book_ID INT NOT NULL,
    branch_ID INT NOT NULL,
    card_No INT NOT NULL,
    date_Out DATE NOT NULL,
    date_Due DATE NOT NULL,
    CONSTRAINT fk_loan_book FOREIGN KEY (book_ID) 
        REFERENCES tbl_book(book_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_loan_branch FOREIGN KEY (branch_ID) 
        REFERENCES tbl_library_branch(branch_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_loan_borrower FOREIGN KEY (card_No) 
        REFERENCES tbl_borrower(card_No) ON DELETE CASCADE ON UPDATE CASCADE
);
-- 1. Liên kết Sách với Nhà xuất bản
ALTER TABLE tbl_book
ADD CONSTRAINT fk_book_publisher 
FOREIGN KEY (book_PublisherName) REFERENCES tbl_publisher(publisher_Name) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- 2. Liên kết Tác giả với Sách
ALTER TABLE tbl_book_authors
ADD CONSTRAINT fk_author_book 
FOREIGN KEY (book_ID) REFERENCES tbl_book(book_ID) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- 3. Liên kết Bản sao sách với Sách và Chi nhánh thư viện
ALTER TABLE tbl_book_copies
ADD CONSTRAINT fk_copies_book 
FOREIGN KEY (book_ID) REFERENCES tbl_book(book_ID) ON DELETE CASCADE ON UPDATE CASCADE,
ADD CONSTRAINT fk_copies_branch 
FOREIGN KEY (branch_ID) REFERENCES tbl_library_branch(branch_ID) ON DELETE CASCADE ON UPDATE CASCADE;

-- 4. Liên kết Giao dịch mượn sách với Sách, Chi nhánh và Độc giả
ALTER TABLE tbl_book_loans
ADD CONSTRAINT fk_loan_book 
FOREIGN KEY (book_ID) REFERENCES tbl_book(book_ID) ON DELETE CASCADE ON UPDATE CASCADE,
ADD CONSTRAINT fk_loan_branch 
FOREIGN KEY (branch_ID) REFERENCES tbl_library_branch(branch_ID) ON DELETE CASCADE ON UPDATE CASCADE,
ADD CONSTRAINT fk_loan_borrower 
FOREIGN KEY (card_No) REFERENCES tbl_borrower(card_No) ON DELETE CASCADE ON UPDATE CASCADE;

