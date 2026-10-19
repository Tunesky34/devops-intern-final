# Loki, Promtail, and Grafana

The Compose stack runs the assessment NGINX image, Loki, Promtail, and Grafana.
Promtail discovers only Docker containers carrying the `promtail.scrape=true`
label and reads their Docker `json-file` logs. The Compose NGINX service has
that label; unrelated containers on the host are excluded.

## Start and verify

From the repository root, run:

```sh
cd monitoring
APP_PORT=18080 docker compose up --build -d
docker compose ps
curl --fail http://localhost:3100/ready
curl --fail http://localhost:3000/api/health
curl --include http://localhost:18080/not-found
```

`APP_PORT` changes the host-side NGINX port if 8080 is already occupied. It
does not change the port inside the container. Grafana is at
<http://localhost:3000>; use `admin` / `dev-only-change-me` for this local
development stack only. The Loki datasource is provisioned from
`grafana-datasources.yaml`.

Expected observations from the verified run:

- Loki `/ready` returned `ready`.
- Grafana `/api/health` returned status `ok` for Grafana 11.2.0.
- `/not-found` returned HTTP 404 and wrote an NGINX access log.

## Labels and LogQL evidence

Promtail applies these labels to the stream:

| Label | Example |
| --- | --- |
| `job` | `nginx-app` |
| `container` | `monitoring-nginx-app-1` |
| `service` | `nginx-app` |

In Grafana, open **Explore**, select Loki, and run:

```logql
{job="nginx-app", service="nginx-app"} |= " 404 "
```

The query returned the NGINX access entry below after requesting
`/not-found`:

```text
172.18.0.1 - - [19/Oct/2026:07:20:23 +0000] "GET /not-found HTTP/1.1" 404 153 "-" "curl/8.5.0"
```

The stream labels included `container="monitoring-nginx-app-1"`,
`job="nginx-app"`, and `service="nginx-app"`. A screenshot of the Grafana
Explore result is in [`../docs/screenshots/grafana-explore.png`](../docs/screenshots/grafana-explore.png).

To query Loki's HTTP API for the same time range, substitute current Unix
timestamps for `START_NANOS` and `END_NANOS`:

```sh
curl --get http://localhost:3100/loki/api/v1/query_range \
  --data-urlencode 'query={job="nginx-app",service="nginx-app"} |= " 404 "' \
  --data-urlencode "start=START_NANOS" \
  --data-urlencode "end=END_NANOS" \
  --data-urlencode limit=20
```

Stop the stack from `monitoring/` with `docker compose down`. The named Loki
and Grafana volumes persist until explicitly removed with
`docker compose down --volumes`.

## Troubleshooting and limitations

- The host already had port 8080 bound, so the initial Compose start failed
  when publishing NGINX. Starting with `APP_PORT=18080` resolved the conflict;
  use `APP_PORT` to select another free host port.
- Loki returned HTTP 503 briefly while initializing. Waiting for `/ready` to
  return `ready` before querying resolved the startup race.
- An initial broad Docker discovery configuration allowed unrelated host
  containers into the scrape and produced Loki errors for unlabeled streams.
  The final configuration filters at Docker discovery with
  `promtail.scrape=true` and retains an explicit `nginx-app` relabel filter.
- Promtail needs access to the host Docker socket and Docker's
  `/var/lib/docker/containers` directory. This configuration is for local
  Linux assessment use, not a hardened production host.
