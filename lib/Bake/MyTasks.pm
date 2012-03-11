#!/usr/bin/env perl
package Bake::Site;
use Moose;
use v5.14;

sub install {
    say 'ys';
}
__PACKAGE__->meta->make_immutable;

package Bake::Sample;
use Moose;
use Cwd;
use LWP::Simple;
use AppConfig;

sub date {
    say ''.localtime;
}

sub timer {
    my $self = shift;
    my $min = shift @ARGV || 2;
    my $time = time;
    $time += 2*60;
    say "Waiting $min minutes";
    $|=1;
    while ($time > time) {
        print ".";
        sleep(1);
    }
    say "Timer done";
}

__PACKAGE__->meta->make_immutable;
