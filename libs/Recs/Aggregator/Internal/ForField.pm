package Recs::Aggregator::Internal::ForField;

use strict;
use lib;

use Recs::Aggregator::Aggregation;
use Recs::DomainLanguage::Registry;

use base 'Recs::Aggregator::Aggregation';

sub new
{
   my $class = shift;
   my $regex = shift;
   my $snippet = shift;

   my $this =
   {
       'REGEX' => $regex,
       'SNIPPET' => $snippet,
   };

   bless $this, $class;

   return $this;
}

sub initial
{
   return {};
}

sub combine
{
   my $this = shift;
   my $cookie = shift;
   my $record = shift;

   for my $field (keys(%$record))
   {
      next unless($field =~ $this->{'REGEX'});

      my $value = $record->{$field};

      if(!exists($cookie->{$field}))
      {
         my $agg = $this->{'SNIPPET'}->evaluate_as('AGG', {'$f' => $field});
         $cookie->{$field} = [$agg, $agg->initial()];
      }

      my ($agg, $sub_cookie) = @{$cookie->{$field}};

      $sub_cookie = $agg->combine($sub_cookie, $record);

      $cookie->{$field}->[1] = $sub_cookie;
   }

   return $cookie;
}

sub squish
{
   my $this   = shift;
   my $cookie = shift;

   for my $field (keys(%$cookie))
   {
      my ($agg, $sub_cookie) = @{$cookie->{$field}};
      $cookie->{$field} = $agg->squish($sub_cookie);
   }

   return $cookie;
}

Recs::DomainLanguage::Registry::register(__PACKAGE__, 'new', 'for_field', 'SCALAR', 'SNIPPET');
# TODO: amling, allow subref to take field, return aggregator

1;
