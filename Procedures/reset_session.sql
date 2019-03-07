SET @ehi_my_diag_utils_build_variable_old_sql_mode = @@sql_mode;
SET @@sql_mode = 'TRADITIONAL,ONLY_FULL_GROUP_BY,IGNORE_SPACE,'
    'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION';

DELIMITER $$
CREATE OR REPLACE
    DEFINER = 'my_diag_utils'@'localhost'
    PROCEDURE my_diag_utils.reset_session()
    LANGUAGE SQL
    NOT DETERMINISTIC
    CONTAINS SQL
    SQL SECURITY DEFINER
    COMMENT
"Created by Kevin Stephenson, 2019-02-25.

Set the user-defined variables used by the library to NULL.

USAGE NOTES
It is an error to call this procedure without the session already being
configured. It will signal and reset the diagnostics area.

DESIGN NOTES
To prevent issues mentioned in my_diag_utils.configure_session for
multiple calls to that procedure and this procedure, signals if session
is not configured as noted in USAGE NOTES above."
BEGIN

    -- Validate state
    IF @ehi_my_diag_utils_session_configured_indicator IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET
                MESSAGE_TEXT =
                    'my_diag_utils.reset_session: '
                    'Called with unconfigured session.';
    END IF;

    /*
    Clear user-defined variables.

    NOTE
    Depending on when this procedure is called, some of the SET
    statements will be NOPs. For example, if a condition event
    did not occur, the *_condition_event_* and *_call_stack_json
    variables will already be NULL.

    To make the code more robust, clearing without checking a
    signalling variable like *ErrorEventInProgressIndicator.

    */
    SET @ehi_my_diag_utils_session_configuring_block_name = NULL;
    SET @ehi_my_diag_utils_condition_event_in_progress_indicator = NULL;
    SET @ehi_my_diag_utils_condition_event_timestamp = NULL;
    SET @ehi_my_diag_utils_call_stack_json = NULL;

    -- Clear diagnostics module shared user-defined variables.
    SET @ehi_my_diag_utils_request_tracking_id = NULL;
    SET @ehi_my_diag_utils_debug_indicator = NULL;
    SET @ehi_my_diag_utils_trace_indicator = NULL;
    SET @ehi_my_diag_utils_profile_indicator = NULL;

    -- Complete de-activation.
    SET @ehi_my_diag_utils_session_configured_indicator = NULL;

END;
$$
DELIMITER ;

SET @@sql_mode = @ehi_my_diag_utils_build_variable_old_sql_mode;
SET @ehi_my_diag_utils_build_variable_old_sql_mode = NULL;
