SET @ehi_my_diag_utils_build_variable_old_sql_mode = @@sql_mode;
SET @@sql_mode = 'TRADITIONAL,ONLY_FULL_GROUP_BY,IGNORE_SPACE,'
    'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION';

DELIMITER $$
CREATE OR REPLACE
    DEFINER = 'my_diag_utils'@'localhost'
    PROCEDURE my_diag_utils.private_flush_condition_event
    (
        _flushing_code_block_name VARCHAR(194)
    )
    LANGUAGE SQL
    NOT DETERMINISTIC
    CONTAINS SQL
    SQL SECURITY DEFINER
    COMMENT
"Created by Kevin Stephenson, 2019-02-25.

Log all available condition event information to log tables
and reset session.

Information is writen to the following tables:
    my_diag_utils.condition_events
    my_diag_utils.conditions
    my_diag_utils.call_stacks

USAGE NOTES
This procedure is private to the my_diag_utils library and should not
be called by non-library routines or scripts.

DESIGN NOTES
Performs limited validations on the user-defined variables via call to
private_validate_flushable_condition_event. These checks may be removed
in a future version if they have an excessive performance impact or are
overly redundant with checks already done in process_conditions and
related routines.

Normally the caller would be trusted, but in order to more quickly find
problems during initial development, the checks are being done here."
BEGIN

    DECLARE _event_id INT UNSIGNED;
    DECLARE _estimated_signaling_block_name VARCHAR(194);
    DECLARE _conditions_json JSON;

    -- Validate state.
    CALL my_diag_utils.private_validate_flushable_condition_event();

    -- Get estimated signaling block name. Will signal if not found.
    SET _estimated_signaling_block_name =
        my_diag_utils.private_get_estimated_signaling_block_name();

    /*
    Before touching tables with inserts, must fetch and store contents
    of the diagnostic area (DA) as the inserts will cause the DA to be
    cleared. Signals if no conditions found in DA.
    */
    SET _conditions_json =
        my_diag_utils.get_conditions_json();

    -- Perform logging operations.
    CALL my_diag_utils.private_insert_condition_event
    (
        @ehi_my_diag_utils_condition_event_timestamp,
        _flushing_code_block_name,
        _estimated_signaling_block_name,
        @ehi_my_diag_utils_request_tracking_id,
        _event_id -- An OUT parameter.
    );

    -- More valuable than call stack so logging first.
    CALL my_diag_utils.private_flush_conditions
    (
        _event_id,
        _conditions_json,
        1 -- Discard ER_SP_STACK_TRACE notes
    );
    
    CALL my_diag_utils.private_flush_call_stack(_event_id);

    -- Cleanup.
    CALL my_diag_utils.reset_session();

END;
$$
DELIMITER ;

SET @@sql_mode = @ehi_my_diag_utils_build_variable_old_sql_mode;
SET @ehi_my_diag_utils_build_variable_old_sql_mode = NULL;