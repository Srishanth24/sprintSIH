-- PostgreSQL schema for authentication and user records

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE uploads (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    filename VARCHAR(255),
    filetype VARCHAR(50),
    metadata JSONB,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE records (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255),
    data JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Seed data
-- Password hash for 'demo123'
INSERT INTO users (email, password_hash, name) VALUES
('demo@demo.com', '$2b$10$rGKqGvPa0s0x5W5NQO6w2.XLHNJbTKJ5FfXlj4c1pG8ZfOeE7G.6C', 'Demo User');

INSERT INTO records (user_id, title, data) VALUES
(1, 'Sample Health Record', '{"value": 42, "note": "Daily step count measurement."}'),
(1, 'Weekly Progress', '{"value": 85, "note": "Fitness goal achievement percentage."}'),
(1, 'Monthly Summary', '{"value": 67, "note": "Overall wellness score this month."}');
