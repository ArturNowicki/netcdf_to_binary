#!/bin/bash
# Created by Artur Nowicki on 18.01.2018.
# This is a series of test cases for program netcdf_to_bin.
# netcdf_to_bin reads given variable from netcdf file and saves it in binary file
# The program takes three input parameters:
# 1 - input netcdf file name
# 2 - name of the parameter to be processed
# 3 - output folder

# Program error codes:
ok_status=0
err_open_file=101
err_nc_reading=102
err_missing_program_input=103
err_writing_bin=104
err_memory_alloc=105

source ./assertions.sh
total_tests=0
failed_tests=0

date_time='2018_01_01_46800'
in_file_name='hydro.pop.h.2018-01-01-46800.nc'
parameter_name='ULAT'
out_path='out_data/'

echo "Compile program."
gfortran error_codes.f90 -I/opt/local/include netcdf_to_bin.f90 -o netcdf_to_bin -L/opt/local/lib -lnetcdff -lnetcdf
if [[ $? -ne 0 ]]; then
	exit
fi

echo "-------------------------"
echo "Test missing all parameters"
expected_error_code=${err_missing_program_input}
./netcdf_to_bin
assertEquals ${expected_error_code} $?
failed_tests=$((failed_tests+$?))
total_tests=$((total_tests+1))

echo "-------------------------"
echo "Missing two parameter"
expected_error_code=${err_missing_program_input}
./netcdf_to_bin ${in_file_name} ${parameter_name}
assertEquals ${expected_error_code} $?
failed_tests=$((failed_tests+$?))
total_tests=$((total_tests+1))

echo "-------------------------"
echo "Test bad input file"
expected_error_code=${err_open_file}
./netcdf_to_bin bad_file_name.nc ${parameter_name} ${date_time} ${out_path}
assertEquals ${expected_error_code} $?
failed_tests=$((failed_tests+$?))
total_tests=$((total_tests+1))

echo "-------------------------"
echo "Test bad parameter name"
expected_error_code=${err_nc_reading}
./netcdf_to_bin ${in_file_name} "bad_parameter_name" ${date_time} ${out_path}
assertEquals ${expected_error_code} $?
failed_tests=$((failed_tests+$?))
total_tests=$((total_tests+1))

echo "-------------------------"
echo "Test bad out path"
expected_error_code=${err_writing_bin}
./netcdf_to_bin ${in_file_name} ${parameter_name} ${date_time} "bad_path/"
assertEquals ${expected_error_code} $?
failed_tests=$((failed_tests+$?))
total_tests=$((total_tests+1))

echo "-------------------------"
echo "Test write error"
expected_error_code=${err_writing_bin}
./netcdf_to_bin ${in_file_name} ${parameter_name} ${date_time} ${out_path}
assertEquals ${expected_error_code} $?
failed_tests=$((failed_tests+$?))
total_tests=$((total_tests+1))

echo "-------------------------"
echo "Test all ok"
expected_error_code=${ok_status}
./netcdf_to_bin ${in_file_name} ${parameter_name} ${date_time} ${out_path}
assertEquals ${expected_error_code} $?
failed_tests=$((failed_tests+$?))
total_tests=$((total_tests+1))

echo
echo "-------------------------"
echo "TESTING RESULTS:"
echo "Tests passed: ${passed_tests}"
echo "Tests failed: ${failed_tests} out of ${total_tests}"