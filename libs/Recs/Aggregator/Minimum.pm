package Recs::Aggregator::Minimum;

use strict;
use lib;

use Recs::Aggregator::InjectInto::Field;
use Recs::DomainLanguage::Registry;

use base qw(Recs::Aggregator::InjectInto::Field);

#sub new -- passed through

#sub new_from_valuation -- passed through

sub combine_field
{
   my $this   = shift;
   my $cookie = shift;
   my $value  = shift;

   return $value unless ( defined $cookie );

   if ( $cookie > $value )
   {
      return $value;
   }

   return $cookie;
}

sub short_usage
{
   return "minimum value for a field";
}

sub long_usage
{
   print "Usage: min,<field>\n";
   print "   Minimum value of specified field.\n";
   exit 1;
}

Recs::Aggregator::register_aggregator('minimum', __PACKAGE__);
Recs::Aggregator::register_aggregator('min', __PACKAGE__);

Recs::DomainLanguage::Registry::register(__PACKAGE__, 'new_from_valuation', 'minimum', 'VALUATION');
Recs::DomainLanguage::Registry::register(__PACKAGE__, 'new_from_valuation', 'min', 'VALUATION');

1;
