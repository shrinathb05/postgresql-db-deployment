-- Safe Insertion for Authors
INSERT INTO authors (author_name, country) 
VALUES 
    ('George ', 'United Kingdom'),
    ('J.K.', 'United Kingdom'),
    ('Harper', 'United States')
ON CONFLICT (author_name) DO NOTHING;

-- Safe Insertion for Books (Checks uniqueness via the ISBN column constraint)
  
