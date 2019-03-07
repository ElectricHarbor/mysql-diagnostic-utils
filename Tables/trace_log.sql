CREATE TABLE my_diag_utils.trace_log (
    id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    entry_timestamp TIMESTAMP NOT NULL,
    block_name VARCHAR(194) NOT NULL,
    message_text VARCHAR(512) NOT NULL,
    profile_details_json JSON NULL,
    request_tracking_id CHAR(36) NULL,
    INDEX ix_request_tracking_id (request_tracking_id)
)
ENGINE = INNODB
COMMENT =
"id is a pure surrogate and has no current function other than being a
lighter-weight clustered index for temporal ordering compared to
entry_timestamp. entry_timestamp is inferior since can have ties and
increases the size of non-clustered indexes.

message_text datatype of VARCHAR(512) is arbitrary. Its length could be
up to platform or configured page-related maximum, or changed to a text
type for longer strings.

profile_details_json is a schemaless column for user routines to
store profiling information. This column is designed to be used when
both the trace_indicator and profile_indicator settings are enabled.";