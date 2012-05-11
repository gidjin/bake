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
    my $sec = 0;
    say "Waiting $min minutes";
    $time += $min*60;
    if ($min < 1) {
        $sec = $min*60;
        $min = 0;
    }
    $|=1;
    while ($time > time) {
        printf '%02d:%02d',$min,$sec;
        if ($sec) {
            $sec--;
        }
        elsif ($min) {
            $min--;
            $sec=59;
        }
        sleep(1);
        print "\b"x6;
    }
    say "\aTimer done";
}

__PACKAGE__->meta->make_immutable;
