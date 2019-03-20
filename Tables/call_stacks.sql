CREATE TABLE my_diag_utils.call_stacks (
    event_id INT UNSIGNED NOT NULL,
    reverse_call_stack_level_value TINYINT UNSIGNED NOT NULL,
    processing_block_name VARCHAR(194) NOT NULL,
    details_json JSON NULL,

    PRIMARY KEY (event_id, reverse_call_stack_level_value),

    CONSTRAINT fk_my_diag_utils_call_stacks_condition_events
        FOREIGN KEY (event_id)
        REFERENCES my_diag_utils.condition_events(event_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT ck_validate_details_json CHECK (JSON_VALID(details_json))

)
ENGINE = INNODB,
COMMENT =
"This is not a true call stack, but rather a stack, in reverse order,
of code blocks (blocks) that handle conditions using DECLARE HANDLER.

The first block to handle conditions has a reverse_call_stack_level_value
of 1, its parent that handles the resignaled conditions has 2, and so on
up to the top-most block that handles conditions. All blocks must use the
condition handler to make the call stack complete, otherwise the table
will have unidentified gaps as a side-effect of MySQL not having a nest
level type metadata function that could be used for gap detection.

details_json is technically schemaless, but typical usage will
have an object of KVPs representing processing block arguments (for
routines), local variables, user-defined variables, and possibly
small resultsets (e.g. from temp tables) stored as nested arrays.

MariaDB doesn't support a validating JSON data type so a check was added.
MySQL JSON data type is validated.";
