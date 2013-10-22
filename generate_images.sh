#!/bin/bash
for i in `ls *.ditaa`
do
	echo ${i} img/`basename ${i} .ditaa`.png
done

