# Loki and Promtail

This Compose stack runs Loki for log storage and Promtail for collecting
Docker's JSON log files. The Promtail configuration expects a Linux Docker
host that stores container logs under
`/var/lib/docker/containers/*/*-json.log` and uses the `json-file` logging
driver.

## Start and check the stack

From this directory, run:

```sh
docker compose up -d
docker compose ps
curl --fail http://localhost:3100/ready
```

Promtail sends entries to Loki at `http://loki:3100`. Loki's HTTP API is
published on port 3100 of the host. Query labels with:

```sh
curl --fail 'http://localhost:3100/loki/api/v1/labels'
```

For example, use Grafana Explore with Loki as a data source at
`http://loki:3100` and query `{job="docker"}`.

Stop the services with `docker compose down`. The `loki-data` volume persists
Loki data; remove it explicitly with `docker compose down --volumes` only when
you intend to delete stored logs.

## Notes

- This configuration is intended for local development, not production.
- Promtail needs read access to the Docker container log directory. Hosts with
  a different Docker data root or logging driver need a corresponding
  `promtail-config.yaml` update.
- The Docker socket mount is not needed for static file discovery and can be
  removed if the deployment policy prohibits exposing it to the Promtail
  container.
