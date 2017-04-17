#!/bin/sh
# Add your shell script below
# Created 2015/10 by R. Lohr
#
#
# Problem: By default, tqagg runs every four hours starting at
# midnight. It usually only takes a couple of seconds to run,
# but it does a great deal of I/O during that brief period.
# Multiply that by several thousand OS images sharing a SAN
# environment, and buffer credits will be depleted.
# Unfortunately there's no way to adjust the time settings from
# the command line, so I needed a way to brute-force the change
# and make it appear random. (There is a way to do this via
# policy from the admin console, but it only works on an open
# database.)
#
# The logic: We're going to assume that the last digit of a
# server's IP address is randomly distributed throughout the
# environment, and change the start time accordingly. This
# will the total amount of I/O into 10 smaller loads, each of
# which should be approximately 1/10 of the total load. When
# spreading that evenly through the 4-hour window, the groups
# will kick off at 24-minute intervals.
#
# Oh, and there's one other kicker. We can't assume that this
# will only have to be done once. IP addresses change.
#
#
#
# First, assign directories, files, temporary files
TQDATADIR="/opt/teamquest/data/production"
tmpdef="/tmp/agentdef"
tmplist="/tmp/agentlist"
#
# Next, we need to stop TQ Manager.
#
#
/opt/teamquest/manager/bin/tqmgr -shutdown
#
# We can't assume that this is the first time the script has
# been run. We'll find out by checking to see if there are
# backups of the original files. If there are, we'll copy
# them back. If not, we'll create them just in case.
#
if [ -e $TQDATADIR/agentdef.orig ]; then
/bin/cp $TQDATADIR/agentdef.orig $TQDATADIR/agentdef
else
/bin/cp $TQDATADIR/agentdef $TQDATADIR/agentdef.orig
fi
if [ -e $TQDATADIR/agentlist.orig ]; then
/bin/cp $TQDATADIR/agentlist.orig $TQDATADIR/agentlist
else
/bin/cp $TQDATADIR/agentlist $TQDATADIR/agentlist.orig
fi
#
#
# Get the server name and use it get the last octet of the
# IP address. Then, if necessary, divide by 10 or 100 and
# take the remainder to get the last digit. (Remember that we
# have to take into account the fact that in this case 'wc -c'
# will report an extra character.)
#
server=`/bin/uname -n`
digit=`cat /etc/hosts | grep $server | /bin/awk '{print $1}' | /bin/awk -F. '{print $4}'`
count=`/bin/echo $digit | wc -c`
if [ $count = 3 ]; then
digit=$((digit %= 10));
elif [ $count = 4 ]; then
digit=$((digit %= 100));
digit=$((digit %= 10));
fi
#
#
# The string we're searching for is a unique occurrence of
# 'value=0000'. We'll work through an if loop and replace
# the numeric string with the appropriate offset.
#
if [ $digit = 0 ]; then
cat $TQDATADIR/agentdef > $tmpdef
cat $TQDATADIR/agentlist > $tmplist
elif [ $digit = 1 ]; then
cat $TQDATADIR/agentdef | sed 's/value=0000/value=0024/' > $tmpdef
cat $TQDATADIR/agentlist | sed 's/map=TIMED%2C0000%2C0400/map=TIMED%2C0024%2C0400/' > $tmplist
elif [ $digit = 2 ]; then
cat $TQDATADIR/agentdef | sed 's/value=0000/value=0048/' > $tmpdef
cat $TQDATADIR/agentlist | sed 's/map=TIMED%2C0000%2C0400/map=TIMED%2C0048%2C0400/' > $tmplist
elif [ $digit = 3 ]; then
cat $TQDATADIR/agentdef | sed 's/value=0000/value=0112/' > $tmpdef
cat $TQDATADIR/agentlist | sed 's/map=TIMED%2C0000%2C0400/map=TIMED%2C0112%2C0400/' > $tmplist
elif [ $digit = 4 ]; then
cat $TQDATADIR/agentdef | sed 's/value=0000/value=0136/' > $tmpdef
cat $TQDATADIR/agentlist | sed 's/map=TIMED%2C0000%2C0400/map=TIMED%2C0136%2C0400/' > $tmplist
elif [ $digit = 5 ]; then
cat $TQDATADIR/agentdef | sed 's/value=0000/value=0200/' > $tmpdef
cat $TQDATADIR/agentlist | sed 's/map=TIMED%2C0000%2C0400/map=TIMED%2C0200%2C0400/' > $tmplist
elif [ $digit = 6 ]; then
cat $TQDATADIR/agentdef | sed 's/value=0000/value=0224/' > $tmpdef
cat $TQDATADIR/agentlist | sed 's/map=TIMED%2C0000%2C0400/map=TIMED%2C0224%2C0400/' > $tmplist
elif [ $digit = 7 ]; then
cat $TQDATADIR/agentdef | sed 's/value=0000/value=0248/' > $tmpdef
cat $TQDATADIR/agentlist | sed 's/map=TIMED%2C0000%2C0400/map=TIMED%2C0248%2C0400/' > $tmplist
elif [ $digit = 8 ]; then
cat $TQDATADIR/agentdef | sed 's/value=0000/value=0312/' > $tmpdef
cat $TQDATADIR/agentlist | sed 's/map=TIMED%2C0000%2C0400/map=TIMED%2C0312%2C0400/' > $tmplist
elif [ $digit = 9 ]; then
cat $TQDATADIR/agentdef | sed 's/value=0000/value=0336/' > $tmpdef
cat $TQDATADIR/agentlist | sed 's/map=TIMED%2C0000%2C0400/map=TIMED%2C0336%2C0400/' > $tmplist
fi
#
#
# Replace the original files with the doctored ones.
#
/bin/cp $tmpdef $TQDATADIR/agentdef
/bin/cp $tmplist $TQDATADIR/agentlist
#
#
# Delete the temporary files
#
/bin/rm $tmpdef $tmplist
#
#
# Restart TQ Manager
#
/opt/teamquest/manager/bin/tqmgr -service
exit 0
#!/bin/bash
#
#
# Created 2015/10 by R. Lohr
#
#
# Problem: By default, tqagg runs every four hours starting at
# midnight. It usually only takes a couple of seconds to run,
# but it does a great deal of I/O during that brief period.
# Multiply that by several thousand OS images sharing a SAN
# environment, and buffer credits will be depleted.
# Unfortunately there's no way to adjust the time settings from
# the command line, so I needed a way to brute-force the change
# and make it appear random. (There is a way to do this via
# policy from the admin console, but it only works on an open
# database.)
#
# The logic: We're going to assume that the last digit of a
# server's IP address is randomly distributed throughout the
# environment, and change the start time accordingly. This
# will the total amount of I/O into 10 smaller loads, each of
# which should be approximately 1/10 of the total load. When
# spreading that evenly through the 4-hour window, the groups
# will kick off at 24-minute intervals.
#
# Oh, and there's one other kicker. We can't assume that this
# will only have to be done once. IP addresses change.
#
#
#
# First, assign directories, files, temporary files
TQDATADIR="/opt/teamquest/data/production"
tmpdef="/tmp/agentdef"
tmplist="/tmp/agentlist"
#
# Next, we need to stop TQ Manager.
#
#
/opt/teamquest/manager/bin/tqmgr -shutdown
#
# We can't assume that this is the first time the script has
# been run. We'll find out by checking to see if there are
# backups of the original files. If there are, we'll copy
# them back. If not, we'll create them just in case.
#
if [ -e $TQDATADIR/agentdef.orig ]; then
/bin/cp $TQDATADIR/agentdef.orig $TQDATADIR/agentdef
else
/bin/cp $TQDATADIR/agentdef $TQDATADIR/agentdef.orig
fi
if [ -e $TQDATADIR/agentlist.orig ]; then
/bin/cp $TQDATADIR/agentlist.orig $TQDATADIR/agentlist
else
/bin/cp $TQDATADIR/agentlist $TQDATADIR/agentlist.orig
fi
#
#
# Get the server name and use it get the last octet of the
# IP address. Then, if necessary, divide by 10 or 100 and
# take the remainder to get the last digit. (Remember that we
# have to take into account the fact that in this case 'wc -c'
# will report an extra character.)
#
server=`/bin/uname -n`
digit=`cat /etc/hosts | grep $server | /bin/awk '{print $1}' | /bin/awk -F. '{print $4}'`
count=`/bin/echo $digit | wc -c`
if [ $count = 3 ]; then
digit=$((digit %= 10));
elif [ $count = 4 ]; then
digit=$((digit %= 100));
digit=$((digit %= 10));
fi
#
#
# The string we're searching for is a unique occurrence of
# 'value=0000'. We'll work through an if loop and replace
# the numeric string with the appropriate offset.
#
if [ $digit = 0 ]; then
cat $TQDATADIR/agentdef > $tmpdef
cat $TQDATADIR/agentlist > $tmplist
elif [ $digit = 1 ]; then
cat $TQDATADIR/agentdef | sed 's/value=0000/value=0024/' > $tmpdef
cat $TQDATADIR/agentlist | sed 's/map=TIMED%2C0000%2C0400/map=TIMED%2C0024%2C0400/' > $tmplist
elif [ $digit = 2 ]; then
cat $TQDATADIR/agentdef | sed 's/value=0000/value=0048/' > $tmpdef
cat $TQDATADIR/agentlist | sed 's/map=TIMED%2C0000%2C0400/map=TIMED%2C0048%2C0400/' > $tmplist
elif [ $digit = 3 ]; then
cat $TQDATADIR/agentdef | sed 's/value=0000/value=0112/' > $tmpdef
cat $TQDATADIR/agentlist | sed 's/map=TIMED%2C0000%2C0400/map=TIMED%2C0112%2C0400/' > $tmplist
elif [ $digit = 4 ]; then
cat $TQDATADIR/agentdef | sed 's/value=0000/value=0136/' > $tmpdef
cat $TQDATADIR/agentlist | sed 's/map=TIMED%2C0000%2C0400/map=TIMED%2C0136%2C0400/' > $tmplist
elif [ $digit = 5 ]; then
cat $TQDATADIR/agentdef | sed 's/value=0000/value=0200/' > $tmpdef
cat $TQDATADIR/agentlist | sed 's/map=TIMED%2C0000%2C0400/map=TIMED%2C0200%2C0400/' > $tmplist
elif [ $digit = 6 ]; then
cat $TQDATADIR/agentdef | sed 's/value=0000/value=0224/' > $tmpdef
cat $TQDATADIR/agentlist | sed 's/map=TIMED%2C0000%2C0400/map=TIMED%2C0224%2C0400/' > $tmplist
elif [ $digit = 7 ]; then
cat $TQDATADIR/agentdef | sed 's/value=0000/value=0248/' > $tmpdef
cat $TQDATADIR/agentlist | sed 's/map=TIMED%2C0000%2C0400/map=TIMED%2C0248%2C0400/' > $tmplist
elif [ $digit = 8 ]; then
cat $TQDATADIR/agentdef | sed 's/value=0000/value=0312/' > $tmpdef
cat $TQDATADIR/agentlist | sed 's/map=TIMED%2C0000%2C0400/map=TIMED%2C0312%2C0400/' > $tmplist
elif [ $digit = 9 ]; then
cat $TQDATADIR/agentdef | sed 's/value=0000/value=0336/' > $tmpdef
cat $TQDATADIR/agentlist | sed 's/map=TIMED%2C0000%2C0400/map=TIMED%2C0336%2C0400/' > $tmplist
fi
#
#
# Replace the original files with the doctored ones.
#
/bin/cp $tmpdef $TQDATADIR/agentdef
/bin/cp $tmplist $TQDATADIR/agentlist
#
#
# Delete the temporary files
#
/bin/rm $tmpdef $tmplist
#
#
# Restart TQ Manager
#
/opt/teamquest/manager/bin/tqmgr -service
exit 0
