SET @ehi_my_diag_utils_build_variable_old_sql_mode = @@sql_mode;
SET @@sql_mode = 'TRADITIONAL,ONLY_FULL_GROUP_BY,IGNORE_SPACE,'
    'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION';

DELIMITER $$
CREATE OR REPLACE
    DEFINER = 'my_diag_utils'@'localhost'
    PROCEDURE my_diag_utils.private_append_to_call_stack
    (
        _processing_block_name VARCHAR(194),
        _details_json JSON
    )
    LANGUAGE SQL
    NOT DETERMINISTIC
    CONTAINS SQL
    SQL SECURITY DEFINER
    COMMENT
"Created by Kevin Stephenson, 2019-02-25.

Initialize or append to call stack user-defined variable that
stores and array of JSON objects, with each object holding the
catching procedure full name and optional details JSON.

USAGE NOTES
This procedure is private to the my_diag_utils library and should not
be called by non-library routines or scripts.

DESIGN NOTES
Inherits all non-sql mode state from caller.

Performs no argument checks as caller is trusted.

JSON_EXTRACT() required due to _details_json inexplicably being
turned from a JSON object to an escaped string by JSON_OBJECT()."
BEGIN

    IF @ehi_my_diag_utils_call_stack_json IS NULL THEN
        SET @ehi_my_diag_utils_call_stack_json =
            JSON_ARRAY
            (
                JSON_OBJECT
                (
                    'processingBlockName',
                    _processing_block_name,
                    'details',
                    JSON_EXTRACT(_details_json, '$')
                )
            );
    ELSE
        SET @ehi_my_diag_utils_call_stack_json =
            JSON_ARRAY_APPEND
            (
                @ehi_my_diag_utils_call_stack_json,
                '$',
                JSON_OBJECT
                (
                    'processingBlockName',
                    _processing_block_name,
                    'details',
                    JSON_EXTRACT(_details_json, '$')
                )
            );
    END IF;

END;
$$
DELIMITER ;

SET @@sql_mode = @ehi_my_diag_utils_build_variable_old_sql_mode;
SET @ehi_my_diag_utils_build_variable_old_sql_mode = NULL;