SET @ehi_my_diag_utils_build_variable_old_sql_mode = @@sql_mode;
SET @@sql_mode = 'TRADITIONAL,ONLY_FULL_GROUP_BY,IGNORE_SPACE,'
    'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION';

DELIMITER $$
CREATE OR REPLACE
    DEFINER = 'my_diag_utils'@'localhost'
    FUNCTION my_diag_utils.private_get_estimated_signaling_block_name()
    RETURNS VARCHAR(194)
    LANGUAGE SQL
    NOT DETERMINISTIC
    CONTAINS SQL
    SQL SECURITY DEFINER
    COMMENT
"Created by Kevin Stephenson, 2019-02-25.

Extract estimated signaling block name from call stack. Signals if not found."
BEGIN

    DECLARE _estimated_signaling_block_name VARCHAR(194);

    SET _estimated_signaling_block_name =
        JSON_VALUE
        (
            @ehi_my_diag_utils_call_stack_json,
            '$[0].processingBlockName'
        );

    IF _estimated_signaling_block_name IS NULL THEN
        CALL my_diag_utils.reset_session();

        SIGNAL SQLSTATE '45000'
            SET
                MESSAGE_TEXT =
                    'my_diag_utils.private_get_estimated_signaling_block_name: '
                    'Estimated signaling block name not found.';
    END IF;

    RETURN _estimated_signaling_block_name;

END;
$$
DELIMITER ;

SET @@sql_mode = @ehi_my_diag_utils_build_variable_old_sql_mode;
SET @ehi_my_diag_utils_build_variable_old_sql_mode = NULL;