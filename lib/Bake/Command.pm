#!/usr/bin/env perl
package Bake::Command;

use v5.14;
use Moo;

has 'name' => ( is => 'rw' );
has 'command' => ( is => 'rw' );
has 'sub' => (
    is => 'ro',
    writer  => '_set_sub'
);
has 'description' => ( is => 'rw', default => sub {''} );
has 'options' => ( is => 'rw', default => sub {[]} );
has 'uses' => ( is => 'rw', default => sub {[]} );

sub subroutine {
    my $self = shift;
    my $perl = shift;
    say $self;

    my $subroutine = sub {
        our $command = shift;
        for my $u (@{$command->uses}) {
            # Require any modules asked for
            my ($use,$param) = $u =~ /^(.*?)(?:\s(.*))?$/;
            $param = '' unless defined $param;
            my $require = 'require '.$use.';'.$use.'->import('.$param.');';
            eval $require;
            say $@ if $@;
        }
        our @args = @_;
        eval $perl;
        say $@ if $@;
    };
    $self->_set_sub($subroutine);
}
sub execute {
    my $self = shift;
    my @args = @_;

    say "Baking ".$self->name;
    if (defined $self->description && $self->description ne '') {
        say $self->description;
    }
    if (defined $self->uses && scalar @{$self->uses}) {
        say YAML::Dump({use => $self->uses});
    }
    if (defined $self->sub) {
        say '> '.$self->command."(".join(",",@args).")";
        my $sub = $self->sub;
        &$sub($self,@args);
    }
    else {
        my $cmd = $self->command;
        if (@args) {
            $cmd .= ' '.join(' ',@args);
        }
        say '> '.$cmd;
        exec $cmd;
    }
}

__PACKAGE__->meta->make_immutable;
