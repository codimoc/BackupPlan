#!/usr/bin/perl -w

use XML::DOM;
use App::BackupPlan;
use App::BackupPlan::CLI qw(printHelp parse_options get_option);
use strict;

#--print help is specifically requested
parse_options;   	   	   

printHelp if get_option('has_help');

#--or print help if nothing else to do
printHelp unless defined(get_option('config_file'));  	

$App::BackupPlan::TAR = get_option('tar') if defined get_option('tar');

#----main functionality is here
my $plan = new App::BackupPlan(get_option('config_file'),
                               get_option('log_file'));
$plan->run;
   	   	



