# php8-on-k8s
Experimenting with Kubernetes

## Notes

One must create a `docker/envVars.private` file with the name/values specified in `docker/envVars.private.template`.
This file is not included in the repository for security reasons.

## Changes

0.1 - Baseline Docker setup with PHP 8.4 and Nginx
0.2 - With Composer config and PHPUnit setup and baseline tests
0.3 - Adding DB support with MariaDB
0.4 - Adding Symfony
