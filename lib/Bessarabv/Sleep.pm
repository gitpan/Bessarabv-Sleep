package Bessarabv::Sleep;
{
  $Bessarabv::Sleep::VERSION = '1.0.0';
}

# ABSTRACT: get Ivan Bessarabov's sleep data


use strict;
use warnings;
use Carp;

use LWP::Simple;
use JSON;
use Time::Local;

my $true = 1;
my $false = '';


sub new {
    my ($class, %opts) = @_;

    croak "new() does not need any parameters. Stopped" if %opts;

    my $self = {};
    bless $self, $class;

    $self->__get_data();

    return $self;
}


sub has_sleep_data {
    my ($self, $date) = @_;

    $self->__die_if_date_is_incorrect($date);

    if (exists $self->{__data}->{$date} and defined $self->{__data}->{$date}) {
        return $true;
    } else {
        return $false;
    }
}


sub get_sleep_hours {
    my ($self, $date) = @_;

    if ($self->has_sleep_data($date)) {
        return $self->{__data}->{$date};
    } else {
        $date = '' if not defined $date;
        croak "There is no sleep info for the date '$date'";
    }
}

sub __get_data {
    my ($self) = @_;

    my $json = get("http://ivan.bessarabov.ru/sleep.json");
    my $data = from_json($json);

    my $day_data = $data->[0]->{day};

    my %date2sleep = map { $_->{label} => $_->{min_value} } @{ $day_data };

    $self->{__data} =  \%date2sleep;

    return $false;
}

sub __die_if_date_is_incorrect {
    my ($self, $date) = @_;

    $date = '' if not defined $date;

    if ($date =~ /^(\d{4})-(\d\d)-(\d\d)$/) {

        my $year = $1;
        my $month = $2;
        my $day = $3;

        # It dies with more or less fiendly message in case of error
        timelocal(0,0,0, $day, $month-1, $year);

    } else {
        croak "Incorrect date '$date'. Stopped";
    }

    return $false;
}

1;

__END__

=pod

=head1 NAME

Bessarabv::Sleep - get Ivan Bessarabov's sleep data

=head1 VERSION

version 1.0.0

=head1 SYNOPSIS

    use Bessarabv::Sleep;

    my $bs = Bessarabv::Sleep->new();

    print $bs->get_sleep_hours("2013-09-27"); # 8.06

=head1 DESCRIPTION

My name is Ivan Bessarabov and I'm a lifelogger. Well, actually I don't record
all of my life, but I do records of some parts of my life.

One of the thing that I measure is my sleep. Every time I go to sleep I record
that time in a text file. And when I get up I also record that time. I have a
simple system that parses that text file and sotores that sleep data somewhere
in the cloud.

This module is a very simple Perl API to get my sleep time data from the
cloud. I sometimes play with this numbers, so I have releases this module to
make things easy. Not sure if someone else will need this module, but there is
no secret here and that's why I've released it on CPAN, but not on my DarkPAN.

Bessarabv::Sleep uses Semantic Versioning standart for version numbers.
Please visit L<http://semver.org/> to find out all about this great thing.

=head1 SEE ALSO

=over

=item * L<Bessarabv::Weight>

=back

=head1 METHODS

=head2 new

This is a constructor. It recieves no parameters and it returns object.

This constructor downloads data from the cloud and stores it in the object.
There is only one interaction with the cloud. After the new() is completed no
interactions with the cloud is done.

    my $bs = Bessarabv::Sleep->new();

=head2 has_sleep_data

If there is sleep data for the given date it returns true value. Othervise it
returns false value. It should recieve date in the format YYYY-MM-DD. In case
the date is incorrect this method will die.

    $bs->has_sleep_data("2013-09-15");  # false
    $bs->has_sleep_data("2013-09-27");  # true

=head2 get_sleep_hours

Returns my sleep in kilograms for the given date. In case the date is
incorrect the method dies. The method dies if there is no value for the
specified date.

    $bs->get_sleep_hours("2013-09-27");  # 8.06
    $bs->get_sleep_hours("2013-09-15");  # Boom! Script dies here because
                        # there is no value. Use has_sleep_data() to check.

=head1 AUTHOR

Ivan Bessarabov <ivan@bessarabov.ru>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Ivan Bessarabov.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
