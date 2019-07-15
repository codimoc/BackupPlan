# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl BackupPlan.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;
use Time::Local;
use File::Path 'rmtree';
use File::Copy qw(copy);
use App::BackupPlan::Utils qw(fromTS2ISO fromISO2TS);

use Test::More tests => 21; 
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
my $td = $policy->getTargetDir;
my $pr = $policy->getPrefix;
my %files = App::BackupPlan::getFiles($td,$pr);
my $nc = keys %files;
cmp_ok(3,'eq',$nc,'number of files in target directory'); #test 8

#test last timestamps
my $last = App::BackupPlan::getLastTs(keys %files);
cmp_ok('20190714','eq',$last,'the last time-stamp'); #test 9
cmp_ok('TestData/target/tst_20190714.tar.gz','eq',$files{$last},'the last file'); #test 10

#test first timestamps
my $first = App::BackupPlan::getFirstTs(keys %files);
cmp_ok('20190630','eq',$first,'the first time-stamp'); #test 11
cmp_ok('TestData/target/tst_20190630.tar.gz','eq',$files{$first},'the first file'); #test 12

#now create a directory to mess about
$td = $policy->getTargetDir;
my $tmpdir = "$td/temp";
$policy->setTargetDir($tmpdir);
if (!-e $tmpdir) {
    mkdir $tmpdir;    
}


#get environment
App::BackupPlan::getEnvironment();

#tar test
if ($App::BackupPlan::TAR eq 'system') {
	my $out = $policy->tar(fromTS2ISO(time),$App::BackupPlan::HAS_EXCLUDE_TAG);
	unlike($out, qr/Error/, 'tar does not produce an Error'); #test 13
	like($out, qr/system/,'system tar'); #test 14
	
}
else { #perl tar test
	my $out = $policy->perlTar(fromTS2ISO(time));
	unlike($out, qr/Error/, 'tar does not produce an Error'); #test 13
	like($out, qr/perl/,'perl tar'); #test 14
}


#test the file exists
my $iso = fromTS2ISO(time);
ok((-e "$tmpdir/$pr\_$iso.tar.gz"), 'tar file created'); #test 15
unlink "$tmpdir/$pr\_$iso.tar.gz";

#copying to the temp dir
for my $f (glob("$td/$pr\_*")) {
    copy($f, $tmpdir) or die "Copy failed: $!";
}
%files = App::BackupPlan::getFiles($tmpdir,$pr);
$nc = keys %files;
cmp_ok(3,'eq',$nc,'number of files in temp directory'); #test 16

my $now = &fromISO2TS('20190801');
$policy->setMaxFiles(3);
App::BackupPlan::run_policy($policy,$now);
%files = App::BackupPlan::getFiles($tmpdir,$pr);
$nc = keys %files;
cmp_ok(3,'eq',$nc,'number of files in temp directory'); #test 17

#test last timestamps
$last = App::BackupPlan::getLastTs(keys %files);
cmp_ok('20190801','eq',$last,'the last time-stamp'); #test 18
cmp_ok('TestData/target/temp/tst_20190801.tar.gz','eq',$files{$last},'the last file'); #test 19

#test first timestamps
$last = App::BackupPlan::getFirstTs(keys %files);
cmp_ok('20190707','eq',$last,'the first time-stamp'); #test 20
cmp_ok('TestData/target/temp/tst_20190707.tar.gz','eq',$files{$last},'the first file'); #test 21




#cleanup
$policy->setTargetDir($td);
if (-e $tmpdir) {
    rmtree([ $tmpdir ]);
}
