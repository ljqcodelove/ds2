#!/bin/bash

### ### ###  		   ### ### ###

### ### ### INITIALIZATION ### ### ###

### ### ###  		   ### ### ###

### paths configuration ###
FLINK_BUILD_PATH="/root/dannylian/code/ds2/workspace/flink-1.4.1-instrumented/flink-1.4.1/build-target/"
FLINK=$FLINK_BUILD_PATH$"bin/flink"
JAR_PATH="/data/dannylian/LongTune/query8/flink-examples-ContTune-query8-any-jar-with-dependencies.jar"

### dataflow configuration ###
QUERY_CLASS="ch.ethz.systems.strymon.ds2.flink.nexmark.queries.Query8"
AUCTIONS_SOURCE_NAME="Source: Custom Source: Auctions -> Timestamps-Watermarks -> Map"
PERSONS_SOURCE_NAME="Source: Custom Source: Persons -> Timestamps-Watermarks -> Map"
SINK_NAME="TriggerWindow -> DummyLatencySink"


### operators and parallelism
if [ "$1" == "" ]; then
    echo "Please provide operators and their initial parallelism"
    exit 1
fi

### parse operator pairs
IFS='#' read -r -a array <<< "$1"
for element in "${array[@]}"
do
    IFS=',' read -r -a parallelism <<< "$element"
        ## search for SOURCE_NAME
    if [ "${parallelism[0]}" == "$AUCTIONS_SOURCE_NAME" ]; then
        echo "AUCTIONS_Source parallelism: ${parallelism[@]: -1:1}"
        P_SOURCE="${parallelism[@]: -1:1}"
    fi
    if [ "${parallelism[0]}" == "$PERSONS_SOURCE_NAME" ]; then
        echo "PERSONS_SOURCE_NAME: ${parallelism[@]: -1:1}"
	P1="${parallelism[@]: -1:1}"
    fi
    ## search for FlatMap
    if [ "${parallelism[0]}" == "$SINK_NAME" ]; then
        echo "SINK parallelism: ${parallelism[@]: -1:1}"
        P2="${parallelism[@]: -1:1}"
    fi
done

nohup $FLINK run -d --class $QUERY_CLASS $JAR_PATH --p-auction-source $P_SOURCE --p-person-source $P1 --p-window $P2  & > job.out
