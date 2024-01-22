An upgrade can be done in three different ways, documented here: https://www.postgresql.org/docs/current/upgrading.html

A dump/reload of the database or use of the pg_upgrade module is required for major upgrades.
Can use pg_upgrade for major release updates that don't change the internal storage format. If the format has changed, this module will not be usable.
pg_upgrade supports upgrades from PG 9.2.X to the current major release version.
pg_upgrade should only take minutes.
We should create a DB backup before attempting the upgrade, for our own completeness.
Release change log: https://www.postgresql.org/docs/current/release.html
Can upgrade from one to another without upgrading to intervening versions, but should pay attention to the release notes of each
Can set up concurrent versions to test side by side and ensure new version is as


We chose to use the pg_upgrade method as it was most complete and done exactly what we needed. Some of the typical error messages and the resolutions that worked for us are documented below.

Cluster Compatibility Check
Each time we ran a check, the below lines were output immediately after the command, to save on filler text, I will emit these from each of the error outputs.

Performing Consistency Checks on Old Live Server
------------------------------------------------
Checking cluster versions


Error 1

connection to database failed: fe_sendauth: no password supplied

could not connect to target postmaster started with the command:


This was happening due to the access method specified in ph_hba.conf for PG10, once we changed it from 'md5' to 'peer', we were able to move by this issue.





Error 2

The source cluster was not shut down cleanly.

To move beyond this, we can simply start up the server and stop it again to ensure it shuts down cleanly. This can be done using the following 2 commands:

"C:\Program Files\PostgreSQL\10\bin\pg_ctl.exe" -D "C:\Program Files\PostgreSQL\10\data" start
"C:\Program Files\PostgreSQL\10\bin\pg_ctl.exe" -D "C:\Program Files\PostgreSQL\10\data" stop




Error 3

connection to server at "localhost" (127.0.0.1), port 50432 failed: FATAL:  role "<username>" does not exist 
The resolution to this was to create a role with my username in the postgres cluster and give it superuser access so it could perform the actions needed.




Error 4

When checking a live server, the old and new port numbers must be different.

This issue came from running the compatibilty check as it was testing two clusters and attempting to use the same port. 
The resolution is to pass specific ports to via the check command, however this is not needed when running the actual update command as the two clusters do not run side by side and therefore just one port can be used.
The below command includes the specific ports for use in checking.


"C:\Program Files\PostgreSQL\15\bin\pg_upgrade.exe" -b "C:\Program Files\PostgreSQL\10\bin" -B "C:\Program Files\PostgreSQL\15\bin" -d "C:\Program Files\PostgreSQL\10\data" -D "C:\Program Files\PostgreSQL\15\data" -c -p 51432 -P 50432



Error 5

database user "<username>" is not the install user

This error related back to when I created my own role within Postgres. The more appropriate and quicker solution, which provides all permissions for database modification is to pass the postgres user as part of the command.



"C:\Program Files\PostgreSQL\15\bin\pg_upgrade.exe" -b "C:\Program Files\PostgreSQL\10\bin" -B "C:\Program Files\PostgreSQL\15\bin" -d "C:\Program Files\PostgreSQL\10\data" -D "C:\Program Files\PostgreSQL\15\data" -c -p 51432 -P 50432 -U postgres




Error 6
Once we got this far, we were able to see a lot more of the checks passing showing that the clusters were nearly compatible. We did run into the below password error again though, which required a different solution.

connection to server at "localhost" (127.0.0.1), port 50432 failed: fe_sendauth: no password supplied


To move on from this, we added a new line in each of the PG10 and PG15 pg_hba.conf files to specific the access encryption to use specifically for the postgres user.



In the connection settings of PG10's pg_hba.conf, we added the following:

host    all             postgres        127.0.0.1/32            trust


And in the connection settings of PG15's pg_hba.conf, we added this:

host    all             postgres        127.0.0.1/32            trust




Compatible:

Completing the above then resulted in us knowing the two clusters were compatible.

Performing Consistency Checks
-----------------------------
Checking cluster versions                                                ok
Checking database user is the install user                               ok
Checking database connection settings                                    ok
Checking for prepared transactions                                       ok
Checking for system-defined composite types in user tables               ok
Checking for reg* data types in user tables                              ok
Checking for contrib/isn with bigint-passing mismatch                    ok
Checking for user-defined encoding conversions                           ok
Checking for user-defined postfix operators                              ok
Checking for incompatible polymorphic functions                          ok
Checking for tables WITH OIDS                                            ok
Checking for invalid "sql_identifier" user columns                       ok
Checking for presence of required libraries                              ok
Checking database user is the install user                               ok
Checking for prepared transactions                                       ok
Checking for new cluster tablespace directories                          ok

*Clusters are compatible*

Upgrading the Cluster
These are the steps I followed to upgrade the cluster from v10 to v15 via Windows CMD:



1. The below notes should be used in parallel and to compliment the steps in the Usage section here: https://www.postgresql.org/docs/current/pgupgrade.html
2. Download PG 15 via choco:
	choco install postgresql15 --params '/Password:XXX'
3. Make a backup dump of the PG cluster before going any further:
	a. docs: https://www.postgresql.org/docs/current/backup-dump.html#BACKUP-DUMP-ALL
	b. Use the postgres user when creating it
	c. Create a PostgreSQL folder within D:\Temp
	d. The dumpall file name should be in the following format D:\Temp\PostgreSQL\pg<X>_dumpall_<datetime>
		§ X being the PostgreSQL version the dump corresponds to
		§ datetime following the UTC datetime format, YYYYMMDDHHMMSS
		§ may be asked for a password for each DB, this won't happen if you have created a password file (.pgpass) for the postgres user in C:\Users\postgres\
	○ "C:\Program Files\PostgreSQL\10\bin\pg_dumpall" > D:\Temp\PostgreSQL\pg10_dumpall_<datetime> -U postgres
4. The server can be stopped/started with the below commands:
	○ "C:\Program Files\PostgreSQL\10\bin\pg_ctl.exe" -D "C:\Program Files\PostgreSQL\10\data" start
	○ "C:\Program Files\PostgreSQL\10\bin\pg_ctl.exe" -D "C:\Program Files\PostgreSQL\10\data" stop
5. Navigate to PostgreSQL/10/data and update PG10 IPv4/IPv6 settings for the postgres user in pg_hba.conf:
	# IPv4 local connections:
	host    all             postgres        127.0.0.1/32            trust
	host    all             all             127.0.0.1/32            md5
	# IPv6 local connections:
	host    all             postgres        ::1/128                 trust
	host    all             all             ::1/128                 md5
6. Navigate to PostgreSQL/15/data and update PG15 IPv4/IPv6 settings for the postgres user in pg_hba.conf:
	# IPv4 local connections:
	host    all             postgres        127.0.0.1/32            trust
	host    all             all             127.0.0.1/32            scram-sha-256
	# IPv6 local connections:
	host    all             postgres        ::1/128                 trust
	host    all             all             ::1/128                 scram-sha-256
7. Run consistency checks between the two clusters before running the upgrade:
	"C:\Program Files\PostgreSQL\15\bin\pg_upgrade.exe" -b "C:\Program Files\PostgreSQL\10\bin" -B "C:\Program Files\PostgreSQL\15\bin" -d "C:\Program Files\PostgreSQL\10\data" -D "C:\Program Files\PostgreSQL\15\data" -c -p 51432 -P 50432 -U postgres
8. If the DB isn't initialized by the pre-built installer, (it should be), then initialize the new DB using a command like:
	"C:\Program Files\PostgreSQL\15\bin\initdb.exe" -D "C:\Program Files\PostgreSQL\10\data"
9. Run the upgrade command
	"C:\Program Files\PostgreSQL\15\bin\pg_upgrade.exe" -b "C:\Program Files\PostgreSQL\10\bin" -B "C:\Program Files\PostgreSQL\15\bin" -d "C:\Program Files\PostgreSQL\10\data" -D "C:\Program Files\PostgreSQL\15\data" -U postgres
10. Revert any configuration changes made, in pg_hba.conf specifically. 
11. Start the server on each node:
	"C:\Program Files\PostgreSQL\15\bin\pg_ctl.exe" -D "C:\Program Files\PostgreSQL\15\data" start
12. Run the recommended command after the upgrade for stats optimization:
	"C:\Program Files\PostgreSQL\15\bin\vacuumdb" -U postgres --all --analyze-in-stages

13. When trying to log in to new DB, got the below error in the log file:
	2024-01-16 11:53:52.366 EST [4056] FATAL:  password authentication failed for user "postgres"
	2024-01-16 11:53:52.366 EST [4056] DETAIL:  User "postgres" does not have a valid SCRAM secret.
	a. Need to uncomment the password encryption on line 96 in postgresql.conf
	b. Old passwords need to be updated to use SCRAM. This needs to be done on each server.
	c. Using this article, update the passwords: https://www.crunchydata.com/blog/how-to-upgrade-postgresql-passwords-to-scram
		i. Set auth to trust for postgres user in pg_hba.conf
		ii. Log into psql with the postgres user
		iii. Check users that need a password updated
		iv. Action the password update as per the doc
14. Once all users passwords have been upgraded to use SCRAM, we need to reload the server.
	"C:\Program Files\PostgreSQL\15\bin\pg_ctl.exe" -D "C:\Program Files\PostgreSQL\15\data" reload
15. If a restart is needed of the server, do so. This should be the upgrade complete.
16. Check PGAdmin to verify data has been migrated correctly.




As we started to upgrade, we quickly got an error when starting up the new cluster, which had an output like below:

Creating dump of database schemas
                                                            ok

*failure*
Consult the last few lines of "C:/Program Files/PostgreSQL/15/data/pg_upgrade_output.d/20240115T092242.306/log/pg_upgrade_server_start.log" or "pg_upgrade_server.log" for
the probable cause of the failure.

connection to server at "localhost" (127.0.0.1), port 50432 failed: Connection refused (0x0000274D/10061)
        Is the server running on that host and accepting TCP/IP connections?
connection to server at "localhost" (::1), port 50432 failed: Connection refused (0x0000274D/10061)
        Is the server running on that host and accepting TCP/IP connections?

could not connect to target postmaster started with the command:
"C:/Program Files/PostgreSQL/15/bin/pg_ctl" -w -l "C:/Program Files/PostgreSQL/15/data/pg_upgrade_output.d/20240115T092242.306/log/pg_upgrade_server.log" -D "C:/Program Files/PostgreSQL/15/data" -o "-p 50432 -b -c synchronous_commit=off -c fsync=off -c full_page_writes=off -c vacuum_defer_cleanup_age=0 " start
Failure, exiting

The issue was trying to start up the new PG cluster with the command shown in the error.

When trying to run that command manually, and rechecking the log, this gave a better indication to the error. In this instance it was retrieving an invalid checkpoint when trying to start the server.

The solution was to reset the write-ahead log to a valid point (by running pg_resetwal on the PG 15 cluster), which allowed the server to be starter & stopped correctly. With it then stopped again, I reran the pg_upgrade command and it ran completely and successfully with output underneath the steps listed below.



Successful Upgrade
Once the server has been upgraded successfully, we should see output similar to the below:

Performing Consistency Checks
-----------------------------
Checking cluster versions                                   ok
Checking database user is the install user                  ok
Checking database connection settings                       ok
Checking for prepared transactions                          ok
Checking for system-defined composite types in user tables  ok
Checking for reg* data types in user tables                 ok
Checking for contrib/isn with bigint-passing mismatch       ok
Checking for user-defined encoding conversions              ok
Checking for user-defined postfix operators                 ok
Checking for incompatible polymorphic functions             ok
Checking for tables WITH OIDS                               ok
Checking for invalid "sql_identifier" user columns          ok
Creating dump of global objects                             ok
Creating dump of database schemas
                                                            ok
Checking for presence of required libraries                 ok
Checking database user is the install user                  ok
Checking for prepared transactions                          ok
Checking for new cluster tablespace directories             ok

If pg_upgrade fails after this point, you must re-initdb the
new cluster before continuing.

Performing Upgrade
------------------
Analyzing all rows in the new cluster                       ok
Freezing all rows in the new cluster                        ok
Deleting files from new pg_xact                             ok
Copying old pg_xact to new server                           ok
Setting oldest XID for new cluster                          ok
Setting next transaction ID and epoch for new cluster       ok
Deleting files from new pg_multixact/offsets                ok
Copying old pg_multixact/offsets to new server              ok
Deleting files from new pg_multixact/members                ok
Copying old pg_multixact/members to new server              ok
Setting next multixact ID and offset for new cluster        ok
Resetting WAL archives                                      ok
Setting frozenxid and minmxid counters in new cluster       ok
Restoring global objects in the new cluster                 ok
Restoring database schemas in the new cluster
                                                            ok
Copying user relation files
                                                            ok
Setting next OID for new cluster                            ok
Sync data directory to disk                                 ok
Creating script to delete old cluster                       ok
Checking for extension updates                              notice

Your installation contains extensions that should be updated
with the ALTER EXTENSION command.  The file
    update_extensions.sql
when executed by psql by the database superuser will update
these extensions.


Upgrade Complete
----------------
Optimizer statistics are not transferred by pg_upgrade.
Once you start the new server, consider running:
    "C:/Program Files/PostgreSQL/15/bin/vacuumdb -U postgres --all --analyze-in-stages"

Running this script will delete the old cluster's data files:
    delete_old_cluster.bat
