#!/bin/bash

LOGFILE="system_health.log"
DATE=$(date "+%Y-%m-%d %H:%M:%S")

CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
RAM_USAGE=$(free | awk '/Mem/ {printf("%.2f"), $3/$2 * 100}')
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

NGINX_STATUS=$(systemctl is-active nginx 2>/dev/null)
APACHE_STATUS=$(systemctl is-active apache2 2>/dev/null)

echo "[$DATE] CPU: $CPU_USAGE% | RAM: $RAM_USAGE% | DISK: $DISK_USAGE%" >> $LOGFILE

if (( $(echo "$CPU_USAGE > 80" | bc -l) )); then
    echo "WARNING: High CPU usage!" >> $LOGFILE
fi

if (( $(echo "$RAM_USAGE > 80" | bc -l) )); then
    echo "WARNING: High RAM usage!" >> $LOGFILE
fi

if [ "$DISK_USAGE" -gt 80 ]; then
    echo "WARNING: High Disk usage!" >> $LOGFILE
fi

if [ "$NGINX_STATUS" != "active" ] && [ "$APACHE_STATUS" != "active" ]; then
    echo "WARNING: Web server is not running!" >> $LOGFILE
fi

echo "Health check completed."
