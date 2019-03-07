CREATE TABLE my_diag_utils.conditions (
    event_id INT UNSIGNED NOT NULL,
    condition_value SMALLINT UNSIGNED NOT NULL,
    sql_state_code CHAR(5) NOT NULL,
    mysql_error_code INT NOT NULL,
    message_text VARCHAR(512) NOT NULL,

    PRIMARY KEY (event_id, condition_value),

    CONSTRAINT fk_my_diag_utils_conditions_condition_events
        FOREIGN KEY (event_id)
        REFERENCES my_diag_utils.condition_events(event_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
)
ENGINE = INNODB,
COMMENT
"Depending on the MySQL or MariaDB version, the other data elements
available in GET DIAGNOSTICS are either missing or of low value
(mainly redundant) and hence are not logged as of now.";