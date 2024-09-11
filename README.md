# PostgreSQL Help

Flask app for comparing help contents of different versions of PostgreSQL.

Something like this:
```
ABORT                                            ABORT
postgres_11.16                                   postgres_12.0
+-------------------------------------------+    +--------------------------------------------------------+
|Command:     ABORT                         |    |Command:     ABORT                                      |
|Description: abort the current transaction |    |Description: abort the current transaction              |
|Syntax:                                    |    |Syntax:                                                 |
|ABORT [ WORK | TRANSACTION ]               |    |ABORT [ WORK | TRANSACTION ] [ AND [ NO ] CHAIN ]       |
|                                           |    |                                                        |
|                                           |    |URL: https://www.postgresql.org/docs/12/sql-abort.html  |
+-------------------------------------------+    +--------------------------------------------------------+
:                                                :
```

## Usage

```bash
$ docker run --rm -dp 5000:5000 ghcr.io/ba230t/postgresql_help
$ open http://localhost:5000    # Then select the PostgreSQL versions and click "Compare" button.
```
