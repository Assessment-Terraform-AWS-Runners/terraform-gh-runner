#!/bin/bash

# Script to monitor CPU, Memory, Disk usage

echo "================== EC2 Monitoring =================="
echo "Timestamp: $(date)"
echo ""

# CPU usage
echo "CPU Usage (%):"
top -bn1 | grep "Cpu(s)" | awk '{print "User: "$2"% | System: "$4"% | Idle: "$8"%"}'
echo ""

# Memory usage
echo "Memory Usage (MB):"
free -m | awk 'NR==2{printf "Used: %s MB | Free: %s MB\n", $3,$4}'
echo ""

# Disk usage
echo "Disk Usage (%):"
df -h | awk '$NF=="/"{printf "Used: %s | Available: %s | Use%%: %s\n", $3,$4,$5}'
echo "====================================================="