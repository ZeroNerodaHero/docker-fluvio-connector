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

start_conn:
	docker cp manage_docker.sh connector:/fluvio/
	docker cp $(config) connector:/fluvio/
	docker exec connector sh -c "./manage_docker.sh start $(shell basename $(config))"

clean_conn:
	docker cp manage_docker.sh connector:/fluvio/
	docker exec connector ./manage_docker.sh clean

stat_conn:
	docker cp manage_docker.sh connector:/fluvio/
	docker exec connector ./manage_docker.sh status

clean:
	docker-compose down
	docker volume prune
.PHONY: all build up profile register update clean
