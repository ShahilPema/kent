
export dir=/cluster/data/mm10/bed/ucsc.19.1
export GENCODE_VERSION=VM23
export oldGeneDir=/cluster/data/mm10/bed/ucsc.18.1
export oldGeneBed=$oldGeneDir/ucscGenes.bed
export db=mm10
export spDb=sp180404
# NCBI Taxon 10090 for mouse, 9606 for human
export taxon=10090
export tempDb=tmpFoo89
export kent=$HOME/kent
export lastVer=11
export curVer=12
export Db=Mm10
export xdb=hg38
export Xdb=Hg38
export ydb=canFam3
export zdb=rn6
export ratDb=rn6
export RatDb=Rn6
export fishDb=danRer11
export flyDb=dm6
export wormDb=ce11
export yeastDb=sacCer3
export tempFa=$dir/ucscGenes.faa
export genomes=/hive/data/genomes

export xdbFa=$genomes/$xdb/bed/ucsc.20.1/ucscGenes.faa
export ratFa=$genomes/$ratDb/bed/ensGene.95/ensembl.faa
export fishFa=$genomes/$fishDb/bed/ensGene.95/ensembl.faa
export flyFa=$genomes/$flyDb/bed/ensGene.95/ensembl.faa
export wormFa=$genomes/$wormDb/bed/ensGene.95/ensembl.faa
export yeastFa=$genomes/$yeastDb/bed/ensGene.95/ensembl.faa
export scratchDir=/hive/users/braney/scratch

export blastTab=mmBlastTab
export xBlastTab=hgBlastTab
export rnBlastTab=rnBlastTab
export dbHost=hgwdev
export ramFarm=ku
export cpuFarm=ku

mkdir -p $dir
cd $dir

# first get list of tables from push request in $lastVer.table.lst #22997
wc -l $lastVer.table.lst
# 55

(
cat $lastVer.table.lst | grep -v "ToKg$lastVer" | grep -v "XrefOld" | grep -v "knownGeneOld" | grep -v "knownToGencode" 
echo kg${lastVer}ToKg${curVer} 
echo knownGeneOld$lastVer
echo kgXrefOld$lastVer
) | sort >  $curVer.table.lst 

for i in `cat $curVer.table.lst`; do d=`hgsql mm10 -Ne "SELECT create_time FROM INFORMATION_SCHEMA.TABLES
  WHERE table_schema = 'mm10'
    AND table_name = '$i'"` ; echo $i $d;   done | sort -nk2

echo "create database $tempDb" | hgsql ""

echo "create table knownGeneOld$lastVer like  $db.knownGene" | hgsql $tempDb
echo "insert into knownGeneOld$lastVer select * from   $db.knownGene" | hgsql $tempDb
echo "create table kgXrefOld$lastVer like  $db.kgXref" | hgsql $tempDb
echo "insert into kgXrefOld$lastVer select * from   $db.kgXref" | hgsql $tempDb

hgsql -e "select * from wgEncodeGencodeComp$GENCODE_VERSION" --skip-column-names $db | cut -f 2-16 |  genePredToBed stdin tmp
hgsql -e "select * from wgEncodeGencodePseudoGene$GENCODE_VERSION" --skip-column-names $db | cut -f 2-16 |  genePredToBed stdin tmp2
sort -k1,1 -k2,2n tmp tmp2 | gzip -c > gencode${GENCODE_VERSION}.bed.gz

# get current list of ids
zcat gencode${GENCODE_VERSION}.bed.gz |  awk '{print $4}' | sort > newGencodeName.txt

# grab ENST to UC map from the previous set
hgsql $db -Ne "select name,alignId from knownGene" | sort > EnstToUC.txt


# get lastId from last run of the geneset   (human V32)
# lastId 5070122
kgAllocId EnstToUC.txt newGencodeName.txt 5170122 stdout | sort -u >  txToAcc.tab
#lastId 5174009

touch oldToNew.tab

# check to make sure we don't have any dups.  These two numbers should
# be the same.   
awk '{print $2}' txToAcc.tab | sed 's/\..*//' | sort -u | wc -l
# 138930
awk '{print $2}' txToAcc.tab | sed 's/\..*//' | sort  | wc -l
# 138930

# this should be the current db instead of olDdb if not the first release
echo "select * from knownGene" | hgsql $db | sort > $db.knownGene.gp
#grep lost oldToNew.tab | tawk '{print $2}' | sort > lost.txt
#join -t $'\t' lost.txt $db.knownGene.gp > $db.lost.gp

#awk '{if ($7 == $6) print}' $db.lost.gp | wc -l
# non-coding 10566
#awk '{if ($7 != $6) print}' $db.lost.gp | wc -l
# coding 12277

#ifdef NOTNOW
# Assign permanent accessions to each transcript, and make up a number
# of our files with this accession in place of the temporary IDs we've been
# using.  Takes 4 seconds

#cd $dir
#cp ~kent/src/hg/txGene/txGeneAccession/txLastId saveLastId
#cp /cluster/data/hg38/bed/ucsc.19.1/startId startId
#txGeneAccession $oldGeneBed startId gencode${GENCODE_VERSION}.bed.gz txToAcc.tab oldToNew.tab
#endif

#subColumn 4 gencode${GENCODE_VERSION}Comp.bed.gz txToAcc.tab ucscGenes.bed
zcat gencode${GENCODE_VERSION}.bed.gz > ucscGenes.bed
#subColumn 4 gencode${GENCODE_VERSION}txToAcc.tab ucscGenes.bed
twoBitToFa -noMask /cluster/data/$db/$db.2bit -bed=ucscGenes.bed stdout | faFilter -uniq stdin  ucscGenes.fa
hgPepPred $tempDb generic knownGeneMrna ucscGenes.fa
bedToPsl /cluster/data/$db/chrom.sizes ucscGenes.bed ucscGenes.psl
pslRecalcMatch ucscGenes.psl /cluster/data/$db/$db.2bit ucscGenes.fa kgTargetAli.psl
# should be empty
awk '$11 != $1 + $3+$4' kgTargetAli.psl

echo "create table chromInfo like  $db.chromInfo" | hgsql $tempDb
echo "insert into chromInfo select * from   $db.chromInfo" | hgsql $tempDb
hgLoadPsl $tempDb kgTargetAli.psl

txBedToGraph ucscGenes.bed ucscGenes ucscGenes.txg
txgAnalyze ucscGenes.txg $genomes/$db/$db.2bit stdout | sort | uniq | bedClip stdin /cluster/data/$db/chrom.sizes  ucscSplice.bed
hgLoadBed $tempDb knownAlt ucscSplice.bed

#hgsql -N $spDb -e "select p.acc, p.val from protein p, accToTaxon x where x.taxon=$taxon and p.acc=x.acc" | awk '{print ">" $1;print $2}' >uniProt.fa
#faSize uniProt.fa

#needs two passes.  First make knownGene, then supporting tables
#tawk '{print $4,$4}' ucscGenes.bed | sort | uniq > txToAcc.tab
makeGencodeKnownGene -justKnown $db $tempDb $GENCODE_VERSION txToAcc.tab

hgLoadSqlTab -notOnServer $tempDb knownGene $kent/src/hg/lib/knownGene.sql knownGene.gp
hgLoadGenePred -genePredExt $tempDb  knownGeneExt knownGeneExt.gp

#getRnaPred -genePredExt -peptides $tempDb knownGeneExt all ucscGenes.faa
genePredToProt knownGeneExt.gp /cluster/data/$db/$db.2bit tmp.faa
faFilter -uniq tmp.faa ucscGenes.faa
hgPepPred $tempDb generic knownGenePep ucscGenes.faa

hgMapToGene -type=psl -all -tempDb=$tempDb $db all_mrna knownGene knownToMrna
hgMapToGene -tempDb=$tempDb $db refGene knownGene knownToRefSeq
hgMapToGene -type=psl -tempDb=$tempDb $db all_mrna knownGene knownToMrnaSingle

makeGencodeKnownGene $db $tempDb $GENCODE_VERSION txToAcc.tab

hgsql $tempDb -Ne "select k.name, g.geneId, g.geneStatus, g.geneType,g.transcriptName,g.transcriptType,g.transcriptStatus, g.havanaGeneId,  g.ccdsId, g.level, g.transcriptClass from knownGene k, $db.wgEncodeGencodeAttrs$GENCODE_VERSION g where k.name=g.transcriptId" > knownAttrs.tab
hgLoadSqlTab -notOnServer $tempDb knownAttrs $kent/src/hg/lib/knownAttrs.sql knownAttrs.tab

#tawk '$4=="new" {print $3}' oldToNew.tab | sort > new.txt
#sort -t $'\t' -k 12  knownGene.gp | join -1 1 -2 12 -t $'\t' new.txt /dev/stdin > new.gp
#sort -t $'\t' -k 12  knownGene.gp | join -1 1 -2 12 -t $'\t' lost.txt /dev/stdin | wc
# should be zero
# tawk '{print $12}' hg38.lost.gp | while read name; do grep $name /tmp/2; done | wc

hgLoadSqlTab -notOnServer $tempDb kgColor $kent/src/hg/lib/kgColor.sql kgColor.tab
 
hgLoadSqlTab -notOnServer $tempDb knownIsoforms $kent/src/hg/lib/knownIsoforms.sql knownIsoforms.tab

hgLoadSqlTab -notOnServer $tempDb kgXref $kent/src/hg/lib/kgXref.sql kgXref.tab

hgLoadSqlTab -notOnServer $tempDb knownCanonical $kent/src/hg/lib/knownCanonical.sql knownCanonical.tab

hgsql $tempDb -e "select * from knownToMrna" | tail -n +2 | tawk '{if ($1 != last) {print last, count, buffer; count=1; buffer=$2} else {count++;buffer=$2","buffer} last=$1}' | tail -n +2 | sort > tmp1
hgsql $tempDb  -e "select * from knownToMrnaSingle" | tail -n +2 | sort > tmp2
join  tmp2 tmp1 > knownGene.ev

txGeneAlias $db $spDb kgXref.tab knownGene.ev oldToNew.tab foo.alias foo.protAlias
awk 'BEGIN {OFS="\t"} {split($2,a,"."); for(ii = 1; ii <= a[2]; ii++) print $1,a[1] "." ii }' txToAcc.tab >> foo.alias
sort foo.alias | uniq > ucscGenes.alias
sort foo.protAlias | uniq > ucscGenes.protAlias
rm foo.alias foo.protAlias
hgLoadSqlTab -notOnServer $tempDb kgAlias $kent/src/hg/lib/kgAlias.sql ucscGenes.alias
hgLoadSqlTab -notOnServer $tempDb kgProtAlias $kent/src/hg/lib/kgProtAlias.sql ucscGenes.protAlias

# Build kgSpAlias table, which combines content of both kgAlias and kgProtAlias tables.

hgsql $tempDb -N -e 'select kgXref.kgID, spID, alias from kgXref, kgAlias where kgXref.kgID=kgAlias.kgID' > kgSpAlias_0.tmp
         
hgsql $tempDb -N -e 'select kgXref.kgID, spID, alias from kgXref, kgProtAlias where kgXref.kgID=kgProtAlias.kgID' >> kgSpAlias_0.tmp
cat kgSpAlias_0.tmp|sort -u  > kgSpAlias.tab
rm kgSpAlias_0.tmp

hgLoadSqlTab -notOnServer $tempDb kgSpAlias $kent/src/hg/lib/kgSpAlias.sql kgSpAlias.tab

txGeneExplainUpdate2 $oldGeneBed ucscGenes.bed kgOldToNew.tab
hgLoadSqlTab -notOnServer $tempDb kg${lastVer}ToKg${curVer} $kent/src/hg/lib/kg1ToKg2.sql kgOldToNew.tab
# TODO add kg${lastVer}ToKg${curVer} to all.joiner !!!!

sort txToAcc.tab > tmp1
#hgsql -e "select * from wgEncodeGencodeComp$GENCODE_VERSION" --skip-column-names hg38 | cut -f 2-16 |  tawk '{print $1 "." $2,$13,$14,$8,$15}' | sort | join /dev/stdin tmp1 | awk 'BEGIN {OFS="\t"} {print $6, $2, $3, $4, $5}' | sort > knownCds.tab
hgsql -e "select * from wgEncodeGencodeComp$GENCODE_VERSION" --skip-column-names $db | cut -f 2-16 |  tawk '{print $1,$13,$14,$8,$15}' | sort > knownCds.tab
hgLoadSqlTab -notOnServer $tempDb knownCds $kent/src/hg/lib/knownCds.sql knownCds.tab

hgsql -e "select * from wgEncodeGencodeTag$GENCODE_VERSION" --skip-column-names $db |  sort > knownToTag.tab
hgLoadSqlTab -notOnServer $tempDb knownToTag $kent/src/hg/lib/knownTo.sql knownToTag.tab


# this should be done AFTER moving the new tables into hg38
hgKgGetText $tempDb tempSearch.txt
sort tempSearch.txt > tempSearch2.txt
tawk '{split($2,a,"."); printf "%s\t", $1;for(ii = 1; ii <= a[2]; ii++) printf "%s ",a[1] "." ii; printf "\n" }' txToAcc.tab | sort > tempSearch3.txt
join tempSearch2.txt tempSearch3.txt | sort > knownGene.txt
ixIxx knownGene.txt knownGene.ix knownGene.ixx
 rm -rf /gbdb/$tempDb/knownGene.ix /gbdb/$tempDb/knownGene.ixx
ln -s $dir/knownGene.ix  /gbdb/$tempDb/knownGene.ix
ln -s $dir/knownGene.ixx /gbdb/$tempDb/knownGene.ixx  

hgsql --skip-column-names -e "select mrnaAcc,locusLinkId from hgFixed.refLink" $db > refToLl.txt
hgMapToGene -tempDb=$tempDb $db refGene knownGene knownToLocusLink -lookup=refToLl.txt
knownToVisiGene $tempDb -probesDb=$db

#awk '{OFS="\t"} {print $2,$1}' tmp1 | sort > knownToEnsembl.tab
awk '{OFS="\t"} {print $1,$1}' tmp1 | sort > knownToEnsembl.tab
tawk '{print $1,$1}' tmp1 | sort > knownToGencode${GENCODE_VERSION}.tab
hgLoadSqlTab -notOnServer $tempDb  knownToEnsembl  $kent/src/hg/lib/knownTo.sql  knownToEnsembl.tab
hgLoadSqlTab -notOnServer $tempDb  knownToGencode${GENCODE_VERSION}  $kent/src/hg/lib/knownTo.sql  knownToGencode${GENCODE_VERSION}.tab

# hgMapToGene -tempDb=$tempDb $db gnfAtlas2 knownGene knownToGnfAtlas2 '-type=bed 12'

#NOTHAPPENING

if ($db =~ hg*) then
    #hgMapToGene -exclude=abGenes.txt -tempDb=$tempDb $db HInvGeneMrna knownGene knownToHInv
    #hgMapToGene -exclude=abGenes.txt -tempDb=$tempDb $db affyU133Plus2 knownGene knownToU133Plus2
    hgMapToGene -tempDb=$tempDb $db affyU133 knownGene knownToU133
    hgMapToGene -tempDb=$tempDb $db affyU95 knownGene knownToU95
    mkdir hprd
    cd hprd
    wget "http://www.hprd.org/edownload/HPRD_FLAT_FILES_041310"
    tar xvf HPRD_FLAT_FILES_041310
    knownToHprd $tempDb FLAT_FILES_072010/HPRD_ID_MAPPINGS.txt
#    hgsql $tempDb -e "delete k from knownToHprd k, kgXref x where k.name = x.kgID and x.geneSymbol = 'abParts'"
endif


if ($db =~ hg*) then
    cd $dir
    time hgExpDistance $tempDb hgFixed.gnfHumanU95MedianRatio \
	    hgFixed.gnfHumanU95Exps gnfU95Distance  -lookup=knownToU95
    time hgExpDistance $tempDb hgFixed.gnfHumanAtlas2MedianRatio \
	hgFixed.gnfHumanAtlas2MedianExps gnfAtlas2Distance \
	-lookup=knownToGnfAtlas2
endif

if ($db =~ mm*) then
    hgMapToGene -exclude=abGenes.txt -tempDb=$tempDb $db affyGnf1m knownGene knownToGnf1m
    hgMapToGene -exclude=abGenes.txt -tempDb=$tempDb $db gnfAtlas2 knownGene knownToGnfAtlas2 '-type=bed 12'
    hgMapToGene -exclude=abGenes.txt -tempDb=$tempDb $db affyU74  knownGene knownToU74
    hgMapToGene -exclude=abGenes.txt -tempDb=$tempDb $db affyMOE430 knownGene knownToMOE430
    hgMapToGene -exclude=abGenes.txt -tempDb=$tempDb $db affyMOE430 -prefix=A: knownGene knownToMOE430A
    hgExpDistance $tempDb $db.affyGnfU74A affyGnfU74AExps affyGnfU74ADistance -lookup=knownToU74
    hgExpDistance $tempDb $db.affyGnfU74B affyGnfU74BExps affyGnfU74BDistance -lookup=knownToU74
    hgExpDistance $tempDb $db.affyGnfU74C affyGnfU74CExps affyGnfU74CDistance -lookup=knownToU74
    hgExpDistance $tempDb hgFixed.gnfMouseAtlas2MedianRatio \
	    hgFixed.gnfMouseAtlas2MedianExps gnfAtlas2Distance -lookup=knownToGnf1m
endif

cd $dir 

# Create Human P2P protein-interaction Gene Sorter columns
if ($db =~ hg*) then
hgLoadNetDist $genomes/hg19/p2p/hprd/hprd.pathLengths $tempDb humanHprdP2P \
    -sqlRemap="select distinct value, name from knownToHprd"
hgLoadNetDist $genomes/hg19/p2p/vidal/humanVidal.pathLengths $tempDb humanVidalP2P -sqlRemap="select distinct locusLinkID, kgID from hgFixed.refLink,kgXref where hgFixed.refLink.mrnaAcc = kgXref.refSeq"
hgLoadNetDist $genomes/hg19/p2p/wanker/humanWanker.pathLengths $tempDb humanWankerP2P -sqlRemap="select distinct locusLinkID, kgID from hgFixed.refLink,kgXref where hgFixed.refLink.mrnaAcc = kgXref.refSeq"
endif

#endif NOTHAPP

# Run nice Perl script to make all protein blast runs for
# Gene Sorter and Known Genes details page.  Takes about
# 45 minutes to run.
rm -rf   $dir/hgNearBlastp
mkdir  $dir/hgNearBlastp
cd $dir/hgNearBlastp
# make sure all the fasta is there
ls -l $tempFa
ls -l $xdbFa
ls -l $ratFa
ls -l $fishFa
ls -l $flyFa
ls -l $wormFa
ls -l $yeastFa
tcsh
cat << _EOF_ > config.ra
# Latest human vs. other Gene Sorter orgs:
# mouse, rat, zebrafish, worm, yeast, fly

targetGenesetPrefix known
targetDb $tempDb
queryDbs $xdb $ratDb $fishDb $flyDb $wormDb $yeastDb

${tempDb}Fa $tempFa
${xdb}Fa $xdbFa
${ratDb}Fa $ratFa
${fishDb}Fa $fishFa
${flyDb}Fa $flyFa
${wormDb}Fa $wormFa
${yeastDb}Fa $yeastFa

buildDir $dir/hgNearBlastp
scratchDir $scratchDir/brHgNearBlastp
_EOF_

# exit tcsh

rm -rf  $scratchDir/brHgNearBlastp
doHgNearBlastp.pl -noLoad -clusterHub=ku -distrHost=hgwdev -dbHost=hgwdev -workhorse=hgwdev config.ra >  do.log  2>&1 &

# Load self
cd $dir/hgNearBlastp/run.$tempDb.$tempDb
# builds knownBlastTab
./loadPairwise.csh

# Load human and rat
cd $dir/hgNearBlastp/run.$tempDb.$xdb
hgLoadBlastTab $tempDb $xBlastTab -maxPer=1 out/*.tab
cd $dir/hgNearBlastp/run.$tempDb.$ratDb
hgLoadBlastTab $tempDb $rnBlastTab -maxPer=1 out/*.tab

# Remove non-syntenic hits for human and rat
# Takes a few minutes
mkdir -p /gbdb/$tempDb/liftOver
rm -f /gbdb/$tempDb/liftOver/${tempDb}To$RatDb.over.chain.gz /gbdb/$tempDb/liftOver/${tempDb}To$Xdb.over.chain.gz
ln -s $genomes/$db/bed/liftOver/${db}To$RatDb.over.chain.gz \
    /gbdb/$tempDb/liftOver/${tempDb}To$RatDb.over.chain.gz
ln -s $genomes/$db/bed/liftOver/${db}To${Xdb}.over.chain.gz \
    /gbdb/$tempDb/liftOver/${tempDb}To$Xdb.over.chain.gz

# delete non-syntenic genes from rat and mouse blastp tables
cd $dir/hgNearBlastp
synBlastp.csh $tempDb $xdb
# old number of unique query values: 62743
# old number of unique target values 27998
# new number of unique query values: 54818
# new number of unique target values 26309

synBlastp.csh $tempDb $ratDb knownGene ensGene
# old number of unique query values: 63123
# old number of unique target values 21163
# new number of unique query values: 57012
# new number of unique target values 20298

# Make reciprocal best subset for the blastp pairs that are too
# Far for synteny to help

# Us vs. fish
cd $dir/hgNearBlastp
export aToB=run.$tempDb.$fishDb
export bToA=run.$fishDb.$tempDb
cat $aToB/out/*.tab > $aToB/all.tab
cat $bToA/out/*.tab > $bToA/all.tab
blastRecipBest $aToB/all.tab $bToA/all.tab $aToB/recipBest.tab $bToA/recipBest.tab
hgLoadBlastTab $tempDb drBlastTab $aToB/recipBest.tab

# Us vs. fly
cd $dir/hgNearBlastp
export aToB=run.$tempDb.$flyDb
export bToA=run.$flyDb.$tempDb
cat $aToB/out/*.tab > $aToB/all.tab
cat $bToA/out/*.tab > $bToA/all.tab
blastRecipBest $aToB/all.tab $bToA/all.tab $aToB/recipBest.tab $bToA/recipBest.tab
hgLoadBlastTab $tempDb dmBlastTab $aToB/recipBest.tab

# Us vs. worm
cd $dir/hgNearBlastp
export aToB=run.$tempDb.$wormDb
export bToA=run.$wormDb.$tempDb
cat $aToB/out/*.tab > $aToB/all.tab
cat $bToA/out/*.tab > $bToA/all.tab
blastRecipBest $aToB/all.tab $bToA/all.tab $aToB/recipBest.tab $bToA/recipBest.tab
hgLoadBlastTab $tempDb ceBlastTab $aToB/recipBest.tab

# Us vs. yeast
cd $dir/hgNearBlastp
export aToB=run.$tempDb.$yeastDb
export bToA=run.$yeastDb.$tempDb
cat $aToB/out/*.tab > $aToB/all.tab
cat $bToA/out/*.tab > $bToA/all.tab
blastRecipBest $aToB/all.tab $bToA/all.tab $aToB/recipBest.tab $bToA/recipBest.tab
hgLoadBlastTab $tempDb scBlastTab $aToB/recipBest.tab

# Clean up
cd $dir/hgNearBlastp
cat run.$tempDb.$tempDb/out/*.tab | gzip -c > run.$tempDb.$tempDb/all.tab.gz
gzip run.*/all.tab

# Didn't do
# load malacards table
hgsql -e "select geneSymbol,kgId from kgXref" --skip-column-names hg38 | awk '{if (NF == 2) print}' | sort > geneSymbolToKgId.txt
hgsql -e "select geneSymbol from malacards" --skip-column-names hg38 | sort > malacardExists.txt
join malacardExists.txt  geneSymbolToKgId.txt | awk 'BEGIN {OFS="\t"} {print $2, $1}' > knownToMalacard.txt
hgLoadSqlTab -notOnServer $tempDb  knownToMalacards $kent/src/hg/lib/knownTo.sql  knownToMalacard.txt
#end didn't do

# make knownToLynx
mkdir -p $dir/lynx
cd $dir/lynx

wget "http://lynx.ci.uchicago.edu/downloads/LYNX_GENES.tab"
awk '{print $2}' LYNX_GENES.tab | sort -f > lynxExists.txt
hgsql -e "select geneSymbol,kgId from kgXref" --skip-column-names $tempDb | awk '{if (NF == 2) print}' | sort -f > geneSymbolToKgId.txt
join -i -t $'\t' lynxExists.txt geneSymbolToKgId.txt | awk 'BEGIN {OFS="\t"} {print $2,$1}' | sort > knownToLynx.tab
hgLoadSqlTab -notOnServer $tempDb  knownToLynx $kent/src/hg/lib/knownTo.sql  knownToLynx.tab

# make knownToWikipedia
mkdir $dir/wikipedia
cd $dir/wikipedia
hgsql $tempDb -e "select geneSymbol,name from knownGene g, kgXref x where g.name=x.kgId " | sort -f > $tempDb.symbolToId.txt
sort -f /hive/groups/browser/wikipediaScrape/symbolToPage.txt > $tempDb.symbolToPage.txt
join -i -t $'\t'   $tempDb.symbolToPage.txt $tempDb.symbolToId.txt | tawk '{print $3,$2}' | sort | uniq > $tempDb.idToPage.txt
hgLoadSqlTab $tempDb knownToWikipedia $HOME/kent/src/hg/lib/knownTo.sql $tempDb.idToPage.txt


# THIS HAS TO BE DONE AFTER MOVING tempDb to $db
# MAKE FOLDUTR TABLES 
# First set up directory structure and extract UTR sequence on hgwdev
cd $dir
mkdir -p rnaStruct
cd rnaStruct
mkdir -p utr3/split utr5/split utr3/fold utr5/fold
# these commands take some significant time
utrFa $db knownGene utr3 utr3/utr.fa
utrFa $db knownGene utr5 utr5/utr.fa

# Split up files and make files that define job.
faSplit sequence utr3/utr.fa 10000 utr3/split/s
faSplit sequence utr5/utr.fa 10000 utr5/split/s
ls -1 utr3/split > utr3/in.lst
ls -1 utr5/split > utr5/in.lst
cd utr3
cat << _EOF_ > template
#LOOP
rnaFoldBig split/\$(path1) fold
#ENDLOOP
_EOF_
gensub2 in.lst single template jobList
cp template ../utr5
cd ../utr5

gensub2 in.lst single template jobList

# Do cluster runs for UTRs
ssh $cpuFarm "cd $dir/rnaStruct/utr3; para make jobList"
ssh $cpuFarm "cd $dir/rnaStruct/utr5; para make jobList"


# Load database
    cd $dir/rnaStruct/utr5
    hgLoadRnaFold $db foldUtr5 fold
    cd ../utr3
    hgLoadRnaFold -warnEmpty $db foldUtr3 fold

# Clean up
    rm -r split fold err batch.bak
    cd ../utr5
    rm -r split fold err batch.bak

# Make pfam run.  Actual cluster run is about 6 hours.
#mkdir -p /hive/data/outside/pfam/Pfam27.0
#cd /hive/data/outside/pfam/Pfam27.0
#wget ftp://ftp.sanger.ac.uk/pub/databases/Pfam/current_release/Pfam-A.hmm.gz
#gunzip Pfam-A.hmm.gz
#set pfamScratch = $scratchDir/pfamBR
#ssh $cpuFarm mkdir -p $pfamScratch
#ssh $cpuFarm cp /hive/data/outside/pfam/Pfam26.0/Pfam-A.hmm $pfamScratch

mkdir -p $dir/pfam
cd $dir/pfam
rm -rf  splitProt
mkdir  splitProt
faSplit sequence $dir/ucscGenes.faa 10000 splitProt/
mkdir -p result
ls -1 splitProt > prot.list
# /hive/data/outside/pfam/hmmpfam -E 0.1 /hive/data/outside/pfam/current/Pfam_fs \
cat << '_EOF_' > doPfam
#!/bin/csh -ef  
/hive/data/outside/pfam/Pfam29.0/PfamScan/hmmer-3.1b2-linux-intel-x86_64/binaries/hmmsearch   --domtblout /scratch/tmp/pfam.$2.pf --noali -o /dev/null -E 0.1 /hive/data/outside/pfam/Pfam29.0/Pfam-A.hmm     splitProt/$1 
mv /scratch/tmp/pfam.$2.pf $3
_EOF_
    # << happy emacs
chmod +x doPfam
cat << '_EOF_' > template
#LOOP
doPfam $(path1) $(root1) {check out line+ result/$(root1).pf}
#ENDLOOP
_EOF_
gensub2 prot.list single template jobList

ssh $cpuFarm "cd $dir/pfam; para make jobList"
ssh $cpuFarm "cd $dir/pfam; para time > run.time"
cat run.time

# Completed: 9410 of 9410 jobs
# CPU time in finished jobs:    2262078s   37701.29m   628.35h   26.18d  0.072 y
# IO & Wait Time:                477969s    7966.16m   132.77h    5.53d  0.015 y
# Average job time:                 291s       4.85m     0.08h    0.00d
# Longest finished job:             354s       5.90m     0.10h    0.00d
# Submission to last job:          2917s      48.62m     0.81h    0.03d

# Make up pfamDesc.tab by converting pfam to a ra file first
cat << '_EOF_' > makePfamRa.awk
/^NAME/ {print}
/^ACC/ {print}
/^DESC/ {print}
/^TC/ {print $1,$3; printf("\n");}
_EOF_
awk -f makePfamRa.awk  /hive/data/outside/pfam/Pfam29.0/Pfam-A.hmm  > pfamDesc.ra
raToTab -cols=ACC,NAME,DESC,TC pfamDesc.ra stdout |  awk -F '\t' '{printf("%s\t%s\t%s\t%g\n", $1, $2, $3, $4);}' | sort > pfamDesc.tab

# Convert output to tab-separated file. 
cd $dir/pfam
catDir result | sed '/^#/d' > allResults.tab
awk 'BEGIN {OFS="\t"} { print $5,$1,$18-1,$19,$4,$14}' allResults.tab | sort > allUcscPfam.tab
join  -t $'\t' -j 1  allUcscPfam.tab pfamDesc.tab | tawk '{if ($6 > $9) print $2, $3, $4, $5, $6, $1}' > ucscPfam.tab
cd $dir

# Convert output to knownToPfam table
tawk '{print $1, gensub(/\.[0-9]+/, "", "g", $6)}' pfam/ucscPfam.tab | sort -u > knownToPfam.tab
hgLoadSqlTab -notOnServer $tempDb knownToPfam $kent/src/hg/lib/knownTo.sql knownToPfam.tab
tawk '{print gensub(/\.[0-9]+/, "", "g", $1), $2, $3}' pfam/pfamDesc.tab| hgLoadSqlTab -notOnServer $tempDb pfamDesc $kent/src/hg/lib/pfamDesc.sql stdin

cd $dir/pfam
genePredToFakePsl $tempDb knownGene knownGene.psl cdsOut.tab
sort cdsOut.tab | sed 's/\.\./   /' > sortCdsOut.tab
sort ucscPfam.tab> sortPfam.tab
awk '{print $10, $11}' knownGene.psl > gene.sizes
join sortCdsOut.tab sortPfam.tab |  awk '{print $1, $2 - 1 + 3 * $4, $2 - 1 + 3 * $5, $6}' | bedToPsl gene.sizes stdin domainToGene.psl
pslMap domainToGene.psl knownGene.psl stdout | pslToBed stdin stdout | bedOrBlocks -useName stdin domainToGenome.bed 
hgLoadBed $tempDb ucscGenePfam domainToGenome.bed

# Do scop run. Takes about 6 hours
#mkdir /hive/data/outside/scop/1.75
#cd /hive/data/outside/scop/1.75
#wget "ftp://license:SlithyToves@supfam.org/models/hmmlib_1.75.gz"
#gunzip hmmlib_1.75.gz
#wget "ftp://license:SlithyToves@supfam.org/models/model.tab.gz"
#gunzip model.tab.gz

mkdir -p $dir/scop
cd $dir/scop
rm -rf result
mkdir  result
ls -1 ../pfam/splitProt > prot.list
cat << '_EOF_' > doScop
#!/bin/csh -ef
/hive/data/outside/pfam/Pfam29.0/PfamScan/hmmer-3.1b2-linux-intel-x86_64/binaries/hmmsearch   --domtblout /scratch/tmp/scop.$2.pf --noali -o /dev/null -E 0.1 /hive/data/outside/scop/1.75/hmmlib_1.75  ../pfam/splitProt/$1
mv /scratch/tmp/scop.$2.pf $3
_EOF_
    # << happy emacs
chmod +x doScop
cat << '_EOF_' > template
#LOOP
doScop $(path1) $(root1) {check out line+ result/$(root1).pf}
#ENDLOOP
_EOF_
    # << happy emacs
gensub2 prot.list single template jobList

ssh $cpuFarm "cd $dir/scop; para make jobList"
ssh $cpuFarm "cd $dir/scop; para time > run.time"
cat run.time

#Completed: 9410 of 9410 jobs
#CPU time in finished jobs:    2078659s   34644.32m   577.41h   24.06d  0.066 y
#IO & Wait Time:                441779s    7362.98m   122.72h    5.11d  0.014 y
#Average job time:                 268s       4.46m     0.07h    0.00d
#Longest finished job:             463s       7.72m     0.13h    0.01d
#Submission to last job:          2689s      44.82m     0.75h    0.03d

# Convert scop output to tab-separated files
cd $dir
catDir scop/result | sed '/^#/d' | awk 'BEGIN {OFS="\t"} {if ($7 <= 0.0001) print $1,$18-1,$19,$4, $7,$8}' | sort > scopPlusScore.tab
sort -k 2 /hive/data/outside/scop/1.75/model.tab > scop.model.tab
scopCollapse scopPlusScore.tab scop.model.tab ucscScop.tab \
	scopDesc.tab knownToSuper.tab
hgLoadSqlTab -notOnServer $tempDb scopDesc $kent/src/hg/lib/scopDesc.sql scopDesc.tab
hgLoadSqlTab $tempDb knownToSuper $kent/src/hg/lib/knownToSuper.sql knownToSuper.tab
#hgsql $tempDb -e "delete k from knownToSuper k, kgXref x where k.gene = x.kgID and x.geneSymbol = 'abParts'"

hgLoadSqlTab $tempDb ucscScop $kent/src/hg/lib/ucscScop.sql ucscScop.tab

# Regenerate ccdsKgMap table
$kent/src/hg/makeDb/genbank/bin/x86_64/mkCcdsGeneMap  -db=$tempDb -loadDb $db.ccdsGene knownGene ccdsKgMap

#ifdef NOTOW
mkdir -p retroTmp
hgsql -Ne "select kgName from ucscRetroInfo9" hg38 | sort -u > retroTmp/0
tawk '{print $1,$1}' retroTmp/0 |  sed 's/\.[0-9]*//' | sort -u > retroTmp/1
hgsql hg38 -Ne "select alignId,name from knownGene" | sed 's/\.[0-9]*//' | sort -u > retroTmp/2
join retroTmp/1 retroTmp/2 | awk 'BEGIN {OFS="\t"} {print $2,$3}' > retroTmp/3
hgsql -Ne "select * from ucscRetroInfo9" hg38 | tawk '{print $44,"noKg"}' | sort -u > retroTmp/4
cat retroTmp/3 retroTmp/4 | tawk '{if (!found[$1]) print; found[$1]=1}' > retroTmp/5
hgsql -Ne "select * from ucscRetroInfo9" hg38 | subColumn 44 stdin retroTmp/5 stdout | sort -k1,1 -k2,2n  > newUcscRetroInfo9.txt 
rm -rf retroTmp

hgsql hg38 -Ne "create table newUcscRetroInfo9 like ucscRetroInfo9"
hgsql hg38 -Ne "load data local infile 'newUcscRetroInfo9.txt' into table newUcscRetroInfo9;"
hgsql hg38 -Ne "rename table ucscRetroInfo9 to oldUcscRetroInfo9"
hgsql hg38 -Ne "rename table newUcscRetroInfo9 to ucscRetroInfo9"
#endif

# Do BioCyc Pathways build
export bioCycDir=/hive/data/outside/bioCyc/180404/download/mouse/1.7/data
mkdir $dir/bioCyc
cd $dir/bioCyc

grep -E -v "^#" $bioCycDir/genes.col  > genes.tab  
grep -E -v "^#" $bioCycDir/pathways.col  | awk -F'\t' '{if (140 == NF) { printf "%s\t\t\n", $0; } else { print $0}}' > pathways.tab

kgBioCyc1 -noEnsembl genes.tab pathways.tab $tempDb bioCycPathway.tab bioCycMapDesc.tab  
hgLoadSqlTab $tempDb bioCycPathway ~/kent/src/hg/lib/bioCycPathway.sql ./bioCycPathway.tab
hgLoadSqlTab $tempDb bioCycMapDesc ~/kent/src/hg/lib/bioCycMapDesc.sql ./bioCycMapDesc.tab

# Do KEGG Pathways build (borrowing Fan Hus's strategy from hg38.txt)
    mkdir -p $dir/kegg
    cd $dir/kegg

    # Make the keggMapDesc table, which maps KEGG pathway IDs to descriptive names
    cp /cluster/data/mm10/bed/ucsc.13.1/kegg/map_title.tab .
    # wget --timestamping ftp://ftp.genome.jp/pub/kegg/pathway/map_title.tab
    cat map_title.tab | sed -e 's/\t/\tmmu\t/' > j.tmp
    cut -f 2 j.tmp >j.mmu
    cut -f 1,3 j.tmp >j.1
    paste j.mmu j.1 |sed -e 's/\t//' > keggMapDesc.tab
    rm j.mmu j.1 j.tmp
    hgLoadSqlTab -notOnServer $tempDb keggMapDesc $kent/src/hg/lib/keggMapDesc.sql keggMapDesc.tab

    # Following in two-step process, build/load a table that maps UCSC Gene IDs
    # to LocusLink IDs and to KEGG pathways.  First, make a table that maps 
    # LocusLink IDs to KEGG pathways from the downloaded data.  Store it temporarily
    # in the keggPathway table, overloading the schema.
    cp /cluster/data/mm9/bed/ucsc.12/kegg/mmu_pathway.list .

    cat mmu_pathway.list| sed -e 's/path://'|sed -e 's/:/\t/' > j.tmp
    hgLoadSqlTab -notOnServer $tempDb keggPathway $kent/src/hg/lib/keggPathway.sql j.tmp

    # Next, use the temporary contents of the keggPathway table to join with
    # knownToLocusLink, creating the real content of the keggPathway table.
    # Load this data, erasing the old temporary content
    hgsql $tempDb -B -N -e 'select distinct name, locusID, mapID from keggPathway p, knownToLocusLink l where p.locusID=l.value' > keggPathway.tab
    hgLoadSqlTab -notOnServer $tempDb \
	keggPathway $kent/src/hg/lib/keggPathway.sql  keggPathway.tab

   # Finally, update the knownToKeggEntrez table from the keggPathway table.
   hgsql $tempDb -B -N -e 'select kgId, mapID, mapID, "+", locusID from keggPathway' |sort -u| sed -e 's/\t+\t/+/' > knownToKeggEntrez.tab
   hgLoadSqlTab -notOnServer $tempDb knownToKeggEntrez $kent/src/hg/lib/knownToKeggEntrez.sql knownToKeggEntrez.tab
    #hgsql $tempDb -e "delete k from knownToKeggEntrez k, kgXref x where k.name = x.kgID and x.geneSymbol = 'abParts'"

# Make spMrna table 
   cd $dir
   #hgsql $db -N -e "select spDisplayID,kgID from kgXref where spDisplayID != ''" > spMrna.tab;
   hgsql $tempDb -N -e "select spDisplayID,kgID from kgXref where spDisplayID != ''" > spMrna.tab;
   hgLoadSqlTab $tempDb spMrna $kent/src/hg/lib/spMrna.sql spMrna.tab


# Do CGAP tables 

    mkdir -p $dir/cgap
    cd $dir/cgap
    
    wget --timestamping -O Mm_GeneData.dat "ftp://ftp1.nci.nih.gov/pub/CGAP/Mm_GeneData.dat"
    hgCGAP Mm_GeneData.dat
        
    cat cgapSEQUENCE.tab cgapSYMBOL.tab cgapALIAS.tab|sort -u > cgapAlias.tab
    hgLoadSqlTab -notOnServer $tempDb cgapAlias $kent/src/hg/lib/cgapAlias.sql ./cgapAlias.tab

    hgLoadSqlTab -notOnServer $tempDb cgapBiocPathway $kent/src/hg/lib/cgapBiocPathway.sql ./cgapBIOCARTA.tab

    cat cgapBIOCARTAdesc.tab|sort -u > cgapBIOCARTAdescSorted.tab
    hgLoadSqlTab -notOnServer $tempDb cgapBiocDesc $kent/src/hg/lib/cgapBiocDesc.sql cgapBIOCARTAdescSorted.tab


cd $dir
# Make PCR target for UCSC Genes, Part 1.
# 1. Get a set of IDs that consist of the UCSC Gene accession concatenated with the
#    gene symbol, e.g. uc010nxr.1__DDX11L1
hgsql $db -N -e 'select kgId,geneSymbol from kgXref' \
    | perl -wpe 's/^(\S+)\t(\S+)/$1\t${1}__$2/ || die;' \
      | sort -u > idSub.txt 
# 2. Get a file of per-transcript fasta sequences that contain the sequences of each UCSC Genes transcript, with this new ID in the place of the UCSC Genes accession.   Convert that file to TwoBit format and soft-link it into /gbdb/hg38/targetDb/ 
### NEXT TIME  use same name in blatServers table as file name!!!
awk '{if (!found[$4]) print; found[$4]=1 }' ucscGenes.bed > nodups.bed
subColumn 4 nodups.bed idSub.txt ucscGenesIdSubbed.bed 
sequenceForBed -keepName -db=$db -bedIn=ucscGenesIdSubbed.bed -fastaOut=stdout  | faToTwoBit stdin ${db}KgSeq${curVer}.2bit
mkdir -p /gbdb/$db/targetDb/ 
rm -f /gbdb/$db/targetDb/${db}KgSeq${curVer}.2bit
ln -s $dir/${db}KgSeq${curVer}.2bit /gbdb/$db/targetDb/
# Load the table kgTargetAli, which shows where in the genome these targets are.
#cut -f 1-10 knownGene.gp | genePredToFakePsl $tempDb stdin kgTargetAli.psl /dev/null
#hgLoadPsl $tempDb kgTargetAli.psl

#
# At this point we should save a list of the tables in tempDb!!!
echo "show tables" | hgsql $tempDb > tablesInKnownGene.lst

cd $dir
cp ../ucsc.17.1/hg38.knownGene.tables.txt .
cp ../ucsc.17.1/hg38.all.knownGene.tables.txt .
hgsql $tempDb -e "show tables like 'knownTo%'" | tail -n +2 | sort > $tempDb.knownTo.txt
join -v 2 $tempDb.knownTo.txt  hg38.knownGene.tables.txt  | grep knownTo
#nothing

#cat hg38.knownTo.txt hg38.knownGene.tables.txt | sort -u > hg38.all.knownGene.tables.txt
# added ccdsKgMap gnfAtlas2Distance gnfU95Distance

for i in  `cat hg38.knownGene.tables.txt`; do echo "desc $i;" | hgsql $tempDb; done 2>&1 | grep exist | awk '{print $8}' > missing.tables.txt

hgsql -Ne "create database ${db}Backup7" mm10
for i in  `cat $lastVer.table.lst`
do
echo "rename table $db.$i to ${db}Backup7.$i;" 
done > tmp
cat tmp | hgsql mm10

# Drop tempDb history table and chromInfo, we don't want to swap them in!
hgsql -e "drop table history" $tempDb
hgsql -e "drop table chromInfo" $tempDb
for i in  `hgsql $tempDb -Ne "show tables"`
do
echo "rename table $tempDb.$i to ${db}.$i;"  
done > tmp
cat tmp | hgsql mm10

 export tempDb=$db

join -v 1 tablesInKnownGene.lst hg38.all.knownGene.tables.txt
#kg10ToKg11
#kgXrefOld10
#knownAttrs
#knownCds
#knownGeneOld10
#knownToEnsembl
#knownToGencodeV26
#knownToMrna
#knownToMrnaSingle
#knownToTag

join -v 2 tablesInKnownGene.lst hg38.all.knownGene.tables.txt
TBD 'tmpFoo67.ceBlastTab' 
TBD 'tmpFoo67.dmBlastTab' 
TBD 'tmpFoo67.drBlastTab'
TBD 'tmpFoo67.foldUtr3'
TBD 'tmpFoo67.foldUtr5' 
X 'tmpFoo67.kg7ToKg8'
X 'tmpFoo67.kgProtMap2'
TBD 'tmpFoo67.kgTargetAli' 
X 'tmpFoo67.kgTxInfo'
Y 'tmpFoo67.knownAlt'
Y'tmpFoo67.knownGeneMrna'
X 'tmpFoo67.knownGeneTxMrna' 
X 'tmpFoo67.knownGeneTxPep'
TBD 'tmpFoo67.scBlastTab'

#kg7ToKg8
#kgProtMap2
#kgTxInfo
#knownGeneTxMrna
#knownGeneTxPep
#knownToGencodeV20
#knownToGnf1h
#knownToWikipedia

# Create backup database
hgsqladmin create ${db}Backup7

# Swap in new tables, moving old tables to backup database.
for i in  `cat hg38.knownGene.tables.txt`
do
echo "rename table $db.$i to ${db}Backup7.$i;" | hgsql $db;
done
ERROR 1146 (42S02) at line 1: Table 'hg38.kg7ToKg8' doesn't exist
ERROR 1146 (42S02) at line 1: Table 'hg38.kgProtMap2' doesn't exist
ERROR 1146 (42S02) at line 1: Table 'hg38.kgTxInfo' doesn't exist
ERROR 1146 (42S02) at line 1: Table 'hg38.knownGeneTxMrna' doesn't exist
ERROR 1146 (42S02) at line 1: Table 'hg38.knownGeneTxPep' doesn't exist



echo "show tables" | hgsql $tempDb > tablesInKnownGene.lst

for i in  `cat tablesInKnownGene.lst`
do
echo "rename table $tempDb.$i to ${db}.$i;"  | hgsql $db
dkone

ERROR 1146 (42S02) at line 1: Table 'tmpFoo87.Tables_in_tmpFoo87' doesn't exist
ERROR 1050 (42S01) at line 1: Table 'gnfAtlas2Distance' already exists
ERROR 1050 (42S01) at line 1: Table 'gnfU95Distance' already exists
ERROR 1050 (42S01) at line 1: Table 'kg10ToKg11' already exists
ERROR 1050 (42S01) at line 1: Table 'kgXrefOld10' already exists
ERROR 1050 (42S01) at line 1: Table 'knownAttrs' already exists
ERROR 1050 (42S01) at line 1: Table 'knownCds' already exists
ERROR 1050 (42S01) at line 1: Table 'knownGeneExt' already exists
ERROR 1050 (42S01) at line 1: Table 'knownGeneOld10' already exists
ERROR 1050 (42S01) at line 1: Table 'knownToEnsembl' already exists
ERROR 1050 (42S01) at line 1: Table 'knownToGnfAtlas2' already exists
ERROR 1050 (42S01) at line 1: Table 'knownToMrna' already exists
ERROR 1050 (42S01) at line 1: Table 'knownToMrnaSingle' already exists
ERROR 1050 (42S01) at line 1: Table 'knownToTag' already exists
ERROR 1050 (42S01) at line 1: Table 'knownToU133' already exists
ERROR 1050 (42S01) at line 1: Table 'knownToU95' already exists


#ERROR 1050 (42S01) at line 1: Table 'chromInfo' already exists
#ERROR 1050 (42S01) at line 1: Table 'history' already exists
#ERROR 1050 (42S01) at line 1: Table 'knownAttrs' already exists
#ERROR 1050 (42S01) at line 1: Table 'knownCds' already exists
#ERROR 1050 (42S01) at line 1: Table 'knownToEnsembl' already exists
#ERROR 1050 (42S01) at line 1: Table 'knownToMrna' already exists
#ERROR 1050 (42S01) at line 1: Table 'knownToMrnaSingle' already exists
#ERROR 1050 (42S01) at line 1: Table 'knownToTag' already exists



hgsqladmin flush-tables

# Make full text index.  Takes a minute or so.  After this the genome browser
# tracks display will work including the position search.  The genes details

# NOW SWAP IN TABLES FROM TEMP DATABASE TO MAIN DATABASE.
# You'll need superuser powers for this step.....

cd $dir


cat << _EOF_ > moveTablesIntoPlace
# Save old known genes and kgXref tables
sudo ~kent/bin/copyMysqlTable $db knownGene $tempDb knownGeneOld$lastVer
sudo ~kent/bin/copyMysqlTable $db kgXref $tempDb kgXrefOld$lastVer

# Create backup database
hgsqladmin create ${db}BackupBraney2


# Swap in new tables, moving old tables to backup database.
sudo ~kent/bin/swapInMysqlTempDb $tempDb $db ${db}BackupBraney2
_EOF_


# Update database links.
sudo rm /var/lib/mysql/uniProt
sudo ln -s /var/lib/mysql/$spDb /var/lib/mysql/uniProt
sudo rm /var/lib/mysql/proteome
sudo ln -s /var/lib/mysql/$pbDb /var/lib/mysql/proteome
hgsqladmin flush-tables


# Make full text index.  Takes a minute or so.  After this the genome browser
# tracks display will work including the position search.  The genes details
# page, gene sorter, and proteome browser still need more tables.
mkdir -p $dir/index
cd $dir/index
hgKgGetText $db knownGene.text 
ixIxx knownGene.text knownGene.ix knownGene.ixx
rm -f /gbdb/$db/knownGene.ix /gbdb/$db/knownGene.ixx
ln -s $dir/index/knownGene.ix  /gbdb/$db/knownGene.ix
ln -s $dir/index/knownGene.ixx /gbdb/$db/knownGene.ixx


### NEXT TIME  use same name in blatServers table as file name!!!
# 3. Ask cluster-admin to start an untranslated, -stepSize=5 gfServer on       
# /gbdb/$db/targetDb/${db}KgSeq${curVer}.2bit

# 4. On hgwdev, insert new records into blatServers and targetDb, using the 
# host (field 2) and port (field 3) specified by cluster-admin.  Identify the
# blatServer by the keyword "$db"Kg with the version number appended
# Starting untrans gfServer for mm10KgSeq12 on host blat1b, port 17899

hgsql hgcentraltest -e 'INSERT into blatServers values ("mm10KgSeq12", "blat1b", 17899, 0, 1);'
hgsql hgcentraltest -e \
      'INSERT into targetDb values("mm10KgSeq12", "UCSC Genes", \
         "mm10", "kgTargetAli", "", "", \
         "/gbdb/mm10/targetDb/mm10KgSeq12.2bit", 1, now(), "");'

#
##
##   WRAP-UP  
#
#  add database to the db's in kent/src/hg/visiGene/vgGetText

cd $dir
#
# Finally, need to wait until after testing, but update databases in other organisms
# with blastTabs

# Load blastTabs
cd $dir/hgNearBlastp
hgLoadBlastTab $xdb $blastTab run.$xdb.$tempDb/out/*.tab
hgLoadBlastTab $ratDb $blastTab run.$ratDb.$tempDb/out/*.tab 
hgLoadBlastTab $flyDb $blastTab run.$flyDb.$tempDb/recipBest.tab
hgLoadBlastTab $wormDb $blastTab run.$wormDb.$tempDb/recipBest.tab
hgLoadBlastTab $yeastDb $blastTab run.$yeastDb.$tempDb/recipBest.tab
hgLoadBlastTab $fishDb $blastTab run.$fishDb.$tempDb/recipBest.tab

# Do synteny on mouse/human/rat
synBlastp.csh $xdb $db
#old number of unique query values: 99540
#old number of unique target values 27444
#new number of unique query values: 92543
#new number of unique target values 26752

synBlastp.csh $ratDb $db ensGene knownGene
#old number of unique query values: 28429
#old number of unique target values 20661
#new number of unique query values: 25758
#new number of unique target values 20061

# need to generate multiz downloads
#/usr/local/apache/htdocs-hgdownload/goldenPath/hg38/multiz46way/alignments/knownCanonical.exonAA.fa.gz
#/usr/local/apache/htdocs-hgdownload/goldenPath/hg38/multiz46way/alignments/knownCanonical.exonNuc.fa.gz
#/usr/local/apache/htdocs-hgdownload/goldenPath/hg38/multiz46way/alignments/knownGene.exonAA.fa.gz
#/usr/local/apache/htdocs-hgdownload/goldenPath/hg38/multiz46way/alignments/knownGene.exonNuc.fa.gz
#/usr/local/apache/htdocs-hgdownload/goldenPath/hg38/multiz46way/alignments/md5sum.txt

echo
echo "see the bottom of the script for details about knownToWikipedia"
echo
# Clean up
rm -r run.*/out

# Last step in setting up isPCR: after the new UCSC Genes with the new Known Gene isPcr
# is released, take down the old isPcr gfServer  

#######################
### The following is the process Briam Lee used to pull out only
#   the genes from knownToLocusLink for which there are Wikipedia articles.
### get the full knownToLocusLinkTable
# hgsql -Ne 'select value from knownToLocusLink' hg38 | sort -u >> knToLocusLink
###   query Wikipedia for each to if there is an article
# for i in $(cat knToLocusLink); do lynx -dump "http://genewiki.sulab.org/map/wiki/"$i | grep -m 1 "no results" >trash ; echo $? $i | grep "1 "| awk '{print $2}'>> workingLinks; done
###   pull out all isoforms that have permitted LocusLinkIds
# for i in $(cat workingLinks); do hgsql -Ne 'select * from knownToLocusLink where value like "'$i'"' hg38 >> knownToWikipediaNew; done
###   then load the table as knownToWikipedia using the knowToLocusLink INDICES.

# This Section marked as not done... not done again!

# Make up and load kgColor table. Takes about a minute.
#txGeneColor $spDb ucscGenes.info ucscGenes.picks ucscGenes.color
#hgLoadSqlTab -notOnServer $tempDb kgColor $kent/src/hg/lib/kgColor.sql ucscGenes.color

# Load up kgProtMap2 table that says where exons are in terms of CDS
#txGeneCdsMap weeded.bed weeded.info pick.picks refTweaked.psl \
	#refToPep.tab $genomes/$db/chrom.sizes cdsToRna.psl \
	#rnaToGenome.psl
# Missed 337 of 40856 refSeq protein mappings.  A small number of RefSeqs just map to genome in the UTR.

#pslMap cdsToRna.psl rnaToGenome.psl cdsToGenome.psl
#hgLoadPsl $tempDb ucscProtMap.psl -table=kgProtMap2



# TODO: Create knownToTreefam table.
$mkdir -p $dir/treeFam
$cd $dir/treeFam
$wget "http://www.treefam.org/static/download/treefam_family_data.tar.gz"
$tar xfz treefam_family_data.tar.gz
$cd treefam_family_data
 $egrep -a ">ENSP[0-9]+" *  | cut -d/ -f2 | tr -d : | sed -e 's/.aa.fasta//' |sed -e 's/.cds.fasta//' | grep -v accession | grep -v ^\> | tr '>' '\t' | tawk '{print $2,$1}' > ../ensToTreefam.tab 
$cd ..
# hgMapToGene -exclude=abGenes.txt -tempDb=$tempDb $db ensGene knownGene knownToEnsembl -noLoad
#awk '{print $2,$1}' ../knownToEnsembl.tab | sort | uniq > ensTransUcsc.tab
$hgsql $db -e "select value,name from knownToEnsembl" | sort | uniq > ensTransUcsc.tab
$echo "select transcript,protein from ensGtp" | hgsql hg38 | sort | uniq | awk '{if (NF==2) print}'  > ensTransProt.tab
$join ensTransUcsc.tab ensTransProt.tab | awk '{if (NF==3)print $3, $2}' | sort | uniq  > ensProtToUc.tab
$join ensProtToUc.tab ensToTreefam.tab | sort -u | awk 'BEGIN {OFS="\t"} {print $2,$3}' | sort -u > knownToTreefam.tab
$hgLoadSqlTab $tempDb knownToTreefam $kent/src/hg/lib/knownTo.sql knownToTreefam.tab
#end section not done

# make bigKnownGene.bb
cd $dir
makeBigKnown mm10
rm -f /gbdb/mm10/knownGeneM23.bb
ln -s `pwd`/mm10.knownGene.bb /gbdb/mm10/knownGeneM23.bb


#############################################################################
# hgPal downloads 

    mkdir $dir/pal
    cd  $dir/pal
    cat /hive/data/genomes/mm10/bed/multiz60way/species.list | tr '[ ]' '[\n]' > order.list

    export mz=multiz60way
    export gp=knownGene
    export db=mm10
    export I=0
    mkdir exonAA exonNuc
    for C in `sort -nk2 /cluster/data/mm10/chrom.sizes | cut -f1`
    do
        I=`echo $I | awk '{print $1+1}'`
	echo "mafGene -chrom=$C -exons -noTrans $db $mz $gp order.list stdout | gzip -c > exonNuc/$C.exonNuc.fa.gz &"
	echo "mafGene -chrom=$C -exons $db $mz $gp order.list stdout | gzip -c > exonAA/$C.exonAA.fa.gz &"
        if [ $I -gt 6 ]; then
            echo "date"
            echo "wait"
            I=0
        fi
    done > $gp.jobs
    echo "date" >> $gp.jobs
    echo "wait" >> $gp.jobs

    time sh -x ./$gp.jobs > $gp.jobs.log 2>&1 &
    # real    62m33.166s

    time zcat exonAA/*.gz | gzip -c > $gp.$mz.exonAA.fa.gz
    # real    4m45.035s
    time zcat exonNuc/*.gz | gzip -c > $gp.$mz.exonNuc.fa.gz
    # real    16m29.138s

    export mz=multiz60way
    export gp=knownGene
    export db=mm10
    export pd=/usr/local/apache/htdocs-hgdownload/goldenPath/$db/$mz/alignments
    mkdir -p $pd
    rm -f $pd/$gp.exonAA.fa.gz
    rm -f $pd/$gp.exonNuc.fa.gz
    ln -s `pwd`/$gp.$mz.exonAA.fa.gz $pd/$gp.exonAA.fa.gz
    ln -s `pwd`/$gp.$mz.exonNuc.fa.gz $pd/$gp.exonNuc.fa.gz

    rm -rf exonAA exonNuc

    ### And knownCanonical
    cd  $dir/pal
    export mz=multiz60way
    export gp=knownCanonical
    export db=mm10
    mkdir exonAA exonNuc knownCanonical

    time cut -f1 /cluster/data/mm10/chrom.sizes | while read C
    do
        echo $C 1>&2
	hgsql mm10 -N -e "select chrom, chromStart, chromEnd, transcript from knownCanonical where chrom='$C'" > knownCanonical/$C.known.bed
    done
    #   real    0m15.897s

    ls knownCanonical/*.known.bed | while read F
    do
      if [ -s $F ]; then
         echo $F | sed -e 's#knownCanonical/##; s/.known.bed//'
      fi
    done | while read C
    do
	echo "date"
	echo "mafGene -geneBeds=knownCanonical/$C.known.bed -exons -noTrans $db $mz knownGene order.list stdout | \
	    gzip -c > exonNuc/$C.exonNuc.fa.gz"
	echo "mafGene -geneBeds=knownCanonical/$C.known.bed -exons $db $mz knownGene order.list stdout | \
	    gzip -c > exonAA/$C.exonAA.fa.gz"
    done > $gp.$mz.jobs

    time sh -x $gp.$mz.jobs > $gp.$mz.job.log 2>&1 
    # 267m58.813s

    rm *.known.bed
    export mz=multiz60way
    export gp=knownCanonical
    export db=mm10
    zcat exonAA/c*.gz | gzip -c > $gp.$mz.exonAA.fa.gz &
    zcat exonNuc/c*.gz | gzip -c > $gp.$mz.exonNuc.fa.gz &
    # about 6 minutes

    rm -rf exonAA exonNuc

    export mz=multiz60way
    export gp=knownCanonical
    export db=mm10
    export pd=/usr/local/apache/htdocs-hgdownload/goldenPath/$db/$mz/alignments
    mkdir -p $pd
    rm -f $pd/$gp.exonAA.fa.gz
    rm -f $pd/$gp.exonNuc.fa.gz
    ln -s `pwd`/$gp.$mz.exonAA.fa.gz $pd/$gp.exonAA.fa.gz
    ln -s `pwd`/$gp.$mz.exonNuc.fa.gz $pd/$gp.exonNuc.fa.gz
    cd  $pd
    md5sum *.fa.gz > md5sum.txt
   