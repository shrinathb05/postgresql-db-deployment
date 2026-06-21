-- Safe Insertion for Authors
INSERT INTO authors (author_name, country) 
VALUES 
    ('George Orwell', 'United Kingdom'),
    ('J.K. Rowling', 'United Kingdom'),
    ('Harper Lee', 'United States')
ON CONFLICT (author_name) DO NOTHING;

-- Safe Insertion for Books (Checks uniqueness via the ISBN column constraint)
INSERT INTO books (title, author_id, isbn, published_year, price)
VALUES 
    ('1984', (SELECT author_id FROM authors WHERE author_name = 'George Orwell'), '9780451524935', 1949, 9.99),
    ('Animal Farm', (SELECT author_id FROM authors WHERE author_name = 'George Orwell'), '9780451526342', 1945, 7.99),
    ('Harry Potter and the Philosophers Stone', (SELECT author_id FROM authors WHERE author_name = 'J.K. Rowling'), '9780747532699', 1997, 14.99),
    ('To Kill a Mockingbird', (SELECT author_id FROM authors WHERE author_name = 'Harper Lee'), '9780446310789', 1960, 12.50)
ON CONFLICT (isbn) DO NOTHING;

