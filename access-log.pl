#!/usr/bin/perl 

use strict;
use Date::Parse;

my %clients;
my %first_hit;
my %last_hit;
my %downloaded;
my %url;
my $first_entry;
my $last_entry;
my $num_hits = 0;
my $total_data = 0;

my $num_urls = 20;
my $num_hosts = 20;


LINE: while (my $line = <>){
    $num_hits++;
    chomp $line;

    my ($host,$date,$url_with_method,$status,$size) = $line =~
          m/^(\S+) - - \[(\S+ [\-|\+]\d{4})\] "(\S+ \S+ [^"]+)" (\d{3}) (\d+|-)/; 

    if ( ! defined $first_entry ){
	$first_entry = $date;
    }

    $last_entry = $date;

    $clients{$host}++;
    $url{$url_with_method}++;
    
    if ( ! defined $first_hit{$host} ){
	$first_hit{$host} = "$date";
    }

    $last_hit{$host} = "$date";

    if ( $size =~ /^[+-]?\d+$/){

    	$downloaded{$host} = $downloaded{$host} + $size;
        $total_data = $total_data + $size;
    }
}

my $sample_size = str2time($last_entry) - str2time($first_entry);

print "\n\n===================\n Apache Log Report\n===================\n";
print "\nFirst Entry In Log: $first_entry\n";
print "Last Entry In Log:  $last_entry\n";
print "Length of log: $sample_size seconds\n";
print "Number of requests: $num_hits\n";
printf "Total KB: %10.2f\n", $total_data/1024;

print "\nTop hosts:\n===========\n\n";
printf "%-10s %-15s %-15s %-4s %18s\n", "Requests", "Client", "Seconds", "Requests/S", "Total KB";
print "-------------------------------------------------------------------------------\n";

foreach my $client (sort {$clients{$b} <=> $clients{$a} } keys(%clients)){
    if ($num_hosts > 0){
    	my $period = str2time($last_hit{$client}) - str2time($first_hit{$client});

    	if ( $period < 1 ){	
	    $period = 1;
     	}

    	printf "%-10d %-15s %-15d %-04f %18.2f\n",  $clients{$client}, $client,  $period, $clients{$client}/$period, $downloaded{$client}/1024;
    } else {
	last;
    }

    $num_hosts--;
}

print "\nTop URLs:\n==========\n\n";

foreach my $pages (sort {$url{$b} <=> $url{$a}} keys(%url)){
    if ($num_urls > 0){
        printf "%-10d %s\n",  $url{$pages}, $pages;
    } else {
	last;
    }  

    $num_urls--;
}
