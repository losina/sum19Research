#!/bin/bash
# gharchive script

# get gharchive data
# this script iterates through all months/days/hours
# of gharchive data to find known bugs
# the script  gets repos and commits that contain
# the $msg keyword in the commit message and then runs clang sa
# on the buggy version (considered one commit prior to fix)
# keywords in msg are customizable (see TODO below)

# i corresponds to months
# j corresponds to days
# k corresponds to hours
# year: change year in ext

found_error(){
  echo "$1,$3,$2,TIME_OUT_ERROR" >> ~/desktop/s19/gharchive-output-errors.txt
  cd ~/desktop/s19
  rm -rf $3
}
find_new(){
          repo_url=$1
        commit_hash=$3
        repo_name=$2
	commit_msg=${@:4}
    cd ~/desktop/s19
    rm -rf $repo_name
  if git clone $repo_url;
      then
            # clone succeeds, try checkout/get previous commit
	    cd $repo_name
            # get one commit prior
            git checkout $commit_hash
            hashes=$(git log -n 2 --pretty=format:"%H")
            IFS=$'\n'
            set -- ${hashes}
            new_hash="$2"

            #save info in json format
            # clang results found in $repo_name-clang-sa-out folder in root dir
            printf '{"repo_url":"%s","repo_name":"%s","fixed_hash":"%s","buggy_hash":"%s","commit_msg":"%s"},\n' "$repo_url" "$repo_name" "$commit_hash" "$new_hash" "$commit_msg" >> ~/desktop/s19/gharchive-output-march.txt
            cd ~/desktop/s19
            echo removed 
            rm -rf $3
            cd ~/desktop/s19
	  else
            # catch errors
            echo $1
            echo "$1,$3,$2,ERROR" >> ~/desktop/s19/gharchive-output-errors.txt
            cd ~/desktop/s19
            rm -rf $3
    fi

}
export -f find_new
export -f found_error
for i in {03..03}
do
  for j in {05..25}
  do
    for k in {3..18}
    do
      #gets json file of year/month/day/hour data
      ext="2019-$i-$j-$k"
      base_url="http://data.gharchive.org/"
      data_url="$base_url$ext.json.gz"
      wget $data_url
      gunzip "$ext.json.gz"

      # query data with python script
      #inputs: filename, search message, search event
      # TODO: change keywords/event here
      # possible keywords to target c/c++ programs w/ minimal noise include:
      # "null deref", "buffer overrun", "integer overflow"
      event="PushEvent"
      lst=$(python json_handler.py "$ext.json" "$event")
      echo $lst
      #remove data once parsed for space purposes
      rm -r "$ext.json"

      # run clang on previous commit

      IFS=')]' read -r -a array <<< "$lst"
      IFS=', (' 
      for x in "${array[@]}"
      do
        cd ~/desktop/s19
        rm -rf .git
        git init
        IFS="', '"
        set -- ${x//[,)(\'\[\]]}
        # split results to get repo url, commit hash, repo name, and commit msg
        repo_url=$1
        commit_hash=$2
        repo_name=$3
	commit_msg=${@:4}
	if [[ "$x" != "kernel" ]];
	then
    bash-timeout 40s find_new $repo_url $repo_name $commit_hash $commit_msg  || bash rm -f $repo_name
    fi
    done
  done
done
done 

