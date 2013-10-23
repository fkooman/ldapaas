#!/bin/bash
for i in `ls *.ditaa`
do
	ditaa ${i} img/`basename ${i} .ditaa`.png
done

