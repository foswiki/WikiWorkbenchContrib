# Module of Foswiki - The Free and Open Source Wiki, http://foswiki.org/
#
# Copyright (C) 2007-2025 Michael Daum http://michaeldaumconsulting.com
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version. For
# more details read LICENSE in the root of this distribution.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
# As per the GPL, removal of this notice is prohibited.

package Foswiki::Contrib::WikiWorkbenchContrib;

use strict;
use warnings;
use Foswiki::Func();
use Error qw(:try);

our $VERSION = '6.00';
our $RELEASE = '%$RELEASE%';
our $SHORTDESCRIPTION = 'Framework for <nop>WikiApplications';
our $LICENSECODE = '%$LICENSECODE%';

sub convertTopicType {
  my ($session) = @_;

  my $request = Foswiki::Func::getRequestObject();
  my $class = $request->param("class");

  try {
    throw Error::Simple("no class specified") unless defined $class;
    $class = 'Foswiki::Contrib::WikiWorkbenchContrib::'.$class unless $class =~ /^Foswiki::/;

    my $path = $class . '.pm';
    $path =~ s/::/\//g;
    eval {require $path};
    throw Error::Simple($@) if $@;

    my $impl = $class->new();
    $impl->convert($session);
  } catch Error with {
    my $error = shift;

    print STDERR "ERROR: ".$error."\n";
  };
}

1;
