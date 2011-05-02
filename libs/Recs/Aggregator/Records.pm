package Recs::Aggregator::Records;

use strict;
use lib;

use Recs::Aggregator::MapReduce;
use Recs::Aggregator;
use Recs::DomainLanguage::Registry;

use base 'Recs::Aggregator::MapReduce';

sub new
{
   my $class = shift;

   my $this =
   {
   };

   bless $this, $class;

   return $this;
}

sub map
{
   my ($this, $record) = @_;

   return [$record];
}

sub reduce
{
   my ($this, $cookie1, $cookie2) = @_;

   return [@$cookie1, @$cookie2];
}

sub argct
{
   return 0;
}

sub short_usage
{
   return "returns an arrayref of all records";
}

sub long_usage
{
   print "Usage: records\n";
   print "   An arrayref of all records.\n";
   exit 1;
}

sub returns_record
{
   return 0;
}

Recs::Aggregator::register_aggregator('records', __PACKAGE__);
Recs::Aggregator::register_aggregator('recs', __PACKAGE__);

Recs::DomainLanguage::Registry::register(__PACKAGE__, 'new', 'records');
Recs::DomainLanguage::Registry::register(__PACKAGE__, 'new', 'recs');

1;
