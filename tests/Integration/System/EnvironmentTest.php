<?php

namespace App\Tests\Integration\System;

use Generator;
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\Attributes\TestDox;
use PHPUnit\Framework\TestCase;

#[TestDox('Tests of environment variables')]
class EnvironmentTest extends TestCase
{
    #[TestDox('The expected environment variables exist')]
    #[DataProvider('provideCasesForEnvironmentVariablesTest')]
    public function testEnvironmentVariables(string $expectedEnvironmentVariable)
    {
        $this->assertNotFalse(
            getenv($expectedEnvironmentVariable),
            "Expected environment variable $expectedEnvironmentVariable to exist"
        );
    }

    public static function provideCasesForEnvironmentVariablesTest(): Generator
    {
        $varNames = [
            'APP_CACHE_DIR',
            'APP_LOG_DIR',
            'APP_SECRET',
            'MARIADB_DATABASE',
            'MARIADB_HOST',
            'MARIADB_PASSWORD',
            'MARIADB_PORT',
            'MARIADB_USER',
        ];
        foreach ($varNames as $varName) {
            yield $varName => [$varName];
        }
    }
}
