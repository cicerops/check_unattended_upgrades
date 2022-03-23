#!/usr/bin/env bats

setup() {
	. ./test/lib/test-helper.sh
	mock_path test/bin
	patch check_unattended_upgrades 's/ test / test_patched /g'
}

@test "CRITICAL caused by non-zero status of unattended-upgrades --dry-run, short opt" {
	mock_path test/bin/errors
	run ./check_unattended_upgrades_patched -n
	[ "$status" -eq 2 ]
	[ "${lines[0]}" = 'CRITICAL - unattended-upgrades --dry-run exits with a non-zero status.' ]
}

@test "CRITICAL caused by non-zero status of unattended-upgrades --dry-run" {
	mock_path test/bin/errors
	run ./check_unattended_upgrades_patched --dry-run
	[ "$status" -eq 2 ]
	[ "${lines[0]}" = 'CRITICAL - unattended-upgrades --dry-run exits with a non-zero status.' ]
}

@test "CRITICAL last log line ERROR" {
	mock_path test/bin/last_log_line_error
	run ./check_unattended_upgrades_patched
	[ "$status" -eq 2 ]
	[ "${lines[0]}" = 'CRITICAL - The last line in the log file is an ERROR message.' ]
	[ "${lines[1]}" = '2019-01-12 14:35:58,860 ERROR Cache has broken packages, exiting' ]
}

@test "WARNING last log line WARNING" {
	mock_path test/bin/last_log_line_warning
	run ./check_unattended_upgrades_patched
	[ "$status" -eq 1 ]
	[ "${lines[0]}" = 'WARNING - The last line in the log file is a WARNING message.' ]
	[ "${lines[1]}" = '2019-01-12 14:35:58,860 WARNING lol' ]
}

@test "CRITICAL log file doesn't exist. Insufficient permissions" {
	mock_path test/bin/permissions
	run ./check_unattended_upgrades_patched
	[ "$status" -eq 2 ]
	[ "${lines[0]}" = "CRITICAL - The log file (/var/log/unattended-upgrades/unattended-upgrades.log) doesn't exist or you haven't sufficient read permissions." ]
}
