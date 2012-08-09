#!/usr/bin/env perl
package Bake::Command;

use v5.14;
use Moo;

has 'name' => ( is => 'rw' );
has 'command' => ( is => 'rw' );
has 'subroutine' => ( is => 'rw' );
has 'variables' => ( is => 'rw', default => sub { {} } );
has 'description' => ( is => 'rw', default => sub {''} );

sub replace_vars {
    my $self = shift;

    my $cmd = $self->command;
    my %vars = %{$self->variables};

    for my $var (keys %vars) {
        my $matcher = quotemeta($var);
        $matcher = qr($matcher);
        $cmd  =~ s/$matcher/$vars{$var}/;
    }

    return $cmd;
}

__PACKAGE__->meta->make_immutable;
