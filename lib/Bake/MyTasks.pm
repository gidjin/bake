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

__PACKAGE__->meta->make_immutable;
