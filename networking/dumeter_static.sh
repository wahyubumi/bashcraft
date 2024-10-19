#!/bin/bash

# ANSI color codes for colored output
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No color

# Function to print the header in a fixed location
print_header() {
    tput cup 0 0  # Move the cursor to row 0, column 0
    echo -e "${GREEN}DU Meter v0.3:${NC} ${YELLOW}Simply count bytes (in kBytes/sec)${NC}"
    echo -e "${RED}--------------------------------------${NC}"
    tput cup 2 0  # Move the cursor below the header
}

# Declare arrays to store the last RX and TX bytes for each interface
declare -A last_RX last_TX

# Clear the screen initially
clear

# Infinite loop to monitor traffic
while true; do
    # Print the header
    print_header

    # Read /proc/net/dev and skip the first two header lines
    row=3  # Start printing content below the header
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

            # Move the cursor to the current row for dynamic updates
            tput cup $row 0
            # Display the speeds
            printf "~%.6s: (%8.2f/%8.2f) " "$interface" "$rx_spd" "$tx_spd"
            row=$((row + 1))  # Move to the next line for each interface
        fi
    done < <(tail -n +3 /proc/net/dev)

    sleep 1
done
