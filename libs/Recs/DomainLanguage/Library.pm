package Recs::DomainLanguage::Library;

use strict;
use warnings;

use Recs::DomainLanguage::Registry;
use Recs::DomainLanguage::Valuation::KeySpec;
use Recs::DomainLanguage::Valuation::Sub;

sub _identity
{
    my $library_this = shift;
    my $obj = shift;

    return $obj;
}

Recs::DomainLanguage::Registry::register_vfn(\&_identity, 'type_agg', 'AGGREGATOR');
Recs::DomainLanguage::Registry::register_vfn(\&_identity, 'type_valuation', 'VALUATION');
Recs::DomainLanguage::Registry::register_vfn(\&_identity, 'type_scalar', 'SCALAR');

sub _rec_valuation
{
    my $library_this = shift;

    return Recs::DomainLanguage::Valuation::Sub->new(sub { return $_[0]; });
}

Recs::DomainLanguage::Registry::register_vfn(\&_rec_valuation, 'record');
Recs::DomainLanguage::Registry::register_vfn(\&_rec_valuation, 'rec');

sub _raw_valuation
{
    my $library_this = shift;
    my $v = shift;

    if(ref($v) eq "CODE")
    {
        return Recs::DomainLanguage::Valuation::Sub->new($v);
    }

    return Recs::DomainLanguage::Valuation::KeySpec->new($v);
}

Recs::DomainLanguage::Registry::register_vfn(\&_raw_valuation, 'valuation', 'SCALAR');
Recs::DomainLanguage::Registry::register_vfn(\&_raw_valuation, 'val', 'SCALAR');

1;
