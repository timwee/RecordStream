package Recs::Aggregator::Average;

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

   return $sumx / $sum1;
}

sub long_usage
{
   print "Usage: avg,<field>\n";
   print "   Average of specified field.\n";
   exit 1;
}

sub short_usage
{
   return "averages provided field";
}

Recs::Aggregator::register_aggregator('average', __PACKAGE__);
Recs::Aggregator::register_aggregator('avg', __PACKAGE__);

Recs::DomainLanguage::Registry::register_vfn(__PACKAGE__, 'new_from_valuation', 'average', 'VALUATION');
Recs::DomainLanguage::Registry::register_vfn(__PACKAGE__, 'new_from_valuation', 'avg', 'VALUATION');

1;
