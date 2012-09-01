#!/usr/bin/env perl

use strict;
use warnings;
use 5.014002;

use Test::More;


BEGIN {
    plan tests => 10;
    use_ok 'Bake::Parser';
    use_ok 'Bake::Command'; 
}

my $par = Bake::Parser->new();
isa_ok $par, 'Bake::Parser';
my @lines = <DATA>;
my $inst = $par->parse(join q{}, @lines);
isa_ok $inst, 'Bake::Instructions';

my $cmd = $inst->find('list');
isa_ok $cmd, 'Bake::Command';
is $cmd->name, 'list';
ok !defined $cmd->code || $cmd->code eq '', 'Should have no code';

$cmd = $inst->choice('list');
isa_ok $cmd, 'Bake::Command';
is $cmd->name, 'list';
ok !defined $cmd->code || $cmd->code eq '', 'Should have no code';

__DATA__
# % prefix indicates a choice. Only one of the options will be run and you will be given a choice
# Optionally you can pass the choice in when running bake
## list
# list long
# and some more descriptino
bake list ' ls -lart '

## hw
# Details go here
# of the desc
opt 'asdf'
opt 'asdf'
use Cwd;
bake hw {
    say getcwd;
    say "My name is: ".$command->name;
    say join(":",@args);
    say "two";
    for (1..3) {
        say $_.") counting";
    }
}

## start_mongo
# Start the mongo server
bake start_mongo ' /usr/local/bin/mongod run --config /usr/local/Cellar/mongodb/2.0.4-x86_64/mongod.conf '
bake hi {
    say "Hi";
}
#bake cleanm2 {
#    use File::Path qw/remove_tree/;
#    my $m2 = '/Users/jgedeon/.m2/repository/com/x';
#    remove_tree($m2) if (-d $m2);
#}
