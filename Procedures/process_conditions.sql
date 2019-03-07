SET @ehi_my_diag_utils_build_variable_old_sql_mode = @@sql_mode;
SET @@sql_mode = 'TRADITIONAL,ONLY_FULL_GROUP_BY,IGNORE_SPACE,'
    'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION';

DELIMITER $$
CREATE OR REPLACE
    DEFINER = 'my_diag_utils'@'localhost'
    PROCEDURE my_diag_utils.process_conditions
    (
        _processing_block_name VARCHAR(194),
        _details_json JSON
    )
    LANGUAGE SQL
    NOT DETERMINISTIC
    CONTAINS SQL
    SQL SECURITY DEFINER
    COMMENT
"Created by Kevin Stephenson, 2019-02-25.

Process condition(s) in any DECLARE HANLDER (handler) block within a
chain of handler blocks. The chain includes the routine block that
calls configure_session and the handlers in any nested blocks and
routines.

USAGE NOTES
It is a bug to call this procedure without having previously
called configure_session. It is also a bug to call this procedure
without passing in _processing_code_block_name.

Caller must RESIGNAL if desired as it can't be done here due to platform
limitations (RESIGNAL must be invoked in a handler). Having the caller
RESIGNAL also gives more flexibility in processing conditions in
CONTINUE handlers where RESIGNAL is not desired.

DESIGN NOTES
If called without pre-conditions described in USAGE NOTES, will reset
the diagnostics area then SIGNAL, resulting in loss of the original
condition(s).

ROLLBACK is only performed at the end of a chain to make the system a
bit more deterministic given the flaws and limitations in MySQL/MariaDB
explicit transaction handling. After ROLLBACK is completed, then logging
rows can be written (with @@autocommit=1). And condition(s) signalled
by ROLLBACK are fatal to this routine.

FUTURE
When first DECLARE HANDLER block to call this routine is in the block
that called configure_session, the in_progress_indicator variable setting
can be optimized away. Left as distinct steps for now for clarity."
BEGIN

    --  Validate session state.
    IF @ehi_my_diag_utils_session_configured_indicator IS NULL THEN
        CALL my_diag_utils.reset_session(); -- Paranoid fail-safe

        SIGNAL SQLSTATE '45000'
            SET
                MESSAGE_TEXT =
                    'my_diag_utils.process_conditions: '
                    'Called with unconfigured session.';
    END IF;

    -- Validate arguments.
    IF _processing_block_name IS NULL THEN
        CALL my_diag_utils.reset_session();

        SIGNAL SQLSTATE '45000'
            SET
                MESSAGE_TEXT =
                    'my_diag_utils.process_conditions: '
                    '_processing_block_name must not be NULL.';
    END IF;

    -- See if this invocation starts new condition event in a chain.
    IF @ehi_my_diag_utils_condition_event_in_progress_indicator IS NULL THEN
        SET @ehi_my_diag_utils_condition_event_in_progress_indicator = 1;

        /*
        Get the timestamp as fast as possible from when a signal was
        first handled so so error log, general log and my_diag_utils logs
        will have highest possible synchronization. Note: There is no
        ERROR_TIMESTAMP() style metadata function so timestamps can
        never be perfectly synchronized.

        Design Note:
        It is understood that @ehi_my_diag_utils_condition_event_timestamp
        is a surrogate for the in progress indicator. Kept separate for
        clarity.
        */
        SET @ehi_my_diag_utils_condition_event_timestamp = CURRENT_TIMESTAMP();
    END IF;

    /*
    Initialize or append call stack user-defined variable that stores
    an array of JSON objects, with each object holding the processing
    procedure full name and optional details JSON.
    */
    CALL my_diag_utils.private_append_to_call_stack
    (
        _processing_block_name,
        _details_json
    );

    /*
    Determine if called by configurer which means time to flush.
    */
    IF @ehi_my_diag_utils_session_configuring_block_name =
        _processing_block_name THEN
        /*
        At the end of the chain. ROLLBACK if active explict TX then log
        data. ROLLBACK done before inserting logging related rows so
        they aren't also rolled back.

        This TX check is MariaDB specific. Best that can be done with
        MySQL is a blind ROLLBACK.
        
        NOTE
        While it is likely safe to just call ROLLBACK without MariaDB
        specific check since neither MySQL nor MariaDB supports nested
        TXs, leaving with explicit check for possible easier transition
        to a future version that does support nested transactions.
        */
        IF @@in_transaction THEN
            ROLLBACK;
        END IF;

        /*
        Flush all diagnostics area and custom data to my_diag_utils
        log files and reset session.
        */
        CALL my_diag_utils.private_flush_condition_event
        (
            _processing_block_name
        );
    END IF;

END;
$$
DELIMITER ;

SET @@sql_mode = @ehi_my_diag_utils_build_variable_old_sql_mode;
SET @ehi_my_diag_utils_build_variable_old_sql_mode = NULL;