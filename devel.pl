#!/usr/bin/perl

use strict;
use warnings;

use DateTime;
use DateTime::Duration;
use Data::ICal;
use Data::ICal::Entry::Event;

# See Ordinances, Chapter II, 'Terms and Long Vacation' and
# Ordinances, Chapter II, 'Admission to Degrees'
# http://www.admin.cam.ac.uk/univ/so/pdfs/cso_4_ordinance02.171_217.pdf

# "The dates on which Full Terms begin and end shall be as shown in
# the table appended to these regulations"

# This data represents the fiirst day of full term, extracted from the
# table in S&O

#                                     Jan      Apr      Oct
my $full_term_start = { 2007 => {                   m =>  2 },
                        2008 => { l => 15, e => 22, m =>  7 },
                        2009 => { l => 13, e => 21, m =>  6 },
                        2010 => { l => 12, e => 20, m =>  5 },
                        2011 => { l => 18, e => 26, m =>  4 },
                        2012 => { l => 17, e => 24, m =>  2 },
                        2013 => { l => 15, e => 23, m =>  8 },
                        2014 => { l => 14, e => 22, m =>  7 },
                        2015 => { l => 13, e => 21, m =>  6 },
                        2016 => { l => 12, e => 19, m =>  4 },
                        2017 => { l => 17, e => 25, m =>  3 },
                        2018 => { l => 16, e => 24, m =>  2 },
                        2019 => { l => 15, e => 23, m =>  8 },
                        2020 => { l => 14, e => 21.         },
                      };

my $term_name = { m => 'Michaelmas', l => 'Lent', e => 'Easter' };

my $ical = '%Y%m%d';

# The legths of the various terms (actually one less than the lengths
# to produce 'inclusive' dates)
my $eighty_days = DateTime::Duration->new( days => 79 );
my $seventy_days = DateTime::Duration->new( days => 69 );
my $sixty_days = DateTime::Duration->new( days => 59 );
my $fiftythree_days = DateTime::Duration->new( days => 52 );

my $calendar = Data::ICal->new();
$calendar->add_property('X-WR-CALNAME' => 'University of Cambridge Term Dates');

foreach my $year (2007..2020) {

    foreach my $term ('l', 'e', 'm') {

        my $term_start = $full_term_start->{$year}->{$term};
        if ($term_start) {
            my ($start,$end,$fstart,$fend,$div);

# "Full Term shall consist of three-fourths of the whole term
# reckoned from the first day of Full Term as hereinafter determined"

# http://www.cam.ac.uk/univ/termdates.html: "Division of Term is
# half-way through Term (not Full Term). The dates are the same for
# every year except for Easter term: 9 November, 13 February, and 14
# May or 21 May depending on whether Easter Term starts on 10 April or
# 17 April"

# "The Michaelmas Term shall begin on 1 October and shall consist of
# eighty days, ending on 19 December"
            if ($term eq 'm') {
                $start = DateTime->new(year=>$year,
                                       month=>10,
                                       day=>1);
                $end   = $start + $eighty_days;
                $fstart = DateTime->new(year=>$year,
                                        month=>10,
                                        day=>$term_start);
                $fend = $fstart + $sixty_days;
                $div = DateTime->new(year=>$year,
                                       month=>11,
                                       day=>9);
            }

# "The Lent Term shall begin on 5 January and shall consist of eighty
# days, ending on 25 March or in any leap year on 24 March"
            elsif ($term eq 'l') {
                $start = DateTime->new(year=>$year,
                                       month=>1,
                                       day=>5);
                $end   = $start + $eighty_days;
                $fstart = DateTime->new(year=>$year,
                                        month=>1,
                                        day=>$term_start);
                $fend = $fstart + $sixty_days;
                $div = DateTime->new(year=>$year,
                                       month=>2,
                                       day=>13);
            }

# "The Easter Term shall begin on 10 April and shall consist of seventy
# days ending on 18 June, provided that in any year in which Full
# Easter Term begins on or after 22 April the Easter Term shall begin
# on 17 April and end on 25 June"
            elsif ($term eq 'e') {
                if ($term_start >= 22) {
                    $start = DateTime->new(year=>$year,
                                           month=>4,
                                           day=>17);
                    $end = DateTime->new(year=>$year,
                                         month=>6,
                                         day=>25);
                    $div = DateTime->new(year=>$year,
                                       month=>4,
                                       day=>17);
                }
                else {
                    $start = DateTime->new(year=>$year,
                                           month=>4,
                                           day=>10);
                    $end = DateTime->new(year=>$year,
                                         month=>6,
                                         day=>18);
                    $div = DateTime->new(year=>$year,
                                       month=>4,
                                       day=>10);
                }
                $fstart = DateTime->new(year=>$year,
                                        month=>4,
                                        day=>$term_start);
                $fend = $fstart + $fiftythree_days;
            }

            else {
                die ('This can\'t happen - unknown term');
            }

            #print "$year ", $term_name->{$term}, "\n";
            #print "Term start:      $start\n";
            #print "Full term start: $fstart\n";
            #print "Division:        $div\n";
            #print "Full term end:   $fend\n";
            #print "Full term end:   $end\n";
            #print "\n";

            my $ts = Data::ICal::Entry::Event->new();
            $ts->add_properties(
                summary => "Start of " . $term_name->{$term} . " Term",
                dtstart => [$start->strftime($ical), { VALUE => 'DATE' } ],
                dtend   => [$start->clone->add(days=>1)->strftime($ical), { VALUE => 'DATE' } ],
              );
            $calendar->add_entry($ts);
            my $d = Data::ICal::Entry::Event->new();
            $d->add_properties(
                summary => "Division of Term",
                dtstart => [$div->strftime($ical), { VALUE => 'DATE' } ],
                dtend   => [$div->clone->add(days=>1)->strftime($ical), { VALUE => 'DATE' } ],
              );
            $calendar->add_entry($d);
            my $te = Data::ICal::Entry::Event->new();
            $te->add_properties(
                summary => "End of " . $term_name->{$term} . " Term",
                dtstart => [$end->strftime($ical), { VALUE => 'DATE' } ],
                dtend   => [$end->clone->add(days=>1)->strftime($ical), { VALUE => 'DATE' } ],
              );
            $calendar->add_entry($te);
            my $full = Data::ICal::Entry::Event->new();
            $full->add_properties(
                summary => "Full Term",
                dtstart => [$fstart->strftime($ical), { VALUE => 'DATE' } ],
                dtend   => [$fend->clone->add(days=>1)->strftime($ical), { VALUE => 'DATE' } ],
              );
            $calendar->add_entry($full);

            if ($term eq 'e') {

# "In every year the Thursday, Friday, and Saturday after the third
# Sunday in June shall be days of General Admission to Degrees, save
# that, in accordance with Regulation 3 for Terms and Long Vacation,
# in any year in which Full Easter Term begins on or after 22 April
# the days of General Admission shall be the Thursday, Friday, and
# Saturday after the fourth Sunday in June"

                # Find first day in June
                my $gastart =  DateTime->new(year=>$year, month=>6, day=>1);
                # Move to 1st Sunday
                my $dow = $gastart->day_of_week();
                $gastart->add ( days => (7-$dow+7)%7);
                # Move to the third or fourth Sunday
                if ($term_start >= 22) {
                    $gastart->add (weeks => 3);
                }
                else {
                    $gastart->add (weeks => 2);
                }
                # Move to Thursday
                $gastart->add (days => 4);
                my $gaend = $gastart->clone()->add(days=> 2);

                #print "General Admission $year: $gastart - $gaend\n\n";

                my $ga = Data::ICal::Entry::Event->new();
                $ga->add_properties(
                    summary => "General Admission",
                    dtstart => [$gastart->strftime($ical), { VALUE => 'DATE' } ],
                    dtend   => [$gaend->clone->add(days=>1)->strftime($ical), { VALUE => 'DATE' } ],
                );
                $calendar->add_entry($ga);


# "A course of instruction given during the Long Vacation shall not
# occupy more than four weeks.  Except with the approval of the
# Council on the recommendation of the General Board, no such course
# given within the Precincts of the University shall begin earlier
# than the second Monday after General Admission or end later than the
# sixth Saturday after the Saturday of General Admission"

                # "second Monday after General Admission" is 1 week
                # and 4 days after the first day (Thursday) of General
                # Admission
                my $lvstart = $gastart->clone()->add(days => 4, weeks => 1);
                # "sixth Saturday after the Saturday of General
                # Admission" is 6 weeks and 2 days after the first day
                # (Thursday) of General Admission
                my $lvend   = $gastart->clone()->add(days => 2, weeks => 6);

                #print "Long Vac courses $year: $lvstart - $lvend\n\n";

                my $lvs = Data::ICal::Entry::Event->new();
                $lvs->add_properties(
                    summary => "Long Vac Courses start",
                    dtstart => [$lvstart->strftime($ical), { VALUE => 'DATE' } ],
                    dtend   => [$lvstart->clone->add(days=>1)->strftime($ical), { VALUE => 'DATE' } ],
                );
                $calendar->add_entry($lvs);
                my $lve = Data::ICal::Entry::Event->new();
                $lve->add_properties(
                    summary => "Long Vac Courses end",
                    dtstart => [$lvend->strftime($ical), { VALUE => 'DATE' } ],
                    dtend   => [$lvend->clone->add(days=>1)->strftime($ical), { VALUE => 'DATE' } ],
                );
                $calendar->add_entry($lve);

            } #if $term eq 'e'

        } #if term_start

    } #foreach term

} #foreach year

print $calendar->as_string;
