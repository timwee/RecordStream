package Recs::Aggregator::InjectInto::Field;

use strict;
use lib;

use Recs::DomainLanguage::Registry;
use Recs::DomainLanguage::Valuation::KeySpec;
use Recs::Aggregator::InjectInto;

use base qw(Recs::Aggregator::InjectInto);

sub new
{
   my $class = shift;
   my $field = shift;

   return new_from_valuation($class, Recs::DomainLanguage::Valuation::KeySpec->new($field));
}

sub new_from_valuation
{
   my $class = shift;
   my $valuation = shift;

   my $this =
   {
      'valuation' => $valuation,
   };

   bless $this, $class;

   return $this;
}

sub initial
{
   return undef;
}

sub combine
{
   my $this   = shift;
   my $cookie = shift;
   my $record = shift;

   my $value = $this->get_valuation()->evaluate_record($record);

   if ( defined $value )
   {
      return $this->combine_field($cookie, $value);
   }
   else
   {
      return $cookie;
   }
}

sub get_valuation
{
    my $this = shift;
    return $this->{'valuation'};
}

sub squish
{
   my ($this, $cookie) = @_;

   return $cookie;
}

sub argct
{
   return 1;
}

1;
