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
docker build \
  -f docker/php/Dockerfile.base \
  -t adamcameron/php8-on-k8s-base:x.y \ # where x.y is the actual version, e.g. 0.6 \
  -t adamcameron/php8-on-k8s-base:latest \
  .
docker push adamcameron/php8-on-k8s-base:x.y 
docker push adamcameron/php8-on-k8s-base:latest

# this is for the prod container
docker build \
    -f docker/php/Dockerfile.prod \
    -t adamcameron/php8-on-k8s:x.y \ # where x.y is the actual version, e.g. 0.6 \
    -t adamcameron/php8-on-k8s:latest \
    .

docker push adamcameron/php8-on-k8s:x.y
docker push adamcameron/php8-on-k8s:latest
```

## Running the prod container via Docker

```bash
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
## Running the prod container via Kubernetes

```bash
# from the root of the project
k8s/bin/applyConfig.sh
configmap/php-config created
secret/php-secret created
deployment.apps/php created
service/php created
deployment.apps/php env updated

# verify stability
kubectl get pods --field-selector=status.phase=Running -o custom-columns="NAME:.metadata.name,STATUS:.status.phase"
NAME                  STATUS
php-86c4cf8b4-8q8q9   Running
php-86c4cf8b4-gkmkw   Running
php-86c4cf8b4-lxfx4   Running

# repeat this curl to verify different pods are being used
curl -s http://php8-on-k8s.local:8080/ | grep "Instance ID"
    Instance ID: php-86c4cf8b4-gkmkw<br>

# use one of the pods to verify the Symfony app is running and in prod mode
kubectl exec -it php-86c4cf8b4-gkmkw -- bin/console about | grep -B 1 -A 2 Kernel
 -------------------- -------------------------------------------
  Kernel
 -------------------- -------------------------------------------
  Type                 App\Kernel
  Environment          prod
  Debug                false
```

## Running the prod container via Docker Swarm

```bash
# only needed once to start-up the swarm
docker swarm init --advertise-addr 127.0.0.1

docker service create \
    --name php \
    --replicas 3 \
    --publish published=9000,target=9000 \
    --env-file docker/envVars.public \
    --env-file docker/php/envVars.public \
    --env-file docker/php/envVars.prod.public \
    --env-file docker/envVars.private \
    --env-file docker/php/envVars.private \
    --host host.docker.internal:host-gateway \
    adamcameron/php8-on-k8s:latest
    
# verify stability
docker container ls --all --format "table {{.Names}}\t{{.Status}}" | grep php
php.1.lkrg5g45mb3njmi180gupyknh    Up About a minute (healthy)
php.2.nrwt1j0zhq0bvl1rybb41nytj    Up About a minute (healthy)
php.3.gag30v8g34xmhsgper83n8u8i    Up About a minute (healthy)

# repeat this curl to verify different pods are being used
curl -s http://php8-on-k8s.local:8080/ | grep "Instance ID"
    Instance ID: 04c8f570e5d4<br>

# use one of the containers to verify the Symfony app is running and in prod mode
docker exec php.1.lkrg5g45mb3njmi180gupyknh  bin/console about | grep -B 1 -A 2 Kernel
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

0.8 - Configure for k8s deployment

0.9 - Add Docker Swarm support
