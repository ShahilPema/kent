/* bdgpGeneInfo.c was originally generated by the autoSql program, which also 
 * generated bdgpGeneInfo.h and bdgpGeneInfo.sql.  This module links the database and
 * the RAM representation of objects. */

/* Copyright (C) 2014 The Regents of the University of California 
 * See kent/LICENSE or http://genome.ucsc.edu/license/ for licensing information. */

#include "common.h"
#include "linefile.h"
#include "dystring.h"
#include "jksql.h"
#include "bdgpGeneInfo.h"


void bdgpGeneInfoStaticLoad(char **row, struct bdgpGeneInfo *ret)
/* Load a row from bdgpGeneInfo table into ret.  The contents of ret will
 * be replaced at the next call to this function. */
{

ret->bdgpName = row[0];
ret->flyBaseId = row[1];
ret->go = row[2];
ret->symbol = row[3];
ret->cytorange = row[4];
ret->cdna_clone = row[5];
}

struct bdgpGeneInfo *bdgpGeneInfoLoad(char **row)
/* Load a bdgpGeneInfo from row fetched with select * from bdgpGeneInfo
 * from database.  Dispose of this with bdgpGeneInfoFree(). */
{
struct bdgpGeneInfo *ret;

AllocVar(ret);
ret->bdgpName = cloneString(row[0]);
ret->flyBaseId = cloneString(row[1]);
ret->go = cloneString(row[2]);
ret->symbol = cloneString(row[3]);
ret->cytorange = cloneString(row[4]);
ret->cdna_clone = cloneString(row[5]);
return ret;
}

struct bdgpGeneInfo *bdgpGeneInfoLoadAll(char *fileName) 
/* Load all bdgpGeneInfo from a whitespace-separated file.
 * Dispose of this with bdgpGeneInfoFreeList(). */
{
struct bdgpGeneInfo *list = NULL, *el;
struct lineFile *lf = lineFileOpen(fileName, TRUE);
char *row[6];

while (lineFileRow(lf, row))
    {
    el = bdgpGeneInfoLoad(row);
    slAddHead(&list, el);
    }
lineFileClose(&lf);
slReverse(&list);
return list;
}

struct bdgpGeneInfo *bdgpGeneInfoLoadAllByChar(char *fileName, char chopper) 
/* Load all bdgpGeneInfo from a chopper separated file.
 * Dispose of this with bdgpGeneInfoFreeList(). */
{
struct bdgpGeneInfo *list = NULL, *el;
struct lineFile *lf = lineFileOpen(fileName, TRUE);
char *row[6];

while (lineFileNextCharRow(lf, chopper, row, ArraySize(row)))
    {
    el = bdgpGeneInfoLoad(row);
    slAddHead(&list, el);
    }
lineFileClose(&lf);
slReverse(&list);
return list;
}

struct bdgpGeneInfo *bdgpGeneInfoCommaIn(char **pS, struct bdgpGeneInfo *ret)
/* Create a bdgpGeneInfo out of a comma separated string. 
 * This will fill in ret if non-null, otherwise will
 * return a new bdgpGeneInfo */
{
char *s = *pS;

if (ret == NULL)
    AllocVar(ret);
ret->bdgpName = sqlStringComma(&s);
ret->flyBaseId = sqlStringComma(&s);
ret->go = sqlStringComma(&s);
ret->symbol = sqlStringComma(&s);
ret->cytorange = sqlStringComma(&s);
ret->cdna_clone = sqlStringComma(&s);
*pS = s;
return ret;
}

void bdgpGeneInfoFree(struct bdgpGeneInfo **pEl)
/* Free a single dynamically allocated bdgpGeneInfo such as created
 * with bdgpGeneInfoLoad(). */
{
struct bdgpGeneInfo *el;

if ((el = *pEl) == NULL) return;
freeMem(el->bdgpName);
freeMem(el->flyBaseId);
freeMem(el->go);
freeMem(el->symbol);
freeMem(el->cytorange);
freeMem(el->cdna_clone);
freez(pEl);
}

void bdgpGeneInfoFreeList(struct bdgpGeneInfo **pList)
/* Free a list of dynamically allocated bdgpGeneInfo's */
{
struct bdgpGeneInfo *el, *next;

for (el = *pList; el != NULL; el = next)
    {
    next = el->next;
    bdgpGeneInfoFree(&el);
    }
*pList = NULL;
}

void bdgpGeneInfoOutput(struct bdgpGeneInfo *el, FILE *f, char sep, char lastSep) 
/* Print out bdgpGeneInfo.  Separate fields with sep. Follow last field with lastSep. */
{
if (sep == ',') fputc('"',f);
fprintf(f, "%s", el->bdgpName);
if (sep == ',') fputc('"',f);
fputc(sep,f);
if (sep == ',') fputc('"',f);
fprintf(f, "%s", el->flyBaseId);
if (sep == ',') fputc('"',f);
fputc(sep,f);
if (sep == ',') fputc('"',f);
fprintf(f, "%s", el->go);
if (sep == ',') fputc('"',f);
fputc(sep,f);
if (sep == ',') fputc('"',f);
fprintf(f, "%s", el->symbol);
if (sep == ',') fputc('"',f);
fputc(sep,f);
if (sep == ',') fputc('"',f);
fprintf(f, "%s", el->cytorange);
if (sep == ',') fputc('"',f);
fputc(sep,f);
if (sep == ',') fputc('"',f);
fprintf(f, "%s", el->cdna_clone);
if (sep == ',') fputc('"',f);
fputc(lastSep,f);
}

/* -------------------------------- End autoSql Generated Code -------------------------------- */
