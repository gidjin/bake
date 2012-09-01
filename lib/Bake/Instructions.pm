#!/usr/bin/env perl
package Bake::Instructions;

use v5.14;
use Moo;
use YAML qw/Dump/;
use IO::Prompter;
use Bake::Command;

has 'commands' => ( is => 'rw' );

sub BUILD {
    my $self = shift;
    $self->commands({});
}

sub add {
    my $self = shift;
    my $bake = shift;
    $self->commands->{$bake->name} = $bake;
}

sub choice {
    my $self = shift;
    my $choice = shift // undef;
    my $command = undef;

    # show choices
    if (scalar keys %{$self->commands}) {
        my @i = ();
        for my $choice (keys %{$self->commands}) {
            my $bake = $self->commands->{$choice};
            my $message =  scalar @i.') '.$bake->name ."\n";
            my $sep = 0;
            if ($bake->description ne '') {
                $message .= $bake->description;
                $sep = 1;
            }
            if (!defined $bake->code || $bake->code eq '') {
                $message .= "\n  ---\n" if $sep;
                $message .= '> '.$bake->command;
                $message .= "\n";
            }
            elsif ($sep) {
                $message .= "\n";
            }
            say $message;
            push @i,$choice;
        }
        # prompt if not chosen
        if (!defined $choice) {
            my @choices = sort keys %{$self->commands};
            $choice = prompt 'Choose Bake to run: ', -complete => \@choices;
        }
        if (defined $choice && $choice =~ /^\d+$/ && $choice >= 0 && $choice < scalar @i) {
            $choice = $i[$choice];
        }
        $command = $self->find($choice);
    }
    return $command;
}
sub find {
    my $self = shift;
    my $torun = shift // undef;
    my $command = undef;
    if (scalar keys %{$self->commands}) {
        if (defined $torun && $torun !~ /^\d+$/) {
            # Search keys
            my $search = '|'.join('|',sort keys %{$self->commands}).'|';
            ($torun) = $search =~ /\|(\w*?$torun\w*?)\|/;
        }
        $command = $self->commands->{$torun};
    }
    return $command;
}

__PACKAGE__->meta->make_immutable;
