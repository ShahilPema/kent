#!/usr/bin/env perl

use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin";
use AsmHub;
use File::Basename;

my $argc = scalar(@ARGV);

if ($argc != 2) {
  printf STDERR "usage: asmHubRmskJoinAlign.pl asmId buildDir > asmId.repeatMasker.html\n";
  printf STDERR "where asmId is the assembly identifier,\n";
  printf STDERR "expecting to find buildDir/html/asmId.names.tab naming file for this assembly,\n";
  printf STDERR "and buildDir/trackData/repeatMasker/asmId.rmsk.class.profile counts of rmsk categories.\n";
  exit 255;
}

my $asmId = shift;
my $buildDir = shift;
my $namesFile = "$buildDir/html/$asmId.names.tab";
my $rmskClassProfile = "$buildDir/trackData/repeatMasker/$asmId.rmsk.class.profile.txt";
my $rmskVersion = "$buildDir/$asmId.repeatMasker.version.txt";

my $errOut = 0;
if ( ! -s $rmskClassProfile ) {
  printf STDERR "ERROR: can not find rmsk class profile file:\n\t'%s'\n", $rmskClassProfile;
  $errOut = 255;
}

if ( ! -s $namesFile ) {
  printf STDERR "ERROR: can not find rmsk class profile file:\n\t'%s'\n", $rmskClassProfile;
  $errOut = 255;
}

if ($errOut) {
  exit $errOut;
}

my $em = "<em>";
my $noEm = "</em>";
my $assemblyDate = `grep -v "^#" $namesFile | cut -f9`;
chomp $assemblyDate;
my $ncbiAssemblyId = `grep -v "^#" $namesFile | cut -f10`;
chomp $ncbiAssemblyId;
my $organism = `grep -v "^#" $namesFile | cut -f5`;
chomp $organism;

print <<_EOF_
<h2>Description</h2>
<p>
This track shows the Repeat Masker annotations on the $assemblyDate $em${organism}$noEm/$asmId genome assembly.
</p>

<p>
This track was created by using Arian Smit's
<a href="http://www.repeatmasker.org/" target="_blank">RepeatMasker</a>
program, which screens DNA sequences
for interspersed repeats and low complexity DNA sequences. The program
outputs a detailed annotation of the repeats that are present in the
query sequence (represented by this track), as well as a modified version
of the query sequence in which all the annotated repeats have been masked
(generally available on the
<a href="http://hgdownload.soe.ucsc.edu/downloads.html"
target=_blank>Downloads</a> page). RepeatMasker uses the
<a href="http://www.girinst.org/repbase/update/index.html"
target=_blank>Repbase Update</a> library of repeats from the
<a href="http://www.girinst.org/" target=_blank>Genetic 
Information Research Institute</a> (GIRI).
Repbase Update is described in Jurka (2000) in the References section below.</p>
_EOF_
;

if ( -s "$rmskVersion" ) {

print <<_EOF_
<h2>RepeatMasker and libraries version</h2>
<p>
<pre>
_EOF_
;
print `cat $rmskVersion`;
print <<_EOF_
</pre>
</p>
_EOF_
;

}

print <<_EOF_
<h2>Display Conventions and Configuration</h2>
<h4>Context Sensitive Zooming</h4>
<p>
This track employs a technique which chooses the appropriate visual representation for the data based on the
zoom scale, and or the number of annotations currently in view.  The track will automatically switch from the
most detailed visualization ('Full' mode) to the denser view ('Pack' mode) when the window size is greater
than 45kb of sequence.  It will further switch to the even denser single line view ('Dense' mode) if more than
500 annotations are present in the current view.
</p>
<h4>Dense Mode Visualization</h4>
<p>
In dense display mode, a single line is displayed denoting the coverage of repeats using a series
of colored boxes.  The boxes are colored based on the classification of the repeat (see below for legend).
<br>
<br>
<!-- t2tRepeatMasker-dense-mode.png -->
<img height="31" width="1070" src="/images/rmskDense.jpg">
</p>
<h4>Pack Mode Visualization</h4>
<p>
In pack mode, repeats are represented as sets of joined features.  These are color coded as above based on the
class of the repeat, and the further details such as orientation (denoted by chevrons) and a family label are provided.
This family label may be optionally turned off in the track configuration.
<br>
<br>
<!-- t2tRepeatMasker-pack-mode.png -->
<img height="94" width="1092" src="/images/rmskPack.jpg">
<br>
<br>
The pack display mode may also be configured to resemble the original UCSC repeat track.  In this visualization
repeat features are grouped by classes (see below), and displayed on seperate track lines.  The repeat ranges are
denoted as grayscale boxes, reflecting both the size of the repeat and
the amount of base mismatch, base deletion, and base insertion associated with a repeat element.
The higher the combined number of these, the lighter the shading.
<br>
<br>
<!-- t2tRepeatMasker-orig-pack-mode.png -->
<img height="116" width="1216" src="/images/rmskClassicPack.jpg">
</p>
<h4>Full Mode Visualization</h4>
<p>
In the most detailed visualization repeats are displayed as chevron boxes, indicating the size and orientation of
the repeat.  The interior grayscale shading represents the divergence of the repeat (see above) while the outline color
represents the class of the repeat. Dotted lines above the repeat and extending left or right
indicate the length of unaligned repeat model sequence and provide context for where a repeat fragment originates in its
consensus or pHMM model.  If the length of the unaligned sequence
is large, an iterruption line and bp size is indicated instead of drawing the extension to scale.
<br>
<br>
<!-- t2tRepeatMasker-full-mode.png -->
<img height="90" width="1098" src="/images/rmskFull.jpg">
</p>
<p>
For example, the following repeat is a SINE element in the forward orientation with average
divergence. Only the 5' proximal fragment of the consensus sequence is aligned to the genome.
The 3' unaligned length (384bp) is not drawn to scale and is instead displayed using a set of
interruption lines along with the length of the unaligned sequence.
</p>

<svg width="640.0000000000001" height="150" xmlns="http://www.w3.org/2000/svg" xmlns:svg="http://www.w3.org/2000/svg">
 <!-- Created with SVG-edit - http://svg-edit.googlecode.com/ -->
 <g>
  <title>Layer 1</title>
  <path id="svg_4" d="m231.1875,66l132,0l0.5,13.5l0.5,14.5l-133,0l0,-14l0,-14z" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="5" stroke="#f90404" fill="#999999"/>
  <line stroke="#000000" id="svg_7" y2="49.79012" x2="458.68436" y1="49.79012" x1="366.35802" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="2,2" stroke-width="2" fill="none"/>
  <line stroke="#000000" id="svg_8" y2="57.79012" x2="455.35802" y1="41.79012" x1="462.35802" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="2" fill="none"/>
  <line stroke="#000000" id="svg_9" y2="57.79012" x2="493.10802" y1="41.79012" x1="500.10802" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="2" fill="none"/>
  <line id="svg_12" y2="58.79012" x2="594.10802" y1="41.79012" x1="594.10802" stroke-linecap="null" stroke-linejoin="null" stroke-width="2" stroke="#000000" fill="none"/>
  <line stroke="#000000" id="svg_10" y2="49.79012" x2="592.7712" y1="49.79012" x1="500.44486" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="2,2" stroke-width="2" fill="none"/>
  <line id="svg_13" y2="51.96878" x2="228" y1="68" x1="228" stroke-linecap="null" stroke-linejoin="null" stroke-width="2" stroke="#000000" fill="none"/>
  <line id="svg_14" stroke="#000000" y2="52" x2="228.66318" y1="52" x1="136.33684" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="2,2" stroke-width="2" fill="none"/>
  <line id="svg_15" y2="61.5" x2="133.5" y1="44.5" x1="133.5" stroke-linecap="null" stroke-linejoin="null" stroke-width="2" stroke="#000000" fill="none"/>
  <path stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="5" stroke="#1F77B4" fill="#989898" id="svg_1"/>
  <line stroke="#000000" y2="49.79012" x2="458.68436" y1="49.79012" x1="366.35802" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="2,2" stroke-width="2" fill="none" id="svg_3"/>
  <line stroke="#000000" y2="57.79012" x2="455.35802" y1="41.79012" x1="462.35802" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="2" fill="none" id="svg_5"/>
  <line stroke="#FFFFFF" id="svg_21" y2="79.8125" x2="244" y1="91.0625" x1="234" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none"/>
  <line id="svg_22" y2="80.1875" x2="244.25" y1="68.8125" x1="234.0625" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" stroke="#FFFFFF" fill="none"/>
  <line id="svg_6" y2="48.79012" x2="365.98302" y1="67.84138" x1="366.98302" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="2" fill="none" stroke="#000000" transform="rotate(1.8229113817214966 366.48303222656205,58.315750122070604) "/>
  <line stroke="#FFFFFF" y2="79.875" x2="253.25" y1="91.125" x1="243.25" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none" id="svg_2"/>
  <line y2="80.25" x2="253.5" y1="68.875" x1="243.3125" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" stroke="#FFFFFF" fill="none" id="svg_18"/>
  <line stroke="#FFFFFF" y2="79.875" x2="262.375" y1="91.125" x1="252.375" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none" id="svg_19"/>
  <line y2="80.25" x2="262.625" y1="68.875" x1="252.4375" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" stroke="#FFFFFF" fill="none" id="svg_20"/>
  <line stroke="#FFFFFF" y2="79.59375" x2="271.4375" y1="90.84375" x1="261.4375" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none" id="svg_23"/>
  <line y2="79.96875" x2="271.6875" y1="68.59375" x1="261.5" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" stroke="#FFFFFF" fill="none" id="svg_24"/>
  <line stroke="#FFFFFF" y2="79.65625" x2="280.6875" y1="90.90625" x1="270.6875" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none" id="svg_25"/>
  <line y2="80.03125" x2="280.9375" y1="68.65625" x1="270.75" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" stroke="#FFFFFF" fill="none" id="svg_26"/>
  <line stroke="#FFFFFF" y2="79.65625" x2="289.8125" y1="90.90625" x1="279.8125" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none" id="svg_27"/>
  <line y2="80.03125" x2="290.0625" y1="68.65625" x1="279.875" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" stroke="#FFFFFF" fill="none" id="svg_28"/>
  <line stroke="#FFFFFF" y2="79.84375" x2="298.9375" y1="91.09375" x1="288.9375" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none" id="svg_29"/>
  <line y2="80.21875" x2="299.1875" y1="68.84375" x1="289" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" stroke="#FFFFFF" fill="none" id="svg_30"/>
  <line stroke="#FFFFFF" y2="79.90625" x2="308.1875" y1="91.15625" x1="298.1875" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none" id="svg_31"/>
  <line y2="80.28125" x2="308.4375" y1="68.90625" x1="298.25" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" stroke="#FFFFFF" fill="none" id="svg_32"/>
  <line stroke="#FFFFFF" y2="79.90625" x2="317.3125" y1="91.15625" x1="307.3125" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none" id="svg_33"/>
  <line y2="80.28125" x2="317.5625" y1="68.90625" x1="307.375" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" stroke="#FFFFFF" fill="none" id="svg_34"/>
  <line stroke="#FFFFFF" y2="79.84375" x2="326.6875" y1="91.09375" x1="316.6875" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none" id="svg_35"/>
  <line y2="80.21875" x2="326.9375" y1="68.84375" x1="316.75" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" stroke="#FFFFFF" fill="none" id="svg_36"/>
  <line stroke="#FFFFFF" y2="79.90625" x2="335.9375" y1="91.15625" x1="325.9375" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none" id="svg_37"/>
  <line stroke="#FFFFFF" y2="79.90625" x2="345.0625" y1="91.15625" x1="335.0625" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none" id="svg_39"/>
  <line y2="80.28125" x2="345.3125" y1="68.90625" x1="335.125" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" stroke="#FFFFFF" fill="none" id="svg_40"/>
  <line stroke="#FFFFFF" y2="79.84375" x2="335.9375" y1="91.09375" x1="325.9375" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none" id="svg_41"/>
  <line y2="80.21875" x2="336.1875" y1="68.84375" x1="326" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" stroke="#FFFFFF" fill="none" id="svg_42"/>
  <line stroke="#FFFFFF" y2="79.90625" x2="345.1875" y1="91.15625" x1="335.1875" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none" id="svg_43"/>
  <line y2="80.28125" x2="345.4375" y1="68.90625" x1="335.25" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" stroke="#FFFFFF" fill="none" id="svg_44"/>
  <line stroke="#FFFFFF" y2="79.90625" x2="354.3125" y1="91.15625" x1="344.3125" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none" id="svg_45"/>
  <line y2="80.28125" x2="354.5625" y1="68.90625" x1="344.375" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" stroke="#FFFFFF" fill="none" id="svg_46"/>
  <text font-weight="normal" xml:space="preserve" text-anchor="middle" font-family="Serif" font-size="18" id="svg_11" y="55.66666" x="476.66666" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="0" stroke="#000000" fill="#000000">384</text>
 </g>
</svg>

<p>
Repeats that have been fragmented by insertions or large internal deletions are now represented
by join lines.  In the example below, a LINE element is found as two fragments.  The solid
connection lines indicate that there are no unaligned consensus bases between the two fragments.
Also note these fragments form the 3' extremity of the repeat, as there is no unaligned consensus
sequence following the last fragment.
</p>

<svg width="640" height="150" xmlns="http://www.w3.org/2000/svg" xmlns:svg="http://www.w3.org/2000/svg">
<!-- Created with SVG-edit - http://svg-edit.googlecode.com/ -->
<g>
<title>Layer 1</title>
<path fill="#D8D8D8" stroke="#FF7F0E" stroke-width="5" stroke-dasharray="null" stroke-linejoin="null" stroke-linecap="null" d="m130.1582,51.8418l132,0l0.5,15l0.5,13l-133,0l0.25,-13l-0.25,-15z" id="svg_5"/>
<path fill="#D8D8D8" stroke="#FF7F0E" stroke-width="5" stroke-dasharray="null" stroke-linejoin="null" stroke-linecap="null" d="m397,50l132,0l0.5,15l0.5,13l-133,0l0.25,-12l-0.25,-16z" id="svg_16"/>
<line fill="none" stroke-width="2" stroke-linejoin="null" stroke-linecap="null" x1="263" y1="49" x2="328" y2="35" id="svg_17" stroke="#000000"/>
<line fill="none" stroke="#000000" stroke-width="2" stroke-linejoin="null" stroke-linecap="null" x1="394" y1="50" x2="328" y2="35" id="svg_18"/>
<line fill="none" stroke="#000000" stroke-width="2" stroke-linejoin="null" stroke-linecap="null" x1="126.41841" y1="50.75" x2="126.41841" y2="34.71878" id="svg_24"/>
<line fill="none" stroke-width="2" stroke-dasharray="2,2" stroke-linejoin="null" stroke-linecap="null" x1="81.75525" y1="34.75" x2="127.08159" y2="34.75" id="svg_25" stroke="#000000"/>
<line fill="none" stroke="#000000" stroke-width="2" stroke-linejoin="null" stroke-linecap="null" x1="80.91841" y1="25.25" x2="80.91841" y2="42.25" id="svg_26"/>
<line stroke="#fcf9f9" id="svg_1" y2="66.125" x2="248.625" y1="54.75" x1="258.75" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_2" y2="66.25" x2="248.75" y1="76.75" x1="259.75" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke="#f9fcf9" fill="none"/>
<line id="svg_3" stroke="#fcf9f9" y2="66.375" x2="239.1875" y1="55" x1="249.3125" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_4" y2="66.5" x2="239.3125" y1="77" x1="250.3125" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke="#f9fcf9" fill="none"/>
<line id="svg_6" stroke="#fcf9f9" y2="66.5" x2="229.3125" y1="55.125" x1="239.4375" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_7" y2="66.625" x2="229.4375" y1="77.125" x1="240.4375" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke="#f9fcf9" fill="none"/>
<line id="svg_8" stroke="#fcf9f9" y2="66.625" x2="219.1875" y1="55.25" x1="229.3125" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_9" y2="66.75" x2="219.3125" y1="77.25" x1="230.3125" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke="#f9fcf9" fill="none"/>
<line id="svg_10" stroke="#fcf9f9" y2="66.5" x2="209.53125" y1="55.125" x1="219.65625" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_11" y2="66.625" x2="209.65625" y1="77.125" x1="220.65625" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke="#f9fcf9" fill="none"/>
<line id="svg_12" stroke="#fcf9f9" y2="66.75" x2="200.09375" y1="55.375" x1="210.21875" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_13" y2="66.875" x2="200.21875" y1="77.375" x1="211.21875" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke="#f9fcf9" fill="none"/>
<line id="svg_14" stroke="#fcf9f9" y2="66.5" x2="190.21875" y1="55.125" x1="200.34375" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_15" y2="66.625" x2="190.34375" y1="77.125" x1="201.34375" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke="#f9fcf9" fill="none"/>
<line id="svg_21" stroke="#fcf9f9" y2="66.5" x2="180.09375" y1="55.125" x1="190.21875" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_22" y2="66.625" x2="180.21875" y1="77.125" x1="191.21875" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke="#f9fcf9" fill="none"/>
<line id="svg_34" stroke="#fcf9f9" y2="65.875" x2="170.28125" y1="54.5" x1="180.40625" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_35" y2="66" x2="170.40625" y1="76.5" x1="181.40625" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke="#f9fcf9" fill="none"/>
<line id="svg_36" stroke="#fcf9f9" y2="65.9668" x2="161.31836" y1="54.5918" x1="171.44336" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_37" y2="66.25" x2="161.44336" y1="76.75" x1="172.44336" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke="#f9fcf9" fill="none"/>
<line id="svg_38" stroke="#fcf9f9" y2="66.0918" x2="151.60156" y1="54.7168" x1="161.72656" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_39" y2="66.2168" x2="151.72656" y1="76.7168" x1="162.72656" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke="#f9fcf9" fill="none"/>
<line id="svg_40" stroke="#fcf9f9" y2="66.2168" x2="141.31836" y1="54.8418" x1="151.44336" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_41" y2="66.3418" x2="141.44336" y1="76.8418" x1="152.44336" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke="#f9fcf9" fill="none"/>
<line id="svg_42" stroke="#fcf9f9" y2="66.25586" x2="132.09765" y1="54.88086" x1="142.22265" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_43" y2="66.38086" x2="132.22265" y1="76.88086" x1="143.22265" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke="#f9fcf9" fill="none"/>
<line id="svg_44" stroke="#fcf9f9" y2="64.36036" x2="438.80273" y1="52.98536" x1="448.92773" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_45" y2="64.48536" x2="438.92773" y1="74.98536" x1="449.92773" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke="#f9fcf9" fill="none"/>
<line id="svg_46" stroke="#fcf9f9" y2="64.45215" x2="429.83984" y1="53.07715" x1="439.96484" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_47" y2="64.73536" x2="429.96484" y1="75.23536" x1="440.96484" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke="#f9fcf9" fill="none"/>
<line id="svg_48" stroke="#fcf9f9" y2="64.57715" x2="420.12305" y1="53.20215" x1="430.24805" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_49" y2="64.70215" x2="420.24805" y1="75.20215" x1="431.24805" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke="#f9fcf9" fill="none"/>
<line id="svg_50" stroke="#fcf9f9" y2="64.70215" x2="409.83984" y1="53.32715" x1="419.96484" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_51" y2="64.82715" x2="409.96484" y1="75.32715" x1="420.96484" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke="#f9fcf9" fill="none"/>
<line id="svg_52" stroke="#fcf9f9" y2="64.74122" x2="400.61913" y1="53.36622" x1="410.74413" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_53" y2="64.86622" x2="400.74413" y1="75.36622" x1="411.74413" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke="#f9fcf9" fill="none"/>
<line id="svg_54" stroke="#fcf9f9" y2="64.18457" x2="486.7793" y1="52.80957" x1="496.9043" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_55" y2="64.30957" x2="486.9043" y1="74.80957" x1="497.9043" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke="#f9fcf9" fill="none"/>
<line id="svg_56" stroke="#fcf9f9" y2="64.27637" x2="477.81641" y1="52.90137" x1="487.94141" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_57" y2="64.55957" x2="477.94141" y1="75.05957" x1="488.94141" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke="#f9fcf9" fill="none"/>
<line id="svg_58" stroke="#fcf9f9" y2="64.40137" x2="468.09961" y1="53.02637" x1="478.22461" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_59" y2="64.52637" x2="468.22461" y1="75.02637" x1="479.22461" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke="#f9fcf9" fill="none"/>
<line id="svg_60" stroke="#fcf9f9" y2="64.52637" x2="457.81641" y1="53.15137" x1="467.94141" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_61" y2="64.65137" x2="457.94141" y1="75.15137" x1="468.94141" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke="#f9fcf9" fill="none"/>
<line id="svg_62" stroke="#fcf9f9" y2="64.56543" x2="448.59569" y1="53.19043" x1="458.72069" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_63" y2="64.69043" x2="448.72069" y1="75.19043" x1="459.72069" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke="#f9fcf9" fill="none"/>
<line id="svg_64" stroke="#fcf9f9" y2="64.75" x2="515.02734" y1="53.375" x1="525.15234" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_65" y2="64.875" x2="515.15234" y1="75.375" x1="526.15234" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke="#f9fcf9" fill="none"/>
<line id="svg_66" stroke="#fcf9f9" y2="64.8418" x2="506.06445" y1="53.4668" x1="516.18945" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_67" y2="65.125" x2="506.18945" y1="75.625" x1="517.18945" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke="#f9fcf9" fill="none"/>
<line id="svg_68" stroke="#fcf9f9" y2="64.9668" x2="496.34766" y1="53.5918" x1="506.47266" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_69" y2="65.0918" x2="496.47266" y1="75.5918" x1="507.47266" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke="#f9fcf9" fill="none"/>
</g>
</svg>

<p>
In cases where there is unaligned consensus sequence between the fragments, the repeat will look like
the following.  The dotted line indicates the length of the unaligned sequence between the two
fragments.  In this case the unaligned consensus is longer than the actual genomic distance between
these two fragments.
</p>

<svg width="640" height="150" xmlns="http://www.w3.org/2000/svg" xmlns:svg="http://www.w3.org/2000/svg">
<!-- Created with SVG-edit - http://svg-edit.googlecode.com/ -->
<g>
<title>Layer 1</title>
<line fill="none" stroke="#000000" stroke-width="2" stroke-dasharray="null" stroke-linejoin="null" stroke-linecap="null" x1="NaN" y1="NaN" x2="NaN" y2="NaN" id="svg_45"/>
<line fill="none" stroke-width="2" stroke-linejoin="null" stroke-linecap="null" x1="259.79082" y1="45.5" x2="240.79082" y2="30.5" stroke="#000000" id="svg_29"/>
<line fill="none" stroke-width="2" stroke-linejoin="null" stroke-linecap="null" x1="390.79082" y1="44.5" x2="412.79082" y2="30.5" stroke="#000000" id="svg_30"/>
<line fill="none" stroke-width="2" stroke-dasharray="2,2" stroke-linejoin="null" stroke-linecap="null" x1="79.54606" y1="30.25" x2="124.87239" y2="30.25" stroke="#000000" id="svg_34"/>
<line fill="none" stroke-width="2" stroke-dasharray="2,2" stroke-linejoin="null" stroke-linecap="null" x1="242.83683" y1="31" x2="410.16316" y2="31" stroke="#000000" id="svg_36"/>
<line fill="none" stroke="#000000" stroke-width="2" stroke-linejoin="null" stroke-linecap="null" x1="124.20922" y1="46.25" x2="124.20922" y2="30.21878" id="svg_33"/>
<path d="m127.66602,47.125l131.99996,0l0.5,14.125l0.5,13.875l-132.99996,0l0.11993,-13.20135l-0.11993,-14.79865z" fill="#383838" stroke="#8C564B" stroke-width="5" stroke-dasharray="null" stroke-linejoin="null" stroke-linecap="null" id="svg_27"/>
<line fill="none" stroke="#000000" stroke-width="2" stroke-linejoin="null" stroke-linecap="null" x1="78.70922" y1="20.75" x2="78.70922" y2="37.75" id="svg_35"/>
<path fill="#383838" stroke="#8C564B" stroke-width="5" stroke-dasharray="null" stroke-linejoin="null" stroke-linecap="null" d="m395,47l132,0l0.65625,15.35156l0.34375,12.64844l-133,0l0.14819,-12.59259l-0.14819,-15.40741z" id="svg_58"/>
<line stroke="#fffcfc" id="svg_1" y2="60.63047" x2="407.66233" y1="49.58996" x1="397.87066" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line stroke="#fffcfc" id="svg_3" y2="72.04077" x2="397.90625" y1="60.07202" x1="407.71875" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none"/>
<line id="svg_4" stroke="#fffcfc" y2="60.55379" x2="416.61805" y1="49.51328" x1="406.82639" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_5" stroke="#fffcfc" y2="72.14207" x2="406.86198" y1="60.17332" x1="416.67448" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none"/>
<line id="svg_6" stroke="#fffcfc" y2="60.78733" x2="425.72916" y1="49.74682" x1="415.9375" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_7" stroke="#fffcfc" y2="72.19763" x2="415.97309" y1="60.22888" x1="425.78559" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none"/>
<line id="svg_10" stroke="#fffcfc" y2="60.90002" x2="434.92491" y1="49.85951" x1="425.13325" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_11" stroke="#fffcfc" y2="72.31032" x2="425.16884" y1="60.34157" x1="434.98134" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none"/>
<line id="svg_12" stroke="#fffcfc" y2="60.82334" x2="443.88064" y1="49.78283" x1="434.08898" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_13" stroke="#fffcfc" y2="72.41162" x2="434.12457" y1="60.44287" x1="443.93707" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none"/>
<line id="svg_14" stroke="#fffcfc" y2="61.05687" x2="452.99175" y1="50.01636" x1="443.20009" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_15" stroke="#fffcfc" y2="72.46717" x2="443.23568" y1="60.49842" x1="453.04818" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none"/>
<line id="svg_16" stroke="#fffcfc" y2="60.71252" x2="462.54991" y1="49.67201" x1="452.75825" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_17" stroke="#fffcfc" y2="72.12282" x2="452.79384" y1="60.15407" x1="462.60634" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none"/>
<line id="svg_18" stroke="#fffcfc" y2="60.63584" x2="471.50564" y1="49.59533" x1="461.71398" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_19" stroke="#fffcfc" y2="72.22412" x2="461.74957" y1="60.25537" x1="471.56207" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none"/>
<line id="svg_20" stroke="#fffcfc" y2="60.86937" x2="480.61675" y1="49.82886" x1="470.82509" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_21" stroke="#fffcfc" y2="72.27967" x2="470.86068" y1="60.31092" x1="480.67318" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none"/>
<line id="svg_22" stroke="#fffcfc" y2="60.52502" x2="489.11241" y1="49.48451" x1="479.32075" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_23" stroke="#fffcfc" y2="71.93532" x2="479.35634" y1="59.96657" x1="489.16884" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none"/>
<line id="svg_24" stroke="#fffcfc" y2="60.44834" x2="498.06814" y1="49.40783" x1="488.27648" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_25" stroke="#fffcfc" y2="72.03662" x2="488.31207" y1="60.06787" x1="498.12457" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none"/>
<line id="svg_26" stroke="#fffcfc" y2="60.68187" x2="507.17925" y1="49.64136" x1="497.38759" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_28" stroke="#fffcfc" y2="72.09217" x2="497.42318" y1="60.12342" x1="507.23568" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none"/>
<line id="svg_37" stroke="#fffcfc" y2="60.77502" x2="507.11241" y1="49.73451" x1="497.32075" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_38" stroke="#fffcfc" y2="72.18532" x2="497.35634" y1="60.21657" x1="507.16884" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none"/>
<line id="svg_39" stroke="#fffcfc" y2="60.69834" x2="516.06814" y1="49.65783" x1="506.27648" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_40" stroke="#fffcfc" y2="72.28662" x2="506.31207" y1="60.31787" x1="516.12457" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none"/>
<line id="svg_41" stroke="#fffcfc" y2="60.93187" x2="525.17925" y1="49.89136" x1="515.38759" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_42" stroke="#fffcfc" y2="72.34217" x2="515.42318" y1="60.37342" x1="525.23568" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none"/>
<line id="svg_43" stroke="#fffcfc" y2="61.02502" x2="140.3624" y1="49.98451" x1="130.57073" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_44" stroke="#fffcfc" y2="72.43532" x2="130.60632" y1="60.46657" x1="140.41882" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none"/>
<line id="svg_46" stroke="#fffcfc" y2="60.94834" x2="149.31813" y1="49.90783" x1="139.52646" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_47" stroke="#fffcfc" y2="72.53662" x2="139.56205" y1="60.56787" x1="149.37455" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none"/>
<line id="svg_48" stroke="#fffcfc" y2="61.18187" x2="158.42924" y1="50.14136" x1="148.63757" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_49" stroke="#fffcfc" y2="72.59217" x2="148.67316" y1="60.62342" x1="158.48566" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none"/>
<line id="svg_50" stroke="#fffcfc" y2="61.02502" x2="167.6124" y1="49.98451" x1="157.82073" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_51" stroke="#fffcfc" y2="72.43532" x2="157.85632" y1="60.46657" x1="167.66882" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none"/>
<line id="svg_52" stroke="#fffcfc" y2="60.94834" x2="176.56813" y1="49.90783" x1="166.77646" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_53" stroke="#fffcfc" y2="72.53662" x2="166.81205" y1="60.56787" x1="176.62455" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none"/>
<line id="svg_54" stroke="#fffcfc" y2="61.18187" x2="185.67924" y1="50.14136" x1="175.88757" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_55" stroke="#fffcfc" y2="72.59217" x2="175.92316" y1="60.62342" x1="185.73566" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none"/>
<line id="svg_56" stroke="#fffcfc" y2="61.02502" x2="194.36241" y1="49.98451" x1="184.57075" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_57" stroke="#fffcfc" y2="72.43532" x2="184.60634" y1="60.46657" x1="194.41884" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none"/>
<line id="svg_59" stroke="#fffcfc" y2="60.94834" x2="203.31814" y1="49.90783" x1="193.52648" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_60" stroke="#fffcfc" y2="72.53662" x2="193.56207" y1="60.56787" x1="203.37457" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none"/>
<line id="svg_61" stroke="#fffcfc" y2="61.18187" x2="212.42925" y1="50.14136" x1="202.63759" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_62" stroke="#fffcfc" y2="72.59217" x2="202.67318" y1="60.62342" x1="212.48568" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none"/>
<line id="svg_63" stroke="#fffcfc" y2="61.02502" x2="221.36241" y1="49.98451" x1="211.57075" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_64" stroke="#fffcfc" y2="72.43532" x2="211.60634" y1="60.46657" x1="221.41884" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none"/>
<line id="svg_65" stroke="#fffcfc" y2="60.94834" x2="230.31814" y1="49.90783" x1="220.52648" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_66" stroke="#fffcfc" y2="72.53662" x2="220.56207" y1="60.56787" x1="230.37457" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none"/>
<line id="svg_67" stroke="#fffcfc" y2="61.18187" x2="239.42925" y1="50.14136" x1="229.63759" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_68" stroke="#fffcfc" y2="72.59217" x2="229.67318" y1="60.62342" x1="239.48568" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none"/>
<line id="svg_69" stroke="#fffcfc" y2="61.27502" x2="239.45616" y1="50.23451" x1="229.6645" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_70" stroke="#fffcfc" y2="72.68532" x2="229.70009" y1="60.71657" x1="239.51259" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none"/>
<line id="svg_71" stroke="#fffcfc" y2="61.19834" x2="248.41189" y1="50.15783" x1="238.62023" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_72" stroke="#fffcfc" y2="72.78662" x2="238.65582" y1="60.81787" x1="248.46832" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none"/>
<line id="svg_73" stroke="#fffcfc" y2="61.43187" x2="257.523" y1="50.39136" x1="247.73134" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_74" stroke="#fffcfc" y2="72.84217" x2="247.76693" y1="60.87342" x1="257.57943" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" stroke-width="null" fill="none"/>
</g>
</svg>

<p>
If there is consensus overlap between the two fragments, the joining lines will be drawn to indicate
how much of the left fragment is repeated in the right fragment.
</p>

<svg width="640" height="150" xmlns="http://www.w3.org/2000/svg" xmlns:svg="http://www.w3.org/2000/svg">
<!-- Created with SVG-edit - http://svg-edit.googlecode.com/ -->
<g>
<title>Layer 1</title>
<line fill="none" stroke="#000000" stroke-width="2" stroke-dasharray="null" stroke-linejoin="null" stroke-linecap="null" x1="NaN" y1="NaN" x2="NaN" y2="NaN" id="svg_45"/>
<line fill="none" stroke-width="2" stroke-dasharray="2,2" stroke-linejoin="null" stroke-linecap="null" x1="74.54603" y1="30.25" x2="119.87237" y2="30.25" stroke="#000000" id="svg_62"/>
<line fill="none" stroke="#000000" stroke-width="2" stroke-linejoin="null" stroke-linecap="null" x1="119.20919" y1="46.25" x2="119.20919" y2="30.21878" id="svg_64"/>
<path fill="#A0A0A0" stroke="#2CA02C" stroke-width="5" stroke-dasharray="null" stroke-linejoin="null" stroke-linecap="null" d="m122.91599,47.5l131.99996,0l0.25,14.25l0.75,13.75l-132.99996,0l0,-13l0,-15z" id="svg_65"/>
<line fill="none" stroke="#000000" stroke-width="2" stroke-linejoin="null" stroke-linecap="null" x1="73.70919" y1="20.75" x2="73.70919" y2="37.75" id="svg_67"/>
<path fill="#A0A0A0" stroke="#2CA02C" stroke-width="5" stroke-dasharray="null" stroke-linejoin="null" stroke-linecap="null" d="m389.99997,47l132.00003,0l0.5,14.5l0.5,13.5l-133.00003,0l0.25,-13.5l-0.25,-14.5z" id="svg_68"/>
<line stroke="#000000" fill="none" stroke-width="2" stroke-dasharray="null" stroke-linejoin="null" stroke-linecap="null" x1="238" y1="48.375" x2="325" y2="32" id="svg_70"/>
<line stroke="#000000" fill="none" stroke-width="2" stroke-dasharray="null" stroke-linejoin="null" stroke-linecap="null" x1="387.25" y1="46.125" x2="325" y2="32" id="svg_71"/>
<line stroke="#fffcfc" id="svg_1" y2="61.09375" x2="136.09377" y1="50.34375" x1="125.56252" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line stroke="#fcf7f7" id="svg_2" y2="61.375" x2="135.625" y1="72.75" x1="126.125" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_6" stroke="#fffcfc" y2="61.04688" x2="146.01563" y1="50.29687" x1="135.48438" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_7" stroke="#fcf7f7" y2="61.32812" x2="145.54686" y1="72.70313" x1="136.04686" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_8" stroke="#fffcfc" y2="61.04688" x2="155.89063" y1="50.29687" x1="145.35938" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_9" stroke="#fcf7f7" y2="61.32812" x2="155.42186" y1="72.70313" x1="145.92186" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_10" stroke="#fffcfc" y2="61.04688" x2="165.51563" y1="50.29687" x1="154.98438" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_11" stroke="#fcf7f7" y2="61.32812" x2="165.04686" y1="72.70313" x1="155.54686" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_12" stroke="#fffcfc" y2="61.19531" x2="175.3047" y1="50.44531" x1="164.77345" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_13" stroke="#fcf7f7" y2="61.47656" x2="174.83593" y1="72.85156" x1="165.33593" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_14" stroke="#fffcfc" y2="61.14844" x2="185.22656" y1="50.39844" x1="174.69531" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_15" stroke="#fcf7f7" y2="61.42969" x2="184.75779" y1="72.80469" x1="175.25779" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_16" stroke="#fffcfc" y2="61.14844" x2="195.10156" y1="50.39844" x1="184.57031" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_17" stroke="#fcf7f7" y2="61.42969" x2="194.63279" y1="72.80469" x1="185.13279" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_18" stroke="#fffcfc" y2="61.14844" x2="204.72656" y1="50.39844" x1="194.19531" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_19" stroke="#fcf7f7" y2="61.42969" x2="204.25779" y1="72.80469" x1="194.75779" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_20" stroke="#fffcfc" y2="61.07031" x2="214.9297" y1="50.32031" x1="204.39845" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_21" stroke="#fcf7f7" y2="61.35156" x2="214.46093" y1="72.72656" x1="204.96093" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_22" stroke="#fffcfc" y2="61.02344" x2="224.85156" y1="50.27344" x1="214.32031" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_23" stroke="#fcf7f7" y2="61.30469" x2="224.38279" y1="72.67969" x1="214.88279" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_24" stroke="#fffcfc" y2="61.02344" x2="234.72656" y1="50.27344" x1="224.19531" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_25" stroke="#fcf7f7" y2="61.30469" x2="234.25779" y1="72.67969" x1="224.75779" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_26" stroke="#fffcfc" y2="61.02344" x2="244.35156" y1="50.27344" x1="233.82031" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_27" stroke="#fcf7f7" y2="61.30469" x2="243.88279" y1="72.67969" x1="234.38279" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_28" stroke="#fffcfc" y2="60.92188" x2="253.14062" y1="50.17187" x1="242.60937" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_29" stroke="#fcf7f7" y2="61.20312" x2="252.67185" y1="72.57813" x1="243.17185" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line stroke="#000000" transform="rotate(-0.795723557472229 237.98962402343776,62.50274658203294) " fill="none" stroke-width="2" stroke-dasharray="null" stroke-linejoin="null" stroke-linecap="null" x1="237.98962" y1="77.50007" x2="237.98962" y2="47.50542" id="svg_69"/>
<line id="svg_30" stroke="#fffcfc" y2="60.69531" x2="403.17974" y1="49.94531" x1="392.64849" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_31" stroke="#fcf7f7" y2="60.97656" x2="402.71097" y1="72.35156" x1="393.21097" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_32" stroke="#fffcfc" y2="60.64844" x2="413.1016" y1="49.89844" x1="402.57035" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_33" stroke="#fcf7f7" y2="60.92969" x2="412.63283" y1="72.30469" x1="403.13283" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_34" stroke="#fffcfc" y2="60.64844" x2="422.9766" y1="49.89844" x1="412.44535" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_35" stroke="#fcf7f7" y2="60.92969" x2="422.50783" y1="72.30469" x1="413.00783" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_36" stroke="#fffcfc" y2="60.64844" x2="432.6016" y1="49.89844" x1="422.07035" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_37" stroke="#fcf7f7" y2="60.92969" x2="432.13283" y1="72.30469" x1="422.63283" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_38" stroke="#fffcfc" y2="60.69531" x2="442.36724" y1="49.94531" x1="431.83599" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_39" stroke="#fcf7f7" y2="60.97656" x2="441.89847" y1="72.35156" x1="432.39847" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_40" stroke="#fffcfc" y2="60.64844" x2="452.2891" y1="49.89843" x1="441.75785" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_41" stroke="#fcf7f7" y2="60.92969" x2="451.82033" y1="72.30469" x1="442.32033" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_42" stroke="#fffcfc" y2="60.64844" x2="462.1641" y1="49.89843" x1="451.63285" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_43" stroke="#fcf7f7" y2="60.92969" x2="461.69533" y1="72.30469" x1="452.19533" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_44" stroke="#fffcfc" y2="60.64844" x2="471.7891" y1="49.89843" x1="461.25785" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_46" stroke="#fcf7f7" y2="60.92969" x2="471.32033" y1="72.30469" x1="461.82033" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_47" stroke="#fffcfc" y2="60.50781" x2="481.92974" y1="49.75781" x1="471.39849" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_48" stroke="#fcf7f7" y2="60.78906" x2="481.46097" y1="72.16406" x1="471.96097" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_49" stroke="#fffcfc" y2="60.46094" x2="491.8516" y1="49.71094" x1="481.32035" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_50" stroke="#fcf7f7" y2="60.74219" x2="491.38283" y1="72.11719" x1="481.88283" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_51" stroke="#fffcfc" y2="60.46094" x2="501.7266" y1="49.71094" x1="491.19535" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_52" stroke="#fcf7f7" y2="60.74219" x2="501.25783" y1="72.11719" x1="491.75783" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_53" stroke="#fffcfc" y2="60.46094" x2="511.3516" y1="49.71094" x1="500.82035" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_54" stroke="#fcf7f7" y2="60.74219" x2="510.88283" y1="72.11719" x1="501.38283" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_55" stroke="#fffcfc" y2="60.48437" x2="520.26566" y1="49.73437" x1="509.7344" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
<line id="svg_56" stroke="#fcf7f7" y2="60.76562" x2="519.79689" y1="72.14062" x1="510.29689" stroke-linecap="null" stroke-linejoin="null" stroke-dasharray="null" fill="none"/>
</g>
</svg>

<p>
The following table lists the repeat class colors:
</p>

<table>
  <thead>
  <tr>
    <th style="border-bottom: 2px solid #6678B1;">Color</th>
    <th style="border-bottom: 2px solid #6678B1;">Repeat Class</th>
  </tr>
  </thead>
  <tr>
    <th bgcolor="#1F77B4"></th>
    <th align="left">SINE - Short Interspersed Nuclear Element</th>
  </tr>
  <tr>
    <th bgcolor="#FF7F0E"></th>
    <th align="left">LINE - Long Interspersed Nuclear Element</th>
  </tr>
  <tr>
    <th bgcolor="#2CA02C"></th>
    <th align="left">LTR - Long Terminal Repeat</th>
  </tr>
  <tr>
    <th bgcolor="#D62728"></th>
    <th align="left">DNA - DNA Transposon</th>
  </tr>
  <tr>
    <th bgcolor="#9467BD"></th>
    <th align="left">Simple - Single Nucleotide Stretches and Tandem Repeats</th>
  </tr>
  <tr>

  <tr>
    <th bgcolor="#8C564B"></th>
    <th align="left">Low_complexity - Low Complexity DNA</th>
  </tr>
  <tr>
    <th bgcolor="#E377C2"></th>
    <th align="left">Satellite - Satellite Repeats</th>
  </tr>
  <tr>
    <th bgcolor="#7F7F7F"></th>
    <th align="left">RNA - RNA Repeats (including RNA, tRNA, rRNA, snRNA, scRNA, srpRNA)</th>
  </tr>
  <tr>
    <th bgcolor="#BCBD22"></th>
    <th align="left">Other - Other Repeats (including class RC - Rolling Circle)</th>
  </tr>
  <tr>
    <th bgcolor="#17BECF"></th>
    <th align="left">Unknown - Unknown Classification</th>
  </tr>
</table>
</p>

<p>
A &quot;?&quot; at the end of the &quot;Family&quot; or &quot;Class&quot; (for example, DNA?)
signifies that the curator was unsure of the classification. At some point in the future,
either the &quot;?&quot; will be removed or the classification will be changed.</p>

<h2>Methods</h2>

<p>
The RepeatMasker (<a href="www.repeatmasker.org">www.repeatmasker.org</a>) tool was used to generate the datasets found on this track hub.  
</p>

<h2>Class profiles</h2>
<p>
<ul>
_EOF_
   ;

open (FH, "grep classBed $rmskClassProfile | sed -e 's/^  *//; s#$asmId.rmsk.##; s#classBed/##; s#.bed##;'|sort -rn|") or die "can not grep $rmskClassProfile";
while (my $line = <FH>) {
  chomp $line;
  my ($count, $class) = split('\s+', $line);
  printf "<li>%s - %s</li>\n", &AsmHub::commify($count), $class;
}
close (FH);
printf "</ul>\n</p>\n<h2>Detail class profiles</h2>\n<p>\n<ul>\n";
open (FH, "grep rmskClass $rmskClassProfile | sed -e 's/^  *//; s#rmskClass/##; s#.tab##;'|sort -rn|") or die "can not grep $rmskClassProfile";
while (my $line = <FH>) {
  chomp $line;
  my ($count, $class) = split('\s+', $line);
  printf "<li>%s - %s</li>\n", &AsmHub::commify($count), $class;
}
close (FH);

print <<_EOF_
</ul>
</p>
<h2>Credits</h2>

<p>
Thanks to Arian Smit, Robert Hubley and GIRI for providing the tools and
repeat libraries used to generate this track.
</p>

<h2>References</h2>

<p>
Smit AFA, Hubley R, Green P. ${em}RepeatMasker Open-3.0${noEm}.
<a href="http://www.repeatmasker.org" target="_blank">
http://www.repeatmasker.org</a>. 1996-2010.
</p>

<p>
Repbase Update is described in:
</p>

<p>
Jurka J.
<a href="http://www.sciencedirect.com/science/article/pii/S016895250002093X" target="_blank">
Repbase Update: a database and an electronic journal of repetitive elements</a>.
${em}Trends Genet${noEm}. 2000 Sep;16(9):418-420.
PMID: <a href="https://www.ncbi.nlm.nih.gov/pubmed/10973072" target="_blank">10973072</a>
</p>

<p>
For a discussion of repeats in mammalian genomes, see:
</p>

<p>
Smit AF.
<a href="http://www.sciencedirect.com/science/article/pii/S0959437X99000313" target="_blank">
Interspersed repeats and other mementos of transposable elements in mammalian genomes</a>.
${em}Curr Opin Genet Dev${noEm}. 1999 Dec;9(6):657-63.
PMID: <a href="https://www.ncbi.nlm.nih.gov/pubmed/10607616" target="_blank">10607616</a>
</p>

<p>
Smit AF.
<a href="http://www.sciencedirect.com/science/article/pii/S0959437X9680030X" target="_blank">
The origin of interspersed repeats in the human genome</a>.
${em}Curr Opin Genet Dev${noEm}. 1996 Dec;6(6):743-8.
PMID: <a href="https://www.ncbi.nlm.nih.gov/pubmed/8994846" target="_blank">8994846</a>
</p>
_EOF_
   ;