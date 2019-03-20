/*
Blanket GRANT EXECUTE to my_diag_utils user to call "public" and private_
my_diag_utils routines.
*/
GRANT EXECUTE ON my_diag_utils.* TO 'my_diag_utils'@'localhost';
GRANT INSERT ON my_diag_utils.* TO 'my_diag_utils'@'localhost';

/*
Blanket grant to select from tables for helper views.
No grants for INSERT, DELETE or UPDATE should be given to prevent
updatable views from being misused since there is no way to cleanly
mark views as "read only."
*/
GRANT SELECT ON my_diag_utils.* TO 'my_diag_utils'@'localhost';

-- Tedious but necessary as of MariaDB 10.3.12.
GRANT SELECT ON seq_0_to_65535 TO 'my_diag_utils'@'localhost';
GRANT SELECT ON seq_0_to_255 TO 'my_diag_utils'@'localhost';

/*
ROLE GRANTs
Specific top-level library routines and views can be called by anyone
added to the custom role 'my_diag_utils_role' (MySQL 8+ and MariaDB 10.0.5+.)
*/
GRANT EXECUTE ON PROCEDURE my_diag_utils.configure_session TO my_diag_utils_role;
GRANT EXECUTE ON PROCEDURE my_diag_utils.configure_simple_session TO my_diag_utils_role;
GRANT EXECUTE ON PROCEDURE my_diag_utils.reset_session TO my_diag_utils_role;
GRANT EXECUTE ON PROCEDURE my_diag_utils.process_conditions TO my_diag_utils_role;
GRANT EXECUTE ON PROCEDURE my_diag_utils.tell TO my_diag_utils_role;
GRANT EXECUTE ON FUNCTION my_diag_utils.get_conditions_json TO my_diag_utils_role;
GRANT EXECUTE ON FUNCTION my_diag_utils.get_profile_indicator TO my_diag_utils_role;
GRANT SELECT ON my_diag_utils.first_conditions TO my_diag_utils_role;