# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl BackupPlan.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;
use Time::Local;
use App::BackupPlan::Utils qw(fromTS2ISO);

use Test::More tests => 10; 
BEGIN 
{ use_ok('App::BackupPlan')}; #test 1


#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $configFile = 'TestData/testPlan.xml';
my $logFile = 'TestData/log4perl.conf';
my @planArgs = ($configFile, $logFile);
my $plan = new_ok 'App::BackupPlan' => \@planArgs; #test2

my $parser = new XML::DOM::Parser;
my $doc = $parser->parsefile ($configFile) or die "Could not parse $configFile";
my ($defaultPolicy,%raw_policies) = App::BackupPlan::getPolicies($doc);
isa_ok($defaultPolicy,'App::BackupPlan::Policy'); #test 3
is(3, $defaultPolicy->{maxFiles},'policy default max number of files'); #test4
cmp_ok('1m', 'eq', $defaultPolicy->{frequency},'policy default frequency'); #test5
is(1,keys %raw_policies, 'expected number of policies'); #test6
ok(defined($raw_policies{test}), 'policy test is present'); #test 7


#getFiles test
my $policy = $raw_policies{'test'};
my $sd = $policy->getSourceDir;
my $pr = $policy->getPrefix;
my %files = App::BackupPlan::getFiles($sd,$pr);
my $nc = keys %files;
cmp_ok(0,'lt',$nc,'number of files in source directory'); #test 8

#get environment
App::BackupPlan::getEnvironment();

#tar test
if ($App::BackupPlan::TAR eq 'system') {
	my $out = $policy->tar(fromTS2ISO(time),$App::BackupPlan::HAS_EXCLUDE_TAG);
	unlike($out, qr/Error/, 'tar does not produce an Error'); #test 9
	like($out, qr/system/,'system tar'); #test 10
	
}
else { #perl tar test
	my $out = $policy->perlTar(fromTS2ISO(time));
	unlike($out, qr/Error/, 'tar does not produce an Error'); #test 9
	like($out, qr/perl/,'perl tar'); #test 10
}


