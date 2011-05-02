package Recs::Aggregator::MapReduce::FieldSet;

use strict;
use lib;

use Recs::Aggregator::MapReduce;
use Recs::DomainLanguage::Valuation::KeySpec;

use base 'Recs::Aggregator::MapReduce';

sub new
{
   my $class = shift;
   my @fields = @_;

   return new_from_valuations($class, map { Recs::DomainLanguage::Valuation::KeySpec->new($_) } @fields);
}

sub new_from_valuations
{
   my $class = shift;
   my @valuations = @_;

   my $this =
   {
      'valuations' => \@valuations,
   };
   bless $this, $class;

   return $this;
}

sub map
{
   my ($this, $record) = @_;

   return $this->map_fields(map { $_->evaluate_record($record) } @{$this->{'valuations'}});
}

sub map_fields
{
   die "FieldSet subclass does not implement map_fields\n";
}

1;
