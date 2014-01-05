#!/bin/perl

use strict;
use warnings;

use Date::Calc qw(Delta_Days);
use Statistics::Descriptive;

#Sub-routines
sub read_file_fill_hash;
sub find_match;
sub frequency_analysis; 
sub fill_hash_values_dates;
sub match_print_dates;
sub match_print_date_diffs;
sub hashvalues_to_array;
sub pkg_mean (@);
sub next_value_analysis;

#Command line check
if(@ARGV != 15) {
	print "\n";
	print "Invalid arguments\n";
	print "Format: perl luck.pl mm/pp <1/2> count <count> start_date <start_date> find_value <0/1 find_value> next_value <value>\n";
	print "\n";
	exit(0);
}

#Read command line
my($mm_pp) = $ARGV[1];
my($freq_count) = $ARGV[3];
my($start_date) = $ARGV[5];
my($isfind) = $ARGV[7];
my($find_value) = sprintf "%2d %2d %2d %2d %2d ", $ARGV[8],$ARGV[9],$ARGV[10],$ARGV[11],$ARGV[12];
my($current_value) = $ARGV[14];

#Setting large value to include all values from data
if($freq_count == -1) {
	$freq_count = 100000;
}

#Global variables
#Master hash table
my(%hash_table_sorted) = ();
my(%hash_table_unsorted) = ();
my(%hash_values_dates) = ();
my(@calc_array);

print "\n";

#Read the data file and fill master hash table
read_file_fill_hash;

#Find a matching date for the input value
if ($isfind == 1) {
	find_match;
	close DATA;
	exit(0);
}

if (0) {
	#Frequency analysis
	#Calling sub-routines to find the individual and range frequencies.
	frequency_analysis;
}

if (0) {
	fill_hash_values_dates;
	
	#List dates
	match_print_dates;
}

if (0) {
	fill_hash_values_dates;
	
	#List date differences
	match_print_date_diffs;
}

if (0) {
	@calc_array = hashvalues_to_array;
	pkg_mean (@calc_array);
}

if(1) {
	print "Given: $current_value\n";
	next_value_analysis;
}

#Closing data file and exiting the program.
close DATA;
print("\n");
exit(0);

######################End of main#########################


######################Sub-routines########################

#Read the data file and fill the hash table
sub read_file_fill_hash {
	my($infile);
	my(@x);
	my(@temp_array1);
	my($temp_value1);
	my($temp_value2);
	my($hash_key) = 0;
	my($hash_value) = 0;
	my($flag) = 0;
	my($count) = 1;

	#Input data file
	if ($mm_pp == 1) {
		$infile = "data_mm";
	} elsif ($mm_pp == 2) {
		$infile = "data_pb";
	}
	open(DATA,"$infile" ) || die "could't open $infile$!";

	while(<DATA>)
	{
        	@x=split(' ');

		#Converting to YYYY/MM/DD format
		@temp_array1 = split('/',$x[0]);
		$temp_value1 = $temp_array1[0];
		$temp_value2 = $temp_array1[1];
		$temp_array1[0] = $temp_array1[2];
		$temp_array1[1] = $temp_value1;
		$temp_array1[2] = $temp_value2;
	        $hash_key = join('/',@temp_array1);
	        #$hash_key = $x[0];

		if (($hash_key gt $start_date) && ($flag == 0)) {
			#Without filling hash table, moving on to find the desired date
			next;
		} else {
			#Reached desired date
			$flag = 1;
		}
		if($count > $freq_count) {
			#Reached required count value so exiting loop
			last;	
		}
		#Sorting the values and storing it as 2 digit numeric values
        	@temp_array1 = ($x[1], $x[2], $x[3], $x[4], $x[5]);
        	@temp_array1 = sort {$a <=> $b} @temp_array1;
        	$hash_value = sprintf "%2d %2d %2d %2d %2d ", $temp_array1[0], $temp_array1[1], $temp_array1[2], $temp_array1[3], $temp_array1[4];
		#Building the hash table with date as key and sorted numbers as value.
        	$hash_table_sorted{"$hash_key"} = $hash_value;

		#Storing it as 2 digit numeric values - unsorted
        	@temp_array1 = ($x[1], $x[2], $x[3], $x[4], $x[5]);
        	$hash_value = sprintf "%2d %2d %2d %2d %2d ", $temp_array1[0], $temp_array1[1], $temp_array1[2], $temp_array1[3], $temp_array1[4];
		#Building the hash table with date as key and unsorted numbers as value.
        	$hash_table_unsorted{"$hash_key"} = $hash_value;
		
		$count++;
	}
}

#Find matching date for the input value
sub find_match {
	my($hash_key) = 0;
	my($hash_value) = 0;
	my($found_flag) = 0;
	while (($hash_key, $hash_value) = each(%hash_table_sorted)) {
		if(($find_value eq $hash_value)) {
			print "Value found: $hash_value Date: $hash_key\n";
			$found_flag = 1;
		}
	}
	if ($found_flag == 0) {
		print "No matching value ( $find_value ) found.\n";
	}
}

#Frequency analysis
sub frequency_analysis {
	my(%hash_range_freq) = ();
	my(%hash_indiv_freq) = ();
	my($key) = 0;
	my($value) = 0;
	my($temp_value1) = 0;
	my(@temp_array1);

	while (($key, $value) = each(%hash_table_sorted)) {
		@temp_array1 = split(' ',$value);
		foreach $temp_value1 (@temp_array1) {
			%hash_range_freq = range_frequency ($temp_value1, %hash_range_freq);
			%hash_indiv_freq = indiv_frequency ($temp_value1, %hash_indiv_freq);
		} 
	}

	print "\n";
	print "Date   : $start_date\n";
	print "Period : $freq_count\n";
	foreach $key (sort {$a cmp $b} keys %hash_range_freq) {
	#	print "$key : $hash_range_freq{$key}\n";
	}
	print "\n";
	foreach $key (sort {$a <=> $b} keys %hash_indiv_freq) {
		print "$key : $hash_indiv_freq{$key}\n";
	}
	print "\n";
	print "\n";
}

#Range frequency
sub range_frequency {
	my $value = shift;
	my(%hash_table) = @_;
	my($temp_value1) = 0;
	if (($value > 0) && ($value <= 10)) {
		$temp_value1 = $hash_table{"01 - 10"};
		$temp_value1++;
		$temp_value1 = sprintf "%4d", $temp_value1;
		$hash_table{"01 - 10"} = $temp_value1;
	}
	if (($value > 10) && ($value <= 20)) {
		$temp_value1 = $hash_table{"11 - 20"};
		$temp_value1++;
		$temp_value1 = sprintf "%4d", $temp_value1;
		$hash_table{"11 - 20"} = $temp_value1;
	}
	if (($value > 20) && ($value <= 30)) {
		$temp_value1 = $hash_table{"21 - 30"};
		$temp_value1++;
		$temp_value1 = sprintf "%4d", $temp_value1;
		$hash_table{"21 - 30"} = $temp_value1;
	}
	if (($value > 30) && ($value <= 40)) {
		$temp_value1 = $hash_table{"31 - 40"};
		$temp_value1++;
		$temp_value1 = sprintf "%4d", $temp_value1;
		$hash_table{"31 - 40"} = $temp_value1;
	}
	if (($value > 40) && ($value <= 50)) {
		$temp_value1 = $hash_table{"41 - 50"};
		$temp_value1++;
		$temp_value1 = sprintf "%4d", $temp_value1;
		$hash_table{"41 - 50"} = $temp_value1;
	}
	if (($value > 50) && ($value <= 60)) {
		$temp_value1 = $hash_table{"51 - 60"};
		$temp_value1++;
		$temp_value1 = sprintf "%4d", $temp_value1;
		$hash_table{"51 - 60"} = $temp_value1;
	}
	if (($value > 60) && ($value <= 70)) {
		$temp_value1 = $hash_table{"61 - 70"};
		$temp_value1++;
		$temp_value1 = sprintf "%4d", $temp_value1;
		$hash_table{"61 - 70"} = $temp_value1;
	}
	if (($value > 70) && ($value <= 75)) {
		$temp_value1 = $hash_table{"71 - 75"};
		$temp_value1++;
		$temp_value1 = sprintf "%4d", $temp_value1;
		$hash_table{"71 - 75"} = $temp_value1;
	}
	return %hash_table;
}

#Individual number frequency
sub indiv_frequency {
	my $value = shift;
	$value = sprintf "%2d", $value;
	my(%hash_table) = @_;
	my($temp_value1) = 0;
	
	$temp_value1 = $hash_table{$value};
	$temp_value1++;
	$temp_value1 = sprintf "%4d", $temp_value1;
	$hash_table{$value} = $temp_value1;
	
	return %hash_table;
}


#Find string match and fill hash
sub fill_hash_values_dates {
	my($i) = 0;
	my($k1) = 0;
	my($k2) = 0;
	my($plen) = 0;
	my($keyi) = 0;
	my($valuei) = 0;
	my($keyj) = 0;
	my($valuej) = 0;
	my($substri) = 0;
	my($substrj) = 0;
	my($temp_value1) = 0;
	my(@temp_array1);
	my(%temp_hash) = ();

	$i=0;
	for($plen=(3*2);$plen<=(3*5);$plen+=3) {
		%temp_hash = %hash_table_sorted;
		while (($keyi, $valuei) = each(%hash_table_sorted)) {
			for ($k1=0;$k1<=((3*5)-$plen);$k1+=3) {
				$substri = substr $valuei, $k1, $plen;
				while (($keyj, $valuej) = each(%temp_hash)) {
					if($keyi ne $keyj) {
						for ($k2=0;$k2<=((3*5)-$plen);$k2+=3) {
							$substrj = substr $valuej, $k2, $plen;
							if($substri eq $substrj) {
								if (exists $hash_values_dates{$substri}) {
									$temp_value1 = $hash_values_dates{$substri};
									if ((index $temp_value1, $keyi) == -1) {
										$temp_value1 = sprintf "%s %s",$temp_value1, $keyi;
									}
									if ((index $temp_value1, $keyi) == -1) {
										$temp_value1 = sprintf "%s %s",$temp_value1, $keyj;
									}
									$hash_values_dates{$substri} = $temp_value1;
								} else {
									$hash_values_dates{$substri}= sprintf "%s %s", $keyi, $keyj;
								}
								$i++;
							}
						}
					}
				}
			}
		}
	}
	
	#Reverse sort the dates
	while (($keyi, $valuei) = each(%hash_values_dates)) {
		@temp_array1 = split(' ',$valuei);
        	@temp_array1 = reverse sort @temp_array1;
		$hash_values_dates{$keyi} = join(' ',@temp_array1);
	}
}

#Print string match hash table
sub match_print_dates {
	my($key) = 0;
	my($value) = 0;
	
	print "\n";
	print "\n";
	foreach $key (reverse sort {length $a <=> length $b || length ($hash_values_dates{$a}) <=> length ($hash_values_dates{$b}) || ($hash_values_dates{$a}) cmp ($hash_values_dates{$b})} keys %hash_values_dates) {
		$value = $hash_values_dates{$key};
		$key = sprintf "%15s", $key;
		print "Numbers: $key Dates: $value\n";
	}
}

#Print string matched date diffs
sub match_print_date_diffs {
	my($key) = 0;
	my($value) = 0;
	my($temp_value1) = 0;
	my(@temp_array);
	my($i) = 0;
	my($first_date)=0;
	my($second_date)=0;
	my(@first_array);
	my(@second_array);
	my($days)=0;
	
	print "\n";
	print "\n";
	foreach $key (reverse sort {length $a <=> length $b || length ($hash_values_dates{$a}) <=> length ($hash_values_dates{$b}) || ($hash_values_dates{$a}) cmp ($hash_values_dates{$b})} keys %hash_values_dates) {
		$value = $hash_values_dates{$key};
		@temp_array = split(' ', $value);
		$temp_value1="";
		for ($i = 0; $i < @temp_array-1; $i++) {
			$first_date = $temp_array[$i];
			$second_date = $temp_array[$i+1];
			@first_array = split('/',$first_date);
			@second_array = split('/',$second_date);
			$days = Delta_Days($second_array[0],$second_array[1],$second_array[2],$first_array[0],$first_array[1],$first_array[2]);
			$days = sprintf "%4d ", $days;
			$temp_value1 = $temp_value1.$days;
		}
		$key = sprintf "%15s", $key;
		print "Numbers: $key Dates: $temp_value1\n";
	}
}

#Convert hash values to array 
sub hashvalues_to_array {
	my($keyi) = 0;
	my($valuei) = 0;
	my(%hash_table) = %hash_table_sorted;
	my(@calc_array);
	my(@temp_array);
	
	while (($keyi, $valuei) = each(%hash_table)) {
		@temp_array = split(' ',$valuei);
		push(@calc_array,@temp_array);
	}
	return @calc_array;
}

#Using package, calculate mean of an array and print
sub pkg_mean (@) {
	my(@data_array) = @_;
	my($stat) = Statistics::Descriptive::Full->new();
	$stat->add_data(@data_array);
	my($mean) = $stat->mean();
	my($count) = $stat->count();
	print "Count: $count Mean: $mean\n";
}

#Next value analysis
sub next_value_analysis {
	my($key);
	my($value);
	my(%hash_indiv_freq) = ();
	my(@temp_array1);
	my($i) = 0;

        while (($key, $value) = each(%hash_table_unsorted)) {
                @temp_array1 = split(' ',$value);
		for ($i = 0; $i < @temp_array1; $i++) {
			if($temp_array1[$i] == $current_value) {
				if ($i < 4) {	
                        		%hash_indiv_freq = indiv_frequency ($temp_array1[$i+1], %hash_indiv_freq);
				} elsif ($i == 4) {
                        		%hash_indiv_freq = indiv_frequency (0,%hash_indiv_freq);
				}
			}
                }
        }
	if(%hash_indiv_freq) {
		print "Next : Frequency\n";
        	foreach $key (reverse sort {$hash_indiv_freq{$a} <=> $hash_indiv_freq{$b}} keys %hash_indiv_freq) {
			print "$key   : $hash_indiv_freq{$key}\n";
		}
        } else {
		print "No matching value.\n";
	}
}
################End Sub-routines#########################
