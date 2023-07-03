SRC_DIR=tf
SRC=$(shell find $(SRC_DIR) -type f -name "*.tf")

TERRAFORM=terraform -chdir=$(SRC_DIR)

PG_USER=terraform
PG_HOST=pg.monotremata.xyz
PG_DB=terraform_backend
PG_PORT=5432
PG_PASSWD=$(shell pass "$(PG_HOST)/$(PG_USER)")
PG_CONN_STR=postgres://$(PG_USER):$(PG_PASSWD)@$(PG_HOST):$(PG_PORT)/$(PG_DB)

LINODE_TOKEN=$(shell pass linode.com/token)
VULTR_API_KEY=$(shell pass vultr.com/api_key)

HTTP_PROXY=caladan:8888
HTTPS_PROXY=caladan:8888

export HTTP_PROXY
export HTTPS_PROXY

export LINODE_TOKEN
export VULTR_API_KEY

.PHONY: apply clean

apply: $(SRC_DIR)/tfplan $(SRC)
	$(TERRAFORM) apply $(<F)

$(SRC_DIR)/tfplan: $(SRC_DIR)/tfinit $(SRC)
	$(TERRAFORM) plan -out=$(@F)

$(SRC_DIR)/tfinit: $(SRC)
	$(TERRAFORM) init -backend-config="conn_str=$(PG_CONN_STR)"
	@touch $@

clean:
	rm -f $(SRC_DIR)/tfplan $(SRC_DIR)/tfinit
