# DevOps Intern Final

A small Nginx application with Docker, Nomad, shell utilities, GitHub Actions CI,
and an optional Loki/Promtail logging stack.

## Run the application

Build and run the container:

```sh
docker build -t nginx-app ./app
docker run --rm -p 8080:80 nginx-app
```

Open <http://localhost:8080>. The container also exposes a `/health` endpoint
for readiness checks.

Run the host information script:

```sh
./scripts/sysinfo.sh
```

Check a running application:

```sh
./scripts/healthcheck.sh http://localhost:8080/health
```

The health check accepts an optional URL; it defaults to
`http://localhost:8080/health`.

## Deploy with Nomad

Update the `datacenters` and `count` values in
[`nomad/nginx-app.nomad.hcl`](nomad/nginx-app.nomad.hcl) as appropriate, then
validate and run the job:

```sh
nomad job validate nomad/nginx-app.nomad.hcl
nomad job run nomad/nginx-app.nomad.hcl
```

The job uses the `nginx:alpine` image and publishes port 8080 on the Nomad
client. This standalone example uses the stock Nginx page; build and publish
the custom image, then update the job's `image` setting to deploy this project
instead.

## Local log aggregation

Start Loki and Promtail with Docker Compose:

```sh
cd monitoring
docker compose up -d
```

Loki is available at <http://localhost:3100>. See
[`monitoring/loki_setup.md`](monitoring/loki_setup.md) for configuration and
query examples. Stop the stack with `docker compose down`.

## CI and screenshots

GitHub Actions checks shell script syntax and builds the application image on
pushes and pull requests. Store any project screenshots under
[`docs/screenshots/`](docs/screenshots/).
