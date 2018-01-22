module error_codes
    implicit none
    integer, parameter :: &
        err_open_file=101, &
        err_nc_reading=102, &
        err_missing_program_input=103, &
        err_writing_bin=104, &
        err_memory_alloc=105
end module error_codes