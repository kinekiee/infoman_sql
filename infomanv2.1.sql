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
    PRIMARY KEY (book_id)   --removed constraint pk_book_id
);

CREATE TABLE author (
    author_id       INT             NOT NULL AUTO_INCREMENT,
    author_name     VARCHAR(120)    NOT NULL,
    nationality     VARCHAR(80),
    biography             TEXT,
    PRIMARY KEY (author_id)  --removed constraint pk_author_id
);

CREATE TABLE book_author (
    book_id         INT             NOT NULL,
    author_id       INT             NOT NULL,
    author_role     VARCHAR(50)     NOT NULL,  -- added author_role and publication_order
    publication_order INT            NOT NULL,

    PRIMARY KEY (book_id, author_id),   --removed constraint pk_book_author

    CONSTRAINT chk_publication_order CHECK (
        publication_order > 0
    ),
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
    book_id           INT             NOT NULL,
    genre             VARCHAR(60)     NOT NULL,  --added genre_descfiption and date_added
    genre_description VARCHAR(255)    NULL,
    date_added        DATE            NOT NULL DEFAULT CURRENT_DATE,

    PRIMARY KEY (book_id, genre),   --removed constraint pk_book_genre

    CONSTRAINT fk_bookgenres_book   FOREIGN KEY (book_id)
        REFERENCES book (book_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE branch (
    branch_id       INT             NOT NULL AUTO_INCREMENT,
    branch_name     VARCHAR(100)    NOT NULL,
    address         VARCHAR(255)    NOT NULL,
    phone           VARCHAR(20)     NOT NULL,
    PRIMARY KEY (branch_id)   --removed constraint pk_branch
);

CREATE TABLE book_copy (
    copy_id         INT             NOT NULL AUTO_INCREMENT,
    book_id         INT             NOT NULL,
    branch_id       INT             NOT NULL,
    copy_condition  ENUM('New','Good','Fair','Poor') NOT NULL DEFAULT 'Good',

    PRIMARY KEY (copy_id),                   --removed constraint pk_book_copy

    CONSTRAINT fk_copy_book         FOREIGN KEY (book_id)
        REFERENCES book (book_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
        
    CONSTRAINT fk_copy_branch       FOREIGN KEY (branch_id)
        REFERENCES branch (branch_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE staff (
    staff_id        INT             NOT NULL AUTO_INCREMENT,
    branch_id       INT             NOT NULL,
    staff_name      VARCHAR(120)    NOT NULL,
    role            VARCHAR(60)     NOT NULL,
    PRIMARY KEY (staff_id),                     --removed constraint pk_staff
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
    PRIMARY KEY (member_id)                 --removed constraint pk_member
);

CREATE TABLE membership (
    membership_id   INT             NOT NULL AUTO_INCREMENT,
    member_id       INT             NOT NULL UNIQUE,   -- UNIQUE enforces 1:1 with member
    start_date      DATE            NOT NULL,
    expiry_date     DATE            NOT NULL,
    PRIMARY KEY (membership_id),                 --removed constraint pk_membership
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
    PRIMARY KEY (loan_id),                    --removed constraint pk_loan
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
    status          ENUM('On loan','Returned','Overdue') NOT NULL DEFAULT 'On loan',
    PRIMARY KEY (loan_id, book_copy_id),  -- composite PK         --removed constraint pk_loan_item
    CONSTRAINT fk_loanitem_loan     FOREIGN KEY (loan_id)
        REFERENCES loan (loan_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_loanitem_copy     FOREIGN KEY (book_copy_id)
        REFERENCES book_copy (copy_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

INSERT INTO book (title, isbn, publisher) VALUES
( 'Noli Me Tangere',                           '978-0141441146',                        'Noli Me Tangere'),
( 'One Hundred Years of Solitude',             '978-0060883287',          'One Hundred Years of Solitude'),
( 'Harry Potter and the Sorcerer''s Stone',    '978-0439708180', 'Harry Potter and the Sorcerer''s Stone'),
( 'Cave and Shadows',                          '978-9710943159',                       'Cave and Shadows'),
( '1984',                                      '978-0451524935',                                   '1984'),
( 'The Rosales Saga: Po-on',                   '978-9710945689',                'The Rosales Saga: Po-on'),
( 'Americanah',                                '978-0307455925',                             'Americanah'),
( 'Philippine History and Government',         '978-0198328322',      'Philippine History and Government');


INSERT INTO author (author_name, nationality, biography) VALUES
('Jose Rizal',                 'Filipino',    'National hero of the Philippines; novelist, poet, and polymath.'),
('Gabriel Garcia Marquez',     'Colombian',   'Nobel Prize-winning author known for magical realism.'),
('J.K. Rowling',               'British',     'Author of the Harry Potter fantasy series.'),
('Nick Joaquin',               'Filipino',    'Acclaimed Filipino author, playwright, and journalist; National Artist for Literature.'),
('George Orwell',              'British',     'Author of dystopian novels 1984 and Animal Farm.'),
('F. Sionil Jose',             'Filipino',    'Prolific Filipino novelist, founder of PEN Philippines.'),
('Chimamanda Ngozi Adichie',   'Nigerian',    'Award-winning author known for Americanah and Half of a Yellow Sun.');

INSERT INTO book_author (book_id, author_id, author_role, publication_order) VALUES
(1, 1, 'Primary Author', 1),
(2, 2, 'Primary Author', 1),
(3, 3, 'Primary Author', 1),         --added author role (primary or co author)  and publication order
(4, 4, 'Primary Author', 1),
(5, 5, 'Primary Author', 1),
(6, 6, 'Primary Author', 1),
(7, 7, 'Primary Author', 1),
(8, 6, 'Primary Author', 1),
(8, 7, 'Co-Author', 2);
                                                                            --added genre descriptions and date published(date-added)
INSERT INTO book_genres (book_id, genre, genre_description, date_added) VALUES
(1, 'Historical Fiction', 'Stories based on historical events, often with fictionalized characters and narratives.', '1887-03-21'), 
(1, 'Political Fiction', 'A genre that explores political systems, ideologies, and power dynamics.', '1887-03-21'),

(2, 'Magical Realism', 'A genre that blends magical elements with the real world, often to explore complex social and cultural themes.', '1967-05-30'),    
(2, 'Epic Fiction', 'A long story about heroic characters, great adventures, and important events, often involving battles or journeys.', '1967-05-30'),

(3, 'Fantasy', 'Fiction that involves magical or supernatural elements.', '1997-06-26'),            
(3, 'Young Adult', 'A genre targeted at readers between the ages of 12 and 18.', '1997-06-26'),

(4, 'Literary Fiction', 'Fiction that emphasizes literary merit and artistic value.', '1983-01-01'),   
(4, 'Philippine Literature', 'A literature that reflects the culture and experiences of the Philippines.', '1983-01-01'),

(5, 'Dystopian', 'Fiction that depicts a future society characterized by oppression and suffering.', '1949-06-08'),          
(5, 'Political Fiction', 'A genre that explores political systems, ideologies, and power dynamics.', '1949-06-08'),

(6, 'Historical Fiction', 'A genre that tells stories based on historical events, often with fictionalized characters and narratives.', '1984-01-01'), 
(6, 'Philippine Literature', 'A literature that reflects the culture and experiences of the Philippines.', '1984-01-01'),

(7, 'Contemporary Fiction', 'A genre that portrays modern life and contemporary issues.', '2013-05-14'),
(7, 'Social Commentary', 'A genre that critiques or comments on social issues and conventions.', '2013-05-14'),

(8, 'Non-Fiction', 'Works based on factual information, real events, and real people.', '2015-08-11'),        
(8, 'Academic', 'Works intended for educational, research, or scholarly purposes.', '2021-05-10');

INSERT INTO branch (branch_name, address, phone) VALUES
('Downtown Library', '123 Main St, Cityville', '555-1234'),
('Northside Branch', '456 Oak Ave, Townsburg', '555-5678'),
('East End Library', '789 Pine Rd, Villagetown', '555-9012');

INSERT INTO book_copy (book_id, branch_id, copy_condition) VALUES
(1, 1, 'New'),
(1, 2, 'Good'),
(1, 3, 'Fair'),
(2, 1, 'New'),
(2, 2, 'Good'),
(2, 3, 'Fair'),
(3, 1, 'New'),
(3, 3, 'Good'),
(4, 1, 'Fair'),
(4, 2, 'New'),
(4, 3, 'Good'),
(4, 1, 'Fair'),
(5, 1, 'New'),
(5, 2, 'Good'),
(5, 2, 'Fair'),
(6, 1, 'New'),
(6, 2, 'Good'),
(6, 3, 'Fair'),
(6, 1, 'New'),
(7, 1, 'Good'),
(7, 2, 'Fair'),
(7, 3, 'New'),
(8, 2, 'Good'),
(8, 3, 'Fair'),
(8, 3, 'New');

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
(2, '2024-02-15', '2025-02-14'),   --Swapped Expiry date and start date
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

INSERT INTO loan_item (loan_id, book_copy_id, return_date, status) VALUES
(1, 1, '2024-08-01', 'On loan'),
(2, 2, '2024-08-13', 'Returned'),
(3, 3, '2024-08-10', 'On loan'),
(4, 4, '2024-08-26', 'Overdue'),
(5, 5, '2024-08-15', 'Returned'),
(6, 6, '2024-09-01', 'Overdue'),
(7, 7, '2024-08-20', 'On loan');