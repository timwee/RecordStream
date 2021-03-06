use Test::More qw(no_plan);
use Recs::Test::Tester;

BEGIN { use_ok( 'Recs::Operation::generate' ) };

my $input;
my $output;

my $tester = Recs::Test::Tester->new('generate');

$input = <<INPUT;
{"title":"ernie"}
{"title":"bert"}
INPUT

$output = <<OUTPUT;
{"backpointer":{"title":"ernie"},"title2":"ernie"}
{"backpointer":{"title":"bert"},"title2":"bert"}
OUTPUT

$tester->test_stdin([qw(--keychain backpointer), q(echo '{\"title2\":\"$r->{title}\"}')], $input, $output);

$output = <<OUTPUT;
{"title":"ernie"}
{"backpointer":{"title":"ernie"},"title2":"ernie"}
{"title":"bert"}
{"backpointer":{"title":"bert"},"title2":"bert"}
OUTPUT

$tester->test_stdin([qw(--passthrough --keychain backpointer), q(echo '{\"title2\":\"$r->{title}\"}')], $input, $output);
