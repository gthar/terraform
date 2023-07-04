export TF_VAR_hetzner_token := `pass hetzner.com/tokens/suricata`
export TF_VAR_pg_passwd := `pass pg.monotremata.xyz/terraform`
export TF_VAR_minio_root_user := "rilla"
export TF_VAR_minio_root_password := `pass minio.monotremata.xyz/rilla`

export LINODE_TOKEN := `pass linode.com/token`
export VULTR_API_KEY := `pass vultr.com/api_key`
export HETZNER_DNS_API_TOKEN := `pass hetzner.com/tokens/terraform`

minio_access_key := `pass minio.monotremata.xyz/terraform/access_key`
minio_secret_key := `pass minio.monotremata.xyz/terraform/secret_key`

init:
    terraform init \
        -backend-config="access_key={{minio_access_key}}" \
        -backend-config="secret_key={{minio_secret_key}}"

plan *ARGS:
    terraform plan {{ARGS}}

apply *ARGS:
    terraform apply {{ARGS}}

terraform *ARGS:
    terraform {{ARGS}}
