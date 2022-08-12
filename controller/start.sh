#!/bin/bash

rm -rf ../workspace/flink-1.4.1-instrumented/flink-1.4.1/rates/*
rm -rf ../savepoints/*

cargo run --release --bin manager 
