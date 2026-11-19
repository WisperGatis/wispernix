# Exit code -> short label: signals (128+n) by name, shell codes spelled out,
# anything else stays numeric.
function _wp_exit_name --argument-names code
    switch $code
        case 126; echo "126 noexec"
        case 127; echo "127 notfound"
        case 129; echo SIGHUP
        case 130; echo SIGINT
        case 131; echo SIGQUIT
        case 132; echo SIGILL
        case 133; echo SIGTRAP
        case 134; echo SIGABRT
        case 135; echo SIGBUS
        case 136; echo SIGFPE
        case 137; echo SIGKILL
        case 138; echo SIGUSR1
        case 139; echo SIGSEGV
        case 140; echo SIGUSR2
        case 141; echo SIGPIPE
        case 142; echo SIGALRM
        case 143; echo SIGTERM
        case '*'; echo $code
    end
end
