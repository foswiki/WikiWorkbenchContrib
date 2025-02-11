# Plugin for Foswiki - The Free and Open Source Wiki, http://foswiki.org/
#
# WikiWorkbenckContrib is Copyright (C) 2012-2025 Michael Daum http://michaeldaumconsulting.com
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details, published at
# http://www.gnu.org/copyleft/gpl.html
# See bottom of file for license and copyright information
package Foswiki::Form::Wikiapp;

use strict;
use warnings;

use Foswiki::Form::Select ();
use Foswiki::Func ();
our @ISA = ('Foswiki::Form::Select');

our $APPLICATIONS = 'Applications';

sub getOptions {
  my $this = shift;

  my $vals = $this->{_options};
  return $vals if $vals;

  my @apps = ();

  foreach my $app (Foswiki::Func::getListOfWebs()) {
    next unless $app =~ /^$APPLICATIONS/;
    $app =~ s/\//./g;
    $app =~ s/.*\.(.+?)$/$1/;

    $app = 'WikiWorkbench' if $app eq $APPLICATIONS;
    push @apps, $app;
  }

  @apps = sort @apps;
  unshift @apps, 'none';

  $this->{_options} = \@apps;

  return $this->{_options};
}

sub getDefaultValue {
  my $this = shift;

  my $default = $this::SUPER::getDefaultValue;

  if (!defined $default || $default eq "") {
    $default = $Foswiki::Plugins::SESSION->{webName};
    $default =~ s/^.*\[\.\/]//g;
  }

  $default = "WikiWorkbench" if $default eq $APPLICATIONS;

  return $default;
}

sub renderForDisplay {
  my ($this, $format, $value, $attrs) = @_;


  my $displayValue = $this->getDisplayValue($value);
  $format =~ s/\$value\(display\)/$displayValue/g;
  $format =~ s/\$value/$value/g;

  return $this->SUPER::renderForDisplay($format, $value, $attrs);
}

sub getDisplayValue {
  my ($this, $value) = @_;

  unless ($value eq 'none') {
    my $label = $value;

    if ($value eq 'WikiWorkbench') {
      $value = $APPLICATIONS;
    } else {
      $value = $APPLICATIONS . '.' . $value;
    }

    my $url = Foswiki::Func::getScriptUrl($value, $Foswiki::cfg{HomeTopicName}, "view");
    $value = "<a href='$url'>$label</a>";
  }

  return $value;
}

1;
