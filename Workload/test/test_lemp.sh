#!/bin/bash

# Set runtime duration
runtime="5 minute"
endtime=$(date -ud "$runtime" +%s)

# Loop until the end time is reached
while [[ $(date -u +%s) -le $endtime ]]; do
    # Check if the FQDN is reachable
    if curl -I -s -f $FQDN > /dev/null ; then
        # Fetch and display the first 9 lines of the response
        curl -L -s -f $FQDN 2> /dev/null | head -n 9
        break
    else
        # Wait for 10 seconds before retrying
        sleep 10
    fi
done