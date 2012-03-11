#!/usr/bin/env perl
package Bake::Mine;
use Moose;
use v5.14;
use LWP::Simple;
use AppConfig;

sub gmt {
    say ''.localtime;
}

__PACKAGE__->meta->make_immutable;
