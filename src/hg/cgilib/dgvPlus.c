/* dgvPlus.c was originally generated by the autoSql program, which also 
 * generated dgvPlus.h and dgvPlus.sql.  This module links the database and
 * the RAM representation of objects. */

/* Copyright (C) 2014 The Regents of the University of California 
 * See kent/LICENSE or http://genome.ucsc.edu/license/ for licensing information. */

#include "common.h"
#include "linefile.h"
#include "dystring.h"
#include "jksql.h"
#include "dgvPlus.h"



char *dgvPlusCommaSepFieldNames = "chrom,chromStart,chromEnd,name,score,strand,thickStart,thickEnd,itemRgb,varType,reference,pubMedId,method,platform,mergedVariants,supportingVariants,sampleSize,observedGains,observedLosses,cohortDescription,genes,samples";

void dgvPlusStaticLoad(char **row, struct dgvPlus *ret)
/* Load a row from dgvPlus table into ret.  The contents of ret will
 * be replaced at the next call to this function. */
{

ret->chrom = row[0];
ret->chromStart = sqlUnsigned(row[1]);
ret->chromEnd = sqlUnsigned(row[2]);
ret->name = row[3];
ret->score = sqlUnsigned(row[4]);
safecpy(ret->strand, sizeof(ret->strand), row[5]);
ret->thickStart = sqlUnsigned(row[6]);
ret->thickEnd = sqlUnsigned(row[7]);
ret->itemRgb = sqlUnsigned(row[8]);
ret->varType = row[9];
ret->reference = row[10];
ret->pubMedId = sqlUnsigned(row[11]);
ret->method = row[12];
ret->platform = row[13];
ret->mergedVariants = row[14];
ret->supportingVariants = row[15];
ret->sampleSize = sqlUnsigned(row[16]);
ret->observedGains = sqlUnsigned(row[17]);
ret->observedLosses = sqlUnsigned(row[18]);
ret->cohortDescription = row[19];
ret->genes = row[20];
ret->samples = row[21];
}

struct dgvPlus *dgvPlusLoad(char **row)
/* Load a dgvPlus from row fetched with select * from dgvPlus
 * from database.  Dispose of this with dgvPlusFree(). */
{
struct dgvPlus *ret;

AllocVar(ret);
ret->chrom = cloneString(row[0]);
ret->chromStart = sqlUnsigned(row[1]);
ret->chromEnd = sqlUnsigned(row[2]);
ret->name = cloneString(row[3]);
ret->score = sqlUnsigned(row[4]);
safecpy(ret->strand, sizeof(ret->strand), row[5]);
ret->thickStart = sqlUnsigned(row[6]);
ret->thickEnd = sqlUnsigned(row[7]);
ret->itemRgb = sqlUnsigned(row[8]);
ret->varType = cloneString(row[9]);
ret->reference = cloneString(row[10]);
ret->pubMedId = sqlUnsigned(row[11]);
ret->method = cloneString(row[12]);
ret->platform = cloneString(row[13]);
ret->mergedVariants = cloneString(row[14]);
ret->supportingVariants = cloneString(row[15]);
ret->sampleSize = sqlUnsigned(row[16]);
ret->observedGains = sqlUnsigned(row[17]);
ret->observedLosses = sqlUnsigned(row[18]);
ret->cohortDescription = cloneString(row[19]);
ret->genes = cloneString(row[20]);
ret->samples = cloneString(row[21]);
return ret;
}

struct dgvPlus *dgvPlusLoadAll(char *fileName) 
/* Load all dgvPlus from a whitespace-separated file.
 * Dispose of this with dgvPlusFreeList(). */
{
struct dgvPlus *list = NULL, *el;
struct lineFile *lf = lineFileOpen(fileName, TRUE);
char *row[22];

while (lineFileRow(lf, row))
    {
    el = dgvPlusLoad(row);
    slAddHead(&list, el);
    }
lineFileClose(&lf);
slReverse(&list);
return list;
}

struct dgvPlus *dgvPlusLoadAllByChar(char *fileName, char chopper) 
/* Load all dgvPlus from a chopper separated file.
 * Dispose of this with dgvPlusFreeList(). */
{
struct dgvPlus *list = NULL, *el;
struct lineFile *lf = lineFileOpen(fileName, TRUE);
char *row[22];

while (lineFileNextCharRow(lf, chopper, row, ArraySize(row)))
    {
    el = dgvPlusLoad(row);
    slAddHead(&list, el);
    }
lineFileClose(&lf);
slReverse(&list);
return list;
}

struct dgvPlus *dgvPlusCommaIn(char **pS, struct dgvPlus *ret)
/* Create a dgvPlus out of a comma separated string. 
 * This will fill in ret if non-null, otherwise will
 * return a new dgvPlus */
{
char *s = *pS;

if (ret == NULL)
    AllocVar(ret);
ret->chrom = sqlStringComma(&s);
ret->chromStart = sqlUnsignedComma(&s);
ret->chromEnd = sqlUnsignedComma(&s);
ret->name = sqlStringComma(&s);
ret->score = sqlUnsignedComma(&s);
sqlFixedStringComma(&s, ret->strand, sizeof(ret->strand));
ret->thickStart = sqlUnsignedComma(&s);
ret->thickEnd = sqlUnsignedComma(&s);
ret->itemRgb = sqlUnsignedComma(&s);
ret->varType = sqlStringComma(&s);
ret->reference = sqlStringComma(&s);
ret->pubMedId = sqlUnsignedComma(&s);
ret->method = sqlStringComma(&s);
ret->platform = sqlStringComma(&s);
ret->mergedVariants = sqlStringComma(&s);
ret->supportingVariants = sqlStringComma(&s);
ret->sampleSize = sqlUnsignedComma(&s);
ret->observedGains = sqlUnsignedComma(&s);
ret->observedLosses = sqlUnsignedComma(&s);
ret->cohortDescription = sqlStringComma(&s);
ret->genes = sqlStringComma(&s);
ret->samples = sqlStringComma(&s);
*pS = s;
return ret;
}

void dgvPlusFree(struct dgvPlus **pEl)
/* Free a single dynamically allocated dgvPlus such as created
 * with dgvPlusLoad(). */
{
struct dgvPlus *el;

if ((el = *pEl) == NULL) return;
freeMem(el->chrom);
freeMem(el->name);
freeMem(el->varType);
freeMem(el->reference);
freeMem(el->method);
freeMem(el->platform);
freeMem(el->mergedVariants);
freeMem(el->supportingVariants);
freeMem(el->cohortDescription);
freeMem(el->genes);
freeMem(el->samples);
freez(pEl);
}

void dgvPlusFreeList(struct dgvPlus **pList)
/* Free a list of dynamically allocated dgvPlus's */
{
struct dgvPlus *el, *next;

for (el = *pList; el != NULL; el = next)
    {
    next = el->next;
    dgvPlusFree(&el);
    }
*pList = NULL;
}

void dgvPlusOutput(struct dgvPlus *el, FILE *f, char sep, char lastSep) 
/* Print out dgvPlus.  Separate fields with sep. Follow last field with lastSep. */
{
if (sep == ',') fputc('"',f);
fprintf(f, "%s", el->chrom);
if (sep == ',') fputc('"',f);
fputc(sep,f);
fprintf(f, "%u", el->chromStart);
fputc(sep,f);
fprintf(f, "%u", el->chromEnd);
fputc(sep,f);
if (sep == ',') fputc('"',f);
fprintf(f, "%s", el->name);
if (sep == ',') fputc('"',f);
fputc(sep,f);
fprintf(f, "%u", el->score);
fputc(sep,f);
if (sep == ',') fputc('"',f);
fprintf(f, "%s", el->strand);
if (sep == ',') fputc('"',f);
fputc(sep,f);
fprintf(f, "%u", el->thickStart);
fputc(sep,f);
fprintf(f, "%u", el->thickEnd);
fputc(sep,f);
fprintf(f, "%u", el->itemRgb);
fputc(sep,f);
if (sep == ',') fputc('"',f);
fprintf(f, "%s", el->varType);
if (sep == ',') fputc('"',f);
fputc(sep,f);
if (sep == ',') fputc('"',f);
fprintf(f, "%s", el->reference);
if (sep == ',') fputc('"',f);
fputc(sep,f);
fprintf(f, "%u", el->pubMedId);
fputc(sep,f);
if (sep == ',') fputc('"',f);
fprintf(f, "%s", el->method);
if (sep == ',') fputc('"',f);
fputc(sep,f);
if (sep == ',') fputc('"',f);
fprintf(f, "%s", el->platform);
if (sep == ',') fputc('"',f);
fputc(sep,f);
if (sep == ',') fputc('"',f);
fprintf(f, "%s", el->mergedVariants);
if (sep == ',') fputc('"',f);
fputc(sep,f);
if (sep == ',') fputc('"',f);
fprintf(f, "%s", el->supportingVariants);
if (sep == ',') fputc('"',f);
fputc(sep,f);
fprintf(f, "%u", el->sampleSize);
fputc(sep,f);
fprintf(f, "%u", el->observedGains);
fputc(sep,f);
fprintf(f, "%u", el->observedLosses);
fputc(sep,f);
if (sep == ',') fputc('"',f);
fprintf(f, "%s", el->cohortDescription);
if (sep == ',') fputc('"',f);
fputc(sep,f);
if (sep == ',') fputc('"',f);
fprintf(f, "%s", el->genes);
if (sep == ',') fputc('"',f);
fputc(sep,f);
if (sep == ',') fputc('"',f);
fprintf(f, "%s", el->samples);
if (sep == ',') fputc('"',f);
fputc(lastSep,f);
}

/* -------------------------------- End autoSql Generated Code -------------------------------- */
