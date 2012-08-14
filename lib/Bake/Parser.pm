#!/usr/bin/env perl
package Bake::Parser;
use v5.14;
use Moo;
use Bake::Instructions;
use Bake::Command;
use YAML qw/Dump/;

has 'grammar' => (
    is      => 'ro',
    writer  => '_set_grammar'
);

sub BUILD {
    my $self = shift;
    # Bake file grammar
    use Regexp::Grammars;
    my $grammar =qr@
        <file>
        <rule: file>            <[instructions]>*
        <rule: instructions>    <comment> | <bake> | <startdesc>
        <rule: comment>         \#(?!\#).*$
        <rule: startdesc>       \#\# <name>
        <rule: description>     <startdesc> <[comment]>*
        <rule: bake>            <description>? <[options]>* bake <name> <command>
        <rule: command>         ' <execute> ' | <perlcode>
        <rule: perlcode>        \{ (?: <perlcode> | [^{}])* \}
        <rule: name>            [a-zA-Z0-9.-/_]+
        <rule: execute>         .*?
        <rule: options>          opt ' <getopt> '
        <rule: getopt>          (?:[^'])* # ' for vim
    @xm;
    $self->_set_grammar($grammar);
}

sub parse {
    my $self = shift;
    my $text = shift;
    my %parsed = ();
    my $instructions = undef;
    if ($text =~ $self->grammar) {
        %parsed = %/;
        # transform hash into array of instruction objects
        #say Dump(\%parsed);
        $instructions = new Bake::Instructions();
        for my $inst (@{$parsed{file}->{instructions}}) {
            if (exists $inst->{bake}) {
                my $bake = new Bake::Command({name=>$inst->{bake}->{name}});
                my $exec = $inst->{bake}->{command}->{execute};
                my $perl = (ref $inst->{bake}->{command}->{perlcode} eq 'HASH') 
                    ? $inst->{bake}->{command}->{perlcode}->{''} 
                    : $inst->{bake}->{command}->{perlcode};
                my $desc = $inst->{bake}->{description}->{''};
                if (defined $exec && $exec ne '') {
                    $bake->command($exec);
                }
                elsif (defined $perl && $perl ne '') {
                    $bake->command($bake->name);
                    my $subroutine = sub {
                        our $command = shift;
                        our @args = @_;
                        eval $perl;
                        say $@ if $@;
                    };
                    $bake->subroutine($subroutine);
                }
                if (defined $desc && $desc ne '') {
                    $bake->description($desc);
                }
                $instructions->add($bake);
            }
        }
    }
    else {
        die "Couldn't Parse Text\n";
    }
    return $instructions;
}


__PACKAGE__->meta->make_immutable;
