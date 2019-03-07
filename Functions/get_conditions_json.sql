SET @ehi_my_diag_utils_build_variable_old_sql_mode = @@sql_mode;
SET @@sql_mode = 'TRADITIONAL,ONLY_FULL_GROUP_BY,IGNORE_SPACE,'
    'NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION';

DELIMITER $$
CREATE OR REPLACE
    DEFINER = 'my_diag_utils'@'localhost'
    FUNCTION my_diag_utils.get_conditions_json()
    RETURNS JSON
    LANGUAGE SQL
    NOT DETERMINISTIC
    CONTAINS SQL
    SQL SECURITY INVOKER
    COMMENT
"Created by Kevin Stephenson, 2019-02-25.

Aggregate all current diagnostic area conditions into a JSON array of
condition objects.

USAGE NOTES
Must only be called while the diagnostics area is populated with one or
more conditions."
BEGIN

    DECLARE _conditions_json JSON;
    DECLARE _condition_quantity, _current_condition_value SMALLINT UNSIGNED;

    DECLARE _sql_state_code CHAR(5);
    DECLARE _mysql_error_code INT; 
    DECLARE _message_text VARCHAR(512);

    GET DIAGNOSTICS _condition_quantity = NUMBER;

    -- Assert at least 1 condition.
    IF _condition_quantity < 1 THEN
        CALL my_diag_utils.reset_session();

        SIGNAL SQLSTATE '45000'
            SET
                MESSAGE_TEXT =
                    'my_diag_utils.get_condition_event_json: '
                    'Called with no conditions found.';
    END IF;

    SET _conditions_json = JSON_ARRAY();
    SET _current_condition_value = 1;

    WHILE _current_condition_value <= _condition_quantity DO
        GET DIAGNOSTICS CONDITION _current_condition_value
            _sql_state_code = RETURNED_SQLSTATE,
            _mysql_error_code = MYSQL_ERRNO,
            _message_text = MESSAGE_TEXT;

        SET _conditions_json = JSON_ARRAY_APPEND
        (
            _conditions_json,
            '$',
            JSON_OBJECT
            (
                'conditionValue', _current_condition_value,
                'sqlStateCode', _sql_state_code,
                'mySqlErrorCode', _mysql_error_code,
                'messageText', _message_text
            )
        );

        SET _current_condition_value = _current_condition_value + 1;
    END WHILE;

    RETURN _conditions_json;

END;
$$
DELIMITER ;

SET @@sql_mode = @ehi_my_diag_utils_build_variable_old_sql_mode;
SET @ehi_my_diag_utils_build_variable_old_sql_mode = NULL;