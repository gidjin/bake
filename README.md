## Perl Bake

Perl bake is my attempt at writing a build tool similar to rake. The basic premis is that a task
should boild down to a simple perl subroutine and executed that way. We can easily provide a
colection of tasks in a perl module, and use package names to provide a name space. This is just a
first pass so feel free to send me feed backr: bake (at) magneticorange.com

### Sample usage

  bake server:start
  bake list
  bake db:migrate
