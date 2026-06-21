-- Create Authors table first (Parent Table)
CREATE TABLE IF NOT EXISTS authors (
    author_id SERIAL PRIMARY KEY,
    author_name VARCHAR(100) NOT NULL UNIQUE,
    country VARCHAR(50)
);

-- Create Books table (Child Table with Foreign Key)
CREATE TABLE IF NOT EXISTS books (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    author_id INT REFERENCES authors(author_id) ON DELETE CASCADE,
    isbn VARCHAR(20) UNIQUE,
    published_year INT,
    price DECIMAL(10, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

