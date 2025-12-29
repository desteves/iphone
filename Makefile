# Makefile -- Local MongoDB Replica Set + Vector Search

.PHONY: help
help: ## Show available commands
	@grep -E '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) | \
	awk 'BEGIN{FS=":.*?## "}{printf "  %-22s %s\n", $$1, $$2}'

.PHONY: local-up
local-up: ## Create a secured local Atlas replica set
	atlas deployments setup $(MONGODB_CLUSTER)  \
	  --type LOCAL \
		--username $(MONGODB_USERNAME) \
		--password $(MONGODB_PASSWORD) \
		--force

.PHONY: local-connect
local-connect: ## Open a mongosh session connected to the local cluster
	atlas deployments connect $(MONGODB_CLUSTER) \
	  --type LOCAL \
		--connectWith mongosh \
		--username $(MONGODB_USERNAME) \
		--password $(MONGODB_PASSWORD)


.PHONY: vector-index
vector-index: ## Create or update the vector search index
	atlas deployments search indexes create $(VECTOR_INDEX_NAME) \
		--deploymentName $(MONGODB_CLUSTER) \
		--file $(VECTOR_INDEX_FILE) \
		--type LOCAL \
		--username $(MONGODB_USERNAME) \
		--password $(MONGODB_PASSWORD)

.PHONY: local-delete
local-delete: ## Stop and delete local Atlas deployment
	atlas deployments delete $(MONGODB_CLUSTER) --local --force
