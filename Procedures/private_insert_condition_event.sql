SET @ehi_my_diag_utils_build_variable_old_sql_mode = @@sql_mode;
SET @@sql_mode = 'TRADITIONAL,ONLY_FULL_GROUP_BY,IGNORE_SPACE,'
    'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION';

DELIMITER $$
CREATE OR REPLACE
    DEFINER = 'my_diag_utils'@'localhost'
    PROCEDURE my_diag_utils.private_insert_condition_event
    (
        _event_timestamp TIMESTAMP,
        _flushing_block_name VARCHAR(194),
        _estimated_signaling_block_name VARCHAR(194),
        _request_tracking_id CHAR(36),
        OUT _event_id INT UNSIGNED
    )
    LANGUAGE SQL
    NOT DETERMINISTIC
    CONTAINS SQL
    SQL SECURITY DEFINER
    COMMENT
"Created by Kevin Stephenson, 2019-02-25

Insert a single row into my_diag_utils.condition_events and return the
generated id.

USAGE NOTES
This procedure is private to the my_diag_utils library and should not
be called by non-library routines or scripts.

Performs no argument checks as caller is trusted.

Should be called with @@autocommit = 1 in order to
capture as much condition information as possible even if processor
partially fails and doesn't write out all condition event rows.

But in general, defers to caller for TX handling other than
the explicitly set innodb_lock_wait_timeout.

DESIGN NOTES
This is a simple insert wrapper that sets a low (row) lock timeout.
Low lock timeout will expose any excess locks being taken on
the my_diag_utils.condition_events table. In production use, simple
inserts to an auto incrementing table should almost never block.

_event_id data type is tightly coupled to
my_diag_utils.condition_events.event_id data type.

Parameters not validated. This procedure relies on table definition
and strict mode.

A procedure with OUT parameter used instead of a function to keep
code more portable to other platforms that don't allow DML side-effects
in functions."
BEGIN

    SET STATEMENT innodb_lock_wait_timeout = 50 FOR
        INSERT INTO my_diag_utils.condition_events
        (
            event_timestamp,
            flushing_block_name,
            estimated_signaling_block_name,
            connection_id,
            request_tracking_id
        )
        VALUES
        (
            _event_timestamp,
            _flushing_block_name,
            _estimated_signaling_block_name,
            CONNECTION_ID(),
            _request_tracking_id
        );

    SET _event_id = LAST_INSERT_ID();

END;
$$
DELIMITER ;

SET @@sql_mode = @ehi_my_diag_utils_build_variable_old_sql_mode;
SET @ehi_my_diag_utils_build_variable_old_sql_mode = NULL;