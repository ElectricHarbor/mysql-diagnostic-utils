SET @ehi_my_diag_utils_build_variable_old_sql_mode = @@sql_mode;
SET @@sql_mode = 'TRADITIONAL,ONLY_FULL_GROUP_BY,IGNORE_SPACE,'
    'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION';

DELIMITER $$
CREATE OR REPLACE
    DEFINER = 'my_diag_utils'@'localhost'
    PROCEDURE my_diag_utils.tell
    (
        _block_name VARCHAR(194),
        _message_text VARCHAR(512),
        _profile_details_json JSON
    )
    LANGUAGE SQL
    NOT DETERMINISTIC
    CONTAINS SQL
    SQL SECURITY DEFINER
    COMMENT
"Created by Kevin Stephenson, 2019-02-25.

Print or log messages depending on indicator settings.

USAGE NOTES
It is an error to call this procedure with an unconfigured session.

This procedure inherits all TX related state except for innodb lock timeout,
which it overrides. If the calling block performs a rollback, trace logs
will be lost.

_profile_json is always optional, even if the profile indicator is set
as not all callers will have meaningful profiling information to send.

DESIGN NOTES
The peculiar name of this procedure was used to prevent conflicts with
MySQL, MariaDB and standard SQL keywords such as WRITE."
BEGIN

    --  Validate session state.
    IF @ehi_my_diag_utils_session_configured_indicator IS NULL THEN
        CALL my_diag_utils.reset_session(); -- Paranoid fail-safe

        SIGNAL SQLSTATE '45000'
            SET
                MESSAGE_TEXT =
                    'my_diag_utils.tell: '
                    'Called with unconfigured session.';
    END IF;

    IF @ehi_my_diag_utils_debug_indicator = 1 THEN
        SELECT
            _block_name AS block_name,
            _message_text AS message_text,
            _profile_details_json AS profile_details_json;
    END IF;

    IF @ehi_my_diag_utils_trace_indicator = 1 THEN
        INSERT INTO my_diag_utils.trace_log
        (
            entry_timestamp,
            block_name,
            message_text,
            profile_details_json,
            request_tracking_id
        )
        VALUES
        (
            CURRENT_TIMESTAMP(),
            _block_name,
            _message_text,
            _profile_details_json,
            @ehi_my_diag_utils_request_tracking_id
        );
    END IF;

END;
$$
DELIMITER ;

SET @@sql_mode = @ehi_my_diag_utils_build_variable_old_sql_mode;
SET @ehi_my_diag_utils_build_variable_old_sql_mode = NULL;