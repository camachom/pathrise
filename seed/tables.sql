DROP TABLE IF EXISTS jobs;

CREATE TABLE IF NOT EXISTS 
  jobs (
    id INT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    title TEXT DEFAULT NULL,
    company_name TEXT DEFAULT 'Unknown',
    url TEXT DEFAULT NULL,
    resolved_board TEXT
  );

DROP TABLE IF EXISTS boards;

CREATE TABLE IF NOT EXISTS 
  boards (
    id INT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name TEXT NOT NULL,
    raiting TEXT NOT NULL CHECK (raiting IN ('Okay','Good','Great')),
    root_domain TEXT NOT NULL,
    logo_file TEXT NOT NULL,
    description TEXT NOT NULL,
    query TSQUERY
  );