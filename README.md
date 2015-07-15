# nagios-plugin-failedprocess

## Overview

Tools for making failed bash jobs easily alerting via nagios

## Authors

### Main Author
 Nikola Jnaceski (@deathanchor)

## Installation

In your Nagios plugins directory add the failedprocesscheck.sh
In your scripts source the failure_alert.sh script at the beginning. You can override the $ALERTDIR and $ALERTFILE variables to determine which directory or filenames you want created on failures before the source statement in your code.

## Usage

### Testing the Alert

Once you have setup the alert it should alert with UNKNOWN unless you created the directory already. To test the alert if you are using the default options, just copy the failure_alert.sh and trigger_failalert.sh files to the machine being monitored and run trigger_failalert.sh:
<pre><code>
$ ./trigger_failalert.sh # triggers the alert
Failure will alert
$ cat /opt/log/failalert/trigger_failalert.sh 
started: Wed Jul 15 20:15:50 UTC 2015; startdir: /home/user; cmd: ./trigger_failalert.sh
$ ./trigger_failalert.sh off # does a successful run
Success
</code></pre>

### adding it to your scripts

Just source near the beginning wherever you are storing the failure_alert.sh in your code. Usually I just keep it together with the failedprocesscheck.sh script in the nagios plugins.

<pre><code>
#!/bin/bash

source /path/to/failure_alert.sh

# the rest of my code
# if any of the commands fail and trigger a trap ERR this will cause an alert

false; # triggers an alert

</code></pre>

Every fail run adds a line to $ALERTFILE in the $ALERTDIR.
Every successful run removes the ALERTFILE in the $ALERTDIR.

