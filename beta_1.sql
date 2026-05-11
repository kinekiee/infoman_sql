DROP DATABASE IF EXISTS library_management_system;

CREATE DATABASE library_management_system
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
 
USE library_management_system;

CREATE TABLE book (
    book_id         INT             NOT NULL AUTO_INCREMENT,
    title           VARCHAR(255)    NOT NULL,
    isbn            VARCHAR(20)     NOT NULL UNIQUE,
    publisher       VARCHAR(150)    NOT NULL,
    CONSTRAINT pk_book PRIMARY KEY (book_id)
);

CREATE TABLE author (
    author_id       INT             NOT NULL AUTO_INCREMENT,
    author_name     VARCHAR(120)    NOT NULL,
    nationality     VARCHAR(80),
    biography             TEXT,
    CONSTRAINT pk_author PRIMARY KEY (author_id)
);

CREATE TABLE book_author (
    book_id         INT             NOT NULL,
    author_id       INT             NOT NULL,
    CONSTRAINT pk_book_author       PRIMARY KEY (book_id, author_id),
    CONSTRAINT fk_ba_book           FOREIGN KEY (book_id)
        REFERENCES book (book_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_ba_author         FOREIGN KEY (author_id)
        REFERENCES author (author_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE book_genres (
    book_id         INT             NOT NULL,
    genre           VARCHAR(60)     NOT NULL,
    CONSTRAINT pk_book_genres       PRIMARY KEY (book_id, genre),
    CONSTRAINT fk_bookgenres_book   FOREIGN KEY (book_id)
        REFERENCES book (book_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE book_copy (
    copy_id         INT             NOT NULL AUTO_INCREMENT,
    book_id         INT             NOT NULL,
    branch_id       INT             NOT NULL,
    condition       ENUM('New','Good','Fair','Poor') NOT NULL DEFAULT 'Good',
    CONSTRAINT pk_book_copy         PRIMARY KEY (copy_id),
    CONSTRAINT fk_copy_book         FOREIGN KEY (book_id)
        REFERENCES book (book_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_copy_branch       FOREIGN KEY (branch_id)
        REFERENCES branch (branch_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE branch (
    branch_id       INT             NOT NULL AUTO_INCREMENT,
    branch_name     VARCHAR(100)    NOT NULL,
    address         VARCHAR(255)    NOT NULL,
    phone           VARCHAR(20)     NOT NULL,
    CONSTRAINT pk_branch PRIMARY KEY (branch_id)
);

CREATE TABLE staff (
    staff_id        INT             NOT NULL AUTO_INCREMENT,
    branch_id       INT             NOT NULL,
    staff_name      VARCHAR(120)    NOT NULL,
    role            VARCHAR(60)     NOT NULL,
    CONSTRAINT pk_staff         PRIMARY KEY (staff_id),
    CONSTRAINT fk_staff_branch  FOREIGN KEY (branch_id)
        REFERENCES branch (branch_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE member (
    member_id       INT             NOT NULL AUTO_INCREMENT,
    full_name       VARCHAR(120)    NOT NULL,
    date_of_birth   DATE            NOT NULL,
    email           VARCHAR(150)    NOT NULL UNIQUE,
    -- age is a DERIVED ATTRIBUTE: use the expression below when querying
    --   TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) AS age
    CONSTRAINT pk_member PRIMARY KEY (member_id)
);

CREATE TABLE membership (
    membership_id   INT             NOT NULL AUTO_INCREMENT,
    member_id       INT             NOT NULL UNIQUE,   -- UNIQUE enforces 1:1 with member
    start_date      DATE            NOT NULL,
    expiry_date     DATE            NOT NULL,
    CONSTRAINT pk_membership        PRIMARY KEY (membership_id),
    CONSTRAINT fk_membership_member FOREIGN KEY (member_id)
        REFERENCES member (member_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_membership_dates CHECK (expiry_date > start_date)
);

CREATE TABLE loan (
    loan_id         INT             NOT NULL AUTO_INCREMENT,
    member_id       INT             NOT NULL,
    loan_date       DATE            NOT NULL DEFAULT (CURRENT_DATE),
    due_date        DATE            NOT NULL,
    CONSTRAINT pk_loan          PRIMARY KEY (loan_id),
    CONSTRAINT fk_loan_member   FOREIGN KEY (member_id)
        REFERENCES member (member_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_loan_dates   CHECK (due_date > loan_date)
);

CREATE TABLE loan_item (
    loan_id         INT             NOT NULL,
    book_copy_id    INT             NOT NULL,
    return_date     DATE,                              -- NULL until physically returned
    status          ENUM('On Loan','Returned','Overdue') NOT NULL DEFAULT 'On Loan',
    CONSTRAINT pk_loan_item         PRIMARY KEY (loan_id, book_copy_id),  -- composite PK
    CONSTRAINT fk_loanitem_loan     FOREIGN KEY (loan_id)
        REFERENCES loan (loan_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_loanitem_copy     FOREIGN KEY (book_copy_id)
        REFERENCES book_copy (copy_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

INSERT INTO book (isbn, title, publisher) VALUES
('978-0141441146', 'Noli Me Tangere',                        'Noli Me Tangere'),
('978-0060883287', 'One Hundred Years of Solitude',          'One Hundred Years of Solitude'),
('978-0439708180', 'Harry Potter and the Sorcerer''s Stone', 'Harry Potter and the Sorcerer''s Stone'),
('978-9710943159', 'Cave and Shadows',                       'Cave and Shadows'),
('978-0451524935', '1984',                                   '1984'),
('978-9710945689', 'The Rosales Saga: Po-on',                'The Rosales Saga: Po-on'),
('978-0307455925', 'Americanah',                             'Americanah'),
('978-0198328322', 'Philippine History and Government',      'Philippine History and Government');

INSERT INTO author (author_name, nationality, biography) VALUES
('Jose Rizal',                 'Filipino',    'National hero of the Philippines; novelist, poet, and polymath.'),
('Gabriel Garcia Marquez',     'Colombian',   'Nobel Prize-winning author known for magical realism.'),
('J.K. Rowling',               'British',     'Author of the Harry Potter fantasy series.'),
('Nick Joaquin',               'Filipino',    'Acclaimed Filipino author, playwright, and journalist; National Artist for Literature.'),
('George Orwell',              'British',     'Author of dystopian novels 1984 and Animal Farm.'),
('F. Sionil Jose',             'Filipino',    'Prolific Filipino novelist, founder of PEN Philippines.'),
('Chimamanda Ngozi Adichie',   'Nigerian',    'Award-winning author known for Americanah and Half of a Yellow Sun.');

INSERT INTO book_author (book_id, author_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 6);

INSERT INTO book_genres (book_id, genre) VALUES
(1, 'Historical Fiction'), (1, 'Political Fiction'),
(2, 'Magical Realism'),    (2, 'Literary Fiction'),
(3, 'Fantasy'),            (3, 'Young Adult'),
(4, 'Literary Fiction'),   (4, 'Philippine Literature'),
(5, 'Dystopian'),          (5, 'Political Fiction'),
(6, 'Historical Fiction'), (6, 'Philippine Literature'),
(7, 'Contemporary Fiction'),(7, 'Social Commentary'),
(8, 'Non-Fiction'),        (8, 'Academic');

INSERT INTO book_copy (book_id, branch_id, condition) VALUES
(1, 1, 'Good'),
(1, 1, 'Fair'),
(1, 1, 'New'),
(2, 1, 'Good'),
(2, 1, 'Good'),
(3, 2, 'New'),
(3, 2, 'Good'), 
(4, 2, 'Fair'),
(5, 2, 'Good'),
(5, 2, 'Good'),
(6, 3, 'New'),
(7, 3, 'New'),
(8, 3, 'New'),
(8, 3, 'Good');

INSERT INTO branch (branch_name, address, phone) VALUES
('Downtown Library', '123 Main St, Cityville', '555-1234'),
('Northside Branch', '456 Oak Ave, Townsburg', '555-5678'),
('East End Library', '789 Pine Rd, Villagetown', '555-9012');

INSERT INTO staff (branch_id, staff_name, role) VALUES
(1, 'Charles Penoliar', 'Librarian'),
(1, 'Gabriel Soliven', 'Assistant Librarian'),
(1, 'Nicole Ocsillos', 'Assistant Librarian'),
(2, 'Joceme Meneses', 'Librarian'),
(2, 'Kenneth Ocampo', 'Assistant Librarian'),
(2, 'Marisol Soriano', 'Assistant Librarian'),
(3, 'Andrei Patino', 'Librarian'),
(3, 'Moises Ramirez', 'Assistant Librarian'),
(3, 'Prince Simodio', 'Assistant Librarian');

INSERT INTO member (full_name, date_of_birth, email) VALUES
('Maria Clara', '1990-05-15', 'maria.clara@example.com'),
('Juan Crisostomo Ibarra', '1985-08-20', 'juan.ibarra@example.com'),
('Elias', '1992-11-30', 'elias@example.com'),
('Sisa', '1988-02-10', 'sisa@example.com'),
('Basilio', '1995-07-25', 'basilio@example.com'),
('Padre Damaso', '1970-01-05', 'padre.damaso@example.com'),
('Padre Salvi', '1975-03-12', 'padre.salvi@example.com');

INSERT INTO membership (member_id, start_date, expiry_date) VALUES
(1, '2024-01-01', '2024-12-31'),
(2, '2024-02-15', '2025-02-14'),
(3, '2024-03-10', '2025-03-09'),
(4, '2024-04-20', '2025-04-19'),
(5, '2024-05-05', '2025-05-04'),
(6, '2024-06-01', '2025-05-31'),
(7, '2024-07-15', '2025-07-14');

INSERT INTO loan (member_id, loan_date, due_date) VALUES
(1, '2024-08-01', '2024-08-15'),
(2, '2024-08-05', '2024-08-19'),
(3, '2024-08-10', '2024-08-24'),
(4, '2024-08-12', '2024-08-26'),
(5, '2024-08-15', '2024-08-29'),
(6, '2024-08-18', '2024-09-01'),
(7, '2024-08-20', '2024-09-03');

INSERT INTO loan_item (loan_id, book_copy_id) VALUES
(1, 1), (1, 2),
(2, 3), (2, 4),
(3, 5), (3, 6),
(4, 7), (4, 8),
(5, 9), (5, 10),
(6, 11), (6, 12),
(7, 12), (7, 13);
