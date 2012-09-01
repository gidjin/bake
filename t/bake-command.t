#!/usr/bin/env perl

use strict;
use warnings;
use 5.014002;

use Test::More;

plan tests => 11;

BEGIN { use_ok 'Bake::Command' }

my $name = 'cur_date';
my $desc = 'A sample description';
my $command = 'date';
my $use = 'Test::More';
my $sub = qq'{ 
    ok(defined $command);
}';
my $cmd = new Bake::Command({name=>$name});

ok(defined $cmd, 'Expecting new object instance of Bake::Command');
is($cmd->name, $name, "Expecting $name == ".$cmd->name);
$cmd->description($desc);
is($cmd->description, $desc, "Expecting $desc == ".$cmd->description);
$cmd->command($name);
is($cmd->command, $name, "Expecting $name == ".$cmd->command);
my $i = scalar @{$cmd->uses};
$cmd->uses->[$i] = $use;
is($cmd->uses->[$i],$use,"Expecting $use == ".$cmd->uses->[$i]);
$cmd->subroutine($sub);
ok(defined $cmd->code,'Expecting sub to be defined');
$cmd->execute($name);
$cmd->description(undef);
isnt($cmd->description, $desc, "Expecting $desc == ".$cmd->description);
$cmd->execute($name);
$cmd->uses([]);
is(scalar @{$cmd->uses},0,"Expecting no uses");
$cmd->execute($name);
$cmd = new Bake::Command({name=>$name});
$cmd->command($command);
is($cmd->command, $command, "Expecting $command == ".$cmd->command);
$cmd->execute;
fail('This thread should have gone away');
