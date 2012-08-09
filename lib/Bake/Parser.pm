#!/usr/bin/env perl
package Bake::Parser;
use v5.14;
use Moo;
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
                | bake(s) | variable(s) | description(s) | comment(s)
sub             : "sub" m{[a-zA-Z0-9_]+} <perl_codeblock>
                    { $instructions->routine($item{__PATTERN1__},$item{__DIRECTIVE1__}); }
bakename        : m{[a-zA-Z0-9.-/_]+}
                    { $return = $item{__PATTERN1__} }
bake            : "bake" bakename(1) /\'\s*/ /[^\']+/ /\s*\'/
                    { $instructions->command($item{__PATTERN2__},$item{"bakename(1)"}[0]); }
                | "bake" bakename(1) <perl_codeblock>
                    {
                        $instructions->command($item{"bakename(1)"}[0],$item{"bakename(1)"}[0]);
                        $instructions->routine($item{"bakename(1)"}[0],$item{__DIRECTIVE1__});
                    }
variable        : /\\$\\w+/ "=" m|.+|
                    {$instructions->variable($item{__PATTERN1__},$item{__PATTERN2__})}
description     : "##" bakename(1) comment(s)
                    {$instructions->description($item{"bakename(1)"}[0],$item{"comment(s)"});}
comment         : /#(?!#)/ /.*/
';
    $self->_set_parser(new Parse::RecDescent($grammer));
}

sub parse {
    my $self = shift;
    my $text = shift;
    return $self->parser->instructions($text);
}
__PACKAGE__->meta->make_immutable;
