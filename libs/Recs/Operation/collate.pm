package Recs::Operation::collate;

use strict;
use warnings;

use base qw(Recs::Operation);

use Recs::Aggregator;
use Recs::LRUSheriff;

sub init {
   my $this = shift;
   my $args = shift;

   Recs::Aggregator::load_aggregators();

   my @aggregators;
   my $size = undef;
   my $cube = 0;
   my $cube_default = "ALL";
   my $incremental = 0;
   my $list_aggregators = 0;
   my $aggregator = 0;

   my $key_groups = Recs::KeyGroups->new();

   my $spec = {
      "key|k=s"           => sub { $key_groups->add_groups($_[1]); },
      "aggregator|a=s"    => sub { push @aggregators, split(/:/, $_[1]); },
      "size|sz|n=i"       => \$size,
      "adjacent|1"        => sub { $size = 1; },
      "cube|c"            => \$cube,
      "cube-default=s"    => \$cube_default,
      "incremental|i"     => \$incremental,
      "list-aggregators"  => \$list_aggregators,
      "show-aggregator=s" => \$aggregator,

      #Perfect kept for cli backwards compatability (it is default now)
      "perfect|p"         => sub { $size = undef; },
   };

   $this->parse_options($args, $spec);

   if ( $list_aggregators ) {
      die sub { Recs::Aggregator::list_aggregators(); };
   }

   if ( $aggregator ) {
      die sub { Recs::Aggregator::show_aggregator($aggregator) };
   }

   die "Must specify --key or --aggregator\n" unless ( $key_groups->has_any_group() || @aggregators );

   my $aggregator_objects = Recs::Aggregator::make_aggregators(@aggregators);
   my $lru_sheriff = Recs::LRUSheriff->new();

   $this->{'KEY_GROUPS'}         = $key_groups;
   $this->{'AGGREGATORS'}        = $aggregator_objects;
   $this->{'SIZE'}               = $size;
   $this->{'CUBE'}               = $cube;
   $this->{'INCREMENTAL'}        = $incremental;
   $this->{'LRU_SHERIFF'}        = $lru_sheriff;
   $this->{'CUBE_DEFAULT'}       = $cube_default;
   $this->{'SEEN_RECORD'}        = 0;
}

sub accept_record {
   my $this   = shift;
   my $record = shift;

   if ( !$this->{'SEEN_RECORD'} ) {
     $this->{'SEEN_RECORD'} = 1;
     $this->{'KEYS'} = $this->{'KEY_GROUPS'}->get_keyspecs($record);
   }

   my $record_keys = $this->get_keys($record);

   if ( $this->{'CUBE'} ) {
      $this->deep_put([], $record_keys, $record);
   }
   else {
      $this->put($record_keys, $record);
   }
}

sub canonicalize {
   my $this = shift;
   my $keys = shift;
   return join("\x1E", @$keys);
}

sub deep_put {
   my $this         = shift;
   my $search_keys  = shift;
   my $record_keys  = shift;
   my $record       = shift;

   if(@$search_keys == @$record_keys)
   {
      $this->put([@$search_keys], $record);
      return;
   }

   push @$search_keys, $this->{'CUBE_DEFAULT'};
   $this->deep_put($search_keys, $record_keys, $record);
   pop @$search_keys;

   push @$search_keys, $record_keys->[scalar @$search_keys];
   $this->deep_put($search_keys, $record_keys, $record);
   pop @$search_keys;
}

sub put {
   my $this        = shift;
   my $record_keys = shift;
   my $record      = shift;

   my $lru_sheriff = $this->{'LRU_SHERIFF'};
   my $aggregators  = $this->{'AGGREGATORS'};

   my $key   = $this->canonicalize($record_keys);
   my $value = $lru_sheriff->find($key);

   my $aggregator_values;

   if ( !$value ) {
      $aggregator_values = Recs::Aggregator::map_initial($aggregators);
      $value             = [$aggregator_values, $record_keys];

      $lru_sheriff->put($key, $value);
   }
   else {
      $aggregator_values = $value->[0];
   }

   $value->[0] = Recs::Aggregator::map_combine($aggregators, $aggregator_values, $record);

   if ( $this->{'INCREMENTAL'} ) {
      $this->output(@$value);
   }


   if ( defined($this->{'SIZE'}) ) {
      $this->purge();
   }
}

sub stream_done {
   my $this = shift;
   $this->purge(0);
}

sub purge {
   my $this = shift;
   my $size = shift;

   if ( not defined $size ) {
      $size = $this->{'SIZE'};
   }

   my @goners = $this->{'LRU_SHERIFF'}->purgenate($size);
   if ( !$this->{'INCREMENTAL'} ) {
      foreach my $value (@goners) {
         $this->output(@$value);
      }
   }
}

sub output {
   my $this              = shift;
   my $aggregaotr_values = shift;
   my $record_keys       = shift;

   my $aggregators  = $this->{'AGGREGATORS'};

   my $record = Recs::Aggregator::map_squish($aggregators, $aggregaotr_values);

   my $keys = $this->{'KEYS'};
   for(my $i = 0; $i < @$keys; ++$i) {
      ${$record->guess_key_from_spec($keys->[$i])} = $record_keys->[$i];
   }

   $this->push_record($record);
}


sub get_keys {
   my $this   = shift;
   my $record = shift;

   my @keys = map { ${$record->guess_key_from_spec($_)} } @{$this->{'KEYS'}};
   return \@keys;
}


sub print_usage {
   my $this    = shift;
   my $message = shift;

   if ( $message && UNIVERSAL::isa($message, 'CODE') ) {
      $message->();
      exit 1;
   }

   $this->SUPER::print_usage($message);
}

sub add_help_types {
   my $this = shift;
   $this->use_help_type('keyspecs');
   $this->use_help_type('keygroups');
   $this->use_help_type('keys');
   $this->add_help_type(
     'aggregators',
     sub { Recs::Aggregator::list_aggregators(); },
     'List the aggregators'
   );
}

sub usage {
   return <<USAGE;
Usage: recs-collate <args> [<files>]
   Collate records of input (or records from <files>) into output records.

Arguments:
   --key|-k <keys>               Comma separated list of key fields.  may be a
                                 key spec or key group
   --aggregator|-a <aggregators> Colon separated list of aggregate field specifiers.
                                 See "Aggregates" section below.
   --size|--sz|-n <number>       Number of running clumps to keep.
   --adjacent|-1                 Keep exactly one running clump.
   --cube                        See "Cubing" section below.
   --cube-default                See "Cubing" section below.
   --incremental                 Output a record every time an input record is added
                                 to a clump (instead of everytime a clump is flushed).

Help / Usage Options:
   --list-aggregators             Bail and output a list of aggregators.
   --show-aggregator <aggregator> Bail and output this aggregator's detailed usage.

Aggregates:
   Aggregates are specified as [<fieldname>=]<aggregator>[,<arguments>].  The
   default field name is aggregator and arguments joined by underscores.  See
   --list-aggregators for a list of available aggregators.

   Fieldname maybe a key spec. (i.e. foo/bar=sum,field).  Additionally, all key
   name arguments to aggregators maybe be key specs (i.e.
   foo=max,latency/url), but not key groups

Cubing:
   Instead of added one entry for each input record, we add 2 ** (number of key
   fields), with every possible combination of fields replaced with the default
   (which defaults to "ALL" but can be specified with --cube-default).  This is
   not meant to be used with --adjacent or --size.  If our key fields were x
   and y then we'd get output records for {x = 1, y = 2}, {x = 1, y = ALL}, {x
   = ALL, y = 2} and {x = ALL, y = ALL}.

Examples:
   Count clumps of adjacent lines with matching x fields.
      recs-collate --adjacent --key x --aggregator count
   Count number of each x field in the entire file.
      recs-collate --key x --aggregator count
   Count number of each x field in the entire file, including an "ALL" line.
      recs-collate --key x --aggregator count --cube
   Produce a cummulative sum of field profit up to each date
      recs-collate --key date --adjcent --incremental --aggregator profit_to_date=sum,profit
   Produce record count for each date, hour pair
      recs-collate --key date,hour --aggregator count
    Finds the maximum latency for each date, hour pair
      recs-collate --key date,hour --aggregator worst_latency=max,latency
USAGE
}

1;
