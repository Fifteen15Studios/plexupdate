# Description
Forked from https://github.com/martinorob/plexupdate

Automatically update Plex Media Server on Synology NAS

# How to
## Download the script and put it into a Scheduled Task
### Setup Download Script

SSH into your NAS

execute: 

```
mkdir /volume1/Scripts
wget https://raw.githubusercontent.com/Fifteen15Studios/plexupdate/master/plexupdate.sh
```

### Setup Update Scheduler
- Go back to Synology Console
- Open Control Panel
- Open Task Scheduler
- Click Create -> Scheduled Task -> User-defined script
- Enter Task as Update Plex
- Click Schedule Tab
- Change Schedule to fit needs
- Click Task Settings Tab
- Enter User-defined script as bash /volume1/Scripts/plexupdate.sh
- Click OK

Thanks to https://forums.plex.tv/u/j0nsplex

# Todo
Merge with 
- https://gist.github.com/seanhamlin/dcde16a164377dca87a798a4c2ea051c
- https://forums.plex.tv/t/script-to-auto-update-plex-on-synology-nas-rev4/479748/36?u=martino
