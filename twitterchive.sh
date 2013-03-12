#!/bin/sh

## twitterchive.sh
## Stephen Turner (stephenturner.us)
##
## Script uses the t command line client (https://github.com/sferik/t)
## to search twitter for keywords stored in the arr variable below.
##
## Must first install the t gem and authenticate with OAuth.
##
## Twitter enforces some API limits to how many tweets you can search for
## in one query, and how many queries you can execute in a given period.
##
## I'm not sure what these limitations are, but I've hit them a few times.
## To be safe, I would limit the number of queries to ~5, $n to ~200, and
## run no more than a couple times per day.

## declare an array variable containing all your search terms. 
## prefix any hashtags with a \
declare -a arr=(\#bioinformatics metagenomics rna-seq)

## How many results would you like for each query?
n=200

## get the full path of the script
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo

## now loop through the above array
for query in ${arr[@]}
do
	## if your query contains a hashtag, remove the "#" from the filename
	filename=$scriptdir/${query/\#/}.txt
	echo "Query:\t$query"
	echo "File:\t$filename"

	## create the file for storing tweets if it doesn't already exist.
	if [ ! -f $filename ]
	then
		touch $filename
	fi

	## use t (https://github.com/sferik/t) to search the last $n tweets in the query, 
	## concatenating that output with the existing file, sort and uniq that, then 
	## write the results to a tmp file. 
	search_cmd="t search all -ldn $n '$query' | cat - $filename | sort | uniq | grep -v ^ID > $scriptdir/tmp"
	echo "Search:\t$search_cmd"
	eval $search_cmd

	## rename the tmp file to the original filename
	rename_cmd="mv $scriptdir/tmp $filename"
	echo "Rename:\t$rename_cmd"
	eval $rename_cmd

	echo
done

## push changes to github
git add -A
git commit -a -m "Update search results: $(date)"
git push origin master
