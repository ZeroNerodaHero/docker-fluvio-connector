IMAGE_NAME = fluvio:sdf
WORKER_NAME = docker-worker
SDF_WORKER = sdf-worker

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
.PHONY: all build up profile register update clean
