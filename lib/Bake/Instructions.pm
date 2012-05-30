#!/usr/bin/env perl
package Bake::Instructions;

use v5.14;
use Moose;
use YAML qw/Dump/;

use Bake::Command;

has 'dryrun' => ( is => 'rw' );
has 'subs' => ( is => 'rw' );
has 'commands' => ( is => 'rw' );
has 'variables' => ( is => 'rw' );

sub BUILD {
    my $self = shift;
    $self->subs({});
    $self->commands({});
    $self->variables({});
}

sub routine {
    my $self = shift;
    my $name = shift;
    my $code = shift;

    $self->subs->{$name} = sub { my $command = shift; my @args = @_; eval $code; say $@ if $@; };
}

sub variable {
    my $self = shift;
    my $var = shift;
    my $val = shift;

    $self->variables->{$var} = $val;
}

sub command {
    my $self = shift;
    my $cmd = shift;
    my $name = shift || scalar keys %{$self->commands};
    
    my $command = Bake::Command->new({name=>$name,command=>$cmd});
    $self->commands->{$name} = $command;
}

sub run {
    my $self = shift;
    my $torun = shift // undef;
    my @args = @_;

    # show choices
    if (scalar keys %{$self->commands}) {
        my @i = ();
        for my $choice (keys %{$self->commands}) {
            say scalar @i.') '.$choice ."\n\t".$self->commands->{$choice}->command;
            push @i,$choice;
        }
        print 'Choose (0-'.(scalar(keys %{$self->commands}) - 1).'): ';
        my $choice = $torun;
        unless (defined $choice) {
            $choice = <STDIN>;
            chomp($choice);
        }
        else {
            say $choice;
        }
        if (defined $choice && $choice !~ /^\d+$/) {
            # Search keys
            my $search = '|'.join('|',sort keys %{$self->commands}).'|';
            ($choice) = $search =~ /\|(\w*?$choice\w*?)\|/;
        }
        elsif (defined $choice && $choice =~ /^\d+$/ && $choice >= 0 && $choice < scalar @i) {
            $choice = $i[$choice];
        }
        if (defined $choice && $choice ne '' && exists $self->commands->{$choice}) {
            $self->commands->{$choice}->variables($self->variables);
            my $cmd = $self->commands->{$choice}->replace_vars;
            if (exists $self->subs->{$cmd}) {
                my $sub = $self->subs->{$cmd};
                say "Running $cmd sub";
                &$sub($self->commands->{$choice},@args) unless $self->dryrun;
            }
            else {
                exec($cmd) unless($self->dryrun);
            }
        }
    }
}

__PACKAGE__->meta->make_immutable;
