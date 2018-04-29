#!/usr/bin/env perl

# Unit tests for bionitio_testperl5_2.
#
# usage: perl bionitio_testperl5_2_test.pl

use strict;
use warnings 'FATAL' => 'all';
use Test::More;
use IO::String;
require 'bionitio_testperl5_2.pl';

# Test wrapper for the process_file function from bionitio_testperl5_2.
#
# Arguments:
#     contents: a string containing the contents of the FASTA file to test
#     minlen_threshold: the value of the --minlen command line argument
#     expected: the expected output if the function works correctly
#     test_name: a descriptive label for the test to be printed out when
#     the test runs and succeeds of fails
#
# We set the name of the input file to be "unit-test", which is only needed
# for error messages that are generated by process_file when an exception
# occurs when reading the input FASTA file.
sub test_process_file {
    my ( $contents, $minlen_threshold, $expected, $test_name ) = @_;
    my $file_handle = IO::String->new($contents);
    my $result = process_file( "unit-test", $file_handle, $minlen_threshold );
    is_deeply( $result, $expected, $test_name );
}

test_process_file(
    "", 0,
    [ 0, 0, '-', '-', '-' ],
    "Test input containing zero bytes"
);

test_process_file(
    "\n", 0,
    [ 0, 0, '-', '-', '-' ],
    "Test input containing a single newline character"
);

# The test below fails because Bio::SeqIO raises an exception on this input,
# which we don't currently handle
#test_process_file(
#    ">",
#    0,
#    [1, 0, 0, 0, 0],
#    "Test input containing a single greater-than (>) character");

test_process_file(
    ">header\nATGC\nA", 0,
    [ 1, 5, 5, 5, 5 ],
    "Test input containing one sequence"
);

test_process_file(
    ">header1\nATGC\nAGG\n>header2\nTT\n",
    0,
    [ 2, 9, 2, 4, 7 ],
    "Test input containing two sequences"
);

# This test below fails because Bio::SeqIO raises an exception on this input,
# which we don't currently handle
#test_process_file(
#    "no header\n",
#    0,
#    [0, 0, '-', '-', '-'],
#    "Test input containing sequence without preceding header");

test_process_file(
    ">header1\nATGC\nAGG\n>header2\nTT\n",
    2,
    [ 2, 9, 2, 4, 7 ],
    "Test input when --minlen is less than 2 out of 2 sequences"
);

test_process_file(
    ">header1\nATGC\nAGG\n>header2\nTT\n",
    3,
    [ 1, 7, 7, 7, 7 ],
    "Test input when --minlen is less than 1 out of 2 sequences"
);

test_process_file(
    ">header1\nATGC\nAGG\n>header2\nTT\n",
    8,
    [ 0, 0, '-', '-', '-' ],
    "Test input when --minlen is greater than 2 out of 2 sequences"
);

done_testing();
