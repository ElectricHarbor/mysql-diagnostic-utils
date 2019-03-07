SET @ehi_my_diag_utils_build_variable_old_sql_mode = @@sql_mode;
SET @@sql_mode = 'TRADITIONAL,ONLY_FULL_GROUP_BY,IGNORE_SPACE,'
    'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION';

DELIMITER $$
CREATE OR REPLACE
    DEFINER = 'my_diag_utils'@'localhost'
    PROCEDURE my_diag_utils.private_validate_flushable_condition_event()
    LANGUAGE SQL
    NOT DETERMINISTIC
    CONTAINS SQL
    SQL SECURITY DEFINER
    COMMENT
"Created by Kevin Stephenson, 2019-02-25.

Validate that the library is in a state to allow condition event flushing."
BEGIN

    IF COALESCE(@ehi_my_diag_utils_condition_event_in_progress_indicator, 0) <> 1 THEN
        CALL my_diag_utils.reset_session();

        SIGNAL SQLSTATE '45000'
            SET
                MESSAGE_TEXT =
                    'my_diag_utils.private_validate_flushable_condition_event: '
                    'Called without in progress condition event.';
    END IF;

    IF @ehi_my_diag_utils_condition_event_timestamp IS NULL THEN
        CALL my_diag_utils.reset_session();

        SIGNAL SQLSTATE '45000'
            SET
                MESSAGE_TEXT =
                    'my_diag_utils.private_validate_flushable_condition_event: '
                    '@ehi_my_diag_utils_condition_event_timestamp missing.';
    END IF;

    IF @ehi_my_diag_utils_call_stack_json IS NULL THEN
        CALL my_diag_utils.reset_session();

        SIGNAL SQLSTATE '45000'
            SET
                MESSAGE_TEXT =
                    'my_diag_utils.private_validate_flushable_condition_event: '
                    '@ehi_my_diag_utils_call_stack_json missing.';
    END IF;

END;
$$
DELIMITER ;

SET @@sql_mode = @ehi_my_diag_utils_build_variable_old_sql_mode;
SET @ehi_my_diag_utils_build_variable_old_sql_mode = NULL;