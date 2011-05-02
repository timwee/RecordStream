package Recs::Aggregator::Covariance;

use strict;
use lib;

use Recs::Aggregator::Ord2Bivariate;
use Recs::Aggregator;
use Recs::DomainLanguage::Registry;

use base 'Recs::Aggregator::Ord2Bivariate';

#sub new -- passed through

#sub new_from_valuation -- passed through

sub squish
{
   my ($this, $cookie) = @_;

   my ($sum1, $sumx, $sumy, $sumxy, $sumx2, $sumy2) = @$cookie;

   return ($sumxy / $sum1) - ($sumx / $sum1) * ($sumy / $sum1);
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
   return "find covariance of provided fields";
}

Recs::Aggregator::register_aggregator('cov', __PACKAGE__);
Recs::Aggregator::register_aggregator('covariance', __PACKAGE__);

Recs::DomainLanguage::Registry::register(__PACKAGE__, 'new_from_valuation', 'cov', 'VALUATION', 'VALUATION');
Recs::DomainLanguage::Registry::register(__PACKAGE__, 'new_from_valuation', 'covariance', 'VALUATION', 'VALUATION');

1;

__DATA__
Usage: cov,<field1>,<field2>
   Covariance of specified fields.

This is computed as Cov(X, Y) = E[(X - E[X]) * (Y - E[Y])].
