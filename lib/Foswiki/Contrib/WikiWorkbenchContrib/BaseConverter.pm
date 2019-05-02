# Copyright (C) 2017-2019 Michael Daum http://michaeldaumconsulting.com
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details, published at
# http://www.gnu.org/copyleft/gpl.html

package Foswiki::Contrib::WikiWorkbenchContrib::BaseConverter;

use strict;
use warnings;

use Foswiki::Plugins ();
use Foswiki::Func ();
use Foswiki::Form ();

sub new {
  my $class = shift;

  my $this = bless({
    @_
  }, $class);

  $this->{_translationTable} = {};
  $this->{_inited} = 0;

  return $this;
}

sub init {
  my ($this, $session) = @_;

  unless ($this->{_inited}) {

    $session ||= $Foswiki::Plugins::SESSION;

    my $request = Foswiki::Func::getRequestObject();

    $this->{_query} = $request->param("query");
    $this->{_web} = $request->param("web") || $session->{webName};
    $this->{_oldForm} = $request->param("oldform") || $this->{oldForm};
    $this->{_newForm} = $request->param("newform") || $this->{newForm} || 'Application.WikiTopic';
    $this->{_isDry} = Foswiki::Func::isTrue($request->param("dry"), 0);
    $this->{_isVerbose} = Foswiki::Func::isTrue($request->param("verbose"), 1);
    $this->{_isQuiet} = Foswiki::Func::isTrue($request->param("quiet"), 0);
    $this->{_limit} = $request->param("limit");


    $this->{_inited} = 1;
  }
}

sub getFormDef {
  my ($this) = @_;

  unless (defined $this->{_formDef}) {
    my ($formWeb, $formTopic) = Foswiki::Func::normalizeWebTopicName(undef, $this->{_newForm});
    $this->{_formDef} = new Foswiki::Form($session, $formWeb, $formTopic);
  }

  return $this->{_formDef};
}

sub getFieldDef {
  my ($this, $fieldName) = @_;

  return $this->getFormDef()->getField($fieldName);
}

sub search {
  my ($this) = @_;

  my $query = $this->{_query};
  $query = "form.name='$this->{_oldForm}'" if defined $this->{_oldForm};
  $query = "not form" unless defind $query;

  return Foswiki::Func::searchInWebContent($query, $this->{_web}, undef, {type => "query"});
}

sub log {
  my ($this, $msg) = @_;
  return if $this->{_isQuiet} || !$this->{_isVerbose};
  print STDERR "$msg\n";
}

sub warn {
  my ($this, $msg) = @_;
  return if $this->{_isQuiet};
  print STDERR "WARNING: $msg\n";
}

sub convert {
  my ($this) = @_;

  $this->log("### iterating over topics in $this->{_web}");

  my $matches = $this->search();
  my $index = 0;

  foreach my $topic (sort keys(%$matches)) {
    $index++;

    $this->log("... converting $this->{_web}.$topic");

    throw Error::Simple("topic does not exist") 
      unless Foswiki::Func::topicExists($this->{_web}, $topic);

    my ($meta) = Foswiki::Func::readTopic($this->{_web}, $topic);
    $this->convertTopic($this->{_web}, $topic, $meta);

    last if $this->{_limit} && $index >= $this->{_limit};
  }

  return $index;
}

sub convertTopic {
  my ($this, $web, $topic, $meta) = @_;

  my $form = $meta->get("FORM");
  if (defined $form) {
    # change form
    $form->{name} = $this->{_newForm};

    foreach my $field ($meta->find('FIELD')) {
      $this->translateField($field);

      my $fieldDef = $this->getFieldDef($field->{name});

      if ($fieldDef->{type} eq 'date2') {
        if (!$this->convertDateToDate2($field)) {
          $this->warn("cannot convert date '$field->{value}' in $field->{name} of $web.$topic");
        }
      }

    }
  } else {
    # add form
    $meta->putKeyed("FORM", {name => $this->{_newForm}});
  }

  my $text = $meta->text() || '';
  my $topicTitle = $this->extractTopicTitle($text);
  if (defined $topicTitle) {
    $this->log("... found TopicTitle $topicTitle");
    $this->setTopicTitle($meta, $topicTitle);
  } else {
    $this->setTopicTitle($meta, "");
  }
  $this->setTopicType($meta);
  $this->saveTopic($meta, $text);
}

sub convertDateToDate2 {
  my ($this, $field) = @_;

  my $date = $this->normalizeDate($field->{value});
  if (defined $date) {
    $field->{value} = $date;
    return 1;
  } 

  return 0;
}

sub normalizeDate {
  my ($this, $value) = @_;

  return "" if $value eq "" || $value eq 'dd.mm.jjjj';

  if ($value =~ /^\s*\[\[.*?\]\[(.*?)\]\]\s*$/) {
    $this->warn("... decrufting date field $value to $1");
    $value = $1;
  }

  my $day;
  my $mon;
  my $year;

  if ($value =~ /^(\d\d?)\.(\d\d?)\.((?:\d\d)?\d\d)(?: .*)?$/) {
    $day = $1;
    $mon = $2;
    $year = $3;
    $year += 2000 if $year < 100;
  }  elsif ($value =~ /^(\d\d\d\d)[\.\-](\d\d?)[\.\-](\d\d?)(?: .*)?$/) {
    $day = $3;
    $mon = $2;
    $year = $1;
  }

  if (defined $day && defined $mon && defined $year) {
    return sprintf("%04d/%02d/%02d", $year,$mon,$day);
  }

  return;
}

sub convertPerson {
  my ($this, $value, $stripUsersWebName) = @_;

  my @value = ();
  my $usersWebName = $stripUsersWebName?"":$Foswiki::cfg{UsersWebName}.".";

  foreach my $v (split(/\s*,\s*/, $value)) {
    $v =~ s/^\[\[(.*?)\](?:\[.*?\])?\]/$1/;
    $v =~ s/^(Main|%USERSWEB%|%MAINWEB%)\./$usersWebName/;
    $v =~ s/%BR%|<b \/>//g;
    $v = 'QM.'.$v if ($v =~ /Funktion$/ && !($v=~/^Main\./));
    $v =~ s/^\s+|\s.*$//g;

    $v =~ s/https?:\/\/.*\/MaVerzeichnis?.*suchtext=(.*?)&.*/$1/;
    push @value, $v if $v ne '';
  }

  return join(", ", @value);
}

sub extractTopicTitle {
  my $this = shift;
  #my $text = $_[0];

  if ($_[0] =~ s/^\-\-\-\+(?:!!)?(.*?)\n//) {
    my $topicTitle = $1;
    $topicTitle =~ s/^\s+|\s+$//g;
    return $topicTitle;
  }

  return;
}

sub translate {
  my ($this, $string) = @_;
  return $this->{_translationTable}{$string} // $string;
}

sub translateField {
  my ($this, $field) = @_;

  $field->{name} = $this->translate($field->{name});
  $field->{title} = $this->translate($field->{title});

  return $field;
}

sub setTopicTitle {
  my ($this, $meta, $val) = @_;

  $meta->putKeyed( 'FIELD', { name => 'TopicTitle', title => '<nop>TopicTitle', value =>$val } );
}

sub setTopicType {
  my ($this, $meta, $val) = @_;

  unless (defined $val) {
    # get TopicType from form definition
    my $fieldDef = $this->getFieldDef("TopicType");
    $val = $fieldDef->{value} if defined $fieldDef;
  }

  $meta->putKeyed( 'FIELD', { name => 'TopicType', title => 'TopicType', value => $val } ) if defined $val;
}

sub saveTopic {
  my ($this, $meta, $text) = @_;

  $meta->text($text);

  if ($this->{_isDry}) {
    $this->log($meta->stringify);
  } else {
    $meta->save();
  }
}

1;
