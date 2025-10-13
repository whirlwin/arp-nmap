# arp-nmap
Uses ARP to discover hosts' open ports on the local network

## Description
This tool performs a two-step network scan:
1. Uses `arp -a` to discover all hosts in the local network ARP table
2. Runs `nmap` on each discovered host to identify open ports and services

The results are presented in an easy-to-read table format.

## Requirements
- `arp` command (usually provided by net-tools package)
- `nmap` command
- Bash shell
- Optional: root/sudo privileges for enhanced nmap scanning capabilities

## Installation
Make sure you have the required tools installed:

```bash
# On Debian/Ubuntu
sudo apt-get install net-tools nmap

# On RHEL/CentOS/Fedora
sudo yum install net-tools nmap

# On macOS
brew install nmap
```

## Usage
Simply run the script:

```bash
./arp-nmap.sh
```

For better scanning results, run with sudo:

```bash
sudo ./arp-nmap.sh
```

## Example Output
```
===========================================
ARP-NMAP: Network Host and Port Scanner
===========================================

Step 1: Discovering hosts using ARP...

Found 3 host(s) in ARP table:
192.168.1.1
192.168.1.100
192.168.1.105

Step 2: Scanning ports with nmap...

IP ADDRESS      | PORT       | STATE           | SERVICE
----------------+------------+-----------------+----------------
192.168.1.1     | 80         | open            | http
                | 443        | open            | https
192.168.1.100   | 22         | open            | ssh
                | 80         | open            | http
192.168.1.105   | -          | no open ports   | -

Scan complete!
```

## Notes
- The script scans the top 1000 most common ports by default (nmap's default behavior)
- Hosts with no open ports are still listed in the results
- Running without root privileges may limit some nmap features
- The ARP table only contains hosts that have recently communicated on the local network
