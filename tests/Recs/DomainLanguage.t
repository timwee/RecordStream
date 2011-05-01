use strict;
use warnings;

use Test::More 'no_plan';
use Data::Dumper;

BEGIN { use_ok("Recs::Aggregator"); }
BEGIN { use_ok("Recs::DomainLanguage::Library"); }
BEGIN { use_ok("Recs::DomainLanguage::Snippet"); }
BEGIN { use_ok("Recs::Test::DistinctCountHelper"); }
BEGIN { use_ok("Recs::Test::LastHelper"); }
BEGIN { use_ok("Recs::Test::UniqConcatHelper"); }

Recs::Aggregator::load_aggregators();

my $NO_CHECK = 'NO_CHECK';
my $CAST_FAILURE = 'CAST_FAILURE';

my @tests =
(
    [
        "_last(x)",
        sub
        {
            my $aggr = shift;

            Recs::Test::LastHelper::test_aggregator($aggr, "x");
        },
        $CAST_FAILURE,
        $CAST_FAILURE,
    ],
    [
        "dct(x)",
        sub
        {
            my $aggr = shift;

            Recs::Test::DistinctCountHelper::test_aggregator($aggr, "x");
        },
        $CAST_FAILURE,
        $CAST_FAILURE,
    ],
    [
        "firstrec",
        sub
        {
            my $aggr = shift;

            isa_ok($aggr, 'Recs::Aggregator::FirstRecord');
        },
        $CAST_FAILURE,
        $CAST_FAILURE,
    ],
    [
        "for_field(qr/^t/, 'sum(\$f)')",
        sub
        {
            my $aggr = shift;

            my $cookie = $aggr->initial();

            $cookie = $aggr->combine($cookie, Recs::Record->new());
            $cookie = $aggr->combine($cookie, Recs::Record->new("t1" => 1));
            $cookie = $aggr->combine($cookie, Recs::Record->new("t2" => 3));
            $cookie = $aggr->combine($cookie, Recs::Record->new("t1" => 7, "t2" => 6));

            my $value = $aggr->squish($cookie);

            my $ans =
            {
                "t1" => 8,
                "t2" => 9,
            };

            is_deeply($value, $ans);
        },
        $CAST_FAILURE,
        $CAST_FAILURE,
    ],
    [
        "rec",
        $CAST_FAILURE,
        sub
        {
            my $valuation = shift;

            isa_ok($valuation, 'Recs::DomainLanguage::Valuation');

            for my $rec ({"foo" => "bar"}, {"zoom" => [1, 2]})
            {
                is_deeply($valuation->evaluate_record($rec), $rec);
            }
        },
        $CAST_FAILURE,
    ],
    [
        "sum('ct')",
        sub
        {
            my $aggr = shift;

            my $cookie = $aggr->initial();

            $cookie = $aggr->combine($cookie, Recs::Record->new("ct" => 1));
            $cookie = $aggr->combine($cookie, Recs::Record->new("ct" => 2));
            $cookie = $aggr->combine($cookie, Recs::Record->new("ct" => 3));

            my $value = $aggr->squish($cookie);

            is_deeply($value, 6);
        },
        $CAST_FAILURE,
        $CAST_FAILURE,
    ],
    [
        "sum(ct)",
        $CAST_FAILURE,
        $CAST_FAILURE,
        $CAST_FAILURE,
    ],
    [
        "uconcat(',',x)",
        sub
        {
            my $aggr = shift;

            Recs::Test::UniqConcatHelper::test_aggregator($aggr);
        },
        $CAST_FAILURE,
        $CAST_FAILURE,
    ],
);

for my $test (@tests)
{
    my ($code, $agg_check, $val_check, $scalar_check) = @$test;
    my $snip = Recs::DomainLanguage::Snippet->new($code);
    for my $sub_test (['AGG', $agg_check], ['VALUATION', $val_check], ['SCALAR', $scalar_check])
    {
        my ($type, $check) = @$sub_test;

        my $r;
        eval
        {
            $r = $snip->evaluate_as($type);
        };
        if($@)
        {
            my $fail = $@;
            if(ref($check) && ref($check) eq "CODE")
            {
                fail("'$code' as '$type' failed: $fail");
            }
            elsif($check && $check eq $NO_CHECK)
            {
            }
            elsif($check && $check eq $CAST_FAILURE)
            {
                if($fail =~ /( found where .* expected)|(^No .* possibilities)/)
                {
                    # OK
                }
                else
                {
                    fail("'$code' as '$type' failed, expected cast failure: $fail");
                }
            }
            else
            {
                fail("'$code', '$type' => no expectation, failed: $fail");
            }
        }
        else
        {
            if(ref($check) && ref($check) eq "CODE")
            {
                $check->($r);
            }
            elsif($check && $check eq $NO_CHECK)
            {
                fail("'$code' as '$type' succeeded, expected cast failure: " . Dumper($r));
            }
            else
            {
                fail("'$code', '$type' => no expectation, succeeded: " . Dumper($r));
            }
        }
    }
}
