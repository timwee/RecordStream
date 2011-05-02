package Recs::DomainLanguage;

use strict;
use warnings;

sub usage {
   return <<HELP;
DOMAIN LANGUAGE
   The recs domain language was made to allow the programmatic specification of
   aggregators.  As an example consider someone trying to collate data with a
   large number of fields, all of which need to be aggregated the same way, say
   a collection of times all of which need to be summed.  With the domain
   language, they can use this:

   --dlaggregator "for_field(qr/^time-/, 'sum(\\\$f))"

   for_field creates a very complicated aggregator that in turn will
   instantiate other aggregators based on fields it finds matching the regex
   /^time-/.  The code snippet, 'sum(\\\$f)', indicates that when these fields
   are found a sum aggregator is made for each.

   By combining for_field with sum the user has avoided having to specify many,
   many sum aggregators themselves.

   The language is itself just PERL with a collection of library functions.
   Your favorite aggregators are all here with the constructors you expect.
   Because certain aggregator names conflict with PERL builtins, constructors
   are also included prefixed with an underscore, e.g.  "_last".  Below you can
   find documentation on all the other provided functions.

   for_field(qr/.../, '...')
      Takes a regex and a snippet of code.  Creates an aggregator that creates
      a map.  Keys in the map corresponde to fields chosen by matching the
      regex against the fields from input records.  Values in the map are
      produced by aggregators which the snippet must act as a factory for (\$f
      is the field).

      Example(s):
         To aggregate the sums of all the fields beginning with "time-"
            for_field(qr/^time-/, 'sum(\$f)')

   valuation(sub { ... })
   val(sub { ... })
      Takes a subref, creates a valuation that represents it.  The subref will
      get the record as its first and only argument.

      Example(s):
         To get the square of the "x" field:
            val(sub{ \$[0]->{x} ** 2 })
HELP

# TODO: amling, when we actually have examples/needs for these
#   rec()
#   record()
#      A valuation that just returns the entire record.
#
#   type_agg(obj)
#   type_scalar(obj)
#   type_val(obj)
#      Force the object into a specific type.  Can be used to force certain
#      upconversions (or avoid them).
}

1;
