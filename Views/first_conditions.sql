CREATE OR REPLACE
    ALGORITHM = UNDEFINED
    DEFINER = 'my_diag_utils'@'localhost'
    SQL SECURITY DEFINER
    VIEW my_diag_utils.first_conditions AS

    SELECT
        condition_events.event_id,
        condition_events.event_timestamp,
        conditions.sql_state_code,
        conditions.mysql_error_code,
        condition_events.estimated_signaling_block_name,
        conditions.message_text,
        condition_events.flushing_block_name
    FROM
        my_diag_utils.condition_events AS condition_events
        INNER JOIN
            my_diag_utils.conditions AS conditions
        ON
            condition_events.event_id = conditions.event_id
    WHERE
        conditions.condition_value = 1;
