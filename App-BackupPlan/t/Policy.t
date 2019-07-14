use Test::More tests => 8;

#first check that I can load the package
BEGIN 
{ use_ok('App::BackupPlan::Policy')}; #test 1

my $p = new_ok 'App::BackupPlan::Policy'; #test 2
isa_ok($p,'App::BackupPlan::Policy'); #test 3

$p->set('maxFiles',4);
cmp_ok(4,'eq',$p->getMaxFiles(),'maximum number of files'); #test 4

$p->set('frequency','8d');
cmp_ok('8d','eq',$p->getFrequency(),'frequency'); #test 5

$p->set('prefix','home');
cmp_ok('home','eq',$p->getPrefix(),'home'); #test 6

$p->set('sourceDir','TestData/source');
cmp_ok('TestData/source','eq',$p->getSourceDir(),'source directory'); #test 7

$p->set('targetDir','TestData/target');
cmp_ok('TestData/target','eq',$p->getTargetDir(),'target directory'); #test 8
