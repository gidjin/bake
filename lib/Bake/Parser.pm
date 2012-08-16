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
        <rule: bake>            <[metabake]>* bake <name> <command>
        <rule: metabake>        <description> | <option> | <use>
        <rule: command>         ' <execute> ' | <perlcode>
        <rule: perlcode>        \{ (?: <perlcode> | [^{}])* \}
        <rule: name>            [a-zA-Z0-9.-/_]+
        <rule: execute>         .*?
        <rule: option>          opt ' <execute> '
        <rule: use>             use <execute> ;
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
                my $meta = $inst->{bake}->{metabake};
                if (defined $exec && $exec ne '') {
                    $bake->command($exec);
                }
                elsif (defined $perl && $perl ne '') {
                    $bake->command($bake->name);
                    $bake->subroutine($perl);
                }
                for my $m (@$meta) {
                    if (exists $m->{description}) {
                        my $desc = $m->{description}->{''};
                        if (defined $desc && $desc ne '') {
                            $bake->description($desc);
                        }
                    }
                    if (exists $m->{use}) {
                        my $use = $m->{use}->{execute};
                        my $param = $m->{use}->{param};
                        if (defined $use && $use ne '') {
                            $bake->uses->[@{$bake->uses}] = $use;
                        }
                    }
                    if (exists $m->{option}) {
                        my $option = $m->{option}->{execute};
                        if (defined $option && $option ne '') {
                            $bake->options->[@{$bake->options}] = $option;
                        }
                    }
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
