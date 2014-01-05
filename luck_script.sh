#!/bin/bash


LUCK=1
#for period in 12 18 24 30 36 42 48
: << 'END'
for period in 5
do
for current_value in 10 20 30 40
do
	perl luck.perl mm/pp $LUCK count $period start_date 2014/01/01 find_value 0 0 0 0 0 0 next_value $current_value
		for year in 2013 2012 2011 2010 2009 2008 2007 2006 2005
		do
			for month in 12 11 10 09 08 07 06 05 04 03 02 01
			do
				perl luck.perl mm/pp $LUCK count $period start_date $year/$month/01 find_value 0 0 0 0 0 0 next_value $current_value
			done
		done
	done
done
END
for current_value in {1..75}
do
	perl luck.perl mm/pp $LUCK count -1 start_date 2014/01/01 find_value 0 0 0 0 0 0 next_value $current_value
done
