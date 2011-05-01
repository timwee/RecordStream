package Recs::Aggregator::Variance;

use strict;
use lib;

use Recs::Aggregator::Ord2Univariate;
use Recs::Aggregator;
use Recs::DomainLanguage::Registry;

use base 'Recs::Aggregator::Ord2Univariate';

#sub new -- passed through

#sub new_from_valuation -- passed through

sub squish
{
   my ($this, $cookie) = @_;

   my ($sum1, $sumx, $sumx2) = @$cookie;

   return ($sumx2 / $sum1) - ($sumx / $sum1) ** 2;
}

sub long_usage
{
   while(my $line = <DATA>)
   {
      print $line;
   }
   exit 1;
}

sub short_usage
{
   return "find variance of provided field";
}

Recs::Aggregator::register_aggregator('var', __PACKAGE__);
Recs::Aggregator::register_aggregator('variance', __PACKAGE__);

Recs::DomainLanguage::Registry::register_vfn(__PACKAGE__, 'new_from_valuation', 'var', 'VALUATION');
Recs::DomainLanguage::Registry::register_vfn(__PACKAGE__, 'new_from_valuation', 'variance', 'VALUATION');

1;

__DATA__
Usage: var,<field1>
   Variance of specified fields.

This is computed as Var(X) = E[(X - E[X])^2].  Variance is an indication of
deviation from average value.
