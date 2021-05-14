[![Gitter chat](https://img.shields.io/badge/gitter-join%20chat-brightgreen.svg)](https://gitter.im/CiscoSecurity/Lobby "Gitter chat")

# eStreamer eNcore
This is a fork of the Cisco eStreamer client.

The Cisco Event Streamer (also known as eStreamer) allows you to stream System intrusion,
discovery, and connection data from Firepower Management Center or managed device (also
referred to as the eStreamer server) to external client applications (e.g.: Syslog, Elasticsearch, Azure Sentinel, ...).

eStreamer responds to client requests with terse, compact, binary encoded messages – this
keeps it fast.

eNcore is a new all-purpose client which requests all possible events from eStreamer, parses
the binary content and outputs events in various formats to support other SIEMs.

# Prerequirements
* Python 3.x
* pip install pyOpenSSL
* for Windows:
     pip install win_inet_pton

# Quick install
## Windows
* Navigate to the directory you want to contain eStreamer eNcore
* Run eNcore: `./encore.ps1`
* Run a connectivity test: `./encore.ps1 test` (and enter the pkcs12 password)
* View the log output `Get-Content -Tail 30 -Wait estreamer.log`
* `./encore.ps1 foreground` - run in the foreground
* `./encore.ps1 start` - starts a background task
* `./encore.ps1 stop` - this will stop the background task
* `./encore.ps1 restart` - this will restart the background task
* `./encore.ps1 clean` - this will remove all data files within a 12 hour window

## Linux
* Navigate to the directory you want to contain eStreamer eNcore
* Run eNcore: `./encore.sh`
* Run a connectivity test: `./encore.sh test` (and enter the pkcs12 password)
* View the log output `tail -f estreamer.log`
* `./encore.sh foreground` - run in the foreground
* `./encore.sh start` - starts a background task
* `./encore.sh stop` - this will stop the background task
* `./encore.sh restart` - this will restart the background task
* `./encore.sh clean` - this will remove all data files within a 12 hour window

## Configuration
See in the files: estreamer.conf or default.conf
More details will follow...

# License

Copyright (c) 2017 by Cisco Systems, Inc.

[Cisco EULA](http://www.cisco.com/c/en/us/about/legal/cloud-and-software/software-terms.html)

    ALL RIGHTS RESERVED. THESE SOURCE FILES ARE THE SOLE PROPERTY
    OF CISCO SYSTEMS, Inc. AND CONTAIN CONFIDENTIAL  AND PROPRIETARY
    INFORMATION.  REPRODUCTION OR DUPLICATION BY ANY MEANS OF ANY
    PORTION OF THIS SOFTWARE WITHOUT PRIOR WRITTEN CONSENT OF
    CISCO SYSTEMS, Inc. IS STRICTLY PROHIBITED.
