program main
    use netcdf
    use error_codes
    use messages

    implicit none

    character(len=nf90_max_name) :: f_name, var_name, out_name_prefix, out_path
    integer status

    call read_input_data(f_name, var_name, out_name_prefix, out_path, status)
    if(status .eq. -1) call handle_error(input_params_err_msg, err_missing_program_input)
    call netcdf_to_binary(f_name, var_name, out_name_prefix, out_path)

end program

subroutine netcdf_to_binary(f_name, var_name, out_name_prefix, out_path)

! Created by Artur Nowicki 11.01.2018
! This program reads data from particular netcdf variable and writes it to a binary file
! Resulting file name contains variable dimensions
! This version works for up to 4 dimensions
! In case of dim < 4 size(dim) = 1
! Input parameters:
! f_name - input netcdf file name
! var_name - extracted variable name
! out_name_prefix - prefix for file name (e.g. datetime, series name etc.)
! out_path - output file location

    use netcdf
    use error_codes
    use messages

    implicit none

    integer, parameter :: dp = selected_real_kind(15, 307)
    integer, parameter :: max_var_dims = 4

    character(len=4) :: d2s
    ! input and output parameters
    character(len=nf90_max_name) :: f_name, var_name, out_name_prefix
    character(len=nf90_max_name) :: out_path, out_f_name, bin_iomsg
    ! increment
    integer :: ii
    ! netcdf variable info
    integer :: ncid, status, bin_iostat
    integer :: varid, ndims
    integer :: dim_len
    integer, dimension(max_var_dims) :: dims
    ! input data
    real(kind = dp), dimension(:, :, :, :), allocatable :: input_var



    status = nf90_open(trim(f_name), nf90_nowrite, ncid)
    if(status .ne. nf90_noerr) call handle_error(nf90_strerror(status), err_open_file)

    status = nf90_inq_varid(ncid, var_name, varid)
    if(status .ne. nf90_noerr) call handle_error(nf90_strerror(status), err_nc_reading)

    call get_var_dims(ncid, varid, dims)

    allocate(input_var(dims(1), dims(2), dims(3), dims(4)), STAT = status)
    if(status .ne. 0) call handle_error(msg_memory_alloc_err, err_memory_alloc)

    status = nf90_get_var(ncid, varid, input_var)
    if(status .ne. nf90_noerr) call handle_error(nf90_strerror(status), err_nc_reading)

    out_f_name = trim(out_path)//trim(out_name_prefix)//'_'//trim(var_name)//'_' &
    //d2s(dims(1))//'_'//d2s(dims(2))//'_'//d2s(dims(3))//'_'//d2s(dims(4))//'.ieeer8'

    open(101, file = trim(out_f_name), access = 'direct', status = 'replace', &
        iostat = bin_iostat, iomsg = bin_iomsg, form = 'unformatted', &
        convert = 'big_endian', recl = dims(1)*dims(2)*dims(3)*dims(4)*8)
    if(bin_iostat .ne. 0) call handle_error(bin_iomsg, err_writing_bin)
    write(101, rec = 1, iostat = bin_iostat, iomsg = bin_iomsg) input_var
    if(bin_iostat .ne. 0) call handle_error(bin_iomsg, err_writing_bin)
    deallocate(input_var, STAT = status)
    if(status .ne. 0) call handle_error(msg_memory_dealloc_err, err_memory_alloc)
    close(101, iostat = bin_iostat, iomsg = bin_iomsg)
    if(bin_iostat .ne. 0) call handle_error(bin_iomsg, err_writing_bin)

end subroutine

subroutine get_var_dims(ncid, varid, var_dims)
    use netcdf
    use error_codes
    use messages

    implicit none
    integer, parameter :: max_var_dims = 4

    integer, intent(in) :: ncid, varid
    integer :: status, ndims, ii, dim_len
    integer, dimension(:), allocatable :: dimids
    integer, intent(out), dimension(max_var_dims) :: var_dims

    status = nf90_inquire_variable(ncid, varid, ndims = ndims)
    if(status .ne. nf90_noerr) call handle_error(nf90_strerror(status), err_nc_reading)

    allocate(dimids(ndims), STAT = status)
    if(status .ne. 0) call handle_error(msg_memory_alloc_err, err_memory_alloc)

    status = nf90_inquire_variable(ncid, varid, dimids = dimids)
    if(status .ne. nf90_noerr) call handle_error(nf90_strerror(status), err_nc_reading)

    var_dims = 1
    do ii = 1, ndims
        status = nf90_inquire_dimension(ncid, dimids(ii), len = dim_len)
        if(status .ne. nf90_noerr) call handle_error(nf90_strerror(status), err_nc_reading)
        var_dims(ii) = dim_len
    enddo
    deallocate(dimids, STAT = status)
    if(status .ne. 0) call handle_error(msg_memory_dealloc_err, err_memory_alloc)

end subroutine

function d2s(in_var) result(out_var)
    implicit none
    integer, intent(in) :: in_var
    character(len=*) :: out_var
    write(out_var, '(i4.4)') in_var
end function

subroutine read_input_data(file_name, variable_name, out_name_prefix, output_path, status)
    implicit none
    character(len=256), intent(out) :: file_name, variable_name, out_name_prefix, output_path
    integer, intent(out) :: status
    status = 0
    call getarg(1, file_name)
    call getarg(2, variable_name)
    call getarg(3, out_name_prefix)
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

