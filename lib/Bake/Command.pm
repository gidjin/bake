#!/usr/bin/env perl
package Bake::Command;

use v5.14;
use Moo;

has 'name' => ( is => 'rw' );
has 'command' => ( is => 'rw' );
has 'subroutine' => ( is => 'rw' );
has 'description' => ( is => 'rw', default => sub {''} );

sub execute {
    my $self = shift;
    my @args = @_;

    say "Baking ".$self->name;
    if (defined $self->description && $self->description ne '') {
        say '  '.$self->description;
    }
    if (defined $self->subroutine) {
        say '  '.$self->command."(".join(",",@args).")";
        my $sub = $self->subroutine;
        &$sub($self,@args);
    }
    else {
        my $cmd = $self->command;
        if (@args) {
            $cmd .= ' '.join(' ',@args);
        }
        say '  '.$cmd;
        exec $cmd;
    }
}

__PACKAGE__->meta->make_immutable;
