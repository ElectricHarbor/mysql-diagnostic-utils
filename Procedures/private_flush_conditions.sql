SET @ehi_my_diag_utils_build_variable_old_sql_mode = @@sql_mode;
SET @@sql_mode = 'TRADITIONAL,ONLY_FULL_GROUP_BY,IGNORE_SPACE,'
    'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION';

DELIMITER $$
CREATE OR REPLACE
    DEFINER = 'my_diag_utils'@'localhost'
    PROCEDURE my_diag_utils.private_flush_conditions
    (
        _event_id INT UNSIGNED,
        _conditions_json JSON,
        _discard_ER_SP_STACK_TRACE_conditions_indicator BIT
    )
    LANGUAGE SQL
    NOT DETERMINISTIC
    CONTAINS SQL
    SQL SECURITY DEFINER
    COMMENT
"Created by Kevin Stephenson, 2019-02-25.

Insert event conditions into my_diag_utils.conditions.

PARAMETERS
_event_id
The condition event's id.

_conditions_json
    Expecting minimum format:
    [
        {
            \"conditionValue\": <tinyint unsigned>,
            \"sqlStateCode\": <char(5)>,
            \"mySqlErrorCode\": <int signed>,
            \"messageText\": \"<varchar(512)>\"
        } ...
    ]

_discard_ER_SP_STACK_TRACE_conditions_indicator
Discard MariaDB specific ER_SP_STACK_TRACE (MYSQL_ERRNO 4094) note-level
conditions as they are mainly redundant with this library's call stack.

This library can have multiple blocks in a routine present in the call
stack, but MariaDB only shows a single note per routine regardless of
nested blocks. MariaDB also has a possible RESIGNAL bug that results in
notes in nested routines being discarded when RESIGNAL is called and an
outer handler catches it.

USAGE NOTES
This procedure is private to the my_diag_utils library and should not
be called by non-library routines or scripts.

Parameters not validated. Caller is trusted and underlying table
likely will throw on missing value during insert.

Should be called with @@autocommit = 1 in order to
capture as much error information as possible even if processor
partially fails and doesn't write out all condition event rows.

DESIGN NOTE
Sequence goes to max allowed value for max_error_count system
variable which is 65535.

Uses SEQUENCE Storage Engine.

In general, defers to caller for TX handling other than
the explicitly set innodb_lock_wait_timeout."
BEGIN

    SET STATEMENT innodb_lock_wait_timeout = 50 FOR
        INSERT INTO my_diag_utils.conditions
        (
            event_id,
            condition_value,
            sql_state_code,
            mysql_error_code,
            message_text
        )
        SELECT
            _event_id AS EventId,
            JSON_VALUE
            (
                _conditions_json,
                CONCAT('$[', seq, ']', '.conditionValue')
            ),
            JSON_VALUE
            (
                _conditions_json,
                CONCAT('$[', seq, ']', '.sqlStateCode')
            ),
            JSON_VALUE
            (
                _conditions_json,
                CONCAT('$[', seq, ']', '.mySqlErrorCode')
            ),
            JSON_VALUE
            (
                _conditions_json,
                CONCAT('$[', seq, ']', '.messageText')
            )
        FROM
            seq_0_to_65535
        WHERE
             seq < JSON_LENGTH(_conditions_json) AND
            (
                COALESCE(_discard_ER_SP_STACK_TRACE_conditions_indicator, 0) = 0 OR
                JSON_VALUE
                (
                    _conditions_json,
                    CONCAT('$[', seq, ']', '.mySqlErrorCode')
                ) <> 4094 -- ER_SP_STACK_TRACE
            );

END;
$$
DELIMITER ;

SET @@sql_mode = @ehi_my_diag_utils_build_variable_old_sql_mode;
SET @ehi_my_diag_utils_build_variable_old_sql_mode = NULL;