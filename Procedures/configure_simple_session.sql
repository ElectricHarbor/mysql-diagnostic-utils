SET @ehi_my_diag_utils_build_variable_old_sql_mode = @@sql_mode;
SET @@sql_mode = 'TRADITIONAL,ONLY_FULL_GROUP_BY,IGNORE_SPACE,'
    'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION';

DELIMITER $$
CREATE OR REPLACE
    DEFINER = 'my_diag_utils'@'localhost'
    PROCEDURE my_diag_utils.configure_simple_session
    (
        _configuring_block_name VARCHAR(194)
    )
    LANGUAGE SQL
    NOT DETERMINISTIC
    CONTAINS SQL
    SQL SECURITY DEFINER
    COMMENT
"Created by Kevin Stephenson, 2019-02-25.

Wrap configure_session with defaults for simple cases where the
following features aren't required:
    Request Id Tracking
    Debug and Trace Outputs
    Conditional Profiling
"
BEGIN

    CALL my_diag_utils.configure_session
    (
        _configuring_block_name,
        NULL, -- _request_tracking_id
        NULL, -- _debug_indicator
        NULL, -- _trace_indicator
        NULL  -- _profile_indicator
    );

END;
$$
DELIMITER ;

SET @@sql_mode = @ehi_my_diag_utils_build_variable_old_sql_mode;
SET @ehi_my_diag_utils_build_variable_old_sql_mode = NULL;