#!/usr/bin/env perl
package Bake;
use Moose;
use Module::Pluggable require => 1, sub_name => 'tasks', search_path => ["Bake"];
use v5.14;

=head1 NAME

Bake - Main module for bake script.

=cut

our @ignore = qw/dump DEMOLISHALL meta does new DESTROY BUILDALL can BUILDARGS isa VERSION DOES/;
my $temp = '^_\w+|'.( join "|",@ignore);
our $ignore = qr/$temp/;

sub find_namespace {
    my $self = shift;
    my $namespace = shift;
    my $return = $self;
    if ($namespace) {
        my @found = ();
        for my $ns ($self->tasks) {
            if ($ns =~ /(?<!bake)$namespace/i) {
                $return = $ns;
                $found[scalar @found]=$ns;
            }
        }
        if (scalar @found > 1) {
            warn 'Ambiguous Namespace: '.$namespace.' ('.(join ',',@found).")\n";
            # if ambigous return default
            $return = $self;
        }
    }
    return $return;
}

sub create_command {
    my $self = shift;
    my $namespace = shift;
    my $method = shift;

    ($namespace,$method) = $self->find_task($namespace,$method);
    return $namespace.'->'.$method;
}

sub find_task {
    my $self = shift;
    my $namespace = shift;
    my $method = shift;
    my $return = $self->find_specific_task($namespace,$method);
    # if not found search other spaces
    if (!defined $return && (lc $namespace eq 'bake')) {
        for my $ns (sort $self->tasks) {
            $namespace = $ns;
            $return = $self->find_specific_task($namespace,$method);
            last if defined $return;
        }
    }
    $return = 'default' unless defined $return;
    return ($namespace,$return);
}

sub find_specific_task {
    my $self = shift;
    my $namespace = shift;
    my $method = shift || 'default';
    my $return = undef;
    my @found = ();
    eval {
        for my $md ($namespace->meta->get_all_method_names) {
            if ($md =~ /$method/i) {
                $return=$md;
                $found[scalar @found]=$md;
            }
        }
    };
    if (scalar @found > 1) {
        warn 'Ambiguous Method Name: '.$method.' ('.(join ',',@found).")\n";
        $return = undef;
    }
    return $return;
}

sub info {
    say "Perl Bake Version 0.0.1";
}

sub list {
    my $self = shift;
    for my $ns ($self->tasks) {
        eval {
            my @tasks = $ns->meta->get_all_method_names;
            if (@tasks) {
                say $ns;
                say "\t".(join "\n\t",(grep { unless (/$ignore/) { $_ } else { undef } } @tasks));
            }
        }
    }
}

__PACKAGE__->meta->make_immutable;
