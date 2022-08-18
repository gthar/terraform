# terraform

The terraform code for my small personal infrastructure

## Backend

I use the pg backend on a PostgreSQL hosted on my NAS. Create the user (named
`terraform`) and database (`terraform_backend`) for it. The user's password is
managed with `pass`.

```sh
pass generate pg.monotremata.xyz/terraform
psql -u pg.monotremata.xyz
```

```sql
CREATE DATABASE terraform_backend;
CREATE USER terraform WITH ENCRYPTED PASSWORD '****';
GRANT ALL PRIVILEGES ON DATABASE terraform_backend TO terraform;
```
