#!/bin/bash

### ### ###  		   ### ### ###

### ### ### INITIALIZATION ### ### ###

### ### ###  		   ### ### ###

### paths configuration ###
FLINK_BUILD_PATH="/root/dannylian/code/ds2/workspace/flink-1.4.1-instrumented/flink-1.4.1/build-target/"
FLINK=$FLINK_BUILD_PATH$"bin/flink"
JAR_PATH="/data/dannylian/LongTune/query8/flink-examples-ContTune-query8-any-jar-with-dependencies.jar"
readonly SAVEPOINT_PATH="/root/dannylian/code/ds2/savepoints/"

### dataflow configuration ###
QUERY_CLASS="ch.ethz.systems.strymon.ds2.flink.nexmark.queries.Query8"
AUCTIONS_SOURCE_NAME="Source: Custom Source: Auctions -> Timestamps-Watermarks -> Map"
PERSONS_SOURCE_NAME="Source: Custom Source: Persons -> Timestamps-Watermarks -> Map"
SINK_NAME="TriggerWindow -> DummyLatencySink"

### jobId
if [ "$1" == "" ]; then
    echo "Please provide the Job ID as the first argument"
    exit 1
fi
JOB_ID=$1

### operators and parallelism
if [ "$2" == "" ]; then
    echo "Please provide operators and their initial parallelism as the second argument"
    exit 1
fi


### parse operator pairs
IFS='#' read -r -a array <<< "$2"
for element in "${array[@]}"
do
    IFS=',' read -r -a parallelism <<< "$element"
        ## search for SOURCE_NAME
    if [ "${parallelism[0]}" == "$AUCTIONS_SOURCE_NAME" ]; then
        echo "AUCTIONS Source parallelism: ${parallelism[@]: -1:1}"
        P_SOURCE="${parallelism[@]: -1:1}"
    fi
    if [ "${parallelism[0]}" == "$PERSONS_SOURCE_NAME" ]; then
	echo "PERSONS Source parallelism: ${parallelism[@]: -1:1}"
	P1="${parallelism[@]: -1:1}"
    fi
    ## search for FlatMap
    if [ "${parallelism[0]}" == "$SINK_NAME" ]; then
        echo "SINK parallelism: ${parallelism[@]: -1:1}"
        P2="${parallelism[@]: -1:1}"
    fi
done

#echo Canceling job with savepoint
savepointPathStr=$($FLINK cancel -s $SAVEPOINT_PATH $JOB_ID)

savepointFile=$(echo $savepointPathStr| rev | cut -d'/' -f 1 | rev)
x=$(echo $savepointFile |tr -d '.')
x=$(echo $x |tr -d '\n')


nohup $FLINK run -d -s $SAVEPOINT_PATH$x --class $QUERY_CLASS $JAR_PATH --p-auction-source $P_SOURCE --p-person-source $P1 --p-window  $P2 & > job.out
