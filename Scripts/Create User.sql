/*
Creates a user to be used as the definer for Diagnostics schema routines.

CREATE USER IF NOT EXISTS supported in MariaDB 10.1.3+ and
unknown MySQL version but at least 5.7.

MySQL 5.7+.
    ACCOUNT LOCK can be used to create an account with no password
    that can't login but can still be used as a DEFINER for security checks.
        CREATE USER IF NOT EXISTS 'Diagnostics'@'localhost' ACCOUNT LOCK;

MariaDB up to at least 10.3.12. See Installation Notes.
    Dynamic SQL required to use noise password as CREATE USER
    doesn't allow variables in user specification.

Random Noise Passwords
    MySQL - Unknown Version
        SET @noise_password = SHA2(CONVERT(RANDOM_BYTES(32), char), 256);

    MariaDB 10.4
        RANDOM_BYTES not supported in MariaDB up 10.3.12, and likely not in 10.4 either.
        Workaround technique used below is from here:
        https://stackoverflow.com/questions/39257391/how-do-i-generate-a-unique-random-string-for-one-of-my-mysql-table-columns
*/

-- Creates 32 random alphanumeric (uppercase only) characters. See ref above.
SET @ehi_my_diag_utils_build_variable_noise_password = CONCAT(
    LPAD(CONV(FLOOR(RAND()*POW(36,8)), 10, 36), 8, 0),
    LPAD(CONV(FLOOR(RAND()*POW(36,8)), 10, 36), 8, 0),
    LPAD(CONV(FLOOR(RAND()*POW(36,8)), 10, 36), 8, 0),
    LPAD(CONV(FLOOR(RAND()*POW(36,8)), 10, 36), 8, 0)
);

SET @ehi_my_diag_utils_build_variable_create_user =
    CONCAT
    (
        'CREATE USER IF NOT EXISTS \'my_diag_utils\'@\'localhost\' IDENTIFIED BY \'',
        @ehi_my_diag_utils_build_variable_noise_password,
        '\';'
    ); # compatible with ANSI_QUOTES enabled
PREPARE stmt FROM @ehi_my_diag_utils_build_variable_create_user;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Cleanup session variables. Unable to delete as of MySQL 8.0.12, MariaDB 10.3.12.
SET @ehi_my_diag_utils_build_variable_noise_password = NULL;
SET @ehi_my_diag_utils_build_variable_create_user = NULL;
