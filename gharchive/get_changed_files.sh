#!/bin/bash
# diff info script

# this scripts parses the gharchive output results
# and gets more info on the diffs
filename="diff_test.json"
lst=$(python ~/desktop/sum19Research/gharchive/diff_info.py "$filename")

IFS=')(][' read -r -a array <<< "$lst"
echo "${array[@]}"
echo ---------
for x in "${array[@]}"
do
  cd ~/desktop/sum19Research/gharchive
  IFS=" "
  set -- ${x//[,)(\'\[\]]}

  # split results to get repo url, fixed commit hash, buggy commit hash
  repo_url=$1
  repo_name=$2
  fixed_commit=$3
  buggy_commit=$4
  git clone $repo_url
  cd $repo_name
  res=$(git diff --name-only $fixed_commit $buggy_commit)
  readarray -t array2 <<<"$res"
  files_changed=""
  for fils in "${array2[@]}"; do
    if [ "$files_changed" != "" ];
    then
      files_changed="$files_changed, $fils"
    else
      files_changed="{$fils"
    fi
  done 
  files_changed="$files_changed}"
  csv_str="$repo_name, $repo_url, $fixed_commit, $buggy_commit, $files_changed"
  echo $repo_name
  cd ~/desktop/sum19Research/gharchive
  rm -rf $repo_name
  if [ "$repo_name" != "" ]
  then
    echo $csv_str
    echo $csv_str >> ~/desktop/sum19Research/gharchive/diff_results.csv
  fi
done
