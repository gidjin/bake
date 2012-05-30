#!/usr/bin/env perl
package Bake::Parser;
use v5.14;
use Moose;
use Parse::RecDescent;
use Bake::Instructions;
use YAML qw/Dump/;

has 'parser' => (
    is      => 'ro',
    writer  => '_set_parser'
);

#$::RD_HINT=1;
#$::RD_TRACE=1;

sub BUILD {
    my $self = shift;
    my $grammer =q'
# Bake file grammer
{ my $instructions = new Bake::Instructions(); }
instructions    : any(s) { $return = $instructions }
any             : sub(s) 
                | bake(s) | variable(s) | comment(s)
sub             : "sub" m{[a-zA-Z0-9_]+} <perl_codeblock>
                    { $instructions->routine($item{__PATTERN1__},$item{__DIRECTIVE1__}); }
cmdname         : m{[a-zA-Z0-9.-/]+} arg(s?)
                    { 
                        $return = $item{__PATTERN1__};
                        if (scalar @{$item{"arg(s?)"}}) {
                            $return .= " ".(join(" ",@{$item{"arg(s?)"}}));
                        }
                    }
arg             : m{(?:\\w|\\.|-|_|=|\'|"|:|/)+}
                    { $return = $item{__PATTERN1__} }
                | m{\\$\\w+}
                    { $return = $item{__PATTERN1__} }
bakename        : m{[a-zA-Z0-9.-/_]+}
                    { $return = $item{__PATTERN1__} }
bake            : /bake/ bakename(1) "{" cmdname(1) comment(?) "}"
                    { $instructions->command($item{"cmdname(1)"}[0],$item{"bakename(1)"}[0]) }
                | /bake/ bakename(1) <perl_codeblock>
                    {
                        $instructions->command($item{"bakename(1)"}[0],$item{"bakename(1)"}[0]);
                        $instructions->routine($item{"bakename(1)"}[0],$item{__DIRECTIVE1__});
                    }
variable        : /\\$\\w+/ "=" m|.+|
                    {$instructions->variable($item{__PATTERN1__},$item{__PATTERN2__})}
comment         : /#.*/
';
    $self->_set_parser(new Parse::RecDescent($grammer));
}

sub parse {
    my $self = shift;
    my $text = shift;
    return $self->parser->instructions($text);
}
__PACKAGE__->meta->make_immutable;
