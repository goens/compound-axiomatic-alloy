#!/bin/bash

ALLOY_JAR=~/code/org.alloytools.alloy/org.alloytools.alloy.cli/target/org.alloytools.alloy.cli.jar
OUTPUT=results.csv
echo "test,result" > $OUTPUT
for TEST in `ls generated_litmus/*/*.als`; do
   echo -n ${TEST##*/}, >> $OUTPUT
   java -jar $ALLOY_JAR exec $TEST | grep -o -e "INSTANCE" -e "UNSAT" >> $OUTPUT
done;
