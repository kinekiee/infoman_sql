-- ============================================================
--  LIBRARY MANAGEMENT SYSTEM — COMPLETE SQL DDL + DML SCRIPT
-- ============================================================
--
--  DATABASE OVERVIEW
--  ─────────────────
--  Database Name : library_management_system
--  Character Set : utf8mb4
--  Collation     : utf8mb4_unicode_ci
--
-- ============================================================
--  ENTITY OVERVIEW
-- ============================================================
--
--  1. BOOK
--     Stores general information about book titles.
--
--  2. AUTHOR
--     Stores author details.
--
--  3. BOOK_AUTHOR
--     Bridge entity resolving the M:N relationship
--     between BOOK and AUTHOR.
--
--  4. BOOK_GENRES
--     Resolves the multivalued attribute BOOK.genres.
--
--  5. BRANCH
--     Represents library branch locations.
--
--  6. BOOK_COPY
--     Represents physical copies of books available
--     at specific branches.
--
--  7. STAFF
--     Library employees assigned to branches.
--
--  8. MEMBER
--     Registered library users/patrons.
--
--  9. MEMBERSHIP
--     Membership records for members (1:1 relationship).
--
-- 10. LOAN
--     Borrowing transaction created by a member.
--
-- 11. LOAN_ITEM (WEAK ENTITY)
--     Represents individual borrowed copies in a loan.
--
-- ============================================================
--  RELATIONSHIPS
-- ============================================================
--
--  R1. MEMBER holds MEMBERSHIP
--      (1:1 relationship)
--
--  R2. MEMBER makes LOAN
--      (1:N relationship)
--
--  R3. LOAN contains LOAN_ITEM
--      (1:N identifying relationship)
--
--  R4. LOAN_ITEM references BOOK_COPY
--      (N:1 relationship)
--
--  R5. BOOK_COPY held at BRANCH
--      (N:1 relationship)
--
--  R6. BRANCH employs STAFF
--      (1:N relationship)
--
--  R7. BOOK written by AUTHOR
--      (M:N relationship resolved by BOOK_AUTHOR)
--
-- ============================================================
--  SPECIAL MODELING FEATURES
-- ============================================================
--
--  • Multivalued Attribute
--      BOOK.genres
--      → resolved using BOOK_GENRES table
--
--  • Weak Entity
--      LOAN_ITEM depends on LOAN
--
--  • Composite Primary Keys
--      BOOK_COPY
--      LOAN_ITEM
--
--  • Derived Attribute
--      MEMBER.age
--      → computed dynamically from date_of_birth
--
-- ============================================================
--  DATABASE INITIALIZATION
-- ============================================================

DROP DATABASE IF EXISTS library_management_system;

CREATE DATABASE library_management_system
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE library_management_system;

-- ============================================================
--  ENTITY: BOOK
-- ============================================================

CREATE TABLE book (
    book_id         INT             NOT NULL AUTO_INCREMENT,
    title           VARCHAR(255)    NOT NULL,
    isbn            VARCHAR(20)     NOT NULL UNIQUE,
    publisher       VARCHAR(150)    NOT NULL,

    PRIMARY KEY (book_id)
);

-- ============================================================
--  ENTITY: AUTHOR
-- ============================================================

CREATE TABLE author (
    author_id       INT             NOT NULL AUTO_INCREMENT,
    author_name     VARCHAR(120)    NOT NULL,
    nationality     VARCHAR(80),
    biography       TEXT,

    PRIMARY KEY (author_id)
);

-- ============================================================
--  RELATIONSHIP ENTITY: BOOK_AUTHOR
--  Resolves BOOK ↔ AUTHOR (M:N)
-- ============================================================

CREATE TABLE book_author (
    book_id            INT          NOT NULL,
    author_id          INT          NOT NULL,
    author_role        VARCHAR(50)  NOT NULL,
    publication_order  INT          NOT NULL,

    PRIMARY KEY (book_id, author_id),

    CONSTRAINT chk_publication_order
        CHECK (publication_order > 0),

    CONSTRAINT fk_ba_book
        FOREIGN KEY (book_id)
        REFERENCES book (book_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_ba_author
        FOREIGN KEY (author_id)
        REFERENCES author (author_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ============================================================
--  MULTIVALUED ATTRIBUTE TABLE: BOOK_GENRES
-- ============================================================

CREATE TABLE book_genres (
    book_id             INT             NOT NULL,
    genre               VARCHAR(60)     NOT NULL,
    genre_description   VARCHAR(255),
    date_added          DATE            NOT NULL DEFAULT CURRENT_DATE,

    PRIMARY KEY (book_id, genre),

    CONSTRAINT fk_bookgenres_book
        FOREIGN KEY (book_id)
        REFERENCES book (book_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ============================================================
--  ENTITY: BRANCH
-- ============================================================

CREATE TABLE branch (
    branch_id       INT             NOT NULL AUTO_INCREMENT,
    branch_name     VARCHAR(100)    NOT NULL,
    address         VARCHAR(255)    NOT NULL,
    phone           VARCHAR(20)     NOT NULL,

    PRIMARY KEY (branch_id)
);

-- ============================================================
--  ENTITY: BOOK_COPY
-- ============================================================
--
--  Composite Primary Key:
--      (book_id, copy_number, branch_id)
--
--  Purpose:
--      Represents unique physical copies of books
--      across different branches.
--
-- ============================================================

CREATE TABLE book_copy (
    book_id         INT             NOT NULL,
    copy_number     INT             NOT NULL,
    branch_id       INT             NOT NULL,
    copy_condition  ENUM('New','Good','Fair','Poor')
                                    NOT NULL DEFAULT 'Good',

    PRIMARY KEY (book_id, copy_number, branch_id),

    CONSTRAINT chk_copy_number
        CHECK (copy_number > 0),

    CONSTRAINT fk_copy_book
        FOREIGN KEY (book_id)
        REFERENCES book (book_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_copy_branch
        FOREIGN KEY (branch_id)
        REFERENCES branch (branch_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- ============================================================
--  ENTITY: STAFF
-- ============================================================

CREATE TABLE staff (
    staff_id        INT             NOT NULL AUTO_INCREMENT,
    branch_id       INT             NOT NULL,
    staff_name      VARCHAR(120)    NOT NULL,
    role            VARCHAR(60)     NOT NULL,

    PRIMARY KEY (staff_id),

    CONSTRAINT fk_staff_branch
        FOREIGN KEY (branch_id)
        REFERENCES branch (branch_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- ============================================================
--  ENTITY: MEMBER
-- ============================================================

CREATE TABLE member (
    member_id       INT             NOT NULL AUTO_INCREMENT,
    full_name       VARCHAR(120)    NOT NULL,
    date_of_birth   DATE            NOT NULL,
    email           VARCHAR(150)    NOT NULL UNIQUE,

    PRIMARY KEY (member_id)
);

-- ============================================================
--  ENTITY: MEMBERSHIP
-- ============================================================
--
--  Relationship:
--      MEMBER holds MEMBERSHIP (1:1)
--
-- ============================================================

CREATE TABLE membership (
    membership_id   INT             NOT NULL AUTO_INCREMENT,
    member_id       INT             NOT NULL UNIQUE,
    start_date      DATE            NOT NULL,
    expiry_date     DATE            NOT NULL,

    PRIMARY KEY (membership_id),

    CONSTRAINT fk_membership_member
        FOREIGN KEY (member_id)
        REFERENCES member (member_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT chk_membership_dates
        CHECK (expiry_date > start_date)
);

-- ============================================================
--  ENTITY: LOAN
-- ============================================================

CREATE TABLE loan (
    loan_id         INT             NOT NULL AUTO_INCREMENT,
    member_id       INT             NOT NULL,
    loan_date       DATE            NOT NULL DEFAULT (CURRENT_DATE),
    due_date        DATE            NOT NULL,

    PRIMARY KEY (loan_id),

    CONSTRAINT fk_loan_member
        FOREIGN KEY (member_id)
        REFERENCES member (member_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT chk_loan_dates
        CHECK (due_date > loan_date)
);

-- ============================================================
--  WEAK ENTITY: LOAN_ITEM
-- ============================================================
--
--  Owner Entity:
--      LOAN
--
--  Composite Primary Key:
--      (loan_id, book_id, copy_number, branch_id)
--
--  References:
--      Specific BOOK_COPY record
--
-- ============================================================

CREATE TABLE loan_item (
    loan_id         INT             NOT NULL,
    book_id         INT             NOT NULL,
    copy_number     INT             NOT NULL,
    branch_id       INT             NOT NULL,
    return_date     DATE,
    status          ENUM('On loan','Returned','Overdue')
                                    NOT NULL DEFAULT 'On loan',

    PRIMARY KEY (loan_id, book_id, copy_number, branch_id),

    CONSTRAINT fk_loanitem_loan
        FOREIGN KEY (loan_id)
        REFERENCES loan (loan_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_loanitem_copy
        FOREIGN KEY (book_id, copy_number, branch_id)
        REFERENCES book_copy (book_id, copy_number, branch_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- ============================================================
--  SAMPLE DATA INSERTS
-- ============================================================

INSERT INTO book (title, isbn, publisher) VALUES
('Noli Me Tangere', '978-0141441146', 'Noli Me Tangere'),
('One Hundred Years of Solitude', '978-0060883287', 'One Hundred Years of Solitude'),
('Harry Potter and the Sorcerer''s Stone', '978-0439708180', 'Harry Potter and the Sorcerer''s Stone'),
('Cave and Shadows', '978-9710943159', 'Cave and Shadows'),
('1984', '978-0451524935', '1984'),
('The Rosales Saga: Po-on', '978-9710945689', 'The Rosales Saga: Po-on'),
('Americanah', '978-0307455925', 'Americanah'),
('Philippine History and Government', '978-0198328322', 'Philippine History and Government');

INSERT INTO author (author_name, nationality, biography) VALUES
('Jose Rizal', 'Filipino', 'National hero of the Philippines; novelist, poet, and polymath.'),
('Gabriel Garcia Marquez', 'Colombian', 'Nobel Prize-winning author known for magical realism.'),
('J.K. Rowling', 'British', 'Author of the Harry Potter fantasy series.'),
('Nick Joaquin', 'Filipino', 'Acclaimed Filipino author, playwright, and journalist; National Artist for Literature.'),
('George Orwell', 'British', 'Author of dystopian novels 1984 and Animal Farm.'),
('F. Sionil Jose', 'Filipino', 'Prolific Filipino novelist, founder of PEN Philippines.'),
('Chimamanda Ngozi Adichie', 'Nigerian', 'Award-winning author known for Americanah and Half of a Yellow Sun.');

-- ============================================================
--  SAMPLE QUERIES
-- ============================================================

-- Q1: Compute derived attribute AGE dynamically
-- SELECT member_id,
--        full_name,
--        TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) AS age
-- FROM member;

-- Q2: Active loans with member and book title
-- SELECT
--      m.full_name,
--      b.title,
--      l.due_date,
--      li.status
-- FROM loan_item li
-- JOIN loan l
--      ON li.loan_id = l.loan_id
-- JOIN member m
--      ON l.member_id = m.member_id
-- JOIN book_copy bc
--      ON li.book_id = bc.book_id
--     AND li.copy_number = bc.copy_number
--     AND li.branch_id = bc.branch_id
-- JOIN book b
--      ON bc.book_id = b.book_id
-- WHERE li.status = 'On loan';

-- Q3: Books with all genres
-- SELECT
--      b.title,
--      GROUP_CONCAT(bg.genre
--      ORDER BY bg.genre
--      SEPARATOR ', ') AS genres
-- FROM book b
-- LEFT JOIN book_genres bg
--      ON b.book_id = bg.book_id
-- GROUP BY b.book_id;

-- Q4: Copies available at a branch
-- SELECT
--      br.branch_name,
--      b.title,
--      bc.copy_condition
-- FROM book_copy bc
-- JOIN book b
--      ON bc.book_id = b.book_id
-- JOIN branch br
--      ON bc.branch_id = br.branch_id
-- WHERE br.branch_id = 1;

-- Q5: Members with expired memberships
-- SELECT
--      m.full_name,
--      ms.expiry_date
-- FROM member m
-- JOIN membership ms
--      ON m.member_id = ms.member_id
-- WHERE ms.expiry_date < CURDATE();

-- ============================================================
--  END OF SCRIPT
-- ============================================================
