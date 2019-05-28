#!/bin/bash
# diff info script

# this scripts parses the gharchive output results
# and gets more info on the diffs
filename="gharchive-output-march.json"
# filename="diff_test.json"
lst=$(python diff_info.py "$filename")

IFS=')(][' read -r -a array <<< "$lst"
for x in "${array[@]}"
do
  cd ~/desktop/sum19Research/gharchive/ast_diff
  IFS=" "
  set -- ${x//[,)(\'\[\]]}

  # split results to get repo url, fixed commit hash, buggy commit hash
  echo $x
  echo ----------------
  repo_url=$1
  repo_name=$2
  fixed_commit=$3
  buggy_commit=$4
  commit_msg=${@:5}
  echo $commit_msg
  git clone $repo_url
  cd $repo_name
  res=$(git diff --name-only $fixed_commit $buggy_commit)
  readarray -t array2 <<<"$res"
  files_changed=""
  ind=0
  for fils in "${array2[@]}"; do
    ext=${fils##*.}
    if [ "$repo_name" != "" ] && [ "$ext" == "js" ]
    then
      cd ~/desktop/sum19Research/gharchive/ast_diff/$repo_name
      git checkout $buggy_commit
      bug_file="${repo_name}_${buggy_commit}_bug_$ind.$ext"
      cp $fils $bug_file
      mv ./$bug_file ~/desktop/sum19Research/gumtree_source/dist/build/distributions/re/bin
      git checkout $fixed_commit
      fixed_file="${repo_name}_${fixed_commit}_fix_$ind.$ext"
      cp $fils $fixed_file
      mv ./$fixed_file ~/desktop/sum19Research/gumtree_source/dist/build/distributions/re/bin
      ((ind++))
      cd ~/desktop/sum19Research/gumtree_source/dist/build/distributions/re/bin
      echo ran gumtree
      res=$(./gumtree jsondiff $bug_file $fixed_file)
      if [ "$res" != "" ]
      then 
      echo "$res" >> ~/desktop/sum19Research/gharchive/ast_diff/${repo_name}_${buggy_commit}.json
      cd ~/desktop/sum19Research/gharchive/ast_diff
      ast_diff=$(cat ${repo_name}_${buggy_commit}.json | jq '.actions' | grep -c '\<action\>')
      csv_str="$repo_name, $repo_url, $fixed_commit, $buggy_commit, $fils, $ast_diff, $commit_msg"
      echo $csv_str >> ~/desktop/sum19Research/gharchive/ast_diff/diff_results.csv          
      rm ${repo_name}_${buggy_commit}.json
      fi
    fi
  done 
done
