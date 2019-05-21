SET @ehi_my_diag_utils_build_variable_old_sql_mode = @@sql_mode;
SET @@sql_mode = 'TRADITIONAL,ONLY_FULL_GROUP_BY,IGNORE_SPACE,'
    'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION';

DELIMITER $$
CREATE OR REPLACE
    DEFINER = 'my_diag_utils'@'localhost'
    FUNCTION my_diag_utils.get_session_configured_indicator()
    RETURNS BIT
    LANGUAGE SQL
    NOT DETERMINISTIC
    CONTAINS SQL
    SQL SECURITY INVOKER
    COMMENT
"Created by Kevin Stephenson, 2019-03-23.

Return session configured indicator with NULL coalesced to 0.

DESIGN NOTES
This is a thin wrapper over a user-defined variable used by this
library. The names of the user-defined variable are an implementation
detail that users of this library should not depend on. Use this function
instead."
BEGIN

    /*
    COALESCE/IFNULL defaults to LONGBLOB when using user-defined
    variable, hence the manual logic.
    */
    IF
        @ehi_my_diag_utils_session_configured_indicator IS NULL OR
        @ehi_my_diag_utils_session_configured_indicator <> 1 THEN
        RETURN 0;
    END IF;

    RETURN 1;

END;
$$
DELIMITER ;

SET @@sql_mode = @ehi_my_diag_utils_build_variable_old_sql_mode;
SET @ehi_my_diag_utils_build_variable_old_sql_mode = NULL;