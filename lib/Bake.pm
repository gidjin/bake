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
    my $namespace = shift;
    my $return = __PACKAGE__;
    if ($namespace) {
        my $found = 0;
        for my $ns (__PACKAGE__->tasks) {
            if ($ns =~ /(?<!bake)$namespace/i) {
                $return = $ns;
                $found++;
            }
        }
        if ($found > 1) {
            die 'Ambiguous Namespace: '.$namespace."\n";
        }
    }
    return $return;
}

sub find_task {
    my $namespace = shift;
    my $method = shift || 'default';
    my $return = $method;
    my $found = 0;
    for my $md ($namespace->meta->get_all_method_names) {
        if ($md =~ /$method/i) {
            $return=$md;
            $found++;
        }
    }
    if ($found > 1) {
        die 'Ambiguous Method Name: '.$method."\n";
    }
    return $return;
}

sub list {
    for my $ns (__PACKAGE__->tasks) {
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
