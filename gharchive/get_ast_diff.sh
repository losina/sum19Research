#!/bin/bash
# diff info script

# this scripts parses the gharchive output results
# and gets more info on the diffs
filename="gharchive-output-march.json"
# filename="diff_test.json"
lst=$(python ~/desktop/sum19Research/gharchive/diff_info.py "$filename")

IFS=')(][' read -r -a array <<< "$lst"
for x in "${array[@]}"
do
  cd ~/desktop/sum19Research/gharchive
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
    if [ "$repo_name" != "" ]
    then
      cd ~/desktop/sum19Research/gharchive/$repo_name
      git checkout $buggy_commit
      ext=${fils##*.}
      if [ "$ext" == "java" ]
      then 
        bug_file="${repo_name}_${buggy_commit}_bug_$ind.$ext"
        echo $ind
        cp $fils $bug_file
        mv ./$bug_file ~/desktop/gumtree_resource/dist/build/distributions/re/bin
        git checkout $fixed_commit
        fixed_file="${repo_name}_${fixed_commit}_fix_$ind.$ext"
        echo $ind
        cp $fils $fixed_file
        mv ./$fixed_file ~/desktop/gumtree_resource/dist/build/distributions/re/bin
        ((ind++))
        cd ~/desktop/gumtree_resource/dist/build/distributions/re/bin
        echo ran gumtree
        res=$(./gumtree jsondiff $bug_file $fixed_file)
        if [ "$res" != "" ]
        then 
          echo "$res" >> ~/desktop/sum19Research/gharchive/gumtree/${repo_name}_${buggy_commit}.json
          cd ~/desktop/sum19Research/gharchive/gumtree
          ast_diff=$(cat ${repo_name}_${buggy_commit}.json | jq '.actions' | grep -c '\<action\>')
          csv_str="$repo_name, $repo_url, $fixed_commit, $buggy_commit, $fils, $ast_diff, $commit_msg"
          echo $csv_str >> ~/desktop/sum19Research/gharchive/diffresult/diff_results.csv
          # msg="$repo_name, $repo_url, $fixed_commit, $buggy_commit, $fils, $commit_msg"
          # printf '{"AST_diff":"%s","repo_url":"%s","repo_name":"%s","fixed_hash":"%s","buggy_hash":"%s","changed_file":"%s","commit_msg":"%s"},\n' "$ast_diff" "$repo_url" "$repo_name" "$fixed_commit" "$buggy_commit" "$fils" "$commit_msg" >> ~/desktop/sum19Research/gharchive/diffresult/json_diff_results.json
          rm ${repo_name}_${buggy_commit}.json
        fi
      else
        if [ "$files_changed" != "" ]
        then
        files_changed="$files_changed, $fils"
        else
        files_changed="{$fils"
        fi
      fi 
    fi
  done 
  if [ "$files_changed" != "" ]
  then 
  cd ~/desktop/sum19Research/gharchive
  printf '{"repo_url":"%s","repo_name":"%s","fixed_hash":"%s","buggy_hash":"%s","changed_files":"%s","commit_msg":"%s"},\n' "$repo_url" "$repo_name" "$fixed_commit" "$buggy_commit" "$files_changed" "$commit_msg" >> ~/desktop/sum19Research/gharchive/diffresult/unchecked_diff_results.json
  rm -rf $repo_name
  fi
done
