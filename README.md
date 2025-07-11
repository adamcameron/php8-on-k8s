# php8-on-k8s
Experimenting with Kubernetes

## Notes

One must create some `envVars.private` files,
with the name/values specified in the adjacent `envVars.private.template` file:
* `docker/envVars.private`
* `docker/mariadb/envVars.private`
* `docker/php/envVars.private`

## Building for dev

```bash
# from the root of the project

# only need to do this once or if Dockerfile.base changes
docker build -f docker/php/Dockerfile.base -t adamcameron/php8-on-k8s-base .

docker compose -f docker/docker-compose.yml build
docker compose -f docker/docker-compose.yml up --detach

# verify stability
docker container ls --format "table {{.Names}}\t{{.Status}}"
NAMES     STATUS
nginx     Up 28 minutes (healthy)
php       Up 28 minutes (healthy)
db        Up 28 minutes

docker exec php composer test-all
./composer.json is valid
PHPUnit 12.2.6 by Sebastian Bergmann and contributors.

Runtime:       PHP 8.4.10 with Xdebug 3.4.4
Configuration: /var/www/phpunit.xml.dist

Time: 00:02.270, Memory: 28.00 MB

OK (15 tests, 20 assertions)

Generating code coverage report in HTML format ... done [00:00.006]
```

## Building PHP container for prod

This presupposes appropriate Nginx and DB servers are already running
(the dev containers would be fine).

```bash
# from the root of the project

# only need to do this once or if Dockerfile.base changes
docker build -f docker/php/Dockerfile.base -t adamcameron/php8-on-k8s-base .

docker build \
    -f docker/php/Dockerfile.prod \
    -t adamcameron/php8-on-k8s:x.y \ # where x.y is the actual version, e.g. 0.6 \
    -t adamcameron/php8-on-k8s:latest \
    .

docker run \
    --name php \
    --restart unless-stopped \
    -p 9000:9000 \
    --env-file docker/envVars.public \
    --env-file docker/php/envVars.public \
    --env-file docker/php/envVars.prod.public \
    --env-file docker/envVars.private \
    --env-file docker/php/envVars.private \
    --add-host=host.docker.internal:host-gateway \
    --detach \
    -it \
    adamcameron/php8-on-k8s:latest
    
# verify stability
docker container ls --format "table {{.Names}}\t{{.Status}}" | grep php
php       Up 2 minutes (healthy)

# the tests are deployed in the prod container, so test something else:
curl -s -o /dev/null -w "%{http_code}\n" http://php8-on-k8s.local:8080/
200

docker exec php bin/console about | grep -B 1 -A 2 Kernel
 -------------------- -------------------------------------------
  Kernel
 -------------------- -------------------------------------------
  Type                 App\Kernel
  Environment          prod
  Debug                false
```

## Changes

0.1 - Baseline Docker setup with PHP 8.4 and Nginx

0.2 - With Composer config and PHPUnit setup and baseline tests

0.3 - Adding DB support with MariaDB

0.4 - Adding Symfony

0.41 - Testing Symfony test environment config

0.5 - Rejigging for dev/prod environments for PHP container

0.6 - Rejig for Kubernetes requirements

0.61 - Fix k8s config bugs and update home template

0.7 - Test DB connection from PHP container

0.71 - Bugs & tweaks for dev/prod-by-docker config

0.72 - Another bug
