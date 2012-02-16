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
    if ($namespace) {
        for my $ns (__PACKAGE__->tasks) {
            if ($ns =~ /(?<!bake)$namespace/i) {
                $namespace = $ns;
                last;
            }
        }
    }
    else {
        $namespace = __PACKAGE__;
    }
    return $namespace;
}

sub find_task {
    my $namespace = shift;
    my $method = shift || 'default';
    for my $md ($namespace->meta->get_all_method_names) {
        if ($md =~ /$method/i) {
            $method=$md;
            last;
        }
    }
    return $method;
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
