#!/bin/sh

is_nfs() {
    [ "${REAL_ROOT}" = "/dev/nfs" ] && return 0
    return 1
}

good_msg() {
    [ -n "${QUIET}" ] && [ -z "${DEBUG}" ] && return 0

    msg_string=$1
    msg_string="${msg_string:-...}"
    [ "$2" != 1 ] && \
        echo -e "${GOOD}>>${NORMAL}${BOLD} ${msg_string} ${NORMAL}"
}

warn_msg() {
    msg_string=$1
    msg_string="${msg_string:-...}"
    [ "$2" != 1 ] && \
        echo -e "${WARN}**${NORMAL}${BOLD} ${msg_string} ${NORMAL}"
}

bad_msg() {
    msg_string=$1
    msg_string="${msg_string:-...}"
    if [ "$2" != 1 ]; then
        # TODO(lxnay): fix circular dep with 00-splash.sh
        splashcmd verbose
        echo -e "${BAD}!!${NORMAL}${BOLD} ${msg_string} ${NORMAL}"
    fi
}

quiet_kmsg() {
    # if QUIET is set make the kernel less chatty
    [ -n "${QUIET}" ] && echo "0" > /proc/sys/kernel/printk
}

verbose_kmsg() {
    # if QUIET is set make the kernel less chatty
    [ -n "${QUIET}" ] && echo "6" > /proc/sys/kernel/printk
}

test_success() {
    local ret=${?}
    local error_string="${1:-run command}"

    if [ "${ret}" != "0" ]; then
        bad_msg "Failed to ${1}; failing back to the shell..."
        run_shell
    fi
}

run_shell() {
    /bin/ash
}

do_rundebugshell() {
    # TODO(lxnay): fix circular dep with 00-splash.sh
    splashcmd verbose
    good_msg 'Type "exit" to continue with normal bootup.'
    [ -x /bin/sh ] && /bin/sh || /bin/ash
}

rundebugshell() {
    if [ -n "${DEBUG}" ]; then
        good_msg "Starting debug shell as requested."
        good_msg "Stopping by: ${1}"
        do_rundebugshell
    fi
}
