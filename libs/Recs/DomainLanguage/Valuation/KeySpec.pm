package Recs::DomainLanguage::Valuation::KeySpec;

use strict;
use warnings;

use Recs::DomainLanguage::Valuation;

use base ('Recs::DomainLanguage::Valuation');

sub new
{
    my $class = shift;
    my $keyspec = shift;

    my $this =
    {
        'KEYSPEC' => $keyspec,
    };

    bless $this, $class;

    return $this;
}

sub evaluate_record
{
    my $this = shift;
    my $r = shift;

    my $keyspec = $this->{'KEYSPEC'};

    return ${$r->guess_key_from_spec($keyspec)};
}

1;
