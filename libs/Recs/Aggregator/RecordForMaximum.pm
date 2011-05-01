package Recs::Aggregator::RecordForMaximum;

use strict;
use lib;

use Recs::Aggregator::MapReduce;
use Recs::DomainLanguage::Registry;
use Recs::DomainLanguage::Valuation::KeySpec;

use base 'Recs::Aggregator::MapReduce';

sub new
{
    my $class = shift;
    my $field = shift;

    return new_from_valuation($class, Recs::DomainLanguage::Valuation::KeySpec->new($field));
}

sub new_from_valuation
{
   my $class = shift;
   my ($valuation) = @_;

   my $this =
   {
      'valuation' => $valuation,
   };
   bless $this, $class;

   return $this;
}

sub map
{
   my ($this, $record) = @_;

   my $value = $this->{'valuation'}->evaluate_record($record);

   return [$value, $record];
}

sub reduce
{
   my ($this, $cookie1, $cookie2) = @_;

   my ($v1, $r1) = @$cookie1;
   my ($v2, $r2) = @$cookie2;

   if($v1 > $v2)
   {
      return $cookie1;
   }

   return $cookie2;
}

sub squish
{
   my ($this, $cookie) = @_;

   my ($v, $r) = @$cookie;

   return $r;
}

sub argct
{
   return 1;
}

sub short_usage
{
   return "returns the record corresponding to the maximum value for a field";
}

sub long_usage
{
   print "Usage: recformax,<field>\n";
   print "   The record corresponding to the maximum value of specified field.\n";
   exit 1;
}

sub returns_record
{
   return 1;
}

Recs::Aggregator::register_aggregator('recformax', __PACKAGE__);
Recs::Aggregator::register_aggregator('recformaximum', __PACKAGE__);
Recs::Aggregator::register_aggregator('recordformax', __PACKAGE__);
Recs::Aggregator::register_aggregator('recordformaximum', __PACKAGE__);

Recs::DomainLanguage::Registry::register_vfn(__PACKAGE__, 'new_from_valuation', 'recformax', 'VALUATION');
Recs::DomainLanguage::Registry::register_vfn(__PACKAGE__, 'new_from_valuation', 'recformaximum', 'VALUATION');
Recs::DomainLanguage::Registry::register_vfn(__PACKAGE__, 'new_from_valuation', 'recordformax', 'VALUATION');
Recs::DomainLanguage::Registry::register_vfn(__PACKAGE__, 'new_from_valuation', 'recordformaximum', 'VALUATION');

1;
