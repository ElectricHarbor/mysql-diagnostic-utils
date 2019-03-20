SET @ehi_my_diag_utils_build_variable_old_sql_mode = @@sql_mode;
SET @@sql_mode = 'TRADITIONAL,ONLY_FULL_GROUP_BY,IGNORE_SPACE,'
    'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION';

DELIMITER $$
CREATE OR REPLACE
    DEFINER = 'my_diag_utils'@'localhost'
    FUNCTION my_diag_utils.get_profile_indicator()
    RETURNS BIT
    LANGUAGE SQL
    NOT DETERMINISTIC
    CONTAINS SQL
    SQL SECURITY INVOKER
    COMMENT
"Created by Kevin Stephenson, 2019-03-11.

Return profile indicator as is. NULLs not coalesced to a default.

USAGE NOTES
Designed to be called after the my_diag_utils session has been
configured. Will signal if session is not configured.

DESIGN NOTES
This is a thin wrapper over the user-defined variables used by this
library. The names of the user-defined variable are an implementation
detail that users of this library should not depend on. Use this function
instead."
BEGIN

    IF COALESCE(@ehi_my_diag_utils_session_configured_indicator, 0) = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET
                MESSAGE_TEXT =
                    'my_diag_utils.get_profile_indicator: '
                    'Called with unconfigured session.';
    END IF;

    RETURN @ehi_my_diag_utils_profile_indicator;

END;
$$
DELIMITER ;

SET @@sql_mode = @ehi_my_diag_utils_build_variable_old_sql_mode;
SET @ehi_my_diag_utils_build_variable_old_sql_mode = NULL;