CREATE OR REPLACE FUNCTION sanitize_data()
RETURNS TRIGGER AS $sanitize_data_trigger$
DECLARE 
  BOARD_ID INT;
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
  
  WITH board_matches AS (
    SELECT boards.*, ts_rank(DOCUMENT, boards.query) AS rank
    FROM boards
    WHERE DOCUMENT @@ boards.query
    ORDER BY rank DESC
    LIMIT 1
  )
  SELECT board_matches.id
  INTO BOARD_ID
  FROM board_matches
  LIMIT 1;

  IF BOARD_ID IS NOT NULL THEN
    NEW.board_id = BOARD_ID;
    RETURN NEW;
  END IF;

  COMPANY_NAME_QUERY := plainto_tsquery(
        'english',
        coalesce(regexp_replace(NEW.company_name, '[^\w]+', ' ', 'gi'), '')
    );

  WITH company_matches AS (
      SELECT NEW.*, ts_rank(DOCUMENT, COMPANY_NAME_QUERY) AS rank
      WHERE DOCUMENT @@ COMPANY_NAME_QUERY 
      ORDER BY rank DESC
      LIMIT 1
  )
  SELECT company_matches.company_name
  INTO COMPANY_MATCH
  FROM company_matches;

  IF COMPANY_MATCH IS NOT NULL THEN
    NEW.company_post = TRUE;
  END IF;

  RETURN NEW;
RETURN NULL;
END;
 $sanitize_data_trigger$ LANGUAGE plpgsql;

CREATE TRIGGER preprocess_jobs
    BEFORE INSERT ON jobs
    FOR EACH ROW
    EXECUTE PROCEDURE sanitize_data();

COPY jobs(id, title, company_name, url) 
  FROM '/docker-entrypoint-initdb.d/job_opportunities.csv' DELIMITER ',' CSV;