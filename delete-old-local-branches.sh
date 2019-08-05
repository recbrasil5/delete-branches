
#########################
# LOCAL BRANCH DELETION #
#########################
performDelete=false
start=$(date +%s)
relativePath="../../Eureka/OM3/delete-branches-logs/"
d=`date +%Y%d%m_%H%M%S`
logFileName="local-log_$d.txt"
localDeleteFileName="local-branches-to-delete_$d.txt"
localDeleteFullPath="$relativePath$localDeleteFileName"
logFullPath="$relativePath$logFileName"

#####################################################################################
#                              Functions                                            #
#####################################################################################
function secs_to_mins_and_secs() {
    if [[ -z ${1} || ${1} -lt 60 ]] ;then
        min=0 ; secs="${1}"
    else
        time_mins=$(echo "scale=2; ${1}/60" | bc)
        min=$(echo ${time_mins} | cut -d'.' -f1)
        secs="0.$(echo ${time_mins} | cut -d'.' -f2)"
        secs=$(echo ${secs}*60|bc|awk '{print int($1+0.5)}')
    fi
    echo "Time Elapsed : ${min} minutes and ${secs} seconds."
}

function usage {
  echo ""
  echo -e "\e[0musage:"
  echo "Pass in '-d' or '--delete' to cause script to perform actual branch deletion."
}
########################################################################################

# ensure number of parameters doesn't exceed 1
if [ "$#" -gt 1 ]; then
  echo -e "\e[31m You passed $# parameters and only 1 optional parameter is allowed."
  usage
  exit 1
fi

# search for the help tag and short-circuit if user indicates they want more understanding
for arg in "$@"
do
    if [ "$arg" == "--help" ] || [ "$arg" == "-h" ]
    then
        usage
        exit 0
    fi
done

# check 1st argument for -d or --delete
if [ "$1" == "--delete" ] || [ "$1" == "-d" ]; then
  performDelete=true
  echo -e "\e[31mATTENTION!!! Script will perform local deletion of branches. Starting now..."
else
  performDelete=false
  echo -e "\e[92mScript will not perform local deletion of branches. Starting now..."
fi

# prune remote branches
git remote prune origin 

# https://erikaybar.name/git-deleting-old-local-branches 
if [ "$performDelete" = true ]; then
    # actually delete them all at once -->  -D to force it
    git branch -vv | grep 'origin/.*: gone]' | awk '{print $1}' | xargs git branch -D >> $logFullPath
else
    git branch -vv | grep 'origin/.*: gone]' | awk '{print $1}' >> $localDeleteFullPath
fi

#log stats
if [ "$performDelete" = true ]; then
  echo "" >> $logFullPath
  secs_to_mins_and_secs "$(($(date +%s) - ${start}))" >> $logFullPath
else
  echo "" >> $localDeleteFullPath
  secs_to_mins_and_secs "$(($(date +%s) - ${start}))" >> $localDeleteFullPath
fi