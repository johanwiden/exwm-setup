#!/bin/bash
# Execute xrandr with appropriate arguments, to configure the X11 screens for EXWM
# For specification see: ".xinitrc.exwm"

grep="/bin/grep"
awk="/usr/bin/awk"
xrandr="/usr/bin/xrandr"

if [[ ! -z "${X11_SCREEN_LIST}" ]]; then
    declare -a x11_screens_a=(${X11_SCREEN_LIST})
    declare -a x11_screen_order_a=(${X11_SCREEN_ORDER_LIST})
    declare -a x11_screens_disabled_a=(${X11_SCREEN_DISABLED_LIST})
    declare -a x11_screen_mode_a=(${X11_SCREEN_MODE_LIST})
    declare -a x11_screen_rate_a=(${X11_SCREEN_RATE_LIST})
    declare -a x11_connected_screens_a=($(${xrandr} | ${grep} " connected " | ${awk} '{ print $1 }'))
    x11_connected_screens_list=" ${x11_connected_screens_a[*]} "

    x11_available_screens_a=()
    x11_available_screen_modes_a=()
    x11_available_screen_rates_a=()
    for ((i=0;i<${#x11_screens_a[@]};++i)); do
        screen=${x11_screens_a[$i]}
        if [[ ${x11_connected_screens_list} =~ " $screen " ]]; then
            x11_available_screens_a+=($screen)
            x11_available_screen_modes_a+=("${x11_screen_mode_a[$i]}")
            x11_available_screen_rates_a+=("${x11_screen_rate_a[$i]}")
        fi
    done

    x11_available_screen_order_a=()
    for ((i=0;i<${#x11_screen_order_a[@]};++i)); do
        screen=${x11_screen_order_a[$i]}
        if [[ ${x11_connected_screens_list} =~ " $screen " ]]; then
            x11_available_screen_order_a+=($screen)
        fi
    done

    x11_available_disabled_screens_a=()
    for screen in ${x11_screens_disabled_a[@]}; do
        if [[ ${x11_connected_screens_list} =~ " $screen " ]]; then
            x11_available_disabled_screens_a+=($screen)
        fi
    done

    if [[ ! -z ${x11_available_screens_a} ]]; then
        x11_available_screens_list=" ${x11_available_screens_a[*]} "
        if [[ ! -z ${X11_SCREEN_PREFERRED} ]] && [[ ${x11_available_screens_list} =~ " ${X11_SCREEN_PREFERRED} " ]]; then
            x11_primary_screen=${X11_SCREEN_PREFERRED}
        else
            x11_primary_screen=${x11_available_screens_a[0]}
        fi

        # Start building xrandr command line
        for ((i=0;i<${#x11_available_screens_a[@]};++i)); do
            if [[ "${x11_available_screens_a[$i]}" == "${x11_primary_screen}" ]]; then
                x11_primary_mode=${x11_available_screen_modes_a[$i]}
                x11_primary_rate=${x11_available_screen_rates_a[$i]}
                break
            fi
        done
        declare -a xrandr_args_a=("--dpi" "${X11_DISPLAY_DPI}" "--output" "${x11_primary_screen}" "--primary"
                                  "--mode" "${x11_primary_mode}"
                                  "--rate" "${x11_primary_rate}")

        for ((i=0;i<${#x11_available_disabled_screens_a[@]};++i)); do
            xrandr_args_a+=("--output" "${x11_available_disabled_screens_a[$i]}" "--off")
        done

        if [[ "${X11_SCREEN_USE_ALL_AVAILABLE}" == "yes" ]]; then
            # Add remaining available screens, except the primary screen
            for ((i=0;i<${#x11_available_screens_a[@]};++i)); do
                screen="${x11_available_screens_a[$i]}"
                if [[ "${screen}" != "${x11_primary_screen}" ]]; then
                    xrandr_args_a+=("--output" "${screen}"
                                    "--mode" "${x11_available_screen_modes_a[$i]}"
                                    "--rate" "${x11_available_screen_rates_a[$i]}")
                fi
            done
        else
            # Disable all remaining available screens except the primary screen
            for ((i=0;i<${#x11_available_screens_a[@]};++i)); do
                screen="${x11_available_screens_a[$i]}"
                if [[ "${screen}" != "${x11_primary_screen}" ]]; then
                    xrandr_args_a+=("--output" "${screen}" "--off")
                fi
            done
        fi
        echo ${xrandr} ${xrandr_args_a[*]}
        ${xrandr} ${xrandr_args_a[*]}
        # Place screens relative to each other, if needed
        if [[ "${X11_SCREEN_USE_ALL_AVAILABLE}" == "yes" ]] && [[ ${#x11_available_screen_order_a[@]} -gt 1 ]]; then
            declare -a xrandr_screen_order_args_a
            left_screen=${x11_available_screen_order_a[0]}
            for ((i=1;i<${#x11_available_screen_order_a[@]};++i)); do
                screen="${x11_available_screens_a[$i]}"
                xrandr_screen_order_args_a+=("--output" "${screen}" "--right-of" "${left_screen}")
                left_screen=${screen}
            done
            echo ${xrandr} ${xrandr_screen_order_args_a[*]}
            ${xrandr} ${xrandr_screen_order_args_a[*]}
        fi
    else
        echo "No available X11 screens in X11_SCREEN_LIST"
    fi
else
    echo "X11_SCREEN_LIST is empty"
fi
