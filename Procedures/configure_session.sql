SET @ehi_my_diag_utils_build_variable_old_sql_mode = @@sql_mode;
SET @@sql_mode = 'TRADITIONAL,ONLY_FULL_GROUP_BY,IGNORE_SPACE,'
    'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION';

DELIMITER $$
CREATE OR REPLACE
    DEFINER = 'my_diag_utils'@'localhost'
    PROCEDURE my_diag_utils.configure_session
    (
        _configuring_block_name VARCHAR(194),
        _request_tracking_id CHAR(36),
        _debug_indicator BIT,
        _trace_indicator BIT,
        _profile_indicator BIT
    )
    LANGUAGE SQL
    NOT DETERMINISTIC
    CONTAINS SQL
    SQL SECURITY DEFINER
    COMMENT
"Created by Kevin Stephenson, 2019-02-25.
                                                                        <
Configure the library's user-defined variables.

USAGE NOTES
This procedure must be called in a top-level code block (block) before
calling other routines in this library. Session configuration is only
required in the top-level code block.

Nested blocks and routines that call this procedure again will have
their arguments ignored to reduce complexity. Otherwise, a very
complicated stack of current and prior arguments would need to be
maintained, with multiple condition_events and related child items being
logged for a single condition event. See FUTURE note.

If _profile_indicator is set to 1, _debug_indicator and/or
_trace_indicator must also be set to 1. This is to prevent user code
from compiling profiling information that is simply discarded by
my_diag_utils.tell.

DESIGN NOTES
Uses early return.

Unlike other routines in this library, does not call
my_diag_utils.reset_session before signaling. This can leave some of the
user-defined variables populated until the connection is closed.

WARNINGS
If connection pooling is used by clients without connections being reset
before reuse, the process_conditions will fail to log events when the
reused connection calls a top-level routine different from the one used
to initially configure the session. The workaround is to reset the
session on completion (fail or success) in top-level blocks.

If a top-level block that uses configure_session and reset_session is
called by another block that uses configure_session and reset_session,
the call to reset_session in the nested block will clear the
user-defined variables and invalidate the library state for the calling
procedure. Recommendation is to only configure the session in top-level
blocks that do not call other top-level procedures. See FUTURE note.

FUTURE
Add ability for top-level blocks to call other top-level routines
so configure_session and reset_session behave more like a stack."
this: BEGIN

    -- Validate arguments
    IF _configuring_block_name IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET
                MESSAGE_TEXT =
                    'my_diag_utils.configure_session: '
                    '_configuring_block_name must not be NULL.';
    END IF;

    IF _profile_indicator = 1 AND
        COALESCE(_debug_indicator, 0) = 0 AND
        COALESCE(_trace_indicator, 0) = 0 THEN

        SIGNAL SQLSTATE '45000'
            SET
                MESSAGE_TEXT =
                    'my_diag_utils.configure_session: '
                    'When _profile_indicator is on then _debug_indicator '
                    'and/or _trace_indicator must also be 1.';
    END IF;        

    -- WARNING: Early exit if already configured. See procedure comments.
    IF @ehi_my_diag_utils_session_configured_indicator = 1 THEN
        LEAVE this;
    END IF;

    -- Store block name that first configured session in a chain.
    SET @ehi_my_diag_utils_session_configuring_block_name =
        _configuring_block_name;

    -- Store request tracking id and indicators.
    SET @ehi_my_diag_utils_request_tracking_id = _request_tracking_id;

    /*
    NULL coalesced to 0 for indicators to keep logic simpler in other
    routines in this library.
    */
    SET @ehi_my_diag_utils_debug_indicator =
        COALESCE(_debug_indicator, 0);
    SET @ehi_my_diag_utils_trace_indicator =
        COALESCE(_trace_indicator, 0);
    SET @ehi_my_diag_utils_profile_indicator =
        COALESCE(_profile_indicator, 0);

    -- Mark configuration complete.
    SET @ehi_my_diag_utils_session_configured_indicator = 1;

END;
$$
DELIMITER ;

SET @@sql_mode = @ehi_my_diag_utils_build_variable_old_sql_mode;
SET @ehi_my_diag_utils_build_variable_old_sql_mode = NULL;