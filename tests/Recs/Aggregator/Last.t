use strict;
use warnings;

use Test::More 'no_plan';
use Data::Dumper;
use Recs::Record;

BEGIN { use_ok("Recs::Aggregator::Last"); }
BEGIN { use_ok("Recs::Test::LastHelper"); }

ok(my $aggr = Recs::Aggregator::Last->new("x"), "Initialize");

Recs::Test::LastHelper::test_aggregator($aggr, "x");
