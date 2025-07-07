#!/bin/bash

rm -rf vendor
composer install
php-fpm
