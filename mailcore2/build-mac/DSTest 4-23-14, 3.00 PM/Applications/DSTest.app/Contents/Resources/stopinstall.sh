#!/bin/sh

/bin/launchctl unload -w /Library/LaunchDaemons/com.lcl.TestDaemon.plist
/bin/launchctl start com.lcl.TestDaemon
exit 0
