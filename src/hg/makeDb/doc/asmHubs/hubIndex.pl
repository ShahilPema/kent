#!/usr/bin/env perl

use strict;
use warnings;
use File::Basename;

my $thisMachine = `uname -n`;
chomp $thisMachine;

if ($thisMachine ne "hgdownload") {
  printf STDERR "# NOTE: This script is only used on hgdownload\n";
  exit 255;
}

#############################################################################
sub startHtml() {
printf '<!DOCTYPE HTML 4.01 Transitional>
<!--#set var="TITLE" value="U.C. Santa Cruz Genomics Institute Assembly and Track hubs" -->
<!--#set var="ROOT" value=".." -->

<!--#include virtual="$ROOT/inc/gbPageStartHardcoded.html" -->

<h1>U.C. Santa Cruz Genomics Institute Assembly and Track hubs</h1>

'
}

#############################################################################
sub endHtml() {
printf '
</div><!-- closing gbsPage from gbPageStartHardcoded.html -->
</div><!-- closing container-fluid from gbPageStartHardcoded.html -->
<!--#include virtual="$ROOT/inc/gbFooterHardcoded.html"-->
<script type="text/javascript" src="/js/sorttable.js"></script>
</body></html>
'
}

#############################################################################
startHtml;

my %expectedList = (
 "VGP" => 1,
 "birds" => 1,
 "fish" => 1,
 "globalReference" => 1,
 "mammals" => 1,
 "primates" => 1,
 "vertebrate" => 1,
 "legacy" => 1,
 "plants" => 1,
);

my %titles = (
 "VGP" => "Vertebrate Genomes Project collection",
 "birds" => "NCBI bird genomes",
 "fish" => "NCBI fish genomes",
 "globalReference" => "Global Human Reference genomes, January 2020",
 "mammals" => "NCBI mammal genomes",
 "primates" => "NCBI primate genomes",
 "vertebrate" => "NCBI other vertebrate genomes",
 "legacy" => "NCBI genomes legacy/superseded by newer versions",
 "plants" => "NCBI plant genomes",
 "gtexAnalysis" => "Genotype-Tissue Expression (GTEx) Project analysis results track hub, V6 October 2015",
 "gtex" => "Genotype-Tissue Expression (GTEx) RNA-seq signal track hub, V6 October 2015",
 "mouseStrains" => "16 mouse strain assembly and track hub, May 2017",
 "neuroDiffCrispr" => "Structurally conserved primate cerebral cortex lincRNAs track hub, December 2018",
);

my %newDirectories;

my %otherTopLevels = (
  "GCA" => 1,
  "GCF" => 1,
  "gtex" => 1,
  "gtexAnalysis" => 1,
  "mouseStrains" => 1,
  "neuroDiffCrispr" => 1,
  "UCSC_GI.assemblyHubList.txt" => 1,
  "index.html" => 1,
);

my @orderOutHubs = (
 "primates",
 "mammals",
 "birds",
 "fish",
 "vertebrate",
 "legacy",
 "plants",
 "VGP",
 "globalReference",
 "mouseStrains",
);

my @orderOutTracks = (
 "gtexAnalysis",
 "gtex",
 "neuroDiffCrispr",
);

my %indexPage = (
 "primates" => "index.html",
 "mammals" => "index.html",
 "birds" => "index.html",
 "fish" => "index.html",
 "vertebrate" => "index.html",
 "legacy" => "index.html",
 "plants" => "index.html",
 "VGP" => "index.html",
 "mouseStrains" => "hubIndex.html",
 "globalReference" => "index.html",
 "gtexAnalysis" => "index.html",
 "gtex" => "index.html",
 "neuroDiffCrispr" => "index.html",
);

# verify all known directories and files, alert for any new ones
open (FH, "ls -d /mirrordata/hubs/*|") or die "can not ls -d /mirrordata/hubs/*";
while (my $dirPath = <FH>) {
  chomp $dirPath;
  my $fileDirName = basename($dirPath);
  if (! (defined($expectedList{$fileDirName}) || defined($otherTopLevels{$fileDirName})) ) {
    printf STDERR "# something new: %s\n", $fileDirName;
    $newDirectories{$fileDirName} = 1;
  }
}

close (FH);

### Determine genome counts:
my %genomeCounts;

my $genomeCount = `grep -h ^genome /mirrordata/hubs/VGP/*enomes.txt | wc -l`;
chomp $genomeCount;
$genomeCounts{"VGP"} = $genomeCount;

my @checkList = ('primates', 'mammals', 'birds', 'fish', 'vertebrate', 'legacy', 'plants', 'globalReference');

foreach my $genome (@checkList) {
  $genomeCount = `grep -h ^genome /mirrordata/hubs/$genome/genomes.txt | wc -l`;
  chomp $genomeCount;
  $genomeCounts{$genome} = $genomeCount;
}

my $hubCount = 0;

printf "<h2>Assembly hubs</h2>\n\n";

printf "<table class='sortable' border='1'>\n";
printf "<thead>\n";
printf "  <th>hub&nbsp;gateway</th>\n";
printf "  <th>description</th>\n";
printf "</tr></thead><tbody>\n";

# construct table
foreach my $orderUp (@orderOutHubs) {
  printf "<tr>\n";
  ++$hubCount;
  if ($orderUp eq "fish") {
     printf "    <td><a href='%s/%s' target=_blank>fishes</a></td>\n", $orderUp, $indexPage{$orderUp};
  } else {
     printf "    <td><a href='%s/%s' target=_blank>%s</a></td>\n", $orderUp, $indexPage{$orderUp}, $orderUp;
  }
  if (defined($genomeCounts{$orderUp})) {
    printf "    <td>%s (%d assemblies)</td>\n", $titles{$orderUp}, $genomeCounts{$orderUp};
  } else {
    printf "    <td>%s</td>\n", $titles{$orderUp};
  }
  printf "</tr>\n";
}

printf "</tbody></table>\n";

my $totalAsmHubs = `grep -v "^#" /mirrordata/hubs/UCSC_GI.assemblyHubList.txt | wc -l`;
chomp $totalAsmHubs;
printf "<p>\n";
printf "Please note: text file <a href='UCSC_GI.assemblyHubList.txt' target=_blank>listing</a> of %d NCBI/VGP genome assembly hubs\n", $totalAsmHubs;
printf "</p>\n";

printf "\n<h2>Track hubs</h2>\n\n";

printf "<table class='sortable' border='1'>\n";
printf "<thead>\n";
printf "  <th>hub&nbsp;gateway</th>\n";
printf "  <th>description</th>\n";
printf "</tr></thead><tbody>\n";

# construct table
foreach my $orderUp (@orderOutTracks) {
  printf "<tr>\n";
  ++$hubCount;
  if ($orderUp eq "fish") {
     printf "    <td><a href='%s/%s' target=_blank>fishes</a></td>\n", $orderUp, $indexPage{$orderUp};
  } else {
     printf "    <td><a href='%s/%s' target=_blank>%s</a></td>\n", $orderUp, $indexPage{$orderUp}, $orderUp;
  }
  if (defined($genomeCounts{$orderUp})) {
    printf "    <td>%s (%d assemblies)</td>\n", $titles{$orderUp}, $genomeCounts{$orderUp};
  } else {
    printf "    <td>%s</td>\n", $titles{$orderUp};
  }
  printf "</tr>\n";
}

printf "</tbody></table>\n";

endHtml;

