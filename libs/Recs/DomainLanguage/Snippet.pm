package Recs::DomainLanguage::Snippet;

use strict;
use warnings;

use Recs::DomainLanguage::Executor;
use Recs::DomainLanguage::Value;

sub new
{
    my $class = shift;
    my $code = shift;

    my $this =
    {
        'CODE' => $code,
    };

    bless $this, $class;

    return $this;
}

sub evaluate_as
{
    my $this = shift;
    my $type = shift;
    my $vars = shift || {};

    my $executor = Recs::DomainLanguage::Executor->new();
    $executor->import_registry();

    for my $var (keys(%$vars))
    {
        if(0)
        {
        }
        elsif($var =~ /^\$(.*)$/)
        {
            $executor->set_scalar($1, $vars->{$var});
        }
        else
        {
            die "Bad var for snippet: '$var'";
        }
    }
    my $result = $executor->exec($this->{'CODE'});

    return Recs::DomainLanguage::Value::cast_or_die($type, $result);
}

1;
