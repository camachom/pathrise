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

COPY boards(name, raiting, root_domain, logo_file, description) 
  FROM '/docker-entrypoint-initdb.d/job_boards.csv' DELIMITER ',' CSV;