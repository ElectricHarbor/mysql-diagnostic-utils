# MySQL Diagnostic Utilities
MySQL and MariaDB utilities and patterns for printing and logging profile, trace, debug, note, warn and error diagnostics.

## Features
* Log conditions and the full call stack of nested routines and nested blocks to tables.
* Print (aka SELECT) and/or trace (write to table) routine debugging and profiling information.
* Assign request tracking ids to logged conditions and traces. (Assist in full-stack debugging.)

## Requirements
MariaDB 10.2.7+ with SEQUENCE Storage Engine installed.

## Installation
This is a dbForge Studio for MySQL project. A more portable install script will be released at a later time.

Role my_diag_utils_role is used for access to the public API of this library. /Scripts/Create Role.sql sets 'root'@'localhost' as the role admin by default. Change as necessary.

## Basic Example

    GRANT my_diag_utils_role TO <principal>;

    DELIMITER $$
    CREATE
        DEFINER = <principal>
        PROCEDURE my_schema.my_procedure()
        SQL SECURITY DEFINER
    BEGIN

        DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
			SET ROLE my_diag_utils_role; -- Required only if <principal> is a user. Remove if <principal> is a role.
            CALL my_diag_utils.process_conditions('my_schema.my_procedure', NULL);
        END;

        CALL my_diag_utils.configure_simple_session('my_schema.my_procedure');

        -- Code that may signal. Test with SIGNAL SQLSTATE '45000';

        CALL my_diag_utils.reset_session();

    END;
    $$
    DELIMITER ;

    SELECT * FROM my_diag_utils.first_conditions;

## Copyright
Copyright (c) 2019, Electric Harbor, Inc. All rights reserved.

## License
Licensed under GPLv2. See LICENSE file.