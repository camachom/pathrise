CREATE OR REPLACE FUNCTION sanitize_data()
RETURNS TRIGGER AS $sanitize_data_trigger$
DECLARE 
  BOARD_MATCH TEXT;
  COMPANY_MATCH TEXT;
  COMPANY_NAME_QUERY TSQUERY;
  DOCUMENT TSVECTOR;
BEGIN
  NEW.title = TRIM(BOTH FROM NEW.title);

  IF NEW.title = '' THEN NEW.title = NULL;
  END IF;

  DOCUMENT := 
    to_tsvector(
      'english',
      coalesce(regexp_replace(NEW.url, '[^\w]+', ' ', 'gi'), '')
    );
  
  BOARD_MATCH := (
    SELECT board_matches.name
    FROM (
      SELECT boards.*, ts_rank(DOCUMENT, boards.query) AS rank
      FROM boards
      WHERE DOCUMENT @@ boards.query
      ORDER BY rank DESC
      LIMIT 1
    ) as board_matches
  );

  COMPANY_NAME_QUERY := plainto_tsquery(
        'english',
        coalesce(regexp_replace(NEW.company_name, '[^\w]+', ' ', 'gi'), '')
    );

  COMPANY_MATCH := (
    SELECT company_matches.company_name
    FROM (
      SELECT NEW.*, ts_rank(DOCUMENT, COMPANY_NAME_QUERY) AS rank
      WHERE DOCUMENT @@ COMPANY_NAME_QUERY 
      ORDER BY rank DESC
      LIMIT 1
    ) as company_matches
  );

  NEW.resolved_board = COALESCE(BOARD_MATCH, COMPANY_MATCH, 'Unknown');

  RETURN NEW;
RETURN NULL;
END;
 $sanitize_data_trigger$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION make_board_vectors()
RETURNS TRIGGER AS $make_board_vectors_trigger$
BEGIN
  NEW.query = plainto_tsquery(
        'english',
        coalesce(regexp_replace(NEW.root_domain, '[^\w]+', ' ', 'gi'), '')
    );
  RETURN NEW;
RETURN NULL;
END;
 $make_board_vectors_trigger$ LANGUAGE plpgsql;

CREATE TRIGGER preprocess_boards
    BEFORE INSERT ON boards
    FOR EACH ROW
    EXECUTE PROCEDURE make_board_vectors();

CREATE TRIGGER preprocess_jobs
    BEFORE INSERT ON jobs
    FOR EACH ROW
    EXECUTE PROCEDURE sanitize_data();

COPY boards(name, raiting, root_domain, logo_file, description) 
  FROM '/docker-entrypoint-initdb.d/job_boards.csv' DELIMITER ',' CSV;

COPY jobs(id, title, company_name, url) 
  FROM '/docker-entrypoint-initdb.d/job_opportunities.csv' DELIMITER ',' CSV;