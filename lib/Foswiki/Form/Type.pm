# Plugin for Foswiki - The Free and Open Source Wiki, http://foswiki.org/
#
# WikiWorkbenckContrib is Copyright (C) 2012-2020 Michael Daum http://michaeldaumconsulting.com
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

package Foswiki::Form::Type;

use strict;
use warnings;

use Foswiki::Form::FieldDefinition ();
use Foswiki::Func ();
use Foswiki::Render ();
our @ISA = ('Foswiki::Form::FieldDefinition');

sub isEditable {
  return 0;
}

sub getDefaultValue {
  my $this = shift;

  return $this->{value} // '';
}

sub renderForEdit {
  my $this = shift;

  return (
    '',
    Foswiki::Render::html("input", {
      "type" => "hidden",
      "name" => $this->{name},
      "value" => $this->getDefaultValue()
    })
  );
}

1;
