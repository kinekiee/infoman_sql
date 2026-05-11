DROP DATABASE IF EXISTS library_management_system;

CREATE DATABASE library_management_system
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
 
USE library_management_system;
 
CREATE TABLE publisher (
    publisher_id    INT             NOT NULL AUTO_INCREMENT,
    name            VARCHAR(150)    NOT NULL,
    address         VARCHAR(255)    NOT NULL,
    phone           VARCHAR(20)     NOT NULL,
    email           VARCHAR(100)    NOT NULL UNIQUE,
    website         VARCHAR(200),
    country         VARCHAR(80)     NOT NULL DEFAULT 'Philippines',
    PRIMARY KEY (publisher_id)
);

 CREATE TABLE author (
    author_id       INT             NOT NULL AUTO_INCREMENT,
    first_name      VARCHAR(80)     NOT NULL,
    last_name       VARCHAR(80)     NOT NULL,
    birth_date      DATE,
    nationality     VARCHAR(80),
    biography       TEXT,
    email           VARCHAR(100)    UNIQUE,
    PRIMARY KEY (author_id)
);

CREATE TABLE book (
    book_id         INT             NOT NULL AUTO_INCREMENT,
    isbn            VARCHAR(20)     NOT NULL UNIQUE,
    title           VARCHAR(255)    NOT NULL,
    publisher_id    INT             NOT NULL,
    publish_year    YEAR            NOT NULL,
    edition         VARCHAR(30),
    language        VARCHAR(50)     NOT NULL DEFAULT 'English',
    total_pages     INT             NOT NULL,
    description     TEXT,

    PRIMARY KEY (book_id),
    CONSTRAINT fk_book_publisher
        FOREIGN KEY (publisher_id) REFERENCES publisher(publisher_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE book_author (
    book_id         INT             NOT NULL,
    author_id       INT             NOT NULL,
    role            VARCHAR(60)     NOT NULL DEFAULT 'Author',  -- Author, Editor, Translator
    PRIMARY KEY (book_id, author_id),
    CONSTRAINT fk_ba_book
        FOREIGN KEY (book_id) REFERENCES book(book_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_ba_author
        FOREIGN KEY (author_id) REFERENCES author(author_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE book_copy (
    copy_id         INT             NOT NULL AUTO_INCREMENT,
    book_id         INT             NOT NULL,
    copy_number     INT             NOT NULL,       
    condition       ENUM('New','Good','Fair','Poor','Damaged')  NOT NULL DEFAULT 'Good',
    is_available    BOOLEAN         NOT NULL DEFAULT TRUE,
    date_acquired   DATE            NOT NULL,
    PRIMARY KEY (copy_id),
    UNIQUE KEY uq_book_copy (book_id, copy_number),
    CONSTRAINT fk_copy_book
        FOREIGN KEY (book_id) REFERENCES book(book_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE member (
    member_id       INT             NOT NULL AUTO_INCREMENT,
    first_name      VARCHAR(80)     NOT NULL,
    last_name       VARCHAR(80)     NOT NULL,
    date_of_birth   DATE            NOT NULL,
    -- age is a DERIVED attribute: TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE())
    email           VARCHAR(100)    NOT NULL UNIQUE,
    phone           VARCHAR(20)     NOT NULL,
    address         VARCHAR(255)    NOT NULL,
    membership_type ENUM('Student','Regular','Senior','Premium')  NOT NULL DEFAULT 'Regular',
    registration_date DATE          NOT NULL DEFAULT (CURRENT_DATE),
    expiry_date     DATE            NOT NULL,
    is_active       BOOLEAN         NOT NULL DEFAULT TRUE,
    PRIMARY KEY (member_id)
);

CREATE TABLE staff (
    staff_id        INT             NOT NULL AUTO_INCREMENT,
    first_name      VARCHAR(80)     NOT NULL,
    last_name       VARCHAR(80)     NOT NULL,
    role            ENUM('Librarian','Assistant','Manager','IT','Admin')  NOT NULL,
    email           VARCHAR(100)    NOT NULL UNIQUE,
    phone           VARCHAR(20)     NOT NULL,
    hire_date       DATE            NOT NULL,
    salary          DECIMAL(10,2)   NOT NULL,
    is_active       BOOLEAN         NOT NULL DEFAULT TRUE,
    PRIMARY KEY (staff_id)
);

CREATE TABLE loan (
    loan_id         INT             NOT NULL AUTO_INCREMENT,
    member_id       INT             NOT NULL,
    copy_id         INT             NOT NULL,
    staff_id        INT             NOT NULL,       -- staff who processed the loan
    loan_date       DATE            NOT NULL DEFAULT (CURRENT_DATE),
    due_date        DATE            NOT NULL,
    return_date     DATE,                           -- NULL if not yet returned
    -- days_overdue is DERIVED: IF(return_date IS NULL, DATEDIFF(CURDATE(), due_date), DATEDIFF(return_date, due_date))
    status          ENUM('Active','Returned','Overdue','Lost')  NOT NULL DEFAULT 'Active',
    PRIMARY KEY (loan_id),
    CONSTRAINT fk_loan_member
        FOREIGN KEY (member_id) REFERENCES member(member_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_loan_copy
        FOREIGN KEY (copy_id) REFERENCES book_copy(copy_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_loan_staff
        FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE reservation (
    reservation_id  INT             NOT NULL AUTO_INCREMENT,
    member_id       INT             NOT NULL,
    book_id         INT             NOT NULL,
    reservation_date DATE           NOT NULL DEFAULT (CURRENT_DATE),
    expiry_date     DATE            NOT NULL,
    status          ENUM('Pending','Ready','Fulfilled','Cancelled','Expired')  NOT NULL DEFAULT 'Pending',
    notes           TEXT,
    PRIMARY KEY (reservation_id),
    CONSTRAINT fk_res_member
        FOREIGN KEY (member_id) REFERENCES member(member_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_res_book
        FOREIGN KEY (book_id) REFERENCES book(book_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE fine (
    fine_id         INT             NOT NULL AUTO_INCREMENT,
    loan_id         INT             NOT NULL,
    fine_type       ENUM('Overdue','Damage','Loss')  NOT NULL,
    amount          DECIMAL(8,2)    NOT NULL,
    issued_date     DATE            NOT NULL DEFAULT (CURRENT_DATE),
    paid_date       DATE,                           -- NULL if unpaid
    is_paid         BOOLEAN         NOT NULL DEFAULT FALSE,
    remarks         TEXT,
    PRIMARY KEY (fine_id),
    CONSTRAINT fk_fine_loan
        FOREIGN KEY (loan_id) REFERENCES loan(loan_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

INSERT INTO publisher (name, address, phone, email, website, country) VALUES
('Penguin Random House',   '1745 Broadway, New York, NY',   '+1-212-782-9000', 'contact@penguinrandomhouse.com', 'https://www.penguinrandomhouse.com', 'USA'),
('HarperCollins',          '195 Broadway, New York, NY',    '+1-212-207-7000', 'info@harpercollins.com',         'https://www.harpercollins.com',      'USA'),
('Oxford University Press','Great Clarendon St, Oxford',    '+44-1865-353535', 'enquiry@oup.com',                'https://www.oup.com',                'UK'),
('Rex Book Store',         '856 Nicanor Reyes Sr. St, Manila','+63-2-8736-0564','info@rexbookstore.com',         'https://www.rexbookstore.com',       'Philippines'),
('Anvil Publishing',       '7th Floor Quad Alpha Centrum, Mandaluyong','+63-2-8477-4752','info@anvilpublishing.com','https://www.anvilpublishing.com', 'Philippines'),
('Simon & Schuster',       '1230 Avenue of the Americas, NY','+1-212-698-7000','press@simonandschuster.com',     'https://www.simonandschuster.com',   'USA');
 
INSERT INTO author (first_name, last_name, birth_date, nationality, biography, email) VALUES
('Jose',        'Rizal',        '1861-06-19', 'Filipino',    'National hero of the Philippines; novelist, poet, and polymath.',                             NULL),
('Gabriel',     'Garcia Marquez','1927-03-06','Colombian',   'Nobel Prize-winning author known for magical realism.',                                       NULL),
('J.K.',        'Rowling',      '1965-07-31', 'British',     'Author of the Harry Potter fantasy series.',                                                  NULL),
('Nick',        'Joaquin',      '1917-05-04', 'Filipino',    'Acclaimed Filipino author, playwright, and journalist; National Artist for Literature.',       NULL),
('George',      'Orwell',       '1903-06-25', 'British',     'Author of dystopian novels 1984 and Animal Farm.',                                            NULL),
('F. Sionil',   'Jose',         '1924-12-03', 'Filipino',    'Prolific Filipino novelist, founder of PEN Philippines.',                                     'fsj@example.com'),
('Chimamanda',  'Adichie',      '1977-09-15', 'Nigerian',    'Award-winning author known for Americanah and Half of a Yellow Sun.',                         'cadichie@example.com');

INSERT INTO book (isbn, title, publisher_id, publish_year, edition, language, total_pages, description) VALUES
('978-0141441146', 'Noli Me Tangere',                          1, 1887, 'Penguin Classics', 'Filipino',   480, 'Rizal''s seminal novel exposing Spanish colonial abuses in the Philippines.'),
('978-0060883287', 'One Hundred Years of Solitude',            2, 1967, '1st English Ed',   'English',    417, 'Multigenerational saga of the Buendía family in the fictional town of Macondo.'),
('978-0439708180', 'Harry Potter and the Sorcerer''s Stone',   1, 1997, '1st US Edition',   'English',    309, 'A young boy discovers he is a wizard and begins his education at Hogwarts.'),
('978-9710943159', 'Cave and Shadows',                         4, 1983, '2nd Edition',      'English',    256, 'Nick Joaquin''s acclaimed novel exploring Filipino identity and culture.'),
('978-0451524935', '1984',                                     2, 1949, 'Signet Classic',   'English',    328, 'A totalitarian dystopia where Big Brother watches every move.'),
('978-9710945689', 'The Rosales Saga: Po-on',                  4, 1984, '3rd Edition',      'Filipino',   320, 'First book of F. Sionil Jose''s Rosales Saga; a family''s history against colonial backdrops.'),
('978-0307455925', 'Americanah',                               1, 2013, '1st Edition',      'English',    477, 'Story of a young Nigerian woman navigating race and identity in America.'),
('978-0198328322', 'Philippine History and Government',        3, 2018, '5th Edition',      'Filipino',   512, 'Comprehensive textbook on Philippine history, governance, and society.');


INSERT INTO book_author (book_id, author_id, role) VALUES
(1, 1, 'Author'),
(2, 2, 'Author'),
(3, 3, 'Author'),
(4, 4, 'Author'),
(5, 5, 'Author'),
(6, 6, 'Author'),
(7, 7, 'Author'),
(8, 6, 'Editor');   -- F. Sionil Jose also edited the PH history textbook

INSERT INTO book_copy (book_id, copy_number, condition, is_available, date_acquired) VALUES
(1, 1, 'Good',    TRUE,  '2020-01-15'),
(1, 2, 'Fair',    TRUE,  '2020-01-15'),
(1, 1, 'New',     TRUE,  '2022-06-01'),
(2, 1, 'Good',    FALSE, '2019-03-10'),  -- currently loaned
(2, 1, 'Good',    TRUE,  '2021-09-20'),
(3, 1, 'New',     TRUE,  '2023-01-05'),
(3, 1, 'Good',    TRUE,  '2022-11-11'),
(4, 1, 'Fair',    TRUE,  '2018-07-25'),
(5, 1, 'Good',    FALSE, '2019-08-15'),  -- currently loaned
(5, 1, 'Good',    TRUE,  '2021-04-30'),
(6, 1, 'New',     TRUE,  '2023-03-18'),
(7, 1, 'New',     TRUE,  '2023-05-22'),
(8, 1, 'New',     TRUE,  '2023-07-01'),
(8, 1, 'Good',    TRUE,  '2022-09-14');

INSERT INTO member (first_name, last_name, date_of_birth, email, phone, address, membership_type, registration_date, expiry_date, is_active) VALUES
('Maria',    'Santos',    '1995-03-14', 'maria.santos@email.com',  '+63-917-111-2233', '12 Rizal St, Manila',           'Regular', '2022-01-10', '2025-01-10', TRUE),
('Juan',     'Dela Cruz', '1988-07-22', 'jdc@email.com',           '+63-918-222-3344', '56 Bonifacio Ave, QC',          'Premium', '2021-06-15', '2024-06-15', TRUE),
('Ana',      'Reyes',     '2002-11-05', 'ana.reyes@studl.com',     '+63-920-444-5566', '23 Quezon Blvd, Cebu',          'Senior',  '2020-03-20', '2025-03-20', TRUE),
('Luisa',    'Fernandez', '1999-12-30', 'luisa.f@emailent.edu',   '+63-919-333-4455', '89 Mabini Rd, Makati',          'Student', '2023-08-01', '2024-08-01', TRUE),
('Pedro',    'Lim',       '1950-04-18', 'pedro.lim@emai.com',       '+63-921-555-6677', '77 Davao St, Davao City',       'Regular', '2023-02-14', '2026-02-14', TRUE),
('Carlos',   'Mercado',   '1975-09-08', 'carlos.m@email.com',      '+63-922-666-7788', '101 Legazpi Village, Makati',   'Premium', '2022-09-01', '2025-09-01', TRUE),
('Elena',    'Cruz',      '2001-06-27', 'elena.c@student.edu',     '+63-923-777-8899', '34 UP Campus, QC',              'Student', '2023-01-15', '2024-01-15', FALSE);  -- expired
 
INSERT INTO staff (first_name, last_name, role, email, phone, hire_date, salary, is_active) VALUES
('Ricardo',  'Torres',    'Manager',   'r.torres@citylib.ph',   '+63-917-100-1001', '2015-03-01', 55000.00, TRUE),
('Maricela', 'Bautista',  'Librarian', 'm.bautista@citylib.ph', '+63-917-100-1002', '2017-06-15', 38000.00, TRUE),
('Felix',    'Navarro',   'Assistant', 'f.navarro@citylib.ph',  '+63-917-100-1003', '2020-09-10', 28000.00, TRUE),
('Grace',    'Villanueva','Librarian', 'g.villanueva@citylib.ph','+63-917-100-1004', '2018-01-20', 38000.00, TRUE),
('Ramon',    'Aquino',    'Manager',   'r.aquino@citylib.ph',   '+63-917-100-1005', '2016-05-05', 52000.00, TRUE),
('Dina',     'Pascual',   'IT',        'd.pascual@citylib.ph',  '+63-917-100-1006', '2019-11-01', 42000.00, TRUE),
('Bert',     'Ocampo',    'Assistant', 'b.ocampo@citylib.ph',   '+63-917-100-1007', '2022-03-14', 27000.00, TRUE);

INSERT INTO loan (member_id, copy_id, staff_id, loan_date, due_date, return_date, status) VALUES
(1,  4,  2, '2024-11-01', '2024-11-15', '2024-11-14', 'Returned'),   -- on time
(2,  9,  2, '2024-11-10', '2024-11-24', NULL,          'Overdue'),    -- still out, overdue
(3,  6,  3, '2024-10-20', '2024-11-03', '2024-11-03', 'Returned'),   -- on time
(4,  8,  5, '2024-11-05', '2024-11-19', '2024-11-25', 'Returned'),   -- returned late
(5, 12,  4, '2024-11-15', '2024-11-29', NULL,          'Active'),     -- current loan
(6,  5,  4, '2024-10-01', '2024-10-15', '2024-10-14', 'Returned'),   -- on time
(1,  3,  2, '2024-11-20', '2024-12-04', NULL,          'Active');     -- current loan

INSERT INTO reservation (member_id, book_id, reservation_date, expiry_date, status, notes) VALUES
(2, 2, '2024-11-10', '2024-11-17', 'Pending',   'Waiting for copy'),
(3, 5, '2024-11-12', '2024-11-19', 'Cancelled', 'Member cancelled request'),
(4, 3, '2024-11-01', '2024-11-08', 'Fulfilled', 'Copy was ready and collected'),
(5, 1, '2024-11-18', '2024-11-25', 'Ready',     'Copy waiting for pickup'),
(6, 7, '2024-11-20', '2024-11-27', 'Pending',   NULL),
(1, 8, '2024-11-22', '2024-11-29', 'Pending',   'Second copy requested');

INSERT INTO fine (loan_id, fine_type, amount, issued_date, paid_date, is_paid, remarks) VALUES
(4, 'Overdue', 36.00,  '2024-11-25', '2024-11-26', TRUE,  'Returned 6 days late; PHP 6.00/day'),
(2, 'Overdue', 150.00, '2024-11-25', NULL,          FALSE, 'Still outstanding; accumulated daily'),
(3, 'Damage',  250.00, '2024-11-03', '2024-11-05', TRUE,  'Torn pages on return; repaired'),
(6, 'Overdue',  0.00,  '2024-10-14', '2024-10-14', TRUE,  'Waived — Senior member first offense'),
(1, 'Overdue',  0.00,  '2024-11-14', '2024-11-14', TRUE,  'Returned on time; no fine applied');
