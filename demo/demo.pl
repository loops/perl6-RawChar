#!/bin/env perl6
use IO::RawChar;

#  NOTE: Normally you would not use the :wait parameter when doing raw
#        input. Instead if get() returns an empty string, you would do
#        a chunk of long-running work before coming back and checking
#        again for a user keypress.

sub raw_input() {
	my $term = IO::RawChar.new(:1wait);		# From here on terminal is in raw mode
	LEAVE $term.clean;						# Make sure terminal is reset at end of scope

	loop {
		given $term.get() {					# Get one ascii character, or sleep for 1/10 second
			when ''  { print "."; next }
			when 'q' { last }
			default  { say "|$_ {.ord}|" }
		}
	}
}

# SIGTERM must explicitly exit
signal(SIGTERM).tap: { say "\nTerminated..."; exit 0 };

# Give a little demo
raw_input();

# Prove that the terminal is reset cleanly and normal input can happen
print "\nENTER: ";
say "ENTERED|{get}|";

