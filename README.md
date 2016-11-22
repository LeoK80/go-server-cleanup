# go-server-cleanup

run the script from the machine where your go-server is installed.

It assumes having the default setup and file structure:
'/var/lib/go-server/artifacts/pipelines'

By default it will chuck anything older than 180 days, unless there is 15 builds or less present in a pipeline. In the latter case nothing (more) will be deleted from the pipeline and the scripts moves on to the next pipeline.

##Parameters
Optionally on the bash command you can pass parameters to set your own retention period in days and/or the minimum amount of builds you want to keep in a pipeline.

parameters:
- '-h'  for help
- '-r' or 'R' for Retention time in days
- '-b' or 'B' for Builds to keep in a pipeline

example command: './cleanup.sh -r 100 -b 10'
This would chuck out any builds older than 100 days, unless there is 10 or less builds in a pipeline. In the latter case nothing (more) will deleted and the next pipeline is evaluated.

##Take Care - Common Sense
This script contains a 'rm -rf' command and if amended might behave unexpectedly and start deleting stuff you don't wont to loose.
So, as with any potentially catastrophic scripts, make sure to:
- **NOT** run the script as ROOT!! Use an appropriate user (e.g. 'go')
- make sure you have backups before you start
- running it is at your own risk

**tip: set it up to execute periodically as a cron job and you'll have a lot less worries about go-server disk space issues**
