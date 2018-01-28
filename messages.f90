module messages
    implicit none
    character(len=512), parameter :: &
    input_params_err_msg = "Wrong/missing input parameters", &
    msg_memory_alloc_err = "Error allocating memory", &
    msg_memory_dealloc_err = "Error deallocating memory"
end module messages