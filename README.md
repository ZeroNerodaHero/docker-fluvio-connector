# Docker Fluvio Connector
This repo contains a dockerfile, docker compose file, and a shell script with a make file for managing fluvio clusters.
The make and shell file should be able to automatically download all packages and smartmodules required from the connector file.

1. `up`: will generate a fluvio image as well as the necessary sc,spus and workers
2. Connectors can be started, cleaned or shown stat with the make commands
- `connector`: Starts a connector. Requires the connector file to be included.
  - Ex. `make connector config=A_conn/mqtt-helsinki.yaml`
- `shutdown`: Deletes on connector. Pass in the name
  - Ex. `make shutdown name=<...>`
- `batch`: Starts up all the connectors in folder. Attempts to run all `.yaml` files.
  - Ex. `make batch folder=<...>`
- `clean_conn`: Deletes all connectors. Even running ones
- `stat_conn`: Returns the status of all connectors
3. `clean`: cleans the whole compose
