IMAGE_NAME = fluvio:sdf
WORKER_NAME = docker-worker
SDF_WORKER = sdf-worker

default: help
up: build compose
build:
	docker build -t $(IMAGE_NAME) .
compose:
	docker-compose up
	fluvio profile add sdf-docker 127.0.0.1:9103  docker
	sdf worker register $(WORKER_NAME) $(SDF_WORKER)

ifneq ($(MAKECMDGOALS),)
    ifeq ($(MAKECMDGOALS), connector)
        ifeq ($(config),)
            $(error You must specify a connector. Usage: make connector config=<ex. connector.yaml>)
        endif
    endif
endif
connector:
	docker cp manage_docker.sh connector:/fluvio/
	docker cp $(config) connector:/fluvio/
	docker exec connector sh -c "./manage_docker.sh start $(shell basename $(config))"

ifneq ($(MAKECMDGOALS),)
    ifeq ($(MAKECMDGOALS), shutdown)
        ifeq ($(name),)
            $(error You must specify a running connector. Usage make shutdown name=<...>)
        endif
    endif
endif
shutdown_conn:
	docker cp manage_docker.sh connector:/fluvio/
	docker exec connector sh -c "./manage_docker.sh shutdown $(name)"

clean_conn:
	docker cp manage_docker.sh connector:/fluvio/
	docker exec connector ./manage_docker.sh clean

stat_conn:
	docker cp manage_docker.sh connector:/fluvio/

ifneq ($(MAKECMDGOALS),)
    ifeq ($(MAKECMDGOALS), batch)
        ifeq ($(folder),)
            $(error You must specify a running connector. Usage make batch folder=<...>)
        endif
    endif
endif
batch:
	docker cp manage_docker.sh connector:/fluvio/
	find A_conn -type f -exec make connector config={} \;

clean:
	docker-compose down
	docker volume prune

help:
	@echo "Usage: make <target> [arguments]"
	@echo ""
	@echo "Targets:"
	@echo "  \033[1mup\033[0m                 Initializes the Fluvio cluster "
	@echo ""
	@echo "  \033[1mconnector\033[0m          Starts a specific connector defined by a configuration file."
	@echo "                     Arguments: config=<path_to_config>"
	@echo "                     Example: make connector config=<path-to-file>"
	@echo ""
	@echo "  \033[1mshutdown\033[0m           Shuts down a specific connector by name."
	@echo "                     Arguments: name=<connector_name>"
	@echo "                     Example: make shutdown name=<my_connector>"
	@echo ""
	@echo "  \033[1mbatch\033[0m              Starts all connectors defined in the specified folder, attempting to run all .yaml files."
	@echo "                     Arguments: folder=<path_to_folder>"
	@echo "                     Example: make batch folder=<path/to/connectors>"
	@echo ""
	@echo "  \033[1mclean_conn\033[0m         Deletes all connectors, including any currently running ones."
	@echo ""
	@echo "  \033[1mstat_conn\033[0m          Shows the status of all connectors, including active and inactive connectors."
	@echo ""
	@echo "  \033[1mclean\033[0m              Cleans up the entire Docker Compose environment"
.PHONY: all build up profile register update clean
