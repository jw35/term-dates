#!/usr/bin/perl

# Prints to STDOUT an ICAL calendar for University of Cambridge Term Dates

use strict;
use warnings;

use Ucam::Term;
use DateTime::Duration;
use DateTime::Span;
use Data::ICal;
use Data::ICal::Entry::Event;

use constant ICAL => '%Y%m%d';
use constant ONE_DAY => DateTime::Duration->new( days => 1 );


my $calendar = Data::ICal->new();
$calendar->add_property('X-WR-CALNAME' => 'UofC Term Dates');

foreach my $year (Ucam::Term->available_years) {

    foreach my $term_name ('l', 'e', 'm') {

        my $term = Ucam::Term->new($term_name,$year);

        next unless $term->dates;

        # Make the division into a 1 day span and add it
        my $div = DateTime::Span->from_datetime_and_duration
            (start => $term->division, duration => ONE_DAY );
        add_span($calendar, $div, "Division of term");

        # Remove the division 'day' from full term and add the 2 resulting spans
        my $full = $term->fullterm_dates->complement($div);
        foreach my $span ($full->as_list) {
            add_span($calendar, $span, "Full " . $term->name. " term");
        }

        # Remove full term from term and add the 2 results
        my $allterm = $term->dates->complement($term->fullterm_dates);
        foreach my $span ($allterm->as_list) {
            add_span($calendar, $span, $term->name. " term");
        }

        # For easter, add general Admission and the Long Vac
        if ($term->name eq 'Easter') {
	    add_span($calendar, $term->general_admission, "General Admission");
	    add_span($calendar, $term->long_vac, "Long Vacation courses");
        }

    }

}

# Print the result
print $calendar->as_string;

# -- #

sub add_span {
    my ($calendar, $span, $summary) = @_;

    my $event = Data::ICal::Entry::Event->new();

    $event->add_properties(
        summary => $summary,
        dtstart => [$span->start->strftime(ICAL), { VALUE => 'DATE' } ],
        dtend   => [$span->end  ->strftime(ICAL), { VALUE => 'DATE' } ],
    );

    $calendar->add_entry($event);

}
