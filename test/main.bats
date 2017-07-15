#!/usr/bin/env bats

load test_helper

@test "no arguments prints missing command" {
    run anax
    [ $status -eq 1 ]
    [ $(expr "${lines[0]}" : "Missing command.") -ne 0 ]
}

@test "-v show version" {
    run anax -v
    [ $status -eq 0 ]
    [ $(expr "$output" : "v[0-9][0-9.]*") -ne 0 ]
}

@test "--version show version" {
    run anax --version
    [ $status -eq 0 ]
    [ $(expr "$output" : "v[0-9][0-9.]*") -ne 0 ]
}
