#!/usr/bin/env perl
package Bake::Command;

use 5.014002;
use Moo;
use YAML;

has 'name' => ( is => 'rw' );
has 'command' => ( is => 'rw' );
has 'code' => (
    is => 'ro',
    writer  => '_set_code'
);
has 'description' => ( is => 'rw', default => sub {''} );
has 'options' => ( is => 'rw', default => sub {[]} );
has 'uses' => ( is => 'rw', default => sub {[]} );
has 'perl' => ( is => 'rw');

sub subroutine {
    my $self = shift;
    my $perl = shift;
    $self->perl($perl);

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
    $self->_set_code($subroutine);
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
    if (defined $self->code) {
        say '> '.$self->command."(".join(",",@args).")";
        my $sub = $self->code;
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
