#!/bin/sh
/usr/bin/frontail  /var/log/syslog -p 9001  --ui-highlight  --ui-highlight-preset /opt/trm/frontail.json -l 100
