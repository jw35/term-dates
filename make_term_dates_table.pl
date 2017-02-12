#!/usr/bin/perl

# Print, using Ucam::Term, what should be the same data that appears in the table
# in Ordnances, Chapter II, Section 10 "Dates of Trem and Full Term"

use strict;
use warnings;

use Ucam::Term;

my @results = ();

foreach my $year (sort(Ucam::Term->available_years)) {

    my %year = (number => sprintf("%4.4d-%2.2d", $year, ($year % 100)+1));
    my $term;
    
    $term = Ucam::Term->new('m',$year);
    last unless $term->dates;
    $year{"m_start"} = $term->fullterm_dates->start->day_of_month;
    $year{"m_end"}   = $term->fullterm_dates->end->subtract(days => 1)->day_of_month;
	
    foreach my $term_name ('l', 'e') {
        my $term = Ucam::Term->new($term_name,$year+1);
        next unless $term->dates;
        $year{"${term_name}_start"} = $term->fullterm_dates->start->day_of_month;  
        $year{"${term_name}_end"}   = $term->fullterm_dates->end->subtract(days => 1)->day_of_month;
        # For Easter term, add General Admission
        if ($term->name eq 'Easter') {
	    my $ga = $term->general_admission;
            my @ga;
	    for (my $dt = $ga->start->clone(); $dt < $ga->end; $dt->add(days => 1)) {
		push(@ga,$dt->day_of_month);
	    }
	    $year{ga} = join('/',@ga);
	}
    }

    push(@results, \%year);

}

print "Year    | Mich   | Lent   | Easter | General Admision\n";
print "--------+--------+--------+--------+-----------------\n"; 

foreach my $year (@results) {
    printf "%7.7s | %2.2d  %2.2d | %2.2d  %2.2d | %2.2d  %2.2d | %s\n",
                     $year->{number}, 
                     $year->{m_start} || 0,
                     $year->{m_end}   || 0,
                     $year->{l_start} || 0, 
                     $year->{l_end}   || 0,
                     $year->{e_start} || 0, 
                     $year->{e_end}   || 0, 
                     $year->{ga}      || "";
}

