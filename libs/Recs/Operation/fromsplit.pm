package Recs::Operation::fromsplit;

use strict;

use base qw(Recs::Operation);

sub init {
   my $this = shift;
   my $args = shift;

   my $headers = 0;
   my $strict  = 0;
   my %options = (
      "delim|d=s"       => sub { $this->_set_delimiter($_[1]); },
      "key|k|field|f=s" => sub { $this->add_field(split(/,/, $_[1])); },
      "header"          => \$headers,
      "strict"          => \$strict,
   );

   $this->parse_options($args, \%options);

   $this->{'HEADER'} = $headers;
   $this->{'STRICT'} = $strict;
}

sub _set_delimiter {
   my ($this, $value) = @_;
   $this->{'DELIMITER'} = $value;
}

sub get_delimiter {
   my ($this) = @_;
   if(!defined($this->{'DELIMITER'})) {
      return ',';
   }
   return $this->{'DELIMITER'};
}

sub add_field {
   my $this = shift;
   $this->{'FIELDS'} ||= [];
   push @{$this->{'FIELDS'}}, @_;
}

sub get_field {
   my ($this, $index) = @_;

   if($this->{'FIELDS'} && $index < @{$this->{'FIELDS'}}) {
      return $this->{'FIELDS'}->[$index];
   }
   else {
      return $index;
   }
}

sub run_operation {
   my ($this) = @_;

   local @ARGV = @{$this->_get_extra_args()};


   if ($this->{'HEADER'}) {
      my $line = <>;
      chomp $line;
      my $delim = $this->get_delimiter();
      $this->add_field($_) for @{$this->get_values_for_line($line)};
   }

   while(my $line = <>) {
      chomp $line;

      my $record = Recs::Record->new();
      my $index = 0;

      foreach my $value (@{$this->get_values_for_line($line)}) {
         ${$record->guess_key_from_spec($this->get_field($index))} = $value;
         ++$index;
      }

      $this->push_record($record);
   }
}

sub get_values_for_line {
   my $this = shift;
   my $line = shift;

   my @values;
   my $delim = $this->get_delimiter();
   if ( $this->{'STRICT'} ) {
      @values = split(/\Q$delim\E/, $line);
   }
   else {
      @values = split(/$delim/, $line);
   }

   return \@values;
}

sub add_help_types {
   my $this = shift;
   $this->use_help_type('keyspecs');
}

sub usage {
   return <<USAGE;
Usage: recs-fromsplit <args> [<files>]
   Each line of input (or lines of <files>) is split on provided delimiter to
   produce an output record.  Keys are named numerically (0, 1, etc.) or as
   given by --key.

Arguments:
   --delim|-d <delim> Delimiter to use for splitting input lines (default ',').
   --key|-k <key>     Comma separated list of key names.  May be specified
                      multiple times, may be key specs
   --header           Take key names from the first line of input.
   --strict           Delimiter is not treated as a regex

Examples:
   Parse space separated keys x and y.
      recs-fromsplit --key x,y --delim ' '
   Parse comma separated keys a, b, and c.
      recs-fromsplit --key a,b,c
USAGE
}

1;
