# Docker Fluvio Connector
This repo contains a dockerfile, docker compose file, and a shell script with a make file for managing fluvio clusters.

1. `up`: will generate a fluvio image as well as the necessary sc,spus and workers
2. Connectors can be started, cleaned or shown stat with the make commands
- `start_conn`: Starts a connector. Requires the connector file to be included.
  - Ex. `make start_conn config=A_conn/mqtt-helsinki.yaml`
- `clean_conn`: Deletes all connectors. Even running ones
- `stat_conn`: Returns the status of all connectors
