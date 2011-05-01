package Recs::Aggregator::Internal::Constant;

use strict;
use lib;

use Recs::Aggregator::Aggregation;
use base 'Recs::Aggregator::Aggregation';

sub new
{
    my $class = shift;
    my $value = shift;

    my $this =
    {
        'VALUE' => $value,
    };

    bless $this, $class;

    return $this;
}

sub initial
{
    return undef;
}

sub combine
{
    return undef;
}

sub squish
{
    my $this = shift;

    return $this->{'VALUE'};
}

1;
