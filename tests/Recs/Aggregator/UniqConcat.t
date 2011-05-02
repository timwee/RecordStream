use strict;
use warnings;

use Test::More 'no_plan';
use Data::Dumper;

BEGIN { use_ok("Recs::Aggregator::UniqConcatenate"); }
BEGIN { use_ok("Recs::Record"); }
BEGIN { use_ok("Recs::Test::UniqConcatHelper"); }

ok(my $aggr = Recs::Aggregator::UniqConcatenate->new(',', 'x'), "Initialize");

Recs::Test::UniqConcatHelper::test_aggregator($aggr, ',', 'x');
