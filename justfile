pg_user := "terraform"
# pg_host := "pg.monotremata.xyz"
pg_host := "narwhal"
pg_db := "terraform_backend"
pg_port := "5432"

passwd := `pass pg.monotremata.xyz/terraform`
# todo: I'll use this once string interpolation gets implenented in Just https://github.com/casey/just/issues/11
# conn_str := f"postgres://{{pg_user}}:{{passwd}}@{{pg_host}}:{{pg_port}}/{{pg_db}}"

export NAMECHEAP_API_KEY := `pass namecheap.com/api_key`
export LINODE_TOKEN := `pass linode.com/token`
export VULTR_API_KEY := `pass vultr.com/api_key`
export HTTP_PROXY := "caladan:8888"
export HTTPS_PROXY := "caladan:8888"
export HETZNER_DNS_API_TOKEN := `pass hetzner.com/tokens/terraform`

init:
    terraform init -backend-config="conn_str=postgres://{{pg_user}}:{{passwd}}@{{pg_host}}:{{pg_port}}/{{pg_db}}"


plan *ARGS:
    terraform plan {{ARGS}}

apply *ARGS:
    terraform apply {{ARGS}}

terraform *ARGS:
    terraform {{ARGS}}
