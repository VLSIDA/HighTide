#!/usr/bin/env bash

set -euo pipefail

DIR="$(dirname $(readlink -f $0))"
cd "$DIR"

mkdir -p packages

# Prerequisite Setup
bash "$(pwd)/install/install_bazel_7_4_1.sh"
bash "$(pwd)/install/install_py_3_10_9.sh"
bash "$(pwd)/install/install_srecord.sh"
bash "$(pwd)/install/install_sv2v.sh"

# Copy black-boxed SRAM to replace existing memories before chisel generation
cp "$(pwd)/Sram_512x128_REPLACE.v" "$(pwd)/repo/hdl/verilog/Sram_512x128.v"
cp "$(pwd)/Sram_2048x128_REPLACE.v" "$(pwd)/repo/hdl/verilog/Sram_2048x128.v"

# Generate Source SystemVerilog from chisel
cd "$(pwd)/repo/"

# Bazel requires a user for its state
export USER=${USER:-no_user}
if [ "$HOME" = "/" ]; then
  HOME=/tmp/
fi


"./../packages/bazel" \
  --output_base=/tmp/bazel_root \
  --install_base=/tmp/bazel_install \
  build \
    --action_env=JAVA_TOOL_OPTIONS="-Duser.home=/tmp" \
   //hdl/chisel/src/coralnpu:core_mini_axi_cc_library_emit_verilog

cd ..

# Generate Verilog from generated SV
"$(pwd)/packages/sv2v" -D SYNTHESIS -D layers_CoreMiniAxi_Verification_Assert -D VERILATOR "$(pwd)/repo/bazel-bin/hdl/chisel/src/coralnpu/CoreMiniAxi.sv" > "$(pwd)/../CoreMiniAxi.v"


# Remove debug/slog logic and any conditions that they belong in (not necessary for non-validation silicon)
perl -i -0777 -pe '
sub body_is_debug_slog_only {
  my ($body) = @_;

  # strip comments
  $body =~ s{/\*.*?\*/}{}gs;
  $body =~ s{//[^\n]*}{}g;

  for my $line (split /\n/, $body) {
    $line =~ s/^\s+|\s+$//g;
    next if $line eq "";
    return 0 unless $line =~ /(debug|slog)/;  # substring match
  }
  return 1;
}

sub strip_blocks {
  my ($s, $hdr_re) = @_;
  my $out = "";
  pos($s) = 0;

  while ($s =~ /\G(.*?)(($hdr_re))/sgc) {
    $out .= $1;

    my $hdr   = $2;
    my $start = pos($s) - length($hdr);
    my $i     = pos($s);

    # header ends with "begin" so we are inside a begin/end region
    my $depth = 1;
    while ($depth > 0 && $s =~ /\G(.*?)(\bbegin\b|\bend\b)/sgc) {
      $depth++ if $2 eq "begin";
      $depth-- if $2 eq "end";
      $i = pos($s);
    }

    my $blk  = substr($s, $start, $i - $start);
    my $body = $blk;
    $body =~ s/^.*?\bbegin\b//s;
    $body =~ s/\bend\b\s*$//s;

    if (body_is_debug_slog_only($body)) {
      # drop whole block (including optional leading "initial")
    } else {
      $out .= $blk;
    }

    pos($s) = $i;
  }

  $out .= substr($s, pos($s) // 0);
  return $out;
}

# optional "initial" before if/else
my $PFX = qr/(?:\binitial\b\s*)?/s;

$_ = strip_blocks($_, qr/${PFX}\bif\s*\(.*?\)\s*begin\b/s);
$_ = strip_blocks($_, qr/${PFX}\belse\s*begin\b/s);
' "$(pwd)/../CoreMiniAxi.v"

# Parse empty always blocks after removing debug logic
perl -i -0777 -pe '
  1 while s{
    ^([ \t]*)always\s*@\s*\([^)]*\)\s*\r?\n        
    (?:                                           
      [ \t]*\r?\n
      | [ \t]*//[^\n]*\r?\n
      | [ \t]*/\*.*?\*/[ \t]*\r?\n
    )+
    (?=^[ \t]*\S|\z)                                  
  }{}gmsx;
' "$(pwd)/../CoreMiniAxi.v"

# Remove display/finish tasks
perl -i -0777 -pe '
  s/^[ \t]*\$(?:display|finish)\b.*?\);\s*\r?\n//gms;
' "$(pwd)/../CoreMiniAxi.v"

sed -i '/debug/d' "$(pwd)/../CoreMiniAxi.v"
sed -i '/slog/d' "$(pwd)/../CoreMiniAxi.v"
