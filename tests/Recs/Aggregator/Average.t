use strict;
use warnings;

use Test::More 'no_plan';
use Data::Dumper;

BEGIN { use_ok("Recs::Aggregator::Average"); }
BEGIN { use_ok("Recs::Record"); }

my $aggr = Recs::Aggregator::Average->new("x");

my $cookie = $aggr->initial();

foreach my $n (1, 3, 7)
{
   $cookie = $aggr->combine($cookie, Recs::Record->new("x" => $n));
}

my $value = $aggr->squish($cookie);

is($value, 11 / 3, "average for 1, 3, 7");
