#!/bin/sh

# Source common and dialog subroutines
COMMON_SUBR="/usr/share/bsdconfig/common.subr"
DIALOG_SUBR="/usr/share/bsdconfig/dialog.subr"

if [ ! -f "$COMMON_SUBR" ]; then
    echo "Error: $COMMON_SUBR not found."
    exit 1
fi
. "$COMMON_SUBR"

if [ ! -f "$DIALOG_SUBR" ]; then
    echo "Error: $DIALOG_SUBR not found."
    exit 1
fi
. "$DIALOG_SUBR"

# Initialize dialog titles
f_dialog_title "Network Wizard"
f_dialog_backtitle "FreeBSD Network Configuration"

# Placeholder functions
view_status() {
    local status_info=""
    local interfaces
    local iface
    local ifconfig_output
    local mac_addr
    local ip_addr
    local ipv6_addr
    local flags
    local wpa_status_output
    local ssid
    local signal
    local auth

    # Get all interfaces
    interfaces=$(ifconfig -l)

    status_info="Network Interface Status:\n\n"

    for iface in $interfaces; do
        if [ "$iface" = "lo0" ]; then
            continue
        fi

        status_info="$status_info--------------------------------------------------\n"
        status_info="$status_infoInterface: $iface\n"

        ifconfig_output=$(ifconfig "$iface")

        # Extract MAC address (ether)
        mac_addr=$(echo "$ifconfig_output" | awk '/ether/{print $2}')
        if [ -n "$mac_addr" ]; then
            status_info="$status_info  MAC Address: $mac_addr\n"
        fi

        # Extract IP address (inet)
        ip_addr=$(echo "$ifconfig_output" | awk '/inet /{print $2}')
        if [ -n "$ip_addr" ]; then
            status_info="$status_info  IP Address: $ip_addr\n"
        fi

        # Extract IPv6 address (inet6)
        ipv6_addr=$(echo "$ifconfig_output" | awk '/inet6 /{print $2; exit}') # exit after first match
        if [ -n "$ipv6_addr" ]; then
            # Remove scope if present (e.g. %iface)
            ipv6_addr_clean=$(echo "$ipv6_addr" | cut -d'%' -f1)
            status_info="$status_info  IPv6 Address: $ipv6_addr_clean\n"
        fi

        # Extract Status (flags)
        flags=$(echo "$ifconfig_output" | awk '/flags=/{print $2; exit}') # Get the part after 'flags='
        status_line=$(echo "$ifconfig_output" | grep "status:")
        if [ -n "$flags" ]; then
             status_info="$status_info  Flags: $flags\n"
        fi
        if echo "$ifconfig_output" | grep -q "status: active"; then
            status_info="$status_info  Status: active\n"
        elif echo "$ifconfig_output" | grep -q "status: associated"; then
            status_info="$status_info  Status: associated\n"
        elif echo "$ifconfig_output" | grep -q "status: no carrier"; then
            status_info="$status_info  Status: no carrier\n"
        elif [ -n "$status_line" ]; then # Generic status line if specific ones not found
            status_info="$status_info  $(echo "$status_line" | awk '{$1=""; print $0 }' | xargs)\n" # "status: blah" -> "blah"
        fi


        # Check if it's a wlan interface (common naming convention or ifconfig output)
        if echo "$iface" | grep -qE '^(wlan|ath|ral|rum|run|ural|uath|wpi|iwi|ipw)' || \
           echo "$ifconfig_output" | grep -q "wlan"; then
            status_info="$status_info  Type: Wireless (WLAN)\n"
            wpa_status_output=$(wpa_cli -i "$iface" status 2>/dev/null)
            if [ $? -eq 0 ] && [ -n "$wpa_status_output" ]; then
                ssid=$(echo "$wpa_status_output" | awk -F= '/^ssid=/{print $2}')
                signal=$(wpa_cli -i "$iface" signal_poll 2>/dev/null | awk -F= '/^RSSI=/{print $2 " dBm"}')
                auth=$(echo "$wpa_status_output" | awk -F= '/^key_mgmt=/{print $2}')
                bssid=$(echo "$wpa_status_output" | awk -F= '/^bssid=/{print $2}')

                if [ -n "$ssid" ]; then
                    status_info="$status_info    SSID: $ssid\n"
                fi
                if [ -n "$bssid" ]; then
                    status_info="$status_info    BSSID: $bssid\n"
                fi
                if [ -n "$signal" ]; then
                    status_info="$status_info    Signal Strength: $signal\n"
                fi
                if [ -n "$auth" ]; then
                    status_info="$status_info    Authentication: $auth\n"
                fi
            else
                status_info="$status_info    WPA Status: Not available or not associated\n"
            fi
        else
            status_info="$status_info  Type: Wired\n"
        fi
    done
    status_info="$status_info--------------------------------------------------\n\n"

    # Get IPv4 default route
    ipv4_route=$(netstat -rn -f inet | grep '^default' | awk '{print "Default Gateway (IPv4): " $2 " via " $4}')
    if [ -n "$ipv4_route" ]; then
        status_info="$status_info$ipv4_route\n"
    else
        status_info="$status_infoDefault Gateway (IPv4): Not set\n"
    fi

    # Get IPv6 default route
    ipv6_route=$(netstat -rn -f inet6 | grep '^default' | awk '{print "Default Gateway (IPv6): " $2 " via " $4}')
    if [ -n "$ipv6_route" ]; then
        status_info="$status_info$ipv6_route\n"
    else
        status_info="$status_infoDefault Gateway (IPv6): Not set\n"
    fi

    # Determine dialog size (using fixed values as f_dialog_buttonbox_size is not directly usable here)
    # local dialog_height=20
    # local dialog_width=70
    # If f_dialog_buttonbox_size were available and usable in this context:
    # eval $(f_dialog_buttonbox_size "$status_info" dialog_height dialog_width)

    # Display the collected information
    # Use --textbox which is better for scrollable text
    bsddialog --title "Network Status" --textbox "$status_info" 22 78
}

# Function to manage a single wired interface
manage_one_wired_interface() {
    local iface_name="$1"
    local choice
    local ifconfig_output
    local current_ip
    local is_up

    while true; do
        ifconfig_output=$(ifconfig "$iface_name")
        current_ip=$(echo "$ifconfig_output" | awk '/inet /{print $2}')
        if echo "$ifconfig_output" | grep -q "<UP,"; then
            is_up=true
        else
            is_up=false
        fi

        local menu_options=""
        local status_line="Status: "
        if $is_up; then
            status_line="$status_line UP"
            if [ -n "$current_ip" ]; then
                status_line="$status_line, IP: $current_ip"
            else
                status_line="$status_line, (Obtaining IP...)"
            fi
            menu_options="DEACTIVATE \"Deactivate $iface_name\" "
        else
            status_line="$status_line DOWN"
            menu_options="ACTIVATE \"Activate $iface_name (DHCP)\" "
        fi
        menu_options="$menu_options DETAILS \"View Detailed Status\" BACK \"Back to interface list\""

        # Convert menu_options string to array for bsddialog
        # shellcheck disable=SC2086
        set -- $menu_options # Disables shellcheck warning for word splitting
        choice=$(bsddialog --title "Manage $iface_name" --menu "$status_line" 15 70 5 "$@" 3>&1 1>&2 2>&3 3>&-)

        case "$choice" in
            ACTIVATE)
                # Release existing dhclient lease if any (optional, some systems might need it)
                # dhclient -r "$iface_name" >/dev/null 2>&1
                # Start new dhclient
                # Need to run dhclient in background otherwise it might block the script
                dhclient "$iface_name" >/dev/null 2>&1 &
                # Give it a moment to start and then bring interface up
                sleep 1
                ifconfig "$iface_name" up
                if [ $? -eq 0 ]; then
                    bsddialog --title "Activation" --msgbox "$iface_name is being activated with DHCP. It may take a moment to get an IP." 8 50
                else
                    bsddialog --title "Error" --msgbox "Failed to bring up $iface_name." 8 50
                fi
                ;;
            DEACTIVATE)
                ifconfig "$iface_name" down
                # Optionally, release DHCP lease and kill dhclient
                # dhclient -r "$iface_name" >/dev/null 2>&1
                # pkill -f "dhclient.*$iface_name"
                if [ $? -eq 0 ]; then
                    bsddialog --title "Deactivation" --msgbox "$iface_name has been deactivated." 8 50
                else
                    bsddialog --title "Error" --msgbox "Failed to deactivate $iface_name." 8 50
                fi
                ;;
            DETAILS)
                local detailed_status
                detailed_status=$(ifconfig "$iface_name")
                bsddialog --title "Detailed Status: $iface_name" --textbox "$detailed_status" 20 70
                ;;
            BACK|*)
                break
                ;;
        esac
    done
}

manage_wired() {
    local choice
    local interfaces
    local iface
    local menu_items=""
    local item_count=0

    while true; do
        interfaces=$(ifconfig -l)
        menu_items=""
        item_count=0

        for iface in $interfaces; do
            if [ "$iface" = "lo0" ]; then
                continue
            fi

            # Preliminary filter for known wireless patterns by name
            if echo "$iface" | grep -qE '^(wlan|ath|iwm|ral|run|urtw|otus|uvn|rum|ipw|uath|wpi|iwi)'; then
                continue
            fi

            # More robust check using ifconfig output for wireless characteristics
            if ifconfig "$iface" 2>/dev/null | grep -qE '(status: associated|ssid|wlan|ieee80211)'; then
                continue # Skip if it looks like a wireless interface
            fi

            menu_items="$menu_items $iface \"Manage $iface\""
            item_count=$((item_count + 1))
        done

        menu_items="$menu_items BACK \"Back to Main Menu\""
        item_count=$((item_count + 1))

        if [ "$item_count" -le 1 ]; then # Only "Back" option means no wired interfaces found
            bsddialog --title "Manage Wired Connections" --msgbox "No suitable wired network interfaces found." 8 50
            break
        fi

        # Calculate dialog height - approximately 5 items per 1 unit of height in menu, plus fixed for title/buttons
        local dialog_height=$(( (item_count + 1) / 2 + 8 )) # Simplified calculation
        [ "$dialog_height" -gt 20 ] && dialog_height=20 # Max height

        # shellcheck disable=SC2086
        set -- $menu_items # Disables shellcheck warning for word splitting
        choice=$(bsddialog --title "Manage Wired Connections" --menu "Select a wired interface:" "$dialog_height" 70 "$item_count" "$@" 3>&1 1>&2 2>&3 3>&-)

        case "$choice" in
            BACK|*)
                if [ "$choice" = "BACK" ] || [ -z "$choice" ]; then # Empty choice means ESC/Cancel
                    break
                else
                    # This is an interface name
                    manage_one_wired_interface "$choice"
                fi
                ;;
        esac
    done
}

# Helper to identify Wi-Fi interfaces
_get_wifi_interfaces() {
    local _all_ifaces _iface _ifconfig_out
    _all_ifaces=$(ifconfig -l)
    _phys_wifi_devices=""
    _wlan_clones=""

    for _iface in $_all_ifaces; do
        if echo "$_iface" | grep -qE '^lo[0-9]+$'; then continue; fi

        _ifconfig_out=$(ifconfig "$_iface" 2>/dev/null)

        # Check for existing wlan clone interfaces
        if echo "$_iface" | grep -qE '^wlan[0-9]+$'; then
            if echo "$_ifconfig_out" | grep -q "wlandev"; then
                _wlan_clones="$_wlan_clones $_iface"
            fi
        # Check for physical devices that are Wi-Fi capable but not themselves wlan clones
        # It should have IEEE80211 capabilities but not be a wlan clone itself (e.g. have a 'wlandev' pointing to itself)
        # and not be an ethernet device.
        elif echo "$_ifconfig_out" | grep -q "groups: wlan" || \
             (echo "$_ifconfig_out" | grep -q "IEEE80211" && \
              ! echo "$_ifconfig_out" | grep -q "ether" && \
              ! echo "$_iface" | grep -qE '^(bridge|pflog|pfsync|enc|lo|usbus|carp|tap|tun|gre|gif|faith|pair|dummy|vlan|lagg|em|re|igb|ix|cxl|vtnet|xn|ax|ice|msk|bge|dc|et|fxp|lge|nge|rl|sf|sis|sk|ste|stge|ti|tl|txp|vge|wb|xl|ale|bfe|bce|le|rue|udav|ural|rum|run|zyd|uath|ath|iwm|iwn|ipw|wpi|ral|otus|uvn|urtw|an|awi|wi|mwl|malo)'); then
            _phys_wifi_devices="$_phys_wifi_devices $_iface"
        fi
    done
    echo "$_wlan_clones $_phys_wifi_devices" # First list wlan clones, then phys devices, separated by space
                                           # but this function is expected to return two lists.
                                           # For now, this simplification. Refined logic will use global vars.
}

# Function to manage a single Wi-Fi interface (wlan)
manage_one_wifi_interface() {
    local wlan_iface="$1"
    local choice
    local wpa_status wpa_state current_ssid current_ip
    local prompt_title

    while true; do
        wpa_status=$(wpa_cli -i "$wlan_iface" status 2>/dev/null)
        if [ $? -eq 0 ]; then
            wpa_state=$(echo "$wpa_status" | awk -F= '/^wpa_state=/{print $2}')
            current_ssid=$(echo "$wpa_status" | awk -F= '/^ssid=/{print $2}')
        else
            wpa_state="N/A"
            current_ssid="N/A"
        fi
        current_ip=$(ifconfig "$wlan_iface" | awk '/inet /{print $2}')
        prompt_title="Manage $wlan_iface: SSID: $current_ssid, State: $wpa_state, IP: ${current_ip:-Not set}"

        # shellcheck disable=SC2086
        choice=$(bsddialog --title "$prompt_title" --menu "Select an action:" 18 78 7 \
            "SCAN" "Scan for Networks" \
            "CONNECT" "Connect to a Network" \
            "DISCONNECT" "Disconnect from current Network" \
            "STATUS" "View Detailed Status" \
            "DESTROY" "Destroy this wlan interface ($wlan_iface)" \
            "BACK" "Back to Wi-Fi interface list" \
            3>&1 1>&2 2>&3 3>&-)

        case "$choice" in
            SCAN)
                bsddialog --title "Scanning..." --infobox "Requesting scan for $wlan_iface..." 5 40
                wpa_cli -i "$wlan_iface" scan >/dev/null
                sleep 3 # Give time for scan to complete
                local scan_results_raw scan_menu_items item_count
                scan_results_raw=$(wpa_cli -i "$wlan_iface" scan_results)
                scan_menu_items=""
                item_count=0
                # Skip header line and parse results
                echo "$scan_results_raw" | awk 'NR>1 {printf "%s \"%s %s %s\"\n", $5, $5, $3, $4}' | while IFS= read -r line; do
                    # line is now "SSID" "SSID Signal Flags"
                    scan_menu_items="$scan_menu_items $line"
                    item_count=$((item_count + 1))
                done

                if [ "$item_count" -eq 0 ]; then
                    bsddialog --title "Scan Results" --msgbox "No networks found." 8 40
                else
                    # shellcheck disable=SC2086
                    set -- $scan_menu_items
                    selected_ssid=$(bsddialog --title "Scan Results for $wlan_iface" --menu "Select a network to connect (or view):" 20 70 "$item_count" "$@" 3>&1 1>&2 2>&3 3>&-)
                    # Further action on selected_ssid (like auto-filling connect) could be added here
                    if [ -n "$selected_ssid" ]; then
                         bsddialog --title "Selected Network" --msgbox "You selected SSID: $selected_ssid.\nUse 'Connect to Network' to establish connection." 8 60
                    fi
                fi
                ;;
            CONNECT)
                local ssid_to_connect key_mgmt password network_id
                ssid_to_connect=$(bsddialog --title "Connect to Network" --inputbox "Enter SSID:" 8 40 3>&1 1>&2 2>&3 3>&-)
                if [ -z "$ssid_to_connect" ]; continue; fi

                # Simplified: Ask if network is open or needs WPA-PSK password.
                # A more robust solution would parse scan results for the selected SSID's security.
                bsddialog --yesno "Is '$ssid_to_connect' an open network (no password)?" 8 60
                if [ $? -eq 0 ]; then # Yes, it's open
                    key_mgmt="NONE"
                else # No, it needs a password (assume WPA-PSK for simplicity)
                    key_mgmt="WPA-PSK"
                    password=$(bsddialog --title "Enter Password" --passwordbox "Password for $ssid_to_connect:" 8 40 3>&1 1>&2 2>&3 3>&-)
                    if [ -z "$password" ]; then
                        bsddialog --title "Connection Cancelled" --msgbox "Password not entered. Connection cancelled." 8 50
                        continue
                    fi
                fi

                network_id=$(wpa_cli -i "$wlan_iface" add_network)
                if ! echo "$network_id" | grep -qE '^[0-9]+$'; then
                    bsddialog --title "Error" --msgbox "Failed to add network via wpa_cli." 8 40
                    continue
                fi

                wpa_cli -i "$wlan_iface" set_network "$network_id" ssid "\"$ssid_to_connect\"" >/dev/null
                if [ "$key_mgmt" = "NONE" ]; then
                    wpa_cli -i "$wlan_iface" set_network "$network_id" key_mgmt NONE >/dev/null
                else # WPA-PSK
                    wpa_cli -i "$wlan_iface" set_network "$network_id" psk "\"$password\"" >/dev/null
                fi
                wpa_cli -i "$wlan_iface" enable_network "$network_id" >/dev/null
                wpa_cli -i "$wlan_iface" select_network "$network_id" >/dev/null # or reassociate

                bsddialog --title "Connecting..." --infobox "Attempting to connect to $ssid_to_connect..." 5 50
                # Bring interface up and request DHCP
                ifconfig "$wlan_iface" up
                dhclient "$wlan_iface" >/dev/null 2>&1 &
                sleep 5 # Give time for connection and DHCP

                # Verify connection
                local verify_status verify_ssid verify_ip
                verify_status=$(wpa_cli -i "$wlan_iface" status 2>/dev/null)
                verify_ssid=$(echo "$verify_status" | awk -F= '/^ssid=/{print $2}')
                verify_ip=$(ifconfig "$wlan_iface" | awk '/inet /{print $2}')

                if [ "$verify_ssid" = "$ssid_to_connect" ] && [ -n "$verify_ip" ]; then
                    bsddialog --title "Success" --msgbox "Connected to $ssid_to_connect\nIP Address: $verify_ip" 8 60
                elif [ "$verify_ssid" = "$ssid_to_connect" ]; then
                    bsddialog --title "Partial Success" --msgbox "Associated with $ssid_to_connect, but failed to get an IP address." 8 70
                else
                    bsddialog --title "Failure" --msgbox "Failed to connect to $ssid_to_connect." 8 50
                fi
                ;;
            DISCONNECT)
                local current_net_id
                current_net_id=$(echo "$wpa_status" | awk -F= '/^id=/{print $2}') # Assumes status is fresh enough

                wpa_cli -i "$wlan_iface" disconnect >/dev/null
                if [ -n "$current_net_id" ] && echo "$current_net_id" | grep -qE '^[0-9]+$'; then
                     wpa_cli -i "$wlan_iface" remove_network "$current_net_id" >/dev/null
                fi
                # Optionally release DHCP and kill client
                # dhclient -r "$wlan_iface" >/dev/null 2>&1
                # pkill -f "dhclient.*$wlan_iface"
                # ifconfig "$wlan_iface" delete_addr $(ifconfig "$wlan_iface" | awk '/inet /{print $2}') # Risky if multiple IPs
                bsddialog --title "Disconnect" --msgbox "Disconnected from $current_ssid (if associated)." 8 50
                ;;
            STATUS)
                local detailed_status
                detailed_status="ifconfig $wlan_iface:\n"
                detailed_status="$detailed_status$(ifconfig "$wlan_iface")\n\n"
                detailed_status="$detailed_status\nwpa_cli -i $wlan_iface status:\n"
                detailed_status="$detailed_status$(wpa_cli -i "$wlan_iface" status)"
                bsddialog --title "Detailed Status: $wlan_iface" --textbox "$detailed_status" 20 75
                ;;
            DESTROY)
                bsddialog --yesno "Really destroy interface $wlan_iface?" 7 50
                if [ $? -eq 0 ]; then # Yes
                    ifconfig "$wlan_iface" destroy
                    if [ $? -eq 0 ]; then
                        bsddialog --title "Success" --msgbox "Interface $wlan_iface destroyed." 7 50
                        return 0 # Exit this function, causing refresh in manage_wifi
                    else
                        bsddialog --title "Error" --msgbox "Failed to destroy $wlan_iface." 7 50
                    fi
                fi
                ;;
            BACK|*)
                return 1 # Back to Wi-Fi interface list, no refresh needed unless destroy happened
                ;;
        esac
    done
}


manage_wifi() {
    local choice main_menu_items item_count
    local _wlan_clones_list _phys_devices_list # To store results from _get_wifi_interfaces

    # Helper to get and parse wifi interfaces
    # Assigns to global-like shell variables _wlan_clones_list and _phys_devices_list
    _populate_wifi_interface_lists() {
        local _all_ifaces _iface _ifconfig_out
        _all_ifaces=$(ifconfig -l)
        _wlan_clones_list=""
        _phys_devices_list=""

        for _iface in $_all_ifaces; do
            if echo "$_iface" | grep -qE '^lo[0-9]+$'; then continue; fi
            _ifconfig_out=$(ifconfig "$_iface" 2>/dev/null)

            if echo "$_iface" | grep -qE '^wlan[0-9]+$'; then
                if echo "$_ifconfig_out" | grep -q "wlandev"; then
                    _wlan_clones_list="$_wlan_clones_list $_iface"
                fi
            elif echo "$_ifconfig_out" | grep -q "groups: wlan" || \
                 (echo "$_ifconfig_out" | grep -q "IEEE80211" && \
                  ! echo "$_ifconfig_out" | grep -q "ether" && \
                  ! echo "$_iface" | grep -qE '^(bridge|pflog|pfsync|enc|lo|usbus|carp|tap|tun|gre|gif|faith|pair|dummy|vlan|lagg|em|re|igb|ix|cxl|vtnet|xn|ax|ice|msk|bge|dc|et|fxp|lge|nge|rl|sf|sis|sk|ste|stge|ti|tl|txp|vge|wb|xl|ale|bfe|bce|le|rue|udav|ural|rum|run|zyd|uath|ath|iwm|iwn|ipw|wpi|ral|otus|uvn|urtw|an|awi|wi|mwl|malo)'); then
                # Check if this phys device already has a wlan clone on it
                local is_already_cloned=false
                for _wlan_clone in $_wlan_clones_list; do
                    if ifconfig "$_wlan_clone" 2>/dev/null | grep -q "wlandev $_iface"; then
                        is_already_cloned=true; break
                    fi
                done
                if ! $is_already_cloned; then
                    _phys_devices_list="$_phys_devices_list $_iface"
                fi
            fi
        done
    }


    while true; do
        _populate_wifi_interface_lists # Refresh lists
        main_menu_items=""
        item_count=0

        for wlan_iface in $_wlan_clones_list; do
            main_menu_items="$main_menu_items MANAGE_$wlan_iface \"Manage $wlan_iface\""
            item_count=$((item_count + 1))
        done

        for phys_dev in $_phys_devices_list; do
            main_menu_items="$main_menu_items CREATE_$phys_dev \"Create wlan for $phys_dev\""
            item_count=$((item_count + 1))
        done

        main_menu_items="$main_menu_items BACK \"Back to Main Menu\""
        item_count=$((item_count + 1)) # For the back option

        if [ $item_count -eq 1 ] && [ -z "$_wlan_clones_list" ] && [ -z "$_phys_devices_list" ]; then
             bsddialog --title "Manage Wi-Fi Connections" --msgbox "No Wi-Fi devices found." 8 50
             break
        fi

        local dialog_height=$(( item_count + 8 ))
        [ "$dialog_height" -gt 20 ] && dialog_height=20

        # shellcheck disable=SC2086
        set -- $main_menu_items
        choice=$(bsddialog --title "Manage Wi-Fi Connections" --menu "Select an action or interface:" "$dialog_height" 70 "$item_count" "$@" 3>&1 1>&2 2>&3 3>&-)

        if [ -z "$choice" ]; then break; fi # ESC/Cancel

        case "$choice" in
            BACK)
                break
                ;;
            CREATE_*)
                local phys_dev_to_clone
                phys_dev_to_clone=$(echo "$choice" | sed 's/^CREATE_//')

                # Determine next wlan interface number
                local next_wlan_num=0
                # Check existing wlan interfaces to find the next available number
                # This is a simple approach; a more robust one would check ifconfig -l
                # and parse all wlanX numbers.
                # For now, just iterate if wlan0, wlan1 etc. exist by trying to ifconfig them.
                # A better way: list all wlan interfaces, sort them, find max number.
                # Simplified: find max number from _wlan_clones_list
                if [ -n "$_wlan_clones_list" ]; then
                    for existing_wlan in $_wlan_clones_list; do
                        num=$(echo "$existing_wlan" | sed 's/^wlan//')
                        if [ "$num" -ge "$next_wlan_num" ]; then
                            next_wlan_num=$((num + 1))
                        fi
                    done
                fi

                local new_wlan_iface="wlan${next_wlan_num}"

                ifconfig "$new_wlan_iface" create wlandev "$phys_dev_to_clone" up
                if [ $? -eq 0 ]; then
                    bsddialog --title "Success" --msgbox "Interface $new_wlan_iface created on $phys_dev_to_clone and brought up." 8 60
                    # Don't need to do anything else, loop will refresh menu
                else
                    bsddialog --title "Error" --msgbox "Failed to create $new_wlan_iface on $phys_dev_to_clone." 8 60
                fi
                ;;
            MANAGE_*)
                local wlan_to_manage
                wlan_to_manage=$(echo "$choice" | sed 's/^MANAGE_//')
                manage_one_wifi_interface "$wlan_to_manage"
                # Loop will refresh menu if destroy happened, otherwise no explicit refresh needed
                ;;
            *) # Should not happen with a well-formed menu
                break
                ;;
        esac
    done
}

# Main menu function
main_menu() {
    local _choice
    _choice=$(bsddialog --title "Main Menu" --menu "Select an option:" 15 50 4 \
        '1' "View Network Status" \
        '2' "Manage Wired Connections" \
        '3' "Manage Wi-Fi Connections" \
        'X' "Exit" \
        3>&1 1>&2 2>&3 3>&-)
    echo "$_choice"
}

# Main loop
while true; do
    choice=$(main_menu)
    case "$choice" in
        '1') view_status ;;
        '2') manage_wired ;;
        '3') manage_wifi ;;
        'X') break ;;
        *) break ;; # Handle ESC or Cancel
    esac
done

# Clear screen on exit (optional)
# clear
exit 0
