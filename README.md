# php8-on-k8s
Experimenting with Kubernetes

## Notes

One must create some `envVars.private` files,
with the name/values specified in the adjacent `envVars.private.template` file:
* `docker/envVars.private`
* `docker/mariadb/envVars.private`
* `docker/php/envVars.private`

## Changes

0.1 - Baseline Docker setup with PHP 8.4 and Nginx

0.2 - With Composer config and PHPUnit setup and baseline tests

0.3 - Adding DB support with MariaDB

0.4 - Adding Symfony

0.41 - Testing Symfony test environment config
