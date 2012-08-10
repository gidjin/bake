#!/usr/bin/env perl
package Bake::Instructions;

use v5.14;
use Moo;
use YAML qw/Dump/;

use Bake::Command;

has 'dryrun' => ( is => 'rw' );
has 'subs' => ( is => 'rw' );
has 'commands' => ( is => 'rw' );
has 'descs' => ( is => 'rw' );
has 'opts' => ( is => 'rw' );

sub BUILD {
    my $self = shift;
    $self->subs({});
    $self->commands({});
    $self->descs({});
    $self->opts([]);
}

sub routine {
    my $self = shift;
    my $name = shift;
    my $code = shift;

    my $subroutine = sub { 
        our $command = shift;
        our @args = @_;
        eval $code;
        say $@ if $@; 
    };
    if (exists $self->commands->{$name}) {
        $self->commands->{$name}->subroutine($subroutine);
    }
    else {
        $self->subs->{$name} = $subroutine;
    }
}

sub options {
    my $self = shift;
    my $opt = shift;

    push $self->opts, $opt;
}

sub description {
    my $self = shift;
    my $cmd = shift;
    my $desc = shift;

    $desc = join ("\n  ",@$desc);
    if (exists $self->commands->{$cmd}) {
        $self->commands->{$cmd}->description($desc);
    }
    else {
        $self->descs->{$cmd} = $desc;
    }
}

sub command {
    my $self = shift;
    my $cmd = shift;
    my $name = shift || scalar keys %{$self->commands};
    
    my $command = Bake::Command->new({name=>$name,command=>$cmd});
    if (exists $self->descs->{$name}) {
        $command->description($self->descs->{$name});
    }
    if (exists $self->subs->{$name}) {
        $command->subroutine($self->subs->{$name});
    }
    $self->commands->{$name} = $command;
}


sub choice {
    my $self = shift;
    my $command = undef;

    # show choices
    if (scalar keys %{$self->commands}) {
        my @i = ();
        for my $choice (keys %{$self->commands}) {
            my $message =  scalar @i.') '.$choice ."\n  ";
            my $sep = 0;
            if ($self->commands->{$choice}->description ne '') {
                $message .= $self->commands->{$choice}->description;
                $sep = 1;
            }
            if (!exists $self->subs->{$choice}) {
                $message .= "\n  ---\n  " if $sep;
                $message .= $self->commands->{$choice}->command;
                $message .= "\n";
            }
            elsif ($sep) {
                $message .= "\n";
            }
            say $message;
            push @i,$choice;
        }
        print 'Choose (0-'.(scalar(keys %{$self->commands}) - 1).'): ';
        my $choice = <STDIN>;
        chomp($choice);
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
