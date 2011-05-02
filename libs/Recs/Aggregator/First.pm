package Recs::Aggregator::First;

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

   return defined($cookie) ? $cookie : $value;
}

sub short_usage
{
   return "first value for a field";
}

sub long_usage
{
   print "Usage: first,<field>\n";
   print "   First value of specified field.\n";
   exit 1;
}

Recs::Aggregator::register_aggregator('first', __PACKAGE__);

Recs::DomainLanguage::Registry::register(__PACKAGE__, 'new_from_valuation', 'first', 'VALUATION');

1;
