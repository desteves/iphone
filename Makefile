# Makefile -- Local MongoDB Replica Set + Vector Search

.PHONY: help
help: ## Show available commands
	@grep -E '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) | \
	awk 'BEGIN{FS=":.*?## "}{printf "  %-22s %s\n", $$1, $$2}'


#     /$$                                     /$$
#    | $$                                    | $$
#    | $$        /$$$$$$   /$$$$$$$  /$$$$$$ | $$
#    | $$       /$$__  $$ /$$_____/ |____  $$| $$
#    | $$      | $$  \ $$| $$        /$$$$$$$| $$
#    | $$      | $$  | $$| $$       /$$__  $$| $$
#    | $$$$$$$$|  $$$$$$/|  $$$$$$$|  $$$$$$$| $$
#    |________/ \______/  \_______/ \_______/|__/
#
#
#
#     /$$      /$$
#    | $$$    /$$$
#    | $$$$  /$$$$  /$$$$$$  /$$$$$$$   /$$$$$$   /$$$$$$
#    | $$ $$/$$ $$ /$$__  $$| $$__  $$ /$$__  $$ /$$__  $$
#    | $$  $$$| $$| $$  \ $$| $$  \ $$| $$  \ $$| $$  \ $$
#    | $$\  $ | $$| $$  | $$| $$  | $$| $$  | $$| $$  | $$
#    | $$ \/  | $$|  $$$$$$/| $$  | $$|  $$$$$$$|  $$$$$$/
#    |__/     |__/ \______/ |__/  |__/ \____  $$ \______/
#                                      /$$  \ $$
#                                     |  $$$$$$/
#                                      \______/

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



#      /$$$$$$  /$$                           /$$
#     /$$__  $$| $$                          | $$
#    | $$  \__/| $$  /$$$$$$  /$$   /$$  /$$$$$$$
#    | $$      | $$ /$$__  $$| $$  | $$ /$$__  $$
#    | $$      | $$| $$  \ $$| $$  | $$| $$  | $$
#    | $$    $$| $$| $$  | $$| $$  | $$| $$  | $$
#    |  $$$$$$/| $$|  $$$$$$/|  $$$$$$/|  $$$$$$$
#     \______/ |__/ \______/  \______/  \_______/
#
#
#
#     /$$      /$$
#    | $$$    /$$$
#    | $$$$  /$$$$  /$$$$$$  /$$$$$$$   /$$$$$$   /$$$$$$
#    | $$ $$/$$ $$ /$$__  $$| $$__  $$ /$$__  $$ /$$__  $$
#    | $$  $$$| $$| $$  \ $$| $$  \ $$| $$  \ $$| $$  \ $$
#    | $$\  $ | $$| $$  | $$| $$  | $$| $$  | $$| $$  | $$
#    | $$ \/  | $$|  $$$$$$/| $$  | $$|  $$$$$$$|  $$$$$$/
#    |__/     |__/ \______/ |__/  |__/ \____  $$ \______/
#                                      /$$  \ $$
#                                     |  $$$$$$/
#                                      \______/
.PHONY: cloud-up
cloud-up: ## Create a secured cloud Atlas replica set
	atlas clusters create $(MONGODB_CLUSTER) \
		--projectId $(ATLAS_PROJECT_ID) \
		--provider GCP \
		--region CENTRAL_US \
		--tier M0

.PHONY: cloud-access
cloud-access: ## Whitelist local IP address for cloud cluster access
	MY_CURRENT_IP=$(curl ifconfig.me)
	atlas accessLists create $(MY_CURRENT_IP) \
		--type ipAddress \
		--projectId $(ATLAS_PROJECT_ID) \
		--comment "My local current IP address."

.PHONY: cloud-user
cloud-user: ## Create database user for cloud cluster access
	atlas dbusers create \
		--username $(MONGODB_USERNAME) \
		--password $(MONGODB_PASSWORD) \
		--projectId $(ATLAS_PROJECT_ID) \
		--role "readWrite@$(MONGODB_DATABASE)"  \
		--scope $(MONGODB_CLUSTER)
.PHONY: cloud-connect
cloud-connect: ## Open a mongosh session connected to the cloud cluster
	atlas deployments connect $(MONGODB_CLUSTER) \
		--connectWith mongosh \
		--username $(MONGODB_USERNAME) \
		--password $(MONGODB_PASSWORD) \
		--projectId $(ATLAS_PROJECT_ID)

.PHONY: cloud-vector-index
cloud-vector-index: ## Create or update the vector search index
	atlas clusters search indexes create \
		--clusterName $(MONGODB_CLUSTER) \
		--projectId $(ATLAS_PROJECT_ID) \
		--file "vectorIndex.json"

.PHONY: cloud-audit
cloud-audit: ## Audit cloud cluster for security issues
	atlas auditing update \
	--projectId $(ATLAS_PROJECT_ID) \
	--enabled \
	--auditFilter '{}' \
	--auditAuthorizationSuccess
