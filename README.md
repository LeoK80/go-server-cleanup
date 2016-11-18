# go-server-cleanup

run the script from the machine where your go-server is installed.

It assumes having the default setup and file structure:
'/var/lib/go-server/artifacts/pipelines'

By default it will chuck anything older than 180 days. Optionally on the bash command you can pass a number as argument to set a deviating amount of days you wish to retain.

By default it will always keep at least 15 of your last builds.
Also nothing will get deleted in a pipeline if there is 15 builds or less.

As with any potentially catastrophic scripts, make sure to:
- have a backup of your complete system or snapshot your vm
- run the go-server backup
- running it is at your own risk ;)

**tip: set it up to execute periodically as a cron job and you'll have a lot less worries about go-server disk space issues**
