SET @ehi_my_diag_utils_build_variable_old_sql_mode = @@sql_mode;
SET @@sql_mode = 'TRADITIONAL,ONLY_FULL_GROUP_BY,IGNORE_SPACE,'
    'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION';

DELIMITER $$
CREATE OR REPLACE
    DEFINER = 'my_diag_utils'@'localhost'
    PROCEDURE my_diag_utils.private_flush_call_stack
    (
        _event_id INT UNSIGNED
    )
    LANGUAGE SQL
    NOT DETERMINISTIC
    CONTAINS SQL
    SQL SECURITY DEFINER
    COMMENT
"Created by Kevin Stephenson, 2019-02-25.

Insert call stack entries into my_diag_utils.call_stacks.

USAGE NOTES
This procedure is private to the my_diag_utils library and should not be
called by non-library routines or scripts.

Parameters and handler state not validated. Caller is trusted and
underlying table will likely throw on missing value during insert.

Should be called with @@autocommit = 1 in order to
capture as much error information as possible even if processor
partially fails and doesn't write out all condition event rows.

DESIGN NOTE
reverse_call_stack_level_value is adjusted to be one-based to match
the one-based condition number domain in my_diag_utils.conditions.

Sequence goes to max allowed value for max_sp_recursion_depth system
variable which is 255. Platform docs have no explicit max nesting value
so this is an approximation.

Uses SEQUENCE Storage Engine.

In general, defers to caller for TX handling other than
the explicitly set innodb_lock_wait_timeout."
BEGIN

    SET STATEMENT innodb_lock_wait_timeout = 50 FOR
        INSERT INTO my_diag_utils.call_stacks
        (
            event_id,
            reverse_call_stack_level_value,
            processing_block_name,
            details_json
        )
        SELECT
            _event_id,
            seq + 1,
            JSON_VALUE -- get scaler
            (
                @ehi_my_diag_utils_call_stack_json,
                CONCAT('$[', seq, ']', '.processingBlockName')
            ),
            JSON_QUERY -- get object
            (
                @ehi_my_diag_utils_call_stack_json,
                CONCAT('$[', seq, ']', '.details')
            )
        FROM
            seq_0_to_255
        WHERE
            seq < JSON_LENGTH(@ehi_my_diag_utils_call_stack_json);

END;
$$
DELIMITER ;

SET @@sql_mode = @ehi_my_diag_utils_build_variable_old_sql_mode;
SET @ehi_my_diag_utils_build_variable_old_sql_mode = NULL;
