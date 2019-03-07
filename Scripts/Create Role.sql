/*
As of MySQL 8.0.12 and MariaDB 10.3.12 there is no secure way
to grant execute permissions to all authenticated users. Workaround
is to use explicit execute grants for specific user/hostname (hostname wildcard ok)
pairs or use roles. This library uses a role.

Roles were introduced in MariaDB 10.0.5 and MySQL 8.0.0.

There are differences in implementation between the platforms.

This is the most verbose syntax for MariaDB but is causing a build error
in dbForge 8.1.22 as it doesn't recognize the WITH clause:
CREATE ROLE IF NOT EXISTS my_diag_utils_role WITH ADMIN 'root'@'%';

The statements used below set the role administrator to CURRENT_USER
by default which may be @localhost, causing future issues when trying
to GRANT the role to other users when not connected from localhost.

The pair of CREATE ROLE and GRANT ... WITH ADMIN OPTION work on
both platforms with immediate user validity checking whereas
MariaDB CREATE ROLE ... WITH ADMIN ...; uses delayed validation.

MariaDB does not allow setting a noise name for the host to
disambiguate between the my_diag_utils user and role like MySQL allows,
so to prevent issues the _role suffix has been used.
*/
CREATE ROLE IF NOT EXISTS my_diag_utils_role;
GRANT my_diag_utils_role TO 'root'@'localhost' WITH ADMIN OPTION;

