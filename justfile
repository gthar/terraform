export TF_VAR_pg_passwd := `pass pg.monotremata.xyz/terraform`
export TF_VAR_minio_root_user := "rilla"
export TF_VAR_minio_root_password := `pass minio.monotremata.xyz/rilla`

export LINODE_TOKEN := `pass linode.com/token`
export VULTR_API_KEY := `pass vultr.com/api_key`
export HETZNER_DNS_API_TOKEN := `pass hetzner.com/tokens/terraform`
export MINIO_PASSWORD := `pass minio.monotremata.xyz/terraform`

init:
    terraform init \
        -backend-config="access_key=terraform" \
        -backend-config="secret_key=$MINIO_PASSWORD"

plan *ARGS:
    terraform plan {{ARGS}}

apply *ARGS:
    terraform apply {{ARGS}}

terraform *ARGS:
    terraform {{ARGS}}
