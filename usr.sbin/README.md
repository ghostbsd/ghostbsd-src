# networkwizard.sh

## Purpose

`networkwizard.sh` is a text-based utility for FreeBSD that uses `bsddialog` to simplify common network interface management tasks. It provides an interactive menu system for:

-   Viewing overall network status.
-   Managing wired network connections (activating/deactivating, DHCP).
-   Managing Wi-Fi connections (scanning, connecting to networks, creating and destroying wlan interfaces).

## Requirements

-   **Operating System:** FreeBSD
-   **Dialog Utility:** `bsddialog` (should be part of the FreeBSD base system)
-   **Networking Utilities:** Standard FreeBSD tools such as `ifconfig`, `wpa_cli`, `dhclient`, and `netstat`.
-   **Privileges:** Root privileges are required for most operations that modify network settings (e.g., activating/deactivating interfaces, connecting to Wi-Fi, creating/destroying wlan interfaces).

## How to Run

To run the utility, execute the script from a terminal:

```sh
sh /usr/sbin/networkwizard.sh
```

Or, if you have made it executable (`chmod +x /usr/sbin/networkwizard.sh`):

```sh
/usr/sbin/networkwizard.sh
```

**Note:** Most network modification actions within the script will require root privileges to succeed. Run the script as root or using `sudo`.

## Features Overview

The main menu provides the following options:

1.  **View Network Status:**
    -   Displays a summary of all active network interfaces (excluding `lo0`).
    -   For each interface, it shows:
        -   MAC Address
        -   IP Address (IPv4)
        -   IPv6 Address
        -   Flags and current status (e.g., UP, RUNNING, active, no carrier).
    -   For Wi-Fi interfaces, it additionally attempts to show:
        -   SSID, BSSID
        -   Signal Strength
        -   Authentication type (from `wpa_cli`).
    -   Displays IPv4 and IPv6 default gateway information.

2.  **Manage Wired Connections:**
    -   Lists available wired network interfaces.
    -   For a selected wired interface, allows you to:
        -   **Activate (DHCP):** Bring the interface up and attempt to obtain an IP address via DHCP.
        -   **Deactivate:** Bring the interface down.
        -   **View Detailed Status:** Show the full `ifconfig` output for the interface.

3.  **Manage Wi-Fi Connections:**
    -   Lists existing `wlan` (virtual Wi-Fi) interfaces and physical Wi-Fi capable devices.
    -   **Create wlan interface:** Allows creating a new `wlan` interface (e.g., `wlan0`) from a physical Wi-Fi device.
    -   For a selected `wlan` interface, allows you to:
        -   **Scan for Networks:** Perform a Wi-Fi scan and display available networks (SSID, signal, security flags).
        -   **Connect to Network:** Attempt to connect to a network.
            -   Prompts for SSID.
            -   Asks if the network is Open (no password) or secured.
            -   If secured, prompts for a password (primarily for WPA-PSK).
            -   Configures the connection using `wpa_cli` and attempts to get an IP via `dhclient`.
        -   **Disconnect:** Disconnect from the currently associated Wi-Fi network.
        -   **View Detailed Status:** Show `ifconfig` and `wpa_cli status` output for the `wlan` interface.
        -   **Destroy this wlan interface:** Remove the `wlan` virtual interface.

## Important Notes

-   **Non-Persistent Configuration:** This utility manages network settings for the **current session only**. Changes made (e.g., IP addresses obtained via DHCP, Wi-Fi connections established) are generally not saved automatically to system configuration files like `/etc/rc.conf`. To make network configurations persistent across reboots, you will need to edit `/etc/rc.conf` or use other FreeBSD system configuration tools.
-   **Advanced Configuration:** `networkwizard.sh` aims to simplify common tasks. For complex network setups, advanced interface configurations, or detailed troubleshooting, direct use of standard FreeBSD command-line tools (`ifconfig`, `wpa_cli`, `route`, `netstat`, etc.) and manual editing of configuration files remains the most appropriate approach.
-   **Error Handling:** The script includes basic error reporting, but the output of underlying system commands might be necessary for diagnosing complex issues.
-   **Wi-Fi Security:** Connection support is primarily focused on Open and WPA-PSK (WPA/WPA2 Personal) networks. Connecting to WEP networks might work with password entry but is less tested. Enterprise (WPA-EAP) networks are not explicitly supported by the connection logic.
