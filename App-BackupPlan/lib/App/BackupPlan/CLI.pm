package App::BackupPlan::CLI;

use strict;
use warnings;
use Getopt::Long;

our @ISA = qw(Exporter);
our $VERSION = '0.0.9';

our @EXPORT = qw(printHelp parse_options get_option);

#this is the option configuration that is returned by the get_options package function
my %options = ( config_file => undef,
                log_file    => undef,
                has_help    => undef,
                tar         => undef
              );
              
sub parse_options {
    GetOptions('c=s'     => \$options{config_file},
	           'l=s'     => \$options{log_file},
	           't=s'     => \$options{tar},
	           'h'       => \$options{has_help}); 
}

sub get_option {
	my $key = shift;
	return $options{$key};
}



sub printHelp {
  print "This Perl performs a  regular, recursive backup of a directory structure\n";
  print "and cleans up the target directory of old backup files:\n";
  print "Syntax: backup.pl [-c <configFile> [-t <tar method>] | -h]\n";
  print "  -c <configFile>\tThe configuration file\n";
  print "  -l <log4per>\tThe log4Perl config file\n";
  print "  -t <tar method>\tTar method: system for system tar, or perl for Archive::Tar\t\n";
  print "  -h\t\t\tPrints this help.\n";
  exit;
}

 
1;
