#!/bin/bash

echo "DU Meter v0.3: Simply count bytes (in kBytes/sec)"
echo "--------------------------------------"

# Declare arrays to store the last RX and TX bytes for each interface
declare -A last_RX last_TX

# Infinite loop to monitor traffic
while true; do
    # Read /proc/net/dev and skip the first two header lines
    while read -r line; do
        if [[ "$line" == *:* ]]; then
            # Extract interface name and stats
            interface=$(echo "$line" | cut -d':' -f1 | tr -d ' ')
            rx_bytes=$(echo "$line" | awk '{print $2}')
            tx_bytes=$(echo "$line" | awk '{print $10}')

            # Calculate RX and TX speeds if previous data exists
            if [[ -n "${last_RX[$interface]}" && -n "${last_TX[$interface]}" ]]; then
                rx_spd=$(echo "scale=2; ($rx_bytes - ${last_RX[$interface]}) / 1024" | bc)
                tx_spd=$(echo "scale=2; ($tx_bytes - ${last_TX[$interface]}) / 1024" | bc)
            else
                rx_spd=0
                tx_spd=0
            fi

            # Store the current RX and TX bytes for the next iteration
            last_RX[$interface]=$rx_bytes
            last_TX[$interface]=$tx_bytes

            # Display the speeds
            printf "~%.6s: (%8.2f/%8.2f) " "$interface" "$rx_spd" "$tx_spd"
        fi
    done < <(tail -n +3 /proc/net/dev)

    sleep 1
    echo
done
