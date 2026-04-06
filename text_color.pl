#!/usr/bin/env perl

use strict;
use warnings;
use v5.16;
use Getopt::Long;

my $reset = color('reset');

if (!@ARGV) {
	die(usage());
}

my $inline      = 0; # Read from __DATA__
my $interactive = 0; # Require an interactive terminal

GetOptions(
	'inline'      => \$inline,
	'interactive' => \$interactive,
);

###############################################################################
###############################################################################

my $file = $ARGV[0] || "";

# Make sure the file is readable
if ($file && !-r $file) {
	die("Unable to read '$file'\n");
}

# Not an interactive terminal so we silently exit
if ($interactive && (-t STDOUT == 0)) {
	exit(9);
}

###############################################################################

my @lines;
if (-r $file) {
	@lines = file_get_contents($file);
} elsif ($inline) {
	# Slurp in __DATA__
	local $/ = undef;
	my $str  = <DATA>;

	# Left trim whitespace
	$str   =~ s/^\s+//;
	@lines = split(/\n/, $str);
} else {
	die(usage());
}

foreach my $line (@lines) {
	# {11} = > color(11);
	$line =~ s/(?<!\\)\{(\w+)\}/color($1)/eg;
	# {} => reset
	$line =~ s/(?<!\\)\{\}/$reset/g;

	# Replace any escaped "\{" in text with just "{"
	$line =~ s/\\\{/{/g;

	print "$line\n";
}

###############################################################################
###############################################################################

# String format: '115', '165_bold', '10_on_140', 'reset', 'on_173', 'red', 'white_on_blue'
sub color {
	my ($str, $txt) = @_;

	# If we're NOT connected to a an interactive terminal don't do color
	if (-t STDOUT == 0) { return $txt // ""; }

	# No string sent in, so we just reset
	if (!length($str) || $str eq 'reset') { return "\e[0m"; }

	# Some predefined colors
	my %color_map = qw(red 160 blue 27 green 34 yellow 226 orange 214 purple 93 white 15 black 0);
	$str =~ s|([A-Za-z]+)|$color_map{$1} // $1|eg;

	# Get foreground/background and any commands
	my ($fc,$cmd) = $str =~ /^(\d{1,3})?_?(\w+)?$/g;
	my ($bc)      = $str =~ /on_(\d{1,3})$/g;

	if (defined($fc) && int($fc) > 255) { $fc = undef; } # above 255 is invalid

	# Some predefined commands
	my %cmd_map = qw(bold 1 italic 3 underline 4 blink 5 inverse 7);
	my $cmd_num = $cmd_map{$cmd // 0};

	my $ret = '';
	if ($cmd_num)      { $ret .= "\e[${cmd_num}m"; }
	if (defined($fc))  { $ret .= "\e[38;5;${fc}m"; }
	if (defined($bc))  { $ret .= "\e[48;5;${bc}m"; }
	if (defined($txt)) { $ret .= $txt . "\e[0m";   }

	return $ret;
}

sub file_get_contents {
	open(my $fh, "<", $_[0]) or return undef;
	binmode($fh, ":encoding(UTF-8)");

	my $array_mode = ($_[1]) || (!defined($_[1]) && wantarray);

	if ($array_mode) { # Line mode
		my @lines  = readline($fh);

		# Right trim all lines
		foreach my $line (@lines) { $line =~ s/[\r\n]+$//; }

		return @lines;
	} else { # String mode
		local $/       = undef; # Input rec separator (slurp)
		return my $ret = readline($fh);
	}
}

sub usage {
	my $ret = color('yellow', "Usage:") . " \n\n";
	$ret .= color('white', $0) . " [myfile.txt]\n\n";
	$ret .= "or\n\n";
	$ret .= color('white', $0) . " --inline\n";

	return $ret;
}


__DATA__

{85}text_color.pl{} is great for login banners. Put the following in your {white}~/.bashrc{}:

  # If it's an interactive terminal show the banner
  if [[ $- == *i* ]]; then
      ~/bin/text_color.pl ~/login_banner.txt

      {228}# or{}

      ~/bin/text_color.pl # Read from __DATA__
  fi

Use \{color} or \{123} to start a color, and \{} to end the color.

Valid colors: {red}red, {yellow}yellow, {blue}blue, {green}green, {orange}orange, {purple}purple, {white_on_black}white, {black_on_white}black{}.

or the ANSI color number between 0 and 255.

Background colors can be specified with {on_red}\{on_red}{}.

To insert a literal \{ you can escape it: \\{. Closing braces } do not need to
be escaped.
