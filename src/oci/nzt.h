/* DISABLE check_long_lines */

/* Copyright (c) 1996, 2024, Oracle and/or its affiliates.*/
/* All rights reserved.*/

/*
 * 
 */

/* 
 * NAME
 *    nzt.h
 * 
 * DESCRIPTION
 *    Toolkit public declarations.
 *    
 * PUBLIC FUNCTIONS
 *    nztwOpenWallet           - Open a wallet based on a WRL and pwd.
 *    nztwCloseWallet          - Close a wallet.
 *    nztwRetrievePersonaCopy  - Retieve a copy of a particular persona.
 *    nzteOpenPersona          - Open a persona.
 *    nzteClosePersona         - Close a persona.
 *    nzteDestroyPersona       - Destroy a persona.
 *    nzteRetrieveTrustedIdentCopy - Retrieves a trusted identity frompersona
 *    nztePriKey               - Get the Private Key (X509 Only)
 *    nzteMyCert               - Get the Certificate (X509 only)
 *    nztiAbortIdentity        - Discard an unstored identity.
 *    nztbbReuseBlock          - Reuse a buffer block.           
 *    nztbbPurgeBlock          - Purge the memory used within a buffer block.
 *    nztcts_CipherSpecToStr   - Converts the Cipher Spec Code To String
 *    nztiae_IsEncrEnabled     - Checks to see if Encryption is Enabled
 *                               in the current Cipher Spec.
 *    nztiae_IsHashEnabled     - Checks to see if Hashing is Enabled
 *                               in the current Cipher Spec.
 *    nztwGetCertInfo          - Get peer certificate info
 *    nzICE_Install_Cert_ext   - Installs a Cert into a wallet with Trustflag
 *                               value set for the certificate.
 *
 * NOTE: the '+' indicates that these functions are UNSUPPORTED at this time.
 * 
 * NOTES
 *    
 * MODIFIED
 *    anna       09/04/24 - Bug 36954713 - Add information for nzttWallet
 *    rchahal    10/03/23 - ER 35837962: cert selection using alias, thumbprint
 *    mmiyashi   08/06/21 - Proj 89547: System default certificate store
 *    nitnagpa   05/24/21 - Removing Plateform Dependency for Date
 *    nitnagpa   04/28/21 - OSS-5987
 *    anna       10/21/20 - Code Cleanup - Crypto-962
 *    anna       06/12/20 - Code Cleanup Crypto-736
 *    bapalava   06/04/20 - NZ cleaup task - Jira-751
 *    anna       06/03/20 - Code Cleanup Crypto-733,735,737,743
 *    anna       05/29/20 - Code Cleanup Crypto-752
 *    hyunjele   05/13/20 - CRYPTO-387: Remove dead code under macro NZDEPRECATED,
 *                          MES_DELETE, MES_OBSOLETE, MES_LATER_OBSOLETE and
 *                          NZMES_OBSOLETE
 *    anna       05/11/20 - code cleanup (Crypto-229)
 *    anna       04/23/20 - Code cleanup(Crypto-282): deadcode under macro
 *                          NZ_OLD_TOOLS
 *    anna       02/20/20 - nztbbSetBlock is obsolete bug-30744217
 *    zighuang   04/02/20 - Bug #30743598: Remove method nztbbSetBlock. 
 *    anna       02/13/20 - public APIs in private header nztn.h moved here
 *                          [crypto-214]
 *    abjuneja   09/11/13 - Bug 14245960 - Wallet encryption algo upgrade
 *    nidgarg    05/07/13 - TF Support: Add functions for Trustflags
 *    shiahuan   11/28/07 - 
 *    skalyana   08/15/07 - 
 *    pkale      09/28/06 - Bug 5565668: Removed __STDC__
 *    tnallath   09/22/05 - 
 *    rchahal    07/27/04 - add keyusage 
 *    srtata     11/10/03 - fix nztSetAppDefaultLocation header 
 *    rchahal    10/15/03 - bug 2513821 
 *    rchahal    11/11/02 - pkcs11 support
 *    akoyfman   07/05/02 - adding secret store to persona
 *    supriya    10/11/01 - Fix for bug # 2015732
 *    ajacobs    04/04/01 - make NZT_REGISTRY_WRL always available
 *    ajacobs    03/06/01 - olint fix
 *    ajacobs    03/02/01 - Add GetCertInfo
 *    supriya    02/23/01 - Move nzttKPUsage from nzt0.h
 *    rchahal    01/26/01 - olint fixes
 *    supriya    12/07/00 - Change fn name
 *    supriya    12/01/00 - Certificate API's needed for iAS
 *    supriya    06/19/00 - Adding definitions for MCS and ENTR
 *    lkethana   05/31/00 - multiple cert support
 *    skanjila   06/25/99 - Remove nztcts_CipherSpecToStr() to NZOS.
 *    skanjila   06/23/99 - Change API of nztcts_CipherSpecToStr.
 *    lkethana   06/18/99 - rem nztIPrivateAlloc, etc
 *    lkethana   06/10/99 - changing size_t to ub4
 *    lkethana   06/02/99 - add api for getting auth/encry/hash capability of c
 *    arswamin   12/28/98 - add NZT_MAX_MD5.
 *    arswamin   12/21/98 - change signature of compareDN
 *    qdinh      12/21/98 - change size_t to ub4.
 *    inetwork   11/22/98 - Removing NZDEPRECATED definition
 *    amthakur   09/14/98 - deprecating and updating the c-structures.
 *    arswamin   09/24/98 - adding NZTTWRL_NULL for SSO support.
 *    amthakur   07/30/98 - changing the prototype of nztGetCertChain.
 *    qdinh      05/01/98 - add NZTTIDENTTYPE_INVALID_TYPE
 *    qdinh      04/17/98 - add NZTTWRL_ORACLE.
 *    ascott     10/08/97 - implement nztiStoreTrustedIdentity
 *    ascott     10/07/97 - add nztiGetIdentityDesc
 *    ascott     09/28/97 - clarify prototype comments and error codes
 *    ascott     09/05/97 - update identity: create, destroy, duplicate
 *    ascott     08/21/97 - add GetCert and GetPriKey
 *    ascott     08/07/97 - add other WRL settings
 *    asriniva   03/25/97 - Add ANSI prototypes
 *    rwessman   03/19/97 - Added prototypes for nztific_FreeIdentityContent()
 *    asriniva   03/11/97 - Fix olint errors
 *    sdange     02/28/97 - Removed inclusion of nz0decl.h
 *    sdange     02/18/97 - Moved nzt specific declarations from nz0decl.h
 *    asriniva   01/21/97 - Remove prototypes.
 *    asriniva   10/31/96 - Include oratypes.h
 *    asriniva   10/15/96 - Declare buffer block helper functions
 *    asriniva   10/08/96 - First pass at wallet open/close
 *    asriniva   10/04/96 - Add random number seed function
 *    asriniva   10/03/96 - Reorder parameters in nztbbSetBlock
 *    asriniva   10/03/96 - Keep editing.
 *    asriniva   10/03/96 - Continued edits.
 *    asriniva   10/02/96 - Continue editing.
 *    asriniva   09/26/96 -
 */
   
/* ENABLE check_long_lines */

/**
 * \ingroup NZ_HEADERS
 * @{
 * @file nzt.h
 *
 */

#ifndef NZT_ORACLE
#define NZT_ORACLE

#ifndef ORATYPES
# include <oratypes.h>
#endif /* ORATYPES */

#ifndef NZERROR_ORACLE
# include <nzerror.h>         /* NZ error type */
#endif /* NZERROR_ORACLE */


#define NZT_MAX_SHA1 20
#define NZT_MAX_MD5  16

/***************************************/
/* PUBLIC CONSTANTS, MACROS, AND TYPES */
/***************************************/

/*
 * Wallet Resource Locator Type Strings
 *
 * WRL TYPE        PARMETERS      BEHAVIOR
 * ========        ==========      =====================================
 * default:          <none>        Uses directory defined by the parameter
 *                                 SNZD_DEFAULT_FILE_DIRECTORY which in 
 *                                 unix is "$HOME/oracle/oss"
 * 
 * file:            file path      Find the Oracle wallet in this directory.
 *                                 example: file:<dir-path>
 * 
 * sqlnet:           <none>        In this case, the directory path will be 
 *                                 retrieved from the sqlnet.ora file under
 *                                 the oss.source.my_wallet parameter.
 *
 * mcs:              <none>        Microsoft WRL.
 *
 * entr:             dir path      Entrust WRL. eg: ENTR:<dir-path>   
 * 
 * system:           <none>        System's default certificate
 * 
 */
/* Note that there is no NZT_NULL_WRL.  Instead look in snzd.h for DEFAULT_WRP
 * which is used in our new defaulting mechanism.  The NZT_DEFAULT_WRL
 * should be deprecated.
 */
#define NZT_DEFAULT_WRL    ((text *)"default:")
#define NZT_SQLNET_WRL     ((text *)"sqlnet:")
#define NZT_FILE_WRL       ((text *)"file:")
#define NZT_ENTR_WRL       ((text *)"entr:")
#define NZT_MCS_WRL        ((text *)"mcs:")
#define NZT_SYSTEM_WRL     ((text *)"system:")
#define NZT_ORACLE_WRL     ((text *)"oracle:")
#define NZT_REGISTRY_WRL   ((text *)"reg:")
#define NZT_MEMORY_WRL     ((text *)"memory:")

#define  NZ_TF_SERVER_AUTH  256 /* Trusted server CA certificate */
#define  NZ_TF_CLIENT_AUTH 512  /* Trusted Client CA certificate */
#define  NZ_TF_VALID_PEER 1024  /* Peer's User Certificate */
#define  NZ_TF_USER_CERT 2048   /* User certificate, only for NZ use */
#define  NZ_TF_NULL 4096        /* NULL trustflag to certificate */
#define  NZ_TF_TRUSTED 8192     /* Trusted certificate */
#define  NZ_TF_NONE 16384       /* Used by internal functions when Wallet doesn't support TF */

typedef int nzTrustFlag;

/*! Enum for WRL */
           
enum nzttwrl 
{
   NZTTWRL_DEFAULT = 1,    /*!< Default, use SNZD_DEFAULT_FILE_DIRECTORY */
   NZTTWRL_SQLNET,         /*!< Use oss.source.my_wallet in sqlnet.ora file */
   NZTTWRL_FILE,           /*!< Find the oracle wallet in this directory */
   NZTTWRL_ENTR,           /*!< Find the entrust profile in this directory */
   NZTTWRL_MCS,            /*!< WRL for Microsoft */
   NZTTWRL_ORACLE,         /*!< Get the wallet from OSS db */
   NZTTWRL_NULL,           /*!< New SSO defaulting mechanism */
   NZTTWRL_REGISTRY,       /*!< Find the wallet in Windows Registry */
   NZTTWRL_MEMORY,         /*!< Read the wallet from Memory/Buffer */
   NZTTWRL_SYSTEM          /*!< System's default certs for one-way TLS */
};
typedef enum nzttwrl nzttwrl;

#ifndef NZ0DECL_ORACLE
   /*
    * With the elimination of nz0decl.h from public, we need this
    * redundant typedef.
    */
   typedef struct nzctx nzctx;
   typedef struct nzstrc nzstrc;
   typedef struct nzosContext nzosContext;
#endif /* NZ0DECL_ORACLE */

/* Moved from nz0decl.h */

typedef struct nzttIdentity nzttIdentity;
typedef struct nzttIdentityPrivate nzttIdentityPrivate;
typedef struct nzttPersona nzttPersona;
typedef struct nzttPersonaList nzttPersonaList;
typedef struct nzttPersonaPrivate nzttPersonaPrivate;
typedef struct nzttWallet nzttWallet;
typedef struct nzttWalletPrivate nzttWalletPrivate;
typedef struct nzttWalletObj nzttWalletObj; /* For wallet object */
typedef struct nzssEntry nzssEntry; /* For secretstore */
typedef struct nzpkcs11_Info nzpkcs11_Info;
typedef struct nzpkcs12_Info nzpkcs12_Info;
typedef struct nzttTrustInfo nzttTrustInfo;
typedef struct nzdpTimeDate nzdpTimeDate;

/**
 * \brief Crypto Engine State
 *
 * Once the crypto engine (CE) has been initialized for a particular
 * cipher, it is either at the initial state, or it is continuing to
 * use the cipher.  NZTCES_END is used to change the state back to
 * initialized and flush any remaining output.  NZTTCES_RESET can be
 * used to change the state back to initialized and throw away any
 * remaining output.
 */
enum nzttces 
{
   NZTTCES_CONTINUE = 1,    /*!< Continue processing input */
   NZTTCES_END,             /*!< End processing input */
   NZTTCES_RESET            /*!< Reset processing and skip generating output */
};
typedef enum nzttces nzttces;

/**
 * \brief Crypto Engine Functions
 *
 * List of crypto engine categories; used to index into protection
 * vector.
 */
enum nzttcef
{
   NZTTCEF_DETACHEDSIGNATURE = 1,   /*!< Signature, detached from content */
   NZTTCEF_SIGNATURE,               /*!< Signature combined with content */
   NZTTCEF_ENVELOPING,              /*!< Signature and encryption with content */
   NZTTCEF_PKENCRYPTION,            /*!< Encryption for one or more recipients */
   NZTTCEF_ENCRYPTION,              /*!< Symmetric encryption */
   NZTTCEF_KEYEDHASH,               /*!< Keyed hash/checkusm */
   NZTTCEF_HASH,                    /*!< Hash/checsum */
   NZTTCEF_RANDOM,                  /*!< Random byte generation */

   NZTTCEF_LAST                     /*!< Used for array size */
};
typedef enum nzttcef nzttcef;

/**
 * \brief State of the persona.
 */
enum nzttState
{
   NZTTSTATE_EMPTY = 0,     /*!< is not in any state(senseless???) */
   NZTTSTATE_REQUESTED,     /*!< cert-request */
   NZTTSTATE_READY,         /*!< certificate */
   NZTTSTATE_INVALID,       /*!< certificate */
   NZTTSTATE_RENEWAL        /*!< renewal-requested */
};
typedef enum nzttState nzttState;

/**
 * \brief Cert-version types
 * 
 * This is used to quickly look-up the cert-type
 */
enum nzttVersion
{
   NZTTVERSION_X509v1 = 1,        /*!< X.509v1 */
   NZTTVERSION_X509v3,            /*!< X.509v3 */
   NZTTVERSION_INVALID_TYPE       /*!< For Initialization */
};
typedef enum nzttVersion nzttVersion;

/**
 * \brief Cipher Types
 *
 * List of all cryptographic algorithms, some of which may not be
 * available.
 */
enum nzttCipherType 
{
   NZTTCIPHERTYPE_INVALID = 0,
   NZTTCIPHERTYPE_RSA = 1,          /*!< RSA public key */
   NZTTCIPHERTYPE_DES,              /*!< DES */
   NZTTCIPHERTYPE_RC4,              /*!< RC4 */
   NZTTCIPHERTYPE_MD5DES,           /*!< DES encrypted MD5 with salt (PBE) */
   NZTTCIPHERTYPE_MD5RC2,           /*!< RC2 encrypted MD5 with salt (PBE) */
   NZTTCIPHERTYPE_MD5,              /*!< MD5 */
   NZTTCIPHERTYPE_SHA,              /*!< SHA */
   NZTTCIPHERTYPE_ECC               /*!< ECC */
};
typedef enum nzttCipherType nzttCipherType;

/**
 * \brief TDU Formats
 *
 * List of possible toolkit data unit (TDU) formats.  Depending on the
 * function and cipher used some may be not be available.
 */
enum nztttdufmt
{
   NZTTTDUFMT_PKCS7 = 1,            /*!< PKCS7 format */
   NZTTTDUFMT_RSAPAD,               /*!< RSA padded format */
   NZTTTDUFMT_ORACLEv1,             /*!< Oracle v1 format */
   NZTTTDUFMT_LAST                  /*!< Used for array size */
};
typedef enum nztttdufmt nztttdufmt;

/**
 * \brief Validate State
 *
 * Possible validation states an identity can be in.
 */
enum nzttValState
{
   NZTTVALSTATE_NONE = 1,        /*!< Needs to be validated */
   NZTTVALSTATE_GOOD,            /*!< Validated */
   NZTTVALSTATE_REVOKED          /*!< Failed to validate */
};
typedef enum nzttValState nzttValState;

/**
 * \brief Policy Fields <----NEW (09/14/98)
 *
 * Policies enforced
 */
enum nzttPolicy
{
   NZTTPOLICY_NONE = 0,/*!< null policy */
   NZTTPOLICY_RETRY_1, /*!< number of retries for decryption = 1 */
   NZTTPOLICY_RETRY_2, /*!< number of retries for decryption = 2 */
   NZTTPOLICY_RETRY_3  /*!< number of retries for decryption = 3 */
};
typedef enum nzttPolicy nzttPolicy;

/**
 * Personas and identities have unique id's that are represented with
 * 128 bits.
 */
typedef ub1 nzttID[16];

/**
 * \brief Identity Types
 *
 * List of all Identity types..
 */
enum nzttIdentType 
{
   NZTTIDENTITYTYPE_INVALID_TYPE = 0,  
   NZTTIDENTITYTYPE_CERTIFICTAE,      
   NZTTIDENTITYTYPE_CERT_REQ,      
   NZTTIDENTITYTYPE_RENEW_CERT_REQ,      
   NZTTIDENTITYTYPE_CLEAR_ETP,      
   NZTTIDENTITYTYPE_CLEAR_UTP,      
   NZTTIDENTITYTYPE_CLEAR_PTP       
};
typedef enum nzttIdentType nzttIdentType;

typedef ub4 nzttKPUsage;
/* IF new types are added nztiMUS should be changed */
#define NZTTKPUSAGE_NONE 0
#define NZTTKPUSAGE_SSL 1             /* SSL Server */
#define NZTTKPUSAGE_SMIME_ENCR 2
#define NZTTKPUSAGE_SMIME_SIGN 4
#define NZTTKPUSAGE_CODE_SIGN 8
#define NZTTKPUSAGE_CERT_SIGN 16
#define NZTTKPUSAGE_SSL_CLIENT 32     /* SSL Client */
#define NZTTKPUSAGE_INVALID_USE 0xffff


/**
 * Timestamp as 32 bit quantity in UTC.
 */
typedef ub1 nzttTStamp[4];

/**
 * \brief Buffer Block
 *
 * A function that needs to fill (and possibly grow) an output buffer
 * uses an output parameter block to describe each buffer.
 *
 * The flags_nzttBufferBlock member tells the function whether the
 * buffer can be grown or not.  If flags_nzttBufferBlock is 0, then
 * the buffer will be realloc'ed automatically.  
 *
 * The buflen_nzttBufferBLock member is set to the length of the
 * buffer before the function is called and will be the length of the
 * buffer when the function is finished.  If buflen_nzttBufferBlock is
 * 0, then the initial pointer stored in pobj_nzttBufferBlock is
 * ignored.
 *
 * The objlen_nzttBufferBlock member is set to the length of the
 * object stored in the buffer when the function is finished.  If the
 * initial buffer had a non-0 length, then it is possible that the
 * object length is shorter than the buffer length.
 *
 * The pobj_nzttBufferBlock member is a pointer to the output object.
 */
struct nzttBufferBlock
{
# define NZT_NO_AUTO_REALLOC     0x1

   uword flags_nzttBufferBlock;     /*!< Flags */
   ub4 buflen_nzttBufferBlock;   /*!< Total length of buffer */
   ub4 usedlen_nzttBufferBlock;  /*!< Length of used buffer part */
   ub1 *buffer_nzttBufferBlock;     /*!< Pointer to buffer */
};
typedef struct nzttBufferBlock nzttBufferBlock;

/**
 * \brief NZ Wallet Structure
 *
 * If an application is running is multithreaded mode and nzttWallet 
 * used in nzos_OpenWallet() to open a wallet is global, then using 
 * nzos_OpenWallet() in all the threads using same global wallet will result
 * in memory leak of members persona_nzttWallet, private_nzttWallet.
 * Before a thread will free memory of persona_nzttWallet, private_nzttWallet
 * othere thread would update them. In this scenario nzttWallet should be
 * allocated once and be resued among threads.
 *
 */
struct nzttWallet
{
   ub1 *ldapName_nzttWallet;              /*!< user's LDAP Name */
   ub4  ldapNamelen_nzttWallet;           /*!< len of user's LDAP Name */
   nzttPolicy securePolicy_nzttWallet;    /*!< secured-policy of the wallet */
   nzttPolicy openPolicy_nzttWallet;      /*!< open-policy of the wallet */
   nzttPersona *persona_nzttWallet;       /*!< List of personas in wallet */
   nzttWalletPrivate *private_nzttWallet; /*!< Private wallet information */
};

/**
 * \brief Structure with information about number of trusted 
 *        certificates of each type
 */
struct nzttTrustInfo
{
   ub4 serverAuthTFcount_nzttTrustInfo;    /*!< Number of certificates with
                                                 * SERVER_AUTH trust flag
                                                 */

   ub4 clientAuthTFcount_nzttTrustInfo;    /*!< Number of certificates with
                                                 * CLIENT_AUTH trust flag
                                                 */

   ub4 peerAuthTFcount_nzttTrustInfo;      /*!< Number of certificates with
                                                 * PEER_AUTH trust flag
                                                 */
};
/**
 * \brief Structure containing information about a persona.
 * @note
 * The wallet contains, one or more personas.  A persona always
 * contains its private key and its identity.  It may also contain
 * other 3rd party identites.  All identities qualified with trust
 * where the qualifier can indicate anything from untrusted to trusted
 * for specific operations.
 */
struct nzttPersona
{
   ub1 *genericName_nzttPersona;              /*!< user-friendly persona name  */
   ub4  genericNamelen_nzttPersona;           /*!< persona-name length */
   nzttPersonaPrivate *private_nzttPersona;   /*!< Opaque part of persona */
   nzttIdentity *mycertreqs_nzttPersona;      /*!< My cert-requests */
   nzttIdentity *mycerts_nzttPersona;         /*!< My certificates */
   nzttIdentity *mytps_nzttPersona;           /*!< List of trusted identities */
   nzssEntry *mystore_nzttPersona;            /*!< List of secrets */
   nzpkcs11_Info *mypkcs11Info_nzttPersona;   /*!< PKCS11 token info */
   struct nzttPersona *next_nzttPersona;      /*!< Next persona */
   boolean bTrustFlagEnabled_nzttPersona;     /*!< Persona supports Cert with trustflags */
   nzttTrustInfo trustinfo;                   /*!< Number of certs with C,T,P trustflag
                                               * in Persona 
                                               */
   nzpkcs12_Info *p12Info_nzttPersona;        /*!< PKCS12 Info */
};

/** Persona List */
struct nzttPersonaList
{
struct nzttPersonaList *next_nzttPersonaList;
nzttPersona * mynzttPersona;
};

/**
 * \brief Identity
 *
 * Structure containing information about an identity.
 *
 * @note
 *  -- the next_trustpoint field only applies to trusted identities and
 *     has no meaning (i.e. is NULL) for self identities.
 */
struct nzttIdentity
{
   text *dn_nzttIdentity;                      /*!< Alias */
   ub4 dnlen_nzttIdentity;                  /*!< Length of alias */
   text *frname_nzttIdentity;                   /*!< friendlyName */
   ub4 frnamelen_nzttIdentity;                  /*!< Length of friendlyName */
   text *comment_nzttIdentity;                 /*!< Comment  */
   ub4 commentlen_nzttIdentity;             /*!< Length of comment */
   nzttIdentityPrivate *private_nzttIdentity;  /*!< Opaque part of identity */
   nzttIdentity *next_nzttIdentity;            /*!< next identity in list */
};

/**
 * \brief B64 certificate
 */
struct nzttB64Cert
{
   ub1 *b64Cert_nzttB64Cert;
   ub4  b64Certlen_nzttB64Cert;
   struct nzttB64Cert *next_nzttB64Cert;
};
typedef struct nzttB64Cert nzttB64Cert;

/**
 * \brief PKCS7 protocol information
 */
struct nzttPKCS7ProtInfo
{
   nzttCipherType mictype_nzttPKCS7ProtInfo;    /*!< Hash cipher */
   nzttCipherType symmtype_nzttPKCS7ProtInfo;   /*!< Symmetric cipher */
   ub4 keylen_nzttPKCS7ProtInfo;             /*!< Length of key to use */
};
typedef struct nzttPKCS7ProtInfo nzttPKCS7ProtInfo;

/**
 * \brief Protection Information.
 *
 * Information specific to a type of protection.
 */
union nzttProtInfo
{
   nzttPKCS7ProtInfo pkcs7_nzttProtInfo;
};
typedef union nzttProtInfo nzttProtInfo;

/**
 * \brief Persona description
 *
 * A description of a persona so that the toolkit can create one.  A
 * persona can be symmetric or asymmetric and both contain an
 * identity.  The identity for an asymmetric persona will be the
 * certificate and the identity for the symmetric persona will be
 * descriptive information about the persona.  In either case, an
 * identity will have been created before the persona is created.
 *
 * A persona can be stored separately from the wallet that references
 * it.  By default, a persona is stored with the wallet (it inherits
 * with WRL used to open the wallet).  If a WRL is specified, then it
 * is used to store the actuall persona and the wallet will have a
 * reference to it.
 */
struct nzttPersonaDesc
{
   ub4 privlen_nzttPersonaDesc;        /*!< Length of private info (key)*/
   ub1 *priv_nzttPersonaDesc;             /*!< Private information */
   ub4 prllen_nzttPersonaDesc;         /*!< Length of PRL */
   text *prl_nzttPersonaDesc;             /*!< PRL for storage */
   ub4 aliaslen_nzttPersonaDesc;       /*!< Length of alias */
   text *alias_nzttPersonaDesc;           /*!< Alias */
   ub4 longlen_nzttPersonaDesc;        /*!< Length of longer description*/
   text *long_nzttPersonaDesc;            /*!< Longer persona description */
};
typedef struct nzttPersonaDesc nzttPersonaDesc;

/**
 * \brief Identity description
 * 
 * A description of an identity so that the toolkit can create one.
 * Since an identity can be symmetric or asymmetric, the asymmetric
 * identity information will not be used when a symmetric identity is
 * created.  This means the publen_nzttIdentityDesc and
 * pub_nzttIdentityDesc members will not be used when creating a
 * symmetric identity.
 */
struct nzttIdentityDesc
{
   ub4 publen_nzttIdentityDesc;        /*!< Length of identity */
   ub1 *pub_nzttIdentityDesc;             /*!< Type specific identity */
   ub4 dnlen_nzttIdentityDesc;         /*!< Length of alias */
   text *dn_nzttIdentityDesc;             /*!< Alias */
   ub4 longlen_nzttIdentityDesc;       /*!< Length of longer description */
   text *long_nzttIdentityDesc;           /*!< Longer description */
   ub4 quallen_nzttIdentityDesc;       /*!< Length of trust qualifier */
   text *trustqual_nzttIdentityDesc;      /*!< Trust qualifier */
};
typedef struct nzttIdentityDesc nzttIdentityDesc;

/********************************/
/* PUBLIC FUNCTION DECLARATIONS */
/********************************/

/*---------------------- nztwOpenWallet ----------------------*/
/**
 * @ingroup WALLET
 *  \brief  nztwOpenWallet - Open a wallet based on a wallet Resource Locator (WRL).
 * 
 *  @param [IN]      osscntxt  OSS context. 
 *  @param [IN]      wrllen    Length of WRL.
 *  @param [IN]      wrl       WRL.
 *  @param [IN]      pwdlen    Length of password.
 *  @param [IN]      pwd       Password.
 *  @param [IN/OUT]  wallet    Initialized wallet structure.   
 * 
 * 
 *  @note  The syntax for a WRL is <Wallet Type>:<Wallet Type Parameters>.
 *
 *    Wallet Type       Wallet Type Parameters.
 *    -----------       ----------------------
 *    File              Pathname (e.g. "file:/home/asriniva")
 *    Oracle            Connect string (e.g. "oracle:scott/tiger@oss")
 *
 *    There are also defaults.  If the WRL is NZT_DEFAULT_WRL, then
 *    the platform specific WRL default is used.  If only the wallet
 *    type is specified, then the WRL type specific default is used
 *    (e.g. "oracle:")
 *
 *    There is an implication with Oracle that should be stated: An
 *    Oracle based wallet can be implemented in a user's private space
 *    or in world readable space.
 *
 *    When the wallet is opened, the password is verified by hashing
 *    it and comparing against the password hash stored with the
 *    wallet.  The list of personas (and their associated identities)
 *    is built and stored into the wallet structure.
 *    
 *   @returns   NZERROR_OK           Success.<br>
 *              NZERROR_RIO_OPEN     RIO could not open wallet (see network trace file).<br>
 *              NZERROR_TK_PASSWORD  Password verification failed.<br>
 *              NZERROR_TK_WRLTYPE   WRL type is not known.<br>
 *              NZERROR_TK_WRLPARM   WRL parm does not match type.
 */
nzerror nztwOpenWallet( nzctx *, ub4, text *, ub4, text *, 
                           nzttWallet * );


/*---------------------- nztwCloseWallet ----------------------*/

/**
 * @ingroup WALLET 
 * \brief   nztwCloseWallet - Close a wallet
 * 
 * @param [IN]       osscntxt      OSS context.
 * @param [IN/OUT]   wallet        Wallet.
 * 
 * @note   Closing a wallet also closes all personas associated with that
 *         wallet.  It does not cause a persona to automatically be saved
 *         if it has changed.  The implication is that a persona can be
 *         modified by an application but if it is not explicitly saved it
 *         reverts back to what was in the wallet.
 *
 * @returns   NZERROR_OK           Success.<br>
 *            NZERROR_RIO_CLOSE    RIO could not close wallet (see network trace file).
 */
nzerror nztwCloseWallet( nzctx *, nzttWallet * );

/*--------------------nztwGetCertInfo----------------------------*/
/****NOTE: This function is a temporary hack.****/
/****DO NOT CALL.  It will soon disappear.****/
nzerror nztwGetCertInfo( nzctx *nz_context,
                            nzosContext *nzosCtx,
                            nzttWallet *walletRef,
                            void *peerCert );


/*------------------------ nztwConstructWallet -----------------------*/
/*
 * 
 * nzerror nztwConstructWallet( nzctx *oss_context,    
 *              nzttPolicy openPolicy,
 *              nzttPolicy securePolicy,
 *              ub1 *ldapName,
 *              ub4 ldapNamelen,
 *              nzstrc *wrl,
 *              nzttPersona *personas,
 *              nzttWallet **wallet );
 */

/*---------------------- nztwRetrievePersonaCopy ----------------------*/

/**
 * @ingroup WALLET
 * \brief    nztwRetrievePersonaCopy - Retrieves a persona based from wallet
 * 
 * @param [IN]   osscntxt      OSS context. 
 * @param [IN]   wallet        Wallet.
 * @param [IN]   index         Which wallet index to remove (first persona is zero).
 * @param [OUT]  persona       Persona found.
 * 
 * @note   Retrieves a persona from the wallet based on the index number passed
 *         in.  This persona is a COPY of the one stored in the wallet, therefore
 *         it is perfectly fine for the wallet to be closed after this call is 
 *         made.
 *         The caller is responsible for disposing of the persona when completed.
 *
 * @returns   NZERROR_OK           Success.
 */
nzerror nztwRetrievePersonaCopy( nzctx *, nzttWallet *, ub4, 
                           nzttPersona ** );

/**
 * \ingroup PERSONA
 * @{
 */


/*---------------------- nztwRetrievePersonaCopyByName ----------------------*/

/**
 * \brief   nztwRetrievePersonaCopyByName - Retrieves a persona based on its name.
 *
 * @param [IN]    osscntxt      OSS context.
 * @param [IN]    wallet        Wallet.
 * @param [IN]    name          Name of the persona 
 * @param [OUT]   persona       Persona found.
 *
 * @note   Retrieves a persona from the wallet based on the name of the persona. 
 *         This persona is a COPY of the one stored in the wallet, therefore
 *         it is perfectly fine for the wallet to be closed after this call is
 *         made.
 *         The caller is responsible for disposing of the persona when completed.
 *
 * @returns   NZERROR_OK           Success.
 */
nzerror nztwRetrievePersonaCopyByName( nzctx *, nzttWallet *, char *,
                           nzttPersona ** );

/*---------------------- nzteOpenPersona ----------------------*/

/**
 * \brief   nzteOpenPersona - Open a persona.
 * 
 * @param [IN]       osscntxt   OSS context. 
 * @param [IN/OUT]   persona    Persona.
 * 
 * @note
 *    
 * @returns    NZERROR_OK           Success.<br>
 *             NZERROR_TK_PASSWORD  Password failed to decrypt persona.<br>
 *             NZERROR_TK_BADPRL    Persona resource locator did not work.<br>
 *             NZERROR_RIO_OPEN     Could not open persona (see network trace file).
 */
nzerror nzteOpenPersona( nzctx *, nzttPersona * );

/*--------------------- nzteClosePersona ---------------------*/

/**
 * \brief   nzteClosePersona - Close a persona.
 * 
 * @param [IN]       osscntxt  OSS context.
 * @param [IN/OUT]   persona   Persona.
 * 
 * @note    Closing a persona does not store the persona, it simply releases
 *          the memory associated with the crypto engine.
 *    
 * @returns   NZERROR_OK        Success.
 */
nzerror nzteClosePersona( nzctx *, nzttPersona * );

/*--------------------- nzteDestroyPersona ---------------------*/

/**
 * \brief   nzteDestroyPersona - Destroy a persona.
 * 
 * @param [IN]       osscntxt     OSS context.
 * @param [IN/OUT]   persona      Persona.
 * 
 * @note   The persona is destroyd in the open state, but it will
 *         not be associated with a wallet.<br>
 *         The persona parameter is doubly indirect so that at the
 *         conclusion of the function, the pointer can be set to NULL.
 *
 *
 * @returns   NZERROR_OK        Success.<br>
 *            NZERROR_TK_TYPE   Unsupported itype/ctype combination.<br>
 *            NZERROR_TK_PARMS  Error in persona description.
 */
nzerror nzteDestroyPersona( nzctx *, nzttPersona ** );

/*---------------------- nzteRetrieveTrustedIdentCopy ----------------------*/

/**
 *  \brief  nzteRetrieveTrustedIdentCopy - Retrieves a trusted identity from persona
 * 
 *  @param  osscntxt [IN]     OSS context. 
 *  @param  persona  [IN]     Persona.
 *  @param  index    [IN]     Which wallet index to remove (first element is zero).
 *  @param  identity [OUT]    Trusted Identity from this persona.
 * 
 * @note
 *    Retrieves a trusted identity from the persona based on the index 
 *    number passed in.  This identity is a COPY of the one stored in 
 *    the persona, therefore it is perfectly fine to close the persona
 *    after this call is made.
 *
 *    The caller is responsible for freeing the memory of this object 
 *    by calling nztiAbortIdentity it is no longer needed
 *
 * @return
 *    NZERROR_OK           Success.
 */
nzerror nzteRetrieveTrustedIdentCopy( nzctx *, nzttPersona *, ub4, 
                           nzttIdentity ** );

/*--------------------- nztePriKey ---------------------*/

/**
 * \brief   nztePriKey - Get the decrypted Private Key for the Persona
 * 
 * @param  osscntxt [IN]     OSS context.
 * @param  persona  [IN]     Persona.
 * @param  vkey     [OUT]    Private Key [B_KEY_OBJ]
 * @param  vkey_len [OUT]    Private Key Length
 * 
 * @note
 *    This funiction will only work for X.509 based persona which contain
 *    a private key.  
 *    A copy of the private key is returned to the caller so that they do not 
 *    have to worry about the key changeing "underneath them".
 *    Memory will be allocated for the vkey and therefore, the CALLER
 *    will be responsible for freeing this memory.
 *
 * @returns
 *    NZERROR_OK           Success.
 *    NZERROR_NO_MEMORY    ossctx is null.
 *    NZERROR_TK_BADPRL    Persona resource locator did not work.
 */
nzerror nztePriKey( nzctx *, nzttPersona *, ub1 **, ub4 * );

/*--------------------- nzteMyCert ---------------------*/

/**
 * \brief   nzteMyCert - Get the X.509 Certificate for a persona
 * 
 * @param   osscntxt [IN]     OSS context.
 * @param   persona  [IN]     Persona.
 * @param   cert     [OUT]    X.509 Certificate [BER encoded]
 * @param   cert_len [OUT]    Certificate length
 * 
 * @note
 *    This funiction will only work for X.509 based persona which contain
 *    a certificate for the self identity. 
 *    A copy of the certificate is returned to the caller so that they do not 
 *    have to worry about the certificate changeing "underneath them".
 *    Memory will be allocated for the cert and therefore, the CALLER
 *    will be responsible for freeing this memory.
 *
 * @returns
 *    NZERROR_OK           Success.
 *    NZERROR_NO_MEMORY    ossctx is null.
 */
nzerror nzteMyCert( nzctx *, nzttPersona *, ub1 **, ub4 * );


/**
 * @}
 */

/**
 * \ingroup IDENTITY
 * @{
 */

/*--------------------- nztiAbortIdentity ---------------------*/

/**
 * \brief    nztiAbortIdentity - Abort an unassociated identity.
 * 
 * @param   osscntxt [IN]     OSS context.
 * @param   identity [IN/OUT] Identity.
 * 
 * @note
 *    It is an error to try to abort an identity that can be
 *    referenced through a persona.
 *    
 *    The identity pointer is set to NULL at the conclusion.
 * 
 * @returns
 *    NZERROR_OK           Success.
 *    NZERROR_CANTABORT    Identity is associated with persona.
 */
nzerror nztiAbortIdentity( nzctx *, nzttIdentity ** );

/*--------------------- nztiGetSecInfo ---------------------*/

/**
 * @ingroup PERSONA
 * \brief   nztiGetSecInfo - Get some security information for SSL
 * 
 * @param      osscntxt [IN]        OSS context.
 * @param      persona  [IN]        persona
 * @param      dname    [OUT]       distinguished name of the certificate
 * @param      dnamelen [OUT]       length of the distinguished name 
 * @param      issuername [OUT]     issuer name of the certificate
 * @param      certhash [OUT]       SHA1 hash of the certificate
 * @param      certhashlen[OUT]     length of the hash
 *
 * @note
 *    This function allocate memories for issuername, certhash, and dname.
 *   To deallocate memory for those params, you should call nztdbuf_DestroyBuf.
 * @returns
 *    
 */
nzerror nztiGetSecInfo( nzctx *, nzttPersona *, text **, ub4 *,
            text **, ub4 *, ub1 **, ub4 * );

/*-------------------- nztgch_GetCertHash --------------------*/

/*
 * nztgch_GetCertHash -  Get SHA1 hash for the certificate of the identity 
 * 
 *  osscntxt [IN]        OSS context.
 *  identity [IN]        identity need to get issuername from
 *  certHash [OUT]       certHash buffer 
 *  hashLen  [OUT]       length of the certHash 
 * 
 * NOTE
 *    Need to call nztdbuf_DestroyBuf to deallocate memory for certHash.   
 * RETURNS
 *    
 */
nzerror nztgch_GetCertHash( nzctx *, const nzttIdentity *,
              ub1 **, ub4 * );

/*----------------------- nztCompareDN -----------------------*/

/**
 * \brief   nztCompareDN
 * 
 * @param   osscntxt   [IN]      OSS context.
 * @param   dn1        [IN]      distinguished name 1
 * @param   dn2        [IN]      distinguished name 2
 * 
 * @note
 *    
 * @returns
 *    NZERROR_OK       succeeded
 *   others         failed
 *    
 */
nzerror nztCompareDN( nzctx *, ub1 *,ub4 ,  ub1 *, ub4, boolean * );

/*---------------- nztiee_IsEncrEnabled ----------------*/
/**
 *
 * \brief
 *  nztiee_IsEncrEnabled -  Checks to see if Encryption is Enabled
 *                               in the current Cipher Spec.
 * 
 *   @param ctx   [IN]   Oracle SSL Context
 *   @param ncipher [IN]    CipherSuite
 *   @param EncrEnabled [OUT] Boolean for is Auth Enabled?
 * 
 * @note
 *    
 * @returns
 *      NZERROR_OK on success.
 *      NZERROR_TK_INV_CIPHR_TYPE if Cipher Spec is not Recognized.
 */

nzerror nztiee_IsEncrEnabled( nzctx *ctx, 
                                  ub2 ncipher, 
                                  boolean *EncrEnabled );

/*---------------- nztGetIssuerName ----------------*/
/**
 * @ingroup IDENTITY
 * \brief
 *  nztGetIssuerName - Get Issuer Name from an Identity
 *     
 *   @param ctx          [IN]   Oracle SSL Context
 *   @param identity     [IN]   Identity
 *   @param issuername   [OUT]  Issuername
 *   @param issernamelen [OUT]  Issuername lenght 
 *
 *   @note
 * 
 *   @returns
 *     NZERROR_OK on success.
 *
 */
nzerror nztGetIssuerName( nzctx *ctx,
                             nzttIdentity *identity,
                             ub1  **issuername,
                             ub4   *issuernamelen );
/**
 * @ingroup IDENTITY
 * \brief
 *  nztGetSubjectName - Get Subject Name from an Identity
 *  
 *   @param ctx            [IN]   Oracle SSL Context
 *   @param identity       [IN]   Identity
 *   @param subjectname    [OUT]  subjectname
 *   @param subjectnamelen [OUT]  subjectname
 *         
 *  @note
 *
 *   @returns
 *    NZERROR_OK on success.
 *
 */

nzerror nztGetSubjectName( nzctx *ctx,
                              nzttIdentity *identity,
                              ub1  **subjectname,
                              ub4   *subjectnamelen );
/**
 * @ingroup IDENTITY
 * \brief
 *  nztGetBase64Cert - Get BASE64 encoded certificate from an identity
 *    
 *  @param ctx            [IN]   Oracle SSL Context
 *  @param identity       [IN]   Identity
 *  @param b64cert        [OUT]  b64cert
 *  @param b64certlen     [OUT]  b64certlen
 *
 *  @note
 *
 *  @returns
 *   NZERROR_OK on success.
 *
 **/

nzerror nztGetBase64Cert( nzctx *ctx,
                              nzttIdentity *identity,
                              ub1  **b64cert,
                              ub4   *b64certlen );
/**
 * @ingroup IDENTITY
 * \brief
 *  nztGetBase64Cert - Get Serial Number from an identity
 *  
 *  @param ctx            [IN]   Oracle SSL Context
 *  @param identity       [IN]   Identity
 *  @param serialnum      [OUT]  serialnum
 *  @param serialnumlen   [OUT]  serialnumlen
 *  
 *  @note
 *        
 *  @returns
 *    NZERROR_OK on success.
 *   
 */

nzerror nztGetSerialNumber( nzctx *ctx,
                              nzttIdentity *identity,
                              ub1   **serialnum,
                              ub4    *serialnumlen );
/**
 * \brief
 *  nztSS_Serialnum_to_String - Convert Serial Number to String
 *
 *  @param ctx            [IN]   Oracle SSL Context
 *  @param pserialnum     [IN]   SerialnumIdentity
 *  @param pCertserial    [OUT]  Serial num string
 *  @param certseriallen  [OUT]  certseriallen
 *
 *  @note
 *
 * @returns
 *    NZERROR_OK on success.
 *
 */

nzerror nztSS_Serialnum_to_String( nzctx* ctx,
                                    nzstrc *pSerialNum,
                                    ub1 *pCertserial,
                                    ub4 certseriallen);
/**
 * @ingroup IDENTITY
 * \brief
 *  nztGetValidDate - Convert Serial Number to String
 *
 *  @param ctx            [IN]   Oracle SSL Context
 *  @param identity       [IN]   Identity
 *  @param startdate      [OUT]  Start Date
 *  @param enddate        [OUT]  End Date
 *
 *  @note
 *
 * @returns
 *    NZERROR_OK on success.
 *
 */

nzerror nztGetValidDate( nzctx *ctx,
                            nzttIdentity *identity,
                            ub4  *startdate, 
                            ub4  *enddate  );

nzerror nztGetValidDate_ext( nzctx *ctx,
                            nzttIdentity *identity,
                            ub8  *startdate,
                            ub8  *enddate  );

nzerror nztGetDateTime(
        nzctx *nz_context,
        nzttIdentity *p_identity,
        nzdpTimeDate *startdate,
        nzdpTimeDate *enddate);

/**
 * @ingroup IDENTITY
 * \brief
 *   nztGetVersion - Get Version for Identity 
 *
 *   @param ctx       [IN] Oracle SSL Context
 *   @param identity  [IN] identity
 *   @param pVerStr   [IN] Identity Version
 *
 *   @note
 *
 *   @returns
 *     NZERROR_OK on success
 *
 */ 

nzerror nztGetVersion( nzctx *ctx,
                          nzttIdentity *identity,
                          nzstrc *pVerStr  );

/**
 * @ingroup IDENTITY
 * \brief
 *  nztGetBase64Cert - Get Serial Number from an identity
 *
 *  @param ctx            [IN]   Oracle SSL Context
 *  @param identity       [IN]   Identity
 *  @param pubKey         [OUT]  public key
 *  @param pubKeylen      [OUT]  public key len
 *
 *  @note
 *
 *  @returns
 *    NZERROR_OK on success.
 *
 */

nzerror nztGetPublicKey( nzctx *ctx,
                            nzttIdentity *identity,
                            ub1  **pubKey,
                            ub4   *pubKeylen );

nzerror nztGetPublicKeyNew(
        nzctx *nz_context,
        nzttIdentity *p_identity,
        ub1 **pubkey,
        ub4  *pubkeylen,
        text *mode);

nzerror nztGenericDestroy( nzctx *ctx,
                              ub1  **var );

nzerror nztSetAppDefaultLocation( nzctx *ctx,
                                     text *,
                                     size_t );

nzerror nztSearchNZDefault( nzctx *ctx,
                            boolean *search );

nzerror nztSetLightWeight(nzctx *ctx,
                          boolean flag);

/* ****************** nzICE_Install_Cert_ext ****************** */
/**
 * @ingroup WALLET_CERTIFICATE
 * \brief
 *   nzICE_Install_Cert_ext - Installs a Cert into a wallet if it meets certain conditions.
 * 
 *  @param oss_context     [IN]
 *  @param pWallet         [IN]
 *  @param pPersona        [IN]
 *  @param pCertbuf        [IN]
 *  @param certbuflen      [IN]
 *  @param certtype        [IN]
 *  @param pIdtypestr      [IN]
 *  @param trustflag       [IN]
 *
 * @note
 *
 * It calls the function  nztnAC_Add_Certificate().
 * Finally, it returns a ptr to where the actual object has been added into the
 * wallet. This is used in support of OWM
 * This is an extention of nztnIC_Install_Cert to support Trust flag.
 *
 */
nzerror nzICE_Install_Cert_ext( nzctx *oss_context,
                                    nzttWallet *pWallet,
                                    nzttPersona *pPersona,
                                    ub1* pCertbuf,
                                    ub4 certbuflen,
                                    boolean certtype,
                                    nzstrc *pIdtypestr,
                                    nzTrustFlag trustflag,
                                    nzttIdentity **ppCertOrTP );

/******************** nzMF_Modify_TrustFlags **************************/
/**
 * @ingroup WALLET_TRUSTFLAG
 *\brief 
 *   nzMF_Modify_TrustFlags -  Modifies trust flags assigned to a certificate
 *
 *   @param oss_context [IN]
 *   @param pWallet     [IN]
 *   @param pPersona    [IN]
 *   @param pCert       [IN]
 *   @param trustflag   [IN] 
 * 
 * @note
 *
 * This function would be used to modify trust flags assigned
 * to a certificate. The already assigned trust flag would get replaced
 * by new trust flag value
*/

nzerror nzMF_Modify_TrustFlags(nzctx *oss_context,
                                  nzttWallet *pWallet,
                                  nzttPersona *pPersona,
                                  nzttIdentity *pCert,
                                  int trustflag);

/**
 * @ingroup IDENTITY
 * \brief nztiFBL_Free_B64Cert_List
 * Destroy the contents of nzttB64Cert.
 *
 *
 * @param   nzctx               [IN]   nz_context
 * @param   nzttB64Cert         [OUT]  pp_b64Certlist
 *
 * @note
 *
 * @return
 *      NZERROR_OK
 *      NZERROR_INVALID_INPUT
 *      NZERROR_NOT_INITIALIZED
 */

nzerror nztiFBL_Free_B64Cert_List( nzctx *nz_context,
                                      nzttB64Cert **pp_b64Certlist );

/**
 * @} 
 *
 * */

/*------------------- nztwAW_Allocate_Wallet -------------------*/
/**
 *
 * \brief nztwAW_Allocate_Wallet
 * Allocate memory to wallet
 *
 *
 * @param   nzctx               [IN]     nz context.
 * @param   nzttWallet          [OUT]     wallet
 *
 * @note
 *
 * @return
 *    NZERROR_OK        Success.
 */
nzerror nztwAW_Allocate_Wallet( nzctx *nz_context,
                                   nzttWallet **Wallet );

/*----------------- nztwDWC_Duplicate_Wallet_Contents ------------------*/
/**
 *
 * \brief nztwDWC_Duplicate_Wallet_Contents
 * Duplicate nzttWallet source to nzttWallet target, copy ldapdn, policies, persona, nzttWalletPrivate
 *
 *
 * @param   nzctx               [IN]     nz context.
 * @param   nzttWallet          [IN]     p_sourceWallet
 * @param   nzttWallet          [OUT]    pp_targetWallet
 *
 * @note
 *
 * @return
 *    NZERROR_OK        Success.
 */
nzerror nztwDWC_Duplicate_Wallet_Contents( nzctx *nz_context,
                                              nzttWallet *p_sourceWallet,
                                              nzttWallet *pp_targetWallet );

/*---------------------- nztwGPP_Get_Personalist_Ptr ----------------------*/
/**
 *
 * \brief nztwGPP_Get_Personalist_Ptr
 * get pointer of list of nzttPersona from wallet
 *
 *
 * @param   nzctx               [IN]     nz context.
 * @param   nzttWallet          [IN]     Wallet
 * @param   nzttPersona         [OUT]    personalist
 *
 * @note
 *
 * @return
 *    NZERROR_OK        Success.
 */
nzerror nztwGPP_Get_Personalist_Ptr( nzctx *nz_context,
                                        nzttWallet *p_wallet,
                                        nzttPersona **pp_persona );

/* ****************** nztwLCW_Load_or_Create_Wallet ****************** */
/**
 *
 * \brief nztwLCW_Load_or_Create_Wallet
 * Load the wallet from the encrypted file and if failed to load then create a new  one
 *
 *
 * @param   nzctx               [IN]     oss_context
 * @param   nzstrc              [IN]     pUserpath
 * @param   nzstrc              [IN]     pPassword
 * @param   nzttWallet  [OUT]    ppWallet
 *
 * @note
 *
 * @return
 *    NZERROR_OK        Success.
 */
nzerror nztwLCW_Load_or_Create_Wallet(  nzctx *oss_context,
                                         nzstrc *pUserpath,
                                         nzstrc *pPassword,
                                         nzttWallet **ppWallet );

/******************** nztwLW_Load_Wallet  ******************/
/**
 *
 * \brief nztwLW_Load_Wallet
 * Load a wallet struct from the encrypted file
 *
 *
 * @param   nzctx                       [IN]     oss_context
 * @param   nzstrc                      [IN]     pWrl
 * @param   nzstrc                      [IN]     pPwd
 * @param   nzttWallet                  [OUT]    ppWallet
 *
 * @note
 * Load a wallet struct from the encrypted file.
 * NOTE: this is  similar to nztOpenWallet except:
 * (1) outarg is **ppWallet instead of *pWallet
 * (2) It doesn't bother trying to open clrwallet. No point doing
 *     that when you are in an interactive tool where you can get pwd.
 * (3) It doesn't call nztGetCertChain() <<==== THIS COULD CAUSE SSL failures.
 *     So see if we can modify the SSL code to call nztGetCertChain as needed
 *     or worst case just call it here too.
 *
 *
 * @return
 *    NZERROR_OK        Success.
 */
nzerror nztwLW_Load_Wallet(  nzctx *oss_context,
                              nzstrc *pWrl,
                              nzstrc *pPwd,
                              nzttWallet **ppWallet );

/* ------------------------ nztwSCW_Store_Clear_Wallet --------------- */
/**
 *
 * \brief nztwSCW_Store_Clear_Wallet
 * Stores a Clear Wallet Blob
 *
 *
 * @param   nzctx               [IN]     oss_context
 * @param   nzttWallet          [IN]     pWallet
 * @param   nzstrc              [IN]     pWrl
 * @param   nzstrc              [IN]     pPwd
 *
 * @note
 *
 * @return
 *    NZERROR_OK        Success.
 */
nzerror nztwSCW_Store_Clear_Wallet( nzctx *oss_context, nzttWallet *pWallet,
                                     nzstrc *pWrl,
                                     nzstrc *pPwd );

/**
 *
 * \brief nztwSCW_Store_Local_Wallet
 * Stores a Clear Wallet Blob
 *
 *
 * @param   nzctx               [IN]     oss_context
 * @param   nzttWallet          [IN]     pWallet
 * @param   nzstrc              [OUT]    pWrl
 * @param   nzstrc              [OUT]    pPwd
 *
 * @note
 *
 * @return
 *    NZERROR_OK        Success.
 */
nzerror nztwSCW_Store_Local_Wallet( nzctx *oss_context, nzttWallet *pWallet,
                                     nzstrc *pWrl,
                                     nzstrc *pPwd );

/*------------------- nztiGDN_Get_DName -------------------------*/

/**
 * @ingroup IDENTITY
 * \brief nztiGDN_Get_DName Get dn and dnlen from nzcontext and identity
 *
 *
 *
 * @param   nzctx               [IN]     nz context.
 * @param   nzttIdentity        [IN]     p_identity
 * @param   ub1                 [OUT]    dn
 * @param   ub4`                [OUT]    dn length
 *
 * @note
 *
 * @return
 *    NZERROR_OK        Success.
 */
nzerror nztiGDN_Get_DName( nzctx *nz_context,
                              const nzttIdentity *p_identity,
                              ub1 **dn,
                              ub4 *dnlen );

/*---------------- nztwFWC_Free_Wallet_Contents ----------------*/
/**
 *
 * \brief nztwFWC_Free_Wallet_Contents
 * Free and destroy the contents of nzttWallet like ldapdn, policies, persona, nzttWalletPrivate
 *
 *
 * @param   nzctx               [IN]     nz context.
 * @param   nzttWallet          [IN]     wallet
 *
 * @note
 *
 * @return
 *    NZERROR_OK        Success.
 */
nzerror nztwFWC_Free_Wallet_Contents( nzctx *nz_context,
                                         nzttWallet *Wallet );

/* ****************** nztnIC_Install_Cert ****************** */
/**
 *
 * \brief nztnIC_Install_Cert - Installs a Cert into a wallet if it meets certain conditions.
 *
 * It calls the function  nztnAC_Add_Certificate().
 * Finally, it returns a ptr to where the actual object has been added into the
 * wallet. This is used in support of OWM.
 *
 * @param oss_context  [IN]
 * @param pWallet      [IN]
 * @param pPersona     [IN]
 * @param pCertbuf     [IN]
 * @param certbuflen   [IN]
 * @param pIdtypestr   [IN]
 * @param ppCertOrTP   [OUT]
 *
 * @note
 *
 * @returns
 *
 */
nzerror nztnIC_Install_Cert(  nzctx *oss_context,
                                    nzttWallet *pWallet,
                                    nzttPersona *pPersona,
                                    ub1* pCertbuf,
                                    ub4 certbuflen,
                                    nzstrc *pIdtypestr );

#endif /* NZT_ORACLE */

