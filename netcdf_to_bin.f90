program netcdf_to_binary

    use netcdf
    use error_codes
    implicit none

    character(len=256), parameter :: params_err_msg = "Wrong/missing input marameters"
    character(len=256), parameter :: memory_alloc_err_msg = "Not enough memory"
    integer, parameter :: dp = selected_real_kind(15, 307)
    integer, parameter :: max_var_dims = 4

    character(len=4) :: d2s
    ! input and output parameters
    character(len=nf90_max_name) :: f_name, var_name, date_time
    character(len=nf90_max_name) :: out_path, out_f_name
    ! increment
    integer :: ii
    ! netcdf variable info
    integer :: ncid, status
    integer :: varid, xtype, ndims, nAtts
    integer :: dim_len
    integer, dimension(:), allocatable :: dimids
    integer, dimension(max_var_dims) :: dims
    ! input data
    real(kind = dp), dimension(:, :, :, :), allocatable :: input_var


    call read_input_data(f_name, var_name, date_time, out_path, status)
    if(status .eq. -1) call handle_error(params_err_msg, err_missing_program_input)

    status = nf90_open(trim(f_name), NF90_NOWRITE, ncid)
    if(status .ne. nf90_noerr) call handle_error(nf90_strerror(status), err_open_file)

    status = nf90_inq_varid(ncid, var_name, varid)
    if(status .ne. nf90_noerr) call handle_error(nf90_strerror(status), err_nc_reading)

    status = nf90_inquire_variable(ncid, varid, ndims = ndims)
    if(status .ne. nf90_noerr) call handle_error(nf90_strerror(status), err_nc_reading)

    allocate(dimids(ndims), STAT = status)
    if(status .ne. 0) call handle_error(memory_alloc_err_msg, err_memory_alloc)

    status = nf90_inquire_variable(ncid, varid, dimids = dimids)
    if(status .ne. nf90_noerr) call handle_error(nf90_strerror(status), err_nc_reading)

    dims = 1
    do ii = 1, ndims
        status = nf90_inquire_dimension(ncid, dimids(ii), len = dim_len)
        if(status .ne. nf90_noerr) call handle_error(nf90_strerror(status), err_nc_reading)
        dims(ii) = dim_len
    enddo
    allocate(input_var(dims(1), dims(2), dims(3), dims(4)), STAT = status)
    if(status .ne. 0) call handle_error(memory_alloc_err_msg, err_memory_alloc)

    status = nf90_get_var(ncid, varid, input_var)
    if(status .ne. nf90_noerr) call handle_error(nf90_strerror(status), err_nc_reading)

    out_f_name = trim(out_path)//trim(date_time)//'_'//trim(var_name)//'_' &
    //d2s(dims(1))//'_'//d2s(dims(2))//'_'//d2s(dims(3))//'_'//d2s(dims(4))//'.ieeer8'
    call write_variable(out_path)
    write(*,*) '--------'
    write(*,*) trim(out_f_name)
    call exit(2)
end program

function d2s(in_var) result(out_var)
    implicit none
    integer, intent(in) :: in_var
    character(len=*) :: out_var
    write(out_var, '(i4.4)') in_var
end function

subroutine read_input_data(file_name, variable_name, date_time, output_path, status)
    implicit none
    character(len=256), intent(out) :: file_name, variable_name, date_time, output_path
    integer, intent(out) :: status
    status = 0
    call getarg(1, file_name)
    call getarg(2, variable_name)
    call getarg(3, date_time)
    call getarg(4, output_path)
    if(file_name == '' .or. variable_name == '' .or. output_path == '') status = -1
end subroutine

! subroutine get_var_info(ncid, variable_name)
!     implicit none
! end subroutine

subroutine write_variable(out_path)
    implicit none
    character(len=*) out_path

end subroutine

subroutine handle_error(message, status)
    implicit none
    character(len=*), intent(in) :: message
    integer, intent(in) :: status
    write(*,*) trim(message)
    call exit(status)
end subroutine

