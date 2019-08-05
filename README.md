# delete-branches

-   Contains bash script `delete-old-remote-branches.sh` to delete remote branches older than 4 weeks.
-   Contains bash script `delete-old-local-branches.sh` to prune and delete local branches that have stale tracking.

Important: You'll always want to run `delete-old-remote-branches.sh` prior to running `delete-old-local-branches.sh`.
Note: Make sure to run this script if you've checked out a branch that isn't going to get deleted (ie: `develop`), otherwise you'll encounter an error.

# usage

Call either script with -h or --help to get usage information
ie: $ /c/Eureka/OM3/delete-branches/delete-old-remote-branches.sh -h
or 
    $ /c/Eureka/OM3/delete-branches/delete-old-remote-branches.sh --help

This will display how to call the script.

Note: This also works for the other script:
ie: $ /c/Eureka/OM3/delete-branches/delete-old-local-branches.sh -h
or 
    $ /c/Eureka/OM3/delete-branches/delete-old-local-branches.sh --help

# dry run

Running the script without an argument will perform a dry-run and not delete any branches remotely or locally.
ie: $ /c/Eureka/OM3/delete-branches/delete-old-remote-branches.sh
$ /c/Eureka/OM3/delete-branches/delete-old-local-branches.sh

The 'all-branches.txt' would contain a list of information on all remote branches.
This can be reviewed as well as the 'branches-to-delete.txt' file which is mentioned below.
In this case 'branches-to-delete.txt' would contain the remote branches that would have been deleted.

# real run

If you call the script with -d or --delete, it will result in a real-run that can have damaging effects.

ie: $ /c/Eureka/OM3/delete-branches/delete-old-remote-branches.sh -d 
or 
   $ /c/Eureka/OM3/delete-branches/delete-old-remote-branches.sh --delete

It will be common practice to first run the dry-run and review what will be deleted prior to the actual run.

# local branch cleanup

The script will clean up your local branches should be cleaned up so no orphans exist.
Note: Any branches that are not tracked will not be deleted. So if you had a playground branch, it won't be deleted if it hasn't been pushed and tracked.

# relative path

The relative path describes the path from the directory where you're running the shell script to the directory
where you want your log files (.txt) created at.
for example: relativePath='../../Eureka/OM3/delete-branches-logs/'
this means i'm running the script two-levels outside root. So I back up ../../ to get to root
then the path of the log files is ~/Eureka/OM3/delete-branches-logs/
Feel free to modify these paths (as you'll need to depending on where the repo you're working with lives your machine).

-   Note: this script will not create any directories that do not previously exist.

# logging (remote)

If you're doing a dry-run, the following files will be spit out:

all-branches\_(timestamp).txt: contains branch name & commit info for all remote branches
branches-to-delete\_(timestamp).txt: contains branch name & commit info for all remote branches that would be deleted if NOT a dry-run.
branches-to-keep\_(timestamp).txt: contains branch name & commit info for all remote branches that would be kept if NOT a dry-run.

If you're doing the actual run, the following files will be spit out:

all-branches\_(timestamp).txt: contains branch name & commit info for all remote branches
remote-log\_(timestamp).txt: contains timestamp & log of what happened to all remote branches processed

Note: The `delete-old-remote-branches.sh` script will spit out stats like totalBranchCount, deleteBranchCount, keepBranchCount & duration for dry-run (all text files) or actual-run (remote-log.txt).

# logging (local)

If you're doing a dry-run, the following files will be spit out:
local-branches-to-delete\_(timestamp).txt: contains branch name & commit info for all remote branches that would be deleted if NOT a dry-run.

If you're doing the actual run, the following files will be spit out:
local-log\_(timestamp).txt: contains timestamp & log of what happened to all local branches processed

Note: The `delete-old-local-branches.sh` script will spit out duration for dry-run (local-branches-to-delete.txt) or actual-run (local-log.txt).
