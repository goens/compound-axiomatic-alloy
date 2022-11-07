#!/bin/bash

ALLOY_JAR=~/code/org.alloytools.alloy/org.alloytools.alloy.cli/target/org.alloytools.alloy.cli.jar
OUTPUT=results.csv
DIR=$1
echo "test,expected,result" > $OUTPUT
for TEST in `ls $DIR/*.als`; do
   echo -n ${TEST##*/}, >> $OUTPUT
   grep "// Expected:" $TEST | grep -o -e "?" -e "𐄂" -e "✓" | tr -d '\n' >> $OUTPUT
   echo -n "," >> $OUTPUT
   java -jar $ALLOY_JAR exec $TEST | grep -o -e "INSTANCE" -e "UNSAT" >> $OUTPUT
done;
