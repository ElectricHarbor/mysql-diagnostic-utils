CREATE TABLE my_diag_utils.condition_events (
    event_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    event_timestamp TIMESTAMP NOT NULL,
    flushing_block_name VARCHAR(194) NOT NULL,
    estimated_signaling_block_name VARCHAR(194) NOT NULL,
    connection_id BIGINT UNSIGNED NOT NULL,
    request_tracking_id CHAR(36) NULL
)
ENGINE = INNODB,
COMMENT
"Because MySQL doesn't have sufficiently rich metadata functions or
details for the diagnostics area, it is impossible to guarantee what the
name of the code block is that initially raises a condition.

flushing_block_name is the final (top-most) block in a chain and
typically will be the routine initially called in by clients. The
exception would be if the first routine called did not use this library
but called a nested routine that did. It is a denormalized copy of data
that can be found in my_diag_utils.condition_event_call_stacks (last entry).
        
estimated_signaling_block_name is the block name passed to the first
invocation of process_conditions within a call stack and is used as the
estimated block name where the condition(s) was raised. It is a
denormalized copy of data that can be found in
my_diag_utils.condition_event_call_stacks (first entry).

connection_id can be used for better correlation with entires in error,
general and slow logs. connection_id data type confirmed in
/server/include/my_pthread.h typedef uint64 my_thread_id; (Used by thd class.)

request_tracking_id is sized to hold UUIDs in text format.
(MySQL does not have a native data type for UUIDs.)";