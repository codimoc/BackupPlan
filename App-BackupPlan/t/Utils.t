use Test::More tests => 2;

#first check that I can load the package
BEGIN 
{ use_ok('App::BackupPlan::Utils', qw(fromISO2TS fromTS2ISO))}; #test 1

#check conversion ISO date ->timestam -> ISO date
my $iso = '20190415';
my $ts   = fromISO2TS($iso);
my $iso2 = fromTS2ISO($ts);
cmp_ok($iso2, 'eq', $iso,'roundrip from ISO date back to ISO date'); #test 2
