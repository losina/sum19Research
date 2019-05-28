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

for i in {03..03}
do
  for j in {01..31}
  do
    for k in {0..23}
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
  done
done
done 

