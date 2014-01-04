#!/bin/bash


#for period in 12 18 24 30 36 42 48
for period in 5 12
do
perl mm.perl count $period start_date 2014/01/01 find_value 0 0 0 0 0 0
	for year in 2013 2012 2011 2010 2009 2008 2007 2006 2005
	do
		for month in 12 11 10 09 08 07 06 05 04 03 02 01
		do
			perl mm.perl count $period start_date $year/$month/01 find_value 0 0 0 0 0 0
		done
	done
done
