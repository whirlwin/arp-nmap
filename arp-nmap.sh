#!/bin/bash

# arp-nmap: Uses ARP to discover hosts and scans them with nmap
# Usage: ./arp-nmap.sh

set -e

# Check if required commands are available
command -v arp >/dev/null 2>&1 || { echo >&2 "Error: arp command not found. Please install net-tools."; exit 1; }
command -v nmap >/dev/null 2>&1 || { echo >&2 "Error: nmap command not found. Please install nmap."; exit 1; }

# Check if running with appropriate permissions
if [ "$EUID" -ne 0 ]; then 
    echo "Warning: Running without root privileges. Some nmap features may be limited."
    echo "Consider running with sudo for full functionality."
    echo ""
fi

echo "==========================================="
echo "ARP-NMAP: Network Host and Port Scanner"
echo "==========================================="
echo ""

echo "Step 1: Discovering hosts using ARP..."
echo ""

# Get list of IP addresses from arp -a
# Filter out incomplete entries and extract IP addresses
arp_output=$(arp -a | grep -v "incomplete" | awk '{print $2}' | tr -d '()' | sort -u)

# Count the number of hosts
host_count=$(echo "$arp_output" | grep -c "^[0-9]" || echo "0")

if [ "$host_count" -eq 0 ]; then
    echo "No hosts found in ARP table."
    echo "Make sure you're on a network with other devices."
    exit 0
fi

echo "Found $host_count host(s) in ARP table:"
echo "$arp_output"
echo ""

echo "Step 2: Scanning ports with nmap..."
echo ""

# Create temporary file to store results
temp_file=$(mktemp)

# Print table header
printf "%-15s | %-10s | %-15s | %s\n" "IP ADDRESS" "PORT" "STATE" "SERVICE"
printf "%-15s-+-%-10s-+-%-15s-+-%s\n" "---------------" "----------" "---------------" "---------------"

# Scan each host
for ip in $arp_output; do
    # Skip if IP is empty
    [ -z "$ip" ] && continue
    
    # Run nmap scan for common ports (top 100 ports by default)
    # Using -Pn to skip host discovery since we already know host is up
    # Using -T4 for faster scanning
    # Using --open to only show open ports
    nmap_output=$(nmap -Pn -T4 --open "$ip" 2>/dev/null | grep "^[0-9]" || echo "")
    
    if [ -z "$nmap_output" ]; then
        # No open ports found
        printf "%-15s | %-10s | %-15s | %s\n" "$ip" "-" "no open ports" "-"
    else
        # Parse nmap output and display in table format
        first_line=true
        while IFS= read -r line; do
            # Extract port, state, and service
            port=$(echo "$line" | awk '{print $1}' | cut -d'/' -f1)
            state=$(echo "$line" | awk '{print $2}')
            service=$(echo "$line" | awk '{print $3}')
            
            if [ "$first_line" = true ]; then
                printf "%-15s | %-10s | %-15s | %s\n" "$ip" "$port" "$state" "$service"
                first_line=false
            else
                printf "%-15s | %-10s | %-15s | %s\n" "" "$port" "$state" "$service"
            fi
        done <<< "$nmap_output"
    fi
done

# Cleanup
rm -f "$temp_file"

echo ""
echo "Scan complete!"
