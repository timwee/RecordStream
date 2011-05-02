package Recs::Aggregator::Concatenate;

use strict;
use lib;

use Recs::Aggregator::MapReduce::Field;
use Recs::Aggregator;
use Recs::DomainLanguage::Registry;

use base 'Recs::Aggregator::MapReduce::Field';

sub new
{
   my $class = shift;
   my $delim = shift;
   my $field = shift;

   my $this = $class->SUPER::new($field);
   $this->{'delim'} = $delim;

   return $this;
}

sub new_from_valuation
{
   my $class     = shift;
   my $delim     = shift;
   my $valuation = shift;

   my $this = $class->SUPER::new_from_valuation($valuation);
   $this->{'delim'} = $delim;

   return $this;
}

sub map_field
{
   my ($this, $value) = @_;

   return [$value];
}

sub reduce
{
   my ($this, $cookie, $cookie2) = @_;

   return [@$cookie, @$cookie2];
}

sub squish
{
   my ($this, $cookie) = @_;

   return join($this->{'delim'}, @$cookie);
}

sub long_usage
{
   print "Usage: concat,<delimiter>,<field>\n";
   print "   Concatenate values from specified field.\n";
   exit 1;
}

sub short_usage
{
   return "concatenate values from provided field";
}

sub argct
{
   return 2;
}

Recs::Aggregator::register_aggregator('concatenate', __PACKAGE__);
Recs::Aggregator::register_aggregator('concat', __PACKAGE__);

Recs::DomainLanguage::Registry::register(__PACKAGE__, 'new_from_valuation', 'concatenate', 'SCALAR', 'VALUATION');
Recs::DomainLanguage::Registry::register(__PACKAGE__, 'new_from_valuation', 'concat', 'SCALAR', 'VALUATION');

1;
