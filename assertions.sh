#!/bin/bash
# Created by Artur Nowicki on 18.01.2018.
# This suite provides simple set of assertions for testing purposes.


# If parameters are equal then the test passes
function assertEquals {
	local expected=$1
	local actual=$2
	if [ ${expected} -eq ${actual} ]; then
		echo "Expected: ${expected}. Received: ${actual}."
		echo "TEST SUCCESFULL"
		return 0
	else
		echo "Expected: ${expected}. Received: ${actual}."
		echo "TEST FAILED"
		return 1
	fi
}