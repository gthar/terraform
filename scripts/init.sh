#!/bin/sh

PG_USER=terraform
PG_HOST=pg.monotremata.xyz
PG_DB=terraform_backend
PG_PORT=5432

passwd=$(pass "${PG_HOST}/${PG_USER}")
conn_str="postgres://${PG_USER}:${passwd}@${PG_HOST}:${PG_PORT}/${PG_DB}"

terraform init -backend-config="conn_str=${conn_str}"
