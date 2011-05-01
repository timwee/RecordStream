use strict;
use warnings;

use Test::More 'no_plan';
use Data::Dumper;
use Recs::Record;

BEGIN { use_ok("Recs::Aggregator::DistinctCount"); }
BEGIN { use_ok("Recs::Test::DistinctCountHelper"); }

ok(my $aggr = Recs::Aggregator::DistinctCount->new("x"), "Initialize");

Recs::Test::DistinctCountHelper::test_aggregator($aggr, "x");
