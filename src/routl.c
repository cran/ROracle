/* Copyright (c) 2011, 2013, Oracle and/or its affiliates. 
All rights reserved. */

/*
   NAME
     routl.c

   DESCRIPTION
     Implementation of utlity functions for ORE.
   
   EXPORT FUNCTION(S)
     (*) (UN)SERIALIZE FUNCTIONS
         serializeCall   - serialize R object into data.frame of raw vectors
         unserializeCall - unserialize data.frame of raw vectors to R object

   STATIC FUNCTION(S)
     (*) HELPER FUNCTIONS
         createRawVectorDataframe
         InitMemOutBuffer
         InitMemOutPStream
         CloseMemOutPStream
         InitMemInPStream
         
     (*) CALLBACK FUNCTIONS
         OutCharMem
         OutBytesMem
         InCharMem
         InBytesMem

   NOTES

   MODIFIED   (MM/DD/YY)
   qinwan      03/28/13 - bug 16570993: serialize porting issue
   qinwan      03/04/13 - create and add (un)serializeCall
*/

#include <R.h>
#include <Rdefines.h>

struct membuf_st {
    int   chunksize; /* Byte size of one chunk(raw vector) */
    int   size;      /* Actual byte size of current rawvector */
    int   count;     /* Current number of rawvectors(chunks) in out list */
    SEXP  out;       /* List of raw vectors as output */
    PROTECT_INDEX *px_t; /* PROTECT_INDEX for out */
};

typedef struct membuf_st *membuf_t;
typedef long R_size_t;
#define MAXELTSIZE 8192
#define INCR MAXELTSIZE


/* ----------------------- createRawVectorDataframe ------------------------ */
static SEXP createRawVectorDataframe(SEXP valvec, int nrow, 
                                 long total, SEXP lst) {
  PROTECT_INDEX px;
  SEXP classname, names, rownames;
  SEXP idvec, out;
  int k;
  int nExtracols, i, cval;
  SEXP extracolnames, colvec, colval, cstr;
  SEXP colname; 

  nExtracols = GET_LENGTH(lst);
  extracolnames = getAttrib(lst, R_NamesSymbol);

  PROTECT(out = allocVector(VECSXP, 2+nExtracols));         /* PROTECT 2 */
  PROTECT(names = allocVector(STRSXP, 2+nExtracols));       /* PROTECT 3 */
  /* add extra columns */
  for (i=0; i < nExtracols; i++) {
    colval = VECTOR_ELT(lst, i);
    colname = STRING_ELT(extracolnames, i);
    if (IS_INTEGER(colval)) {
       PROTECT_WITH_INDEX(colvec = allocVector(INTSXP, nrow), &px); /* PROTECT 4 */
       cval = strcmp(CHAR(colname), "TOTAL") ? INTEGER(colval)[0] : total;
       for (k=0; k < nrow; k++) {
         INTEGER(colvec)[k] = cval;
       }
    }
    else if (IS_CHARACTER(colval)) {
       PROTECT_WITH_INDEX(colvec = allocVector(STRSXP, nrow), &px); /* PROTECT 4 */
       cstr = STRING_ELT(colval, 0);
       for (k=0; k < nrow; k++) {
         SET_STRING_ELT(colvec, k, cstr);
       }
    }  
    else {
        error("unsupported column types for .ore.serialize");
    }
    SET_STRING_ELT(names, i, colname);
    SET_VECTOR_ELT(out, i, colvec);
    UNPROTECT(1);                                             /* UNPROTECT 4 */
  }

  /* add two default columns CHUNK and VALUE */
  PROTECT_WITH_INDEX(idvec = allocVector(INTSXP, nrow), &px);   /* PROTECT 4 */
  for (k=0; k < nrow; k++) {
    INTEGER(idvec)[k] = k;
  }
  SET_VECTOR_ELT(out, nExtracols, idvec);
  SET_VECTOR_ELT(out, nExtracols+1, valvec);
  SET_STRING_ELT(names, nExtracols, mkChar("CHUNK"));
  SET_STRING_ELT(names, nExtracols+1, mkChar("VALUE"));

  /* add names */
  setAttrib(out, R_NamesSymbol, names);

  /* add class */
  PROTECT(classname = mkString("data.frame"));                  /* PROTECT 5 */
  setAttrib(out, R_ClassSymbol, classname);

  /* rownames */
  PROTECT(rownames = allocVector(INTSXP, 2));                      /* PROTECT 6 */
  INTEGER(rownames)[0] = NA_INTEGER;
  INTEGER(rownames)[1] = nrow;
  setAttrib(out, R_RowNamesSymbol, rownames);

  return out;
}
/* end of createRawVectorDataframe */

/* ----------------------------- InitMemOutBuffer --------------------------- */
static void InitMemOutBuffer(membuf_t mb, R_size_t est_size, 
                        int chunk_size, PROTECT_INDEX *px_t)
{
    R_size_t nrow = est_size>0 ? (est_size-1)/chunk_size+1 : 0;
    R_size_t nvec = (R_size_t)(nrow*1.05+1);

    if(nvec >= INT_MAX) {
        error("serialization is too large to store");
    }

    PROTECT_WITH_INDEX(mb->out = allocVector(VECSXP, nvec), px_t);  /* PROTECT 1 */

    mb->chunksize = chunk_size;
    mb->size = chunk_size;
    mb->count = 0;
    mb->px_t = px_t;
}
/* end of InitMemOutBuffer */

/* ----------------------------- OutCharMem ------------------------------- */
static void OutCharMem(R_outpstream_t stream, int c)
{
    error("OutCharMem is not supported");
} /* end of OutCharMem */

/* ----------------------------- OutBytesMem ------------------------------- */
static void OutBytesMem(R_outpstream_t stream, void *buf, int length)
{
    membuf_t mb = stream->data;
    const int CHUNKSZ =  mb->chunksize;
    int cpysz, max_count, nchunks, inc; 
    int count=mb->count, bufsz=mb->size, rest=length;
    Rbyte * valout;

    if (length <= 0 ) return;

    /* ensure sufficient elements on list to hold needed rawvectors */
    max_count = GET_LENGTH(mb->out);
    nchunks = (length-1)/CHUNKSZ+1;
    if (count + nchunks > max_count) {
      /* increase by 100% for <= 2GB or 25% otherwise */
      inc = (max_count>>20 == 0 ? max_count+1: (max_count>>2)+1);
      max_count += nchunks < inc ? inc : 2*nchunks;
      if (max_count < INT_MAX) {
                                                        /* REPROTECT 1 */
        REPROTECT(mb->out = Rf_lengthgets(mb->out, max_count), *(mb->px_t));
      }
      else {
        error("serialization is too large to store");
      }
    }

    /* allocate and fill rawvectors */
    while (rest > 0) {
        if (bufsz == CHUNKSZ) {
            /* allocate a new rawvector to take the serialized data */
            SET_VECTOR_ELT(mb->out, count, allocVector(RAWSXP, CHUNKSZ));
            bufsz = 0;
            count++;
        }
        valout = RAW(VECTOR_ELT(mb->out, count-1));
        cpysz = rest + bufsz >= CHUNKSZ ? CHUNKSZ-bufsz : rest;
        memcpy(valout+bufsz, ((unsigned char *)buf)+length-rest, cpysz);
        bufsz += cpysz;
        rest -= cpysz;
    }
    mb->size = bufsz;
    mb->count = count;
} /* end of OutBytesMem */

/* --------------------------- InitMemOutPStream ---------------------------- */
static void InitMemOutPStream(R_outpstream_t stream, membuf_t mb,
                              R_pstream_format_t type, int version,
                              SEXP (*phook)(SEXP, SEXP), SEXP pdata) 
{
    R_InitOutPStream(stream, (R_pstream_data_t) mb, type, version,
                     OutCharMem, OutBytesMem, phook, pdata);
} /* end of InitMemOutPStream */

/* --------------------------- CloseMemOutPStream --------------------------- */
static SEXP CloseMemOutPStream(R_outpstream_t stream, SEXP lst)
{
    SEXP val;
    membuf_t mb = stream->data;
    R_size_t total = ((R_size_t)mb->count-1)*mb->chunksize+mb->size;

    /* duplicate check, for future proofing */
    if(mb->count >= INT_MAX) {
        error("serialization is too large to store");
    }
    if (mb->size < mb->chunksize) {
        /* adjust the size on last chunk */
        SEXP vec;
        PROTECT(vec = allocVector(RAWSXP, mb->size));   /* PROTECT 2 */
        Rbyte * val = RAW(VECTOR_ELT(mb->out, mb->count-1));
        memcpy(RAW(vec), val, mb->size);
        SET_VECTOR_ELT(mb->out, mb->count-1, vec);
        UNPROTECT(1);                                 /* UNPROTECT 2 */
    }
                                                      /* REPROTECT 1 */
    REPROTECT(mb->out = Rf_lengthgets(mb->out, mb->count), *(mb->px_t));
    val = createRawVectorDataframe(mb->out, mb->count, total, lst); 

    UNPROTECT(6);                                   /* UNPROTECT 1~6 */

    return val;
} /* end of CloseMemOutPStream */

/* ----------------------------- serializeCall ----------------------------- */
SEXP serializeCall(SEXP object, SEXP objsz, SEXP chunksz, SEXP lst) {

  struct R_outpstream_st out;
  R_pstream_format_t type=R_pstream_xdr_format;
  SEXP (*hook)(SEXP, SEXP)=NULL, fun=R_NilValue;
  int version=2;
  SEXP val;
  struct membuf_st mbs;
  PROTECT_INDEX px;

  R_size_t estobjsz = (R_size_t)(NUMERIC_POINTER(objsz)[0]);
  int CHUNKSZ = INTEGER(chunksz)[0];

  InitMemOutBuffer(&mbs, estobjsz, CHUNKSZ, &px);
  InitMemOutPStream(&out, &mbs, type, version, hook, fun);
  R_Serialize(object, &out);
  val =  CloseMemOutPStream(&out, lst);

  return val;
} /* end of serializeCall */

/* ----------------------------- InCharMem -------------------------------- */
static int InCharMem(R_inpstream_t stream)
{
    error("InCharMem is not supported");
} /* end of InCharMem */

/* ----------------------------- InBytesMem ------------------------------ */
static void InBytesMem(R_inpstream_t stream, void *buf, int length)
{
    membuf_t mb = stream->data;
    SEXP  valraw = VECTOR_ELT(mb->out, mb->count);
    Rbyte * valin;
    int cpysz, rest = length, bufsz = mb->size, CHUNKSZ;
    int max_count = mb->chunksize; //GET_LENGTH(mb->out);

    /* copy contents from rawvectors to buf */
    CHUNKSZ = GET_LENGTH(valraw);
    while (rest > 0) {
        if (bufsz == CHUNKSZ) {
            mb->count++;
            if (mb->count < max_count) {
              valraw = VECTOR_ELT(mb->out, mb->count);
              CHUNKSZ = GET_LENGTH(valraw);
              bufsz = 0;
            }
            else {
              error("unserializeCall no more buffer to read error");
            }
        }
        valin = RAW(valraw);
        cpysz = rest >= CHUNKSZ-bufsz ? CHUNKSZ-bufsz : rest;
        memcpy(((unsigned char *)buf)+length-rest, valin+bufsz, cpysz);
        bufsz += cpysz;
        rest -= cpysz;
    }
    mb->size = bufsz;
} /* end of InBytesMem */

/* ----------------------------- InitMemInPStream --------------------------- */
static void InitMemInPStream(R_inpstream_t stream, membuf_t mb,
                             SEXP buf,
                             SEXP (*phook)(SEXP, SEXP), SEXP pdata) 
{
    mb->count = 0;
    mb->size = 0;
    mb->out = buf;
    mb->chunksize = GET_LENGTH(mb->out); /* number of chunks (raw vectors) */
    R_InitInPStream(stream, (R_pstream_data_t) mb, R_pstream_any_format,
                    InCharMem, InBytesMem, phook, pdata);
} /* end of InitMemInPStream */

/* ----------------------------- unserializeCall --------------------------- */
SEXP unserializeCall(SEXP data)
{
    struct R_inpstream_st in;
    SEXP ans;
    SEXP (*hook)(SEXP, SEXP)=NULL, fun=R_NilValue;

    if (TYPEOF(data) == VECSXP && LENGTH(data) > 0 && 
           IS_RAW(VECTOR_ELT(data, 0)) ) {
        struct membuf_st mbs;
        InitMemInPStream(&in, &mbs, data, hook, fun);
        PROTECT(ans = R_Unserialize(&in));
        /* verify no more left to read */
        if (mbs.count+1 == GET_LENGTH(mbs.out) && 
            mbs.size == GET_LENGTH(VECTOR_ELT(mbs.out, mbs.count))) {
          UNPROTECT(1);
          return ans;
        }
        else {
          UNPROTECT(1);
          error("unserializeCall more buffer left to read error");
        }
    } 
    else {
        error("invalid type or empty data for unserializeCall");
        return R_NilValue; /* -Wall */
    }
} /* end of unserializeCall */

