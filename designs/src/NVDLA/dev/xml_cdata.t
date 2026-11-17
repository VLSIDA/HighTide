use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/perl_lib";
use File::Temp qw(tempfile);
use Test::More;
use XML::Simple;

$ENV{XML_SIMPLE_PREFERRED_PARSER} = 'XML::SAX::PurePerl';

# Cover each position of the closing marker around a 4096-byte read boundary.
for my $offset (4094 .. 4097) {
    my $prefix = '<root><![CDATA[';
    my $text = 'x' x ($offset - length($prefix));
    my ($fh, $path) = tempfile(UNLINK => 1);
    print {$fh} $prefix, $text, ']]></root>';
    close $fh;
    is(XML::Simple::XMLin($path), $text, "CDATA terminator at byte $offset");
}

done_testing();
