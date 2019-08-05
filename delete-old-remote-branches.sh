##############################
# OLD REMOTE BRANCH DELETION #
##############################
performDelete=false
start=$(date +%s)
totalBranchCount=0
deleteBranchCount=0
keepBranchCount=0
relativePath="../../Eureka/OM3/delete-branches-logs/"
d=`date +%Y%d%m_%H%M%S`
allBrancesFileName="all-branches_$d.txt"
deleteFileName="branches-to-delete_$d.txt"
keepFileName="branches-to-keep_$d.txt"
localDeleteFileName="local-branches-to-delete_$d.txt"
logFileName="remote-log_$d.txt"
allBranchesFullPath="$relativePath$allBrancesFileName"
deleteFullPath="$relativePath$deleteFileName"
keepFullPath="$relativePath$keepFileName"
localDeleteFullPath="$relativePath$localDeleteFileName"
logFullPath="$relativePath$logFileName"
staleTimestamp=$(date -d "now - 4 weeks" +"%s")

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

#check 1st argument for -d or --delete
if [ "$1" == "--delete" ] || [ "$1" == "-d" ]; then
  performDelete=true
  echo -e "\e[31mATTENTION!!! Script will perform remote deletion of branches. Starting now..."
else
  echo -e "\e[92mScript will not perform remote deletion of branches. Starting now..."
fi

#get all remote branches (sorted by committerdate descending)
branches=$(git branch -r --sort=-committerdate | grep -v HEAD)
#loop through each branch and perform operations
for branch in ${branches}; do
  #increment counter
  totalBranchCount=$(($totalBranchCount+1))
  lastCommitInfo=$(git show --format="<%an> - %s - %cI - %cr " $branch | head -n 1)
  lastCommitTimestampStr=$(git show --format="%ci" $branch | head -n 1)
  lastCommitTimestamp=$(date -d "$lastCommitTimestampStr" +"%s")
  #log to all-branches.txt
  echo "$totalBranchCount) $branch - $lastCommitInfo" >> $allBranchesFullPath
  if [[ $branch != *"master"* ]] && #branch doesn't contain string 'master'
     [[ $branch != *"release"* ]] && #branch doesn't contain string 'release'
     [[ $branch != *"hotfix"* ]] && #branch doesn't contain string 'hotfix'
     [[ $branch != *"develop"* ]] && #branch doesn't contain string 'develop'
     [[ $branch != *"aws"* ]] && #branch doesn't contain string 'aws'
     [ ${lastCommitTimestamp} -lt ${staleTimestamp} ]; then #branches latest commit was older than staleTimestamp
    
    #increment delete branch counter
    deleteBranchCount=$(($deleteBranchCount+1))
    
    if [ "$performDelete" = true ]; then
      _branch=$(echo $branch | sed 's/origin\///')
      git push --delete origin $_branch
	    #log deletion time for reference
      echo "$deleteBranchCount) $branch deleted at $(date +%F_%T)" >> $logFullPath
    else
      echo "$deleteBranchCount) $branch would be deleted: $lastCommitInfo" >> $deleteFullPath
    fi
  else

    #increment keep branch counter
    keepBranchCount=$(($keepBranchCount+1))
    
    if [ "$performDelete" = true ]; then
      echo "$keepBranchCount) $branch kept at $(date +%F_%T)" >> $logFullPath
    else
      echo "$keepBranchCount) $branch would be kept: $lastCommitInfo" >> $keepFullPath
    fi
  fi
done

#log stats
if [ "$performDelete" = true ]; then
  echo "" >> $logFullPath
  echo "totalBranchCount: $totalBranchCount" >> $logFullPath
  echo "deleteBranchCount: $deleteBranchCount" >> $logFullPath
  echo "keepBranchCount: $keepBranchCount" >> $logFullPath
  secs_to_mins_and_secs "$(($(date +%s) - ${start}))" >> $logFullPath
else
  echo "" | tee --append $allBranchesFullPath $deleteFullPath $keepFullPath
  echo "Remote Statistics" | tee --append $allBranchesFullPath $deleteFullPath $keepFullPath
  echo "-----------------" | tee --append $allBranchesFullPath $deleteFullPath $keepFullPath
  echo "totalBranchCount: $totalBranchCount" | tee --append $allBranchesFullPath $deleteFullPath $keepFullPath
  echo "deleteBranchCount: $deleteBranchCount" | tee --append $allBranchesFullPath $deleteFullPath $keepFullPath
  echo "keepBranchCount: $keepBranchCount" | tee --append $allBranchesFullPath $deleteFullPath $keepFullPath 
  secs_to_mins_and_secs "$(($(date +%s) - ${start}))" | tee --append $allBranchesFullPath $deleteFullPath $keepFullPath
fi

