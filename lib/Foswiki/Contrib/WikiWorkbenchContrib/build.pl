#!/usr/bin/env perl

BEGIN {
  foreach my $pc (split(/:/, $ENV{FOSWIKI_LIBS})) {
    unshift @INC, $pc;
  }
}

use Foswiki::Contrib::Build;
$build = new Foswiki::Contrib::Build('WikiWorkbenchContrib');
$build->build($build->{target});

