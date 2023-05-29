# terraform

The terraform code for my small personal infrastructure.

## Resources

Currently, this will provision:
* DNS entries on Namecheap
* Alpine VPS on Linode
* OpenBSD VPS on Vultr

## Bootstrapping

This repo alone wouldn't be able to bootstrap all of its resources by itself.
If I had to start again from scratch I'd need to bootstrap some things
manually.

For instance, I use `caladan` as an http(s) proxy when applying the plans,
because `caladan` has a static IP that I can whitelist one Namecheap's and
Vultr's APIs.
My home internet does not have a static IP.
So I can't really apply the infrastructure in this repo before `caladan` is
already provisioned and configured.

So, this repo is mostly as documentation for myself and most of the time I
create resources manually and import them later to terraform.

## Wrapper scripts

I run Terrafrom through two wrapper scripts: `scripts/init.sh` and
`scripts/run_terraform`.

`scripts/init.sh` is used just to run `terraform init`. It fetches the
PostgreSQL password (from `pass`) and it passes the connection string manually
to the partially-configured pg backend.

`scripts/run_terraform` is used to run other terraform commands. It sets up the
`HTTP_PROXY` and `HTTPS_PROXY` variables to use `caladan` as a proxy. It also
fetches the secrets (from `pass`) and exports the variables for api keys and
tokens needed by the different providers.

Additionally, I also wrote a simple `Makefile` to init/plan/apply quickly.

## Backend

I use the pg backend on a PostgreSQL hosted on my NAS.

### Initializing the backend (only the first time)

Create the user (named `terraform`) and database (`terraform_backend`). The
user's password is managed with `pass`.

```sh
pass generate pg.monotremata.xyz/terraform
psql --host pg.monotremata.xyz
```

```sql
CREATE USER terraform WITH ENCRYPTED PASSWORD '****';

CREATE DATABASE terraform_backend;
GRANT ALL PRIVILEGES ON DATABASE terraform_backend TO terraform;

CREATE DATABASE terraform_lan;
GRANT ALL PRIVILEGES ON DATABASE terraform_lan TO terraform;
```
