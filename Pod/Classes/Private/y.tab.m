/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton implementation for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output.  */
#define YYBISON 1

/* Bison version.  */
#define YYBISON_VERSION "2.3"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Using locations.  */
#define YYLSP_NEEDED 1



/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     SHARED_BINDING_IDENTIFIER = 258,
     IDENTIFIER = 259,
     STRING_LITERAL = 260,
     INTEGER_LITERAL = 261,
     STRING_CONSTANT = 262,
     SEP = 263,
     SEMI = 264,
     COLON = 265,
     COMMA = 266,
     LPAREN = 267,
     RPAREN = 268,
     LBRACE = 269,
     RBRACE = 270,
     DOT = 271,
     PLUS = 272,
     TIC = 273,
     PIPE = 274,
     ADAPTER = 275,
     URL_BINDINGS = 276,
     SHARED_BINDINGS = 277,
     URL_BINDING = 278,
     BASE_URL = 279,
     HEADER_FIELDS = 280,
     TIMEOUT_INTERVAL = 281,
     LIFECYCLE = 282,
     LIFECYCLE_STYLE = 283,
     REQUEST_METHOD = 284,
     REQUEST_FORMAT = 285,
     END_POINT = 286,
     END_POINT_PARAMETERS = 287,
     CMO_BINDING = 288,
     BINDING_OPTIONS = 289,
     ONE_TO_ONE = 290,
     ONE_TO_MANY = 291,
     UNORDERED = 292,
     ORDERED = 293,
     ENTITIES = 294,
     ATTRIBUTES = 295,
     ALL = 296,
     ALL_EXCEPT = 297,
     LOGIN = 298,
     LOGOUT = 299,
     PASSWORD_RESET = 300,
     CREATE = 301,
     UPDATE = 302,
     DESTROY = 303,
     RETRIEVE_SERVER_RECORD = 304,
     RETRIEVE_SERVER_RECORDS = 305,
     RETRIEVE_SERVER_RECORD_COUNT = 306,
     RETRIEVE_RELATIONSHIP = 307,
     JSON = 308,
     WEBFORM = 309,
     NO_DATA = 310,
     GET = 311,
     POST = 312,
     PUT = 313,
     DELETE = 314,
     JSON_WRAPPER_KEY = 315,
     JSON_RECEIVE_WRAPPER_KEY = 316,
     JSON_SEND_WRAPPER_KEY = 317,
     BULK_WRAPPER_KEY = 318,
     ATTRIBUTE_BINDINGS = 319,
     ID_ATTRIBUTE = 320,
     RECEIVE_ONLY_ATTRIBUTE = 321,
     SEND_ONLY_ATTRIBUTE = 322,
     RELATIONSHIP_BINDINGS = 323,
     RELATIONSHIP_BINDING = 324,
     JSON_BINDING = 325,
     JSON_ID_BINDING = 326,
     RELATIONSHIPS = 327
   };
#endif
/* Tokens.  */
#define SHARED_BINDING_IDENTIFIER 258
#define IDENTIFIER 259
#define STRING_LITERAL 260
#define INTEGER_LITERAL 261
#define STRING_CONSTANT 262
#define SEP 263
#define SEMI 264
#define COLON 265
#define COMMA 266
#define LPAREN 267
#define RPAREN 268
#define LBRACE 269
#define RBRACE 270
#define DOT 271
#define PLUS 272
#define TIC 273
#define PIPE 274
#define ADAPTER 275
#define URL_BINDINGS 276
#define SHARED_BINDINGS 277
#define URL_BINDING 278
#define BASE_URL 279
#define HEADER_FIELDS 280
#define TIMEOUT_INTERVAL 281
#define LIFECYCLE 282
#define LIFECYCLE_STYLE 283
#define REQUEST_METHOD 284
#define REQUEST_FORMAT 285
#define END_POINT 286
#define END_POINT_PARAMETERS 287
#define CMO_BINDING 288
#define BINDING_OPTIONS 289
#define ONE_TO_ONE 290
#define ONE_TO_MANY 291
#define UNORDERED 292
#define ORDERED 293
#define ENTITIES 294
#define ATTRIBUTES 295
#define ALL 296
#define ALL_EXCEPT 297
#define LOGIN 298
#define LOGOUT 299
#define PASSWORD_RESET 300
#define CREATE 301
#define UPDATE 302
#define DESTROY 303
#define RETRIEVE_SERVER_RECORD 304
#define RETRIEVE_SERVER_RECORDS 305
#define RETRIEVE_SERVER_RECORD_COUNT 306
#define RETRIEVE_RELATIONSHIP 307
#define JSON 308
#define WEBFORM 309
#define NO_DATA 310
#define GET 311
#define POST 312
#define PUT 313
#define DELETE 314
#define JSON_WRAPPER_KEY 315
#define JSON_RECEIVE_WRAPPER_KEY 316
#define JSON_SEND_WRAPPER_KEY 317
#define BULK_WRAPPER_KEY 318
#define ATTRIBUTE_BINDINGS 319
#define ID_ATTRIBUTE 320
#define RECEIVE_ONLY_ATTRIBUTE 321
#define SEND_ONLY_ATTRIBUTE 322
#define RELATIONSHIP_BINDINGS 323
#define RELATIONSHIP_BINDING 324
#define JSON_BINDING 325
#define JSON_ID_BINDING 326
#define RELATIONSHIPS 327




/* Copy the first part of user declarations.  */
#line 1 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"

//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 FOS Services, LLC
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

// NOTE: ***
//
// At this time there's a bug in CocoaPods (https://github.com/CocoaPods/CocoaPods/issues/3127)
// where it will pass CFLAGS to flex/bison, which causes compilation to fail.  Thus, the .[ch]
// files are also checked in, which are used to build the actual lexer and compiler.
//
// Any modification made to this file will necessitate the manual re-generation of the .[ch]
// files from these sources.
//
// NOTE: ***

    #include <stdio.h>
    #include <stdlib.h>

    #import "FOSAdapterBinding.h"
    #import "FOSREST_Internal.h"

    extern void yyerror(char* s, ...);
    extern int yylex();

    // Referenced/managed by FOSAdapterBindingParser
    FOSAdapterBinding *parserAdapterBinding = nil;
    id<fosrestServiceAdapter> parsedServiceAdapter;
    id parsedBinding;

    #undef YYMAXDEPTH
    #define YYMAXDEPTH 900000

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wconversion"
#pragma clang diagnostic ignored "-Wunused-function"
#pragma clang diagnostic ignored "-Wunneeded-internal-declaration"

// Bison doesn't like '@' symbols in the source
#define AT_ @

#define CAPTURE_ORDERED_VAL(result, val)  result = ((__bridge void *)[NSMutableArray arrayWithObject:(__bridge id)(val)])
#define COMBINE_ORDERED_VALS(result, val) {\
    if (![(__bridge id)(result) isKindOfClass:[NSMutableArray class]]) { \
        result = (__bridge void *)[NSMutableArray array]; \
    } \
\
    NSMutableArray *array = (__bridge NSMutableArray *)(result); \
    [array addObject:(__bridge id)(val)]; \
}
#define COMBINE_ORDERED_VALS2(result, val1, val2) {\
    BOOL isNew = NO; \
    if (![(__bridge id)(result) isKindOfClass:[NSMutableArray class]]) { \
        result = (__bridge void *)[NSMutableArray array]; \
        isNew = YES; \
    } \
\
    NSMutableArray *array = (__bridge NSMutableArray *)(result); \
    if (!isNew) { [array addObject:(__bridge id)(val2)]; } \
    [array addObject:(__bridge id)(val1)]; \
}

#define CAPTURE_UNORDERED_VAL(result, val)  result = ((__bridge void *)[NSMutableSet setWithObject:(__bridge id)(val)])
#define COMBINE_UNORDERED_VALS(result, val) {\
    if (![(__bridge id)(result) isKindOfClass:[NSSet class]]) { \
        result = (__bridge void *)[NSMutableSet set]; \
    } \
\
    NSMutableSet *set = (__bridge NSMutableSet *)(result); \
    [set addObject:(__bridge id)(val)]; \
}

#define CAPTURE_ATOM_INFO(atomNameStr, loc, atom) {\
    ((__bridge id<FOSCompiledAtomInfo>)(atom)).atomStartLineNum = (loc).first_line; \
    ((__bridge id<FOSCompiledAtomInfo>)(atom)).atomStartColNum = (loc).first_column; \
    ((__bridge id<FOSCompiledAtomInfo>)(atom)).atomName = (atomNameStr); \
    ((__bridge id<FOSCompiledAtomInfo>)(atom)).serviceAdapter = (parsedServiceAdapter); \
}



/* Enabling traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif

/* Enabling verbose error messages.  */
#ifdef YYERROR_VERBOSE
# undef YYERROR_VERBOSE
# define YYERROR_VERBOSE 1
#else
# define YYERROR_VERBOSE 0
#endif

/* Enabling the token table.  */
#ifndef YYTOKEN_TABLE
# define YYTOKEN_TABLE 0
#endif

#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 102 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
{
	char *string;
    FOSLifecyclePhase lifecyclePhase;
    FOSRequestMethod requestMethod;
    FOSRequestFormat requestFormat;
    FOSBindingOptions bindingOptions;
    void *object;
}
/* Line 193 of yacc.c.  */
#line 350 "/Users/david/Library/Developer/Xcode/DerivedData/FOSREST-fodkpoehriibrldqgafemiosbmld/Build/Intermediates/Pods.build/Debug-iphonesimulator/Pods-FOSRESTApp-fosrest.build/DerivedSources/y.tab.c"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

#if ! defined YYLTYPE && ! defined YYLTYPE_IS_DECLARED
typedef struct YYLTYPE
{
  int first_line;
  int first_column;
  int last_line;
  int last_column;
} YYLTYPE;
# define yyltype YYLTYPE /* obsolescent; will be withdrawn */
# define YYLTYPE_IS_DECLARED 1
# define YYLTYPE_IS_TRIVIAL 1
#endif


/* Copy the second part of user declarations.  */


/* Line 216 of yacc.c.  */
#line 375 "/Users/david/Library/Developer/Xcode/DerivedData/FOSREST-fodkpoehriibrldqgafemiosbmld/Build/Intermediates/Pods.build/Debug-iphonesimulator/Pods-FOSRESTApp-fosrest.build/DerivedSources/y.tab.c"

#ifdef short
# undef short
#endif

#ifdef YYTYPE_UINT8
typedef YYTYPE_UINT8 yytype_uint8;
#else
typedef unsigned char yytype_uint8;
#endif

#ifdef YYTYPE_INT8
typedef YYTYPE_INT8 yytype_int8;
#elif (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
typedef signed char yytype_int8;
#else
typedef short int yytype_int8;
#endif

#ifdef YYTYPE_UINT16
typedef YYTYPE_UINT16 yytype_uint16;
#else
typedef unsigned short int yytype_uint16;
#endif

#ifdef YYTYPE_INT16
typedef YYTYPE_INT16 yytype_int16;
#else
typedef short int yytype_int16;
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif ! defined YYSIZE_T && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned int
# endif
#endif

#define YYSIZE_MAXIMUM ((YYSIZE_T) -1)

#ifndef YY_
# if defined YYENABLE_NLS && YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(msgid) dgettext ("bison-runtime", msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(msgid) msgid
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YYUSE(e) ((void) (e))
#else
# define YYUSE(e) /* empty */
#endif

/* Identity function, used to suppress warnings about constant conditions.  */
#ifndef lint
# define YYID(n) (n)
#else
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static int
YYID (int i)
#else
static int
YYID (i)
    int i;
#endif
{
  return i;
}
#endif

#if ! defined yyoverflow || YYERROR_VERBOSE

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#     ifndef _STDLIB_H
#      define _STDLIB_H 1
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's `empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (YYID (0))
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined _STDLIB_H \
       && ! ((defined YYMALLOC || defined malloc) \
	     && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef _STDLIB_H
#    define _STDLIB_H 1
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* ! defined yyoverflow || YYERROR_VERBOSE */


#if (! defined yyoverflow \
     && (! defined __cplusplus \
	 || (defined YYLTYPE_IS_TRIVIAL && YYLTYPE_IS_TRIVIAL \
	     && defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yytype_int16 yyss;
  YYSTYPE yyvs;
    YYLTYPE yyls;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (yytype_int16) + sizeof (YYSTYPE) + sizeof (YYLTYPE)) \
      + 2 * YYSTACK_GAP_MAXIMUM)

/* Copy COUNT objects from FROM to TO.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(To, From, Count) \
      __builtin_memcpy (To, From, (Count) * sizeof (*(From)))
#  else
#   define YYCOPY(To, From, Count)		\
      do					\
	{					\
	  YYSIZE_T yyi;				\
	  for (yyi = 0; yyi < (Count); yyi++)	\
	    (To)[yyi] = (From)[yyi];		\
	}					\
      while (YYID (0))
#  endif
# endif

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack)					\
    do									\
      {									\
	YYSIZE_T yynewbytes;						\
	YYCOPY (&yyptr->Stack, Stack, yysize);				\
	Stack = &yyptr->Stack;						\
	yynewbytes = yystacksize * sizeof (*Stack) + YYSTACK_GAP_MAXIMUM; \
	yyptr += yynewbytes / sizeof (*yyptr);				\
      }									\
    while (YYID (0))

#endif

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  54
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   280

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  73
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  63
/* YYNRULES -- Number of rules.  */
#define YYNRULES  141
/* YYNRULES -- Number of states.  */
#define YYNSTATES  291

/* YYTRANSLATE(YYLEX) -- Bison symbol number corresponding to YYLEX.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   327

#define YYTRANSLATE(YYX)						\
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[YYLEX] -- Bison symbol number corresponding to YYLEX.  */
static const yytype_uint8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    48,    49,    50,    51,    52,    53,    54,
      55,    56,    57,    58,    59,    60,    61,    62,    63,    64,
      65,    66,    67,    68,    69,    70,    71,    72
};

#if YYDEBUG
/* YYPRHS[YYN] -- Index of the first RHS symbol of rule number YYN in
   YYRHS.  */
static const yytype_uint16 yyprhs[] =
{
       0,     0,     3,     4,     6,     8,    10,    12,    14,    16,
      18,    20,    22,    24,    26,    28,    30,    32,    34,    36,
      38,    40,    47,    51,    56,    58,    61,    80,    85,    87,
      90,    94,    99,   100,   105,   113,   120,   122,   124,   126,
     128,   130,   132,   134,   136,   138,   140,   141,   146,   148,
     152,   154,   156,   158,   160,   161,   166,   167,   172,   177,
     178,   183,   185,   187,   189,   191,   196,   197,   202,   203,
     214,   219,   220,   225,   226,   231,   232,   237,   238,   243,
     248,   250,   254,   257,   260,   267,   269,   276,   280,   287,
     293,   294,   299,   301,   305,   313,   314,   316,   321,   326,
     327,   329,   334,   342,   349,   350,   355,   356,   361,   363,
     365,   367,   368,   370,   375,   383,   390,   392,   394,   396,
     398,   400,   404,   406,   410,   412,   414,   418,   422,   424,
     428,   430,   434,   436,   438,   442,   446,   450,   452,   454,
     456,   458
};

/* YYRHS -- A `-1'-separated list of the rules' RHS.  */
static const yytype_int16 yyrhs[] =
{
      74,     0,    -1,    -1,    76,    -1,    75,    -1,    78,    -1,
      90,    -1,    91,    -1,    92,    -1,    94,    -1,    97,    -1,
      98,    -1,    99,    -1,   100,    -1,   101,    -1,   106,    -1,
      96,    -1,   108,    -1,   114,    -1,   115,    -1,   118,    -1,
      20,     8,    77,    78,    81,     9,    -1,    90,    91,   114,
      -1,    21,     8,    79,     9,    -1,    80,    -1,    79,    80,
      -1,    23,     8,    84,    85,    87,    90,    92,   115,   114,
      91,    94,    95,    97,   100,   109,    96,   112,   117,    -1,
      22,     8,    82,     9,    -1,    83,    -1,    82,    83,    -1,
     135,     8,    75,    -1,    27,     8,    86,     9,    -1,    -1,
      28,     8,    41,     9,    -1,    28,     8,    42,    12,   127,
      13,     9,    -1,    28,     8,    12,   127,    13,     9,    -1,
      43,    -1,    44,    -1,    45,    -1,    46,    -1,    47,    -1,
      48,    -1,    49,    -1,    50,    -1,    51,    -1,    52,    -1,
      -1,    34,     8,    88,     9,    -1,    89,    -1,    88,    19,
      89,    -1,    35,    -1,    36,    -1,    37,    -1,    38,    -1,
      -1,    25,     8,   128,     9,    -1,    -1,    24,     8,   119,
       9,    -1,    24,     8,   135,     9,    -1,    -1,    29,     8,
      93,     9,    -1,    56,    -1,    57,    -1,    58,    -1,    59,
      -1,    31,     8,   119,     9,    -1,    -1,    32,     8,   128,
       9,    -1,    -1,    33,     8,    97,    98,    99,   109,   101,
     106,   118,     9,    -1,    33,     8,   135,     9,    -1,    -1,
      60,     8,   119,     9,    -1,    -1,    61,     8,   119,     9,
      -1,    -1,    62,     8,   119,     9,    -1,    -1,    63,     8,
     119,     9,    -1,    64,     8,   102,     9,    -1,   103,    -1,
     102,    11,   103,    -1,    65,   104,    -1,    66,   104,    -1,
      67,    14,   119,    10,   119,    15,    -1,   104,    -1,    14,
     119,    10,   119,    15,   105,    -1,    40,     8,    41,    -1,
      40,     8,    42,    12,   127,    13,    -1,    40,     8,    12,
     127,    13,    -1,    -1,    68,     8,   107,     9,    -1,   108,
      -1,   107,    11,   108,    -1,    69,     8,   110,   111,    97,
     113,   118,    -1,    -1,   110,    -1,    70,     8,   128,     9,
      -1,    71,     8,   119,     9,    -1,    -1,   113,    -1,    72,
       8,    41,     9,    -1,    72,     8,    42,    12,   127,    13,
       9,    -1,    72,     8,    12,   127,    13,     9,    -1,    -1,
      26,     8,   132,     9,    -1,    -1,    30,     8,   116,     9,
      -1,    53,    -1,    54,    -1,    55,    -1,    -1,   118,    -1,
      39,     8,    41,     9,    -1,    39,     8,    42,    12,   127,
      13,     9,    -1,    39,     8,    12,   127,    13,     9,    -1,
     131,    -1,   132,    -1,   134,    -1,   120,    -1,   124,    -1,
     134,    16,   121,    -1,   123,    -1,   121,   122,   123,    -1,
      16,    -1,   133,    -1,    18,   120,    18,    -1,    12,   125,
      13,    -1,   119,    -1,   125,    17,   119,    -1,   119,    -1,
     126,    11,   119,    -1,   126,    -1,   129,    -1,   128,    11,
     129,    -1,    14,   130,    15,    -1,   119,    10,   119,    -1,
       5,    -1,     6,    -1,     7,    -1,     4,    -1,     3,    -1
};

/* YYRLINE[YYN] -- source line where rule number YYN was defined.  */
static const yytype_uint16 yyrline[] =
{
       0,   176,   176,   178,   179,   183,   184,   185,   186,   187,
     188,   189,   190,   191,   192,   193,   194,   195,   196,   197,
     198,   202,   225,   239,   243,   246,   252,   382,   386,   387,
     391,   397,   401,   407,   412,   418,   428,   429,   430,   431,
     432,   433,   434,   435,   436,   437,   441,   442,   446,   447,
     451,   452,   453,   454,   458,   459,   463,   464,   465,   473,
     474,   478,   479,   480,   481,   485,   489,   490,   494,   495,
     524,   532,   533,   537,   538,   542,   543,   547,   548,   552,
     556,   557,   561,   568,   575,   581,   585,   595,   600,   606,
     615,   616,   620,   621,   625,   644,   645,   649,   653,   657,
     658,   662,   667,   673,   682,   683,   687,   688,   692,   693,
     694,   698,   699,   702,   707,   713,   722,   723,   724,   725,
     726,   731,   753,   754,   760,   768,   773,   777,   785,   786,
     790,   791,   795,   801,   802,   806,   815,   821,   833,   844,
     850,   859
};
#endif

#if YYDEBUG || YYERROR_VERBOSE || YYTOKEN_TABLE
/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "SHARED_BINDING_IDENTIFIER",
  "IDENTIFIER", "STRING_LITERAL", "INTEGER_LITERAL", "STRING_CONSTANT",
  "SEP", "SEMI", "COLON", "COMMA", "LPAREN", "RPAREN", "LBRACE", "RBRACE",
  "DOT", "PLUS", "TIC", "PIPE", "ADAPTER", "URL_BINDINGS",
  "SHARED_BINDINGS", "URL_BINDING", "BASE_URL", "HEADER_FIELDS",
  "TIMEOUT_INTERVAL", "LIFECYCLE", "LIFECYCLE_STYLE", "REQUEST_METHOD",
  "REQUEST_FORMAT", "END_POINT", "END_POINT_PARAMETERS", "CMO_BINDING",
  "BINDING_OPTIONS", "ONE_TO_ONE", "ONE_TO_MANY", "UNORDERED", "ORDERED",
  "ENTITIES", "ATTRIBUTES", "ALL", "ALL_EXCEPT", "LOGIN", "LOGOUT",
  "PASSWORD_RESET", "CREATE", "UPDATE", "DESTROY",
  "RETRIEVE_SERVER_RECORD", "RETRIEVE_SERVER_RECORDS",
  "RETRIEVE_SERVER_RECORD_COUNT", "RETRIEVE_RELATIONSHIP", "JSON",
  "WEBFORM", "NO_DATA", "GET", "POST", "PUT", "DELETE", "JSON_WRAPPER_KEY",
  "JSON_RECEIVE_WRAPPER_KEY", "JSON_SEND_WRAPPER_KEY", "BULK_WRAPPER_KEY",
  "ATTRIBUTE_BINDINGS", "ID_ATTRIBUTE", "RECEIVE_ONLY_ATTRIBUTE",
  "SEND_ONLY_ATTRIBUTE", "RELATIONSHIP_BINDINGS", "RELATIONSHIP_BINDING",
  "JSON_BINDING", "JSON_ID_BINDING", "RELATIONSHIPS", "$accept", "begin",
  "binding", "adapter", "adapter_fields", "url_bindings",
  "url_binding_list", "url_binding", "shared_bindings",
  "shared_bindings_list", "shared_binding", "lifecycle", "lifecycle_style",
  "lifecycle_phase", "binding_options", "binding_options_list",
  "binding_option", "header_fields", "base_url", "request_method",
  "request_method_spec", "end_point_url", "end_point_parameters",
  "cmo_binding", "json_wrapper_key", "json_receive_wrapper_key",
  "json_send_wrapper_key", "bulk_wrapper_key", "attribute_bindings",
  "attribute_binding_list", "attribute_binding", "attribute_binding_spec",
  "matching_attributes", "relationship_bindings",
  "relationship_binding_list", "relationship_binding",
  "optional_json_binding", "json_binding", "json_id_binding",
  "optional_relationships", "relationships", "timeout_interval",
  "request_format", "request_format_spec", "optional_matching_entities",
  "matching_entities", "expression", "keypath_expression",
  "keypath_expression_list", "keypath_dot_element", "keypath_element",
  "concat_expression", "concat_expression_list", "expression_list",
  "expression_set", "key_value_pair_list", "key_value_pair",
  "key_value_pair_desc", "string_literal", "integer_literal",
  "string_constant", "identifier", "shared_binding_identifier", 0
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[YYLEX-NUM] -- Internal token number corresponding to
   token YYLEX-NUM.  */
static const yytype_uint16 yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,   266,   267,   268,   269,   270,   271,   272,   273,   274,
     275,   276,   277,   278,   279,   280,   281,   282,   283,   284,
     285,   286,   287,   288,   289,   290,   291,   292,   293,   294,
     295,   296,   297,   298,   299,   300,   301,   302,   303,   304,
     305,   306,   307,   308,   309,   310,   311,   312,   313,   314,
     315,   316,   317,   318,   319,   320,   321,   322,   323,   324,
     325,   326,   327
};
# endif

/* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const yytype_uint8 yyr1[] =
{
       0,    73,    74,    74,    74,    75,    75,    75,    75,    75,
      75,    75,    75,    75,    75,    75,    75,    75,    75,    75,
      75,    76,    77,    78,    79,    79,    80,    81,    82,    82,
      83,    84,    85,    85,    85,    85,    86,    86,    86,    86,
      86,    86,    86,    86,    86,    86,    87,    87,    88,    88,
      89,    89,    89,    89,    90,    90,    91,    91,    91,    92,
      92,    93,    93,    93,    93,    94,    95,    95,    96,    96,
      96,    97,    97,    98,    98,    99,    99,   100,   100,   101,
     102,   102,   103,   103,   103,   103,   104,   105,   105,   105,
     106,   106,   107,   107,   108,   109,   109,   110,   111,   112,
     112,   113,   113,   113,   114,   114,   115,   115,   116,   116,
     116,   117,   117,   118,   118,   118,   119,   119,   119,   119,
     119,   120,   121,   121,   122,   123,   123,   124,   125,   125,
     126,   126,   127,   128,   128,   129,   130,   131,   132,   133,
     134,   135
};

/* YYR2[YYN] -- Number of symbols composing right hand side of rule YYN.  */
static const yytype_uint8 yyr2[] =
{
       0,     2,     0,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     6,     3,     4,     1,     2,    18,     4,     1,     2,
       3,     4,     0,     4,     7,     6,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     0,     4,     1,     3,
       1,     1,     1,     1,     0,     4,     0,     4,     4,     0,
       4,     1,     1,     1,     1,     4,     0,     4,     0,    10,
       4,     0,     4,     0,     4,     0,     4,     0,     4,     4,
       1,     3,     2,     2,     6,     1,     6,     3,     6,     5,
       0,     4,     1,     3,     7,     0,     1,     4,     4,     0,
       1,     4,     7,     6,     0,     4,     0,     4,     1,     1,
       1,     0,     1,     4,     7,     6,     1,     1,     1,     1,
       1,     3,     1,     3,     1,     1,     3,     3,     1,     3,
       1,     3,     1,     1,     3,     3,     3,     1,     1,     1,
       1,     1
};

/* YYDEFACT[STATE-NAME] -- Default rule to reduce with in state
   STATE-NUM when YYTABLE doesn't specify something else to do.  Zero
   means the default is an error.  */
static const yytype_uint8 yydefact[] =
{
       2,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     4,
       3,     5,     6,     7,     8,     9,    16,    10,    11,    12,
      13,    14,    15,    17,    18,    19,    20,    54,     0,     0,
       0,     0,     0,     0,     0,    71,     0,     0,     0,     0,
       0,     0,     0,     0,     1,     0,    56,     0,     0,    24,
     141,   140,   137,   138,     0,     0,   119,   120,   116,   117,
     118,     0,     0,     0,   133,     0,    61,    62,    63,    64,
       0,   108,   109,   110,     0,     0,    73,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      80,    85,     0,    92,     0,     0,     0,   104,     0,    23,
      25,   128,     0,    57,     0,    58,     0,     0,    55,     0,
     105,    60,   107,    65,    75,    70,   130,   132,     0,   113,
       0,    72,    74,    76,    78,     0,    82,    83,     0,    79,
       0,    91,     0,     0,     0,    71,     0,     0,    22,     0,
      32,   127,     0,   139,     0,   121,   122,   125,     0,   135,
     134,    95,     0,     0,     0,     0,     0,    81,    93,     0,
       0,     0,     0,    21,     0,     0,    46,   129,     0,     0,
     124,     0,   136,     0,    96,   131,   115,     0,     0,     0,
      97,     0,     0,     0,     0,    28,     0,    36,    37,    38,
      39,    40,    41,    42,    43,    44,    45,     0,     0,     0,
      54,   126,   123,    90,   114,     0,     0,    98,     0,    94,
      27,    29,    54,    31,     0,     0,     0,     0,    59,     0,
       0,    86,    84,     0,     0,     0,    30,     0,    33,     0,
      50,    51,    52,    53,     0,    48,   106,     0,     0,     0,
     101,     0,     0,     0,    47,     0,   104,    69,     0,    87,
       0,     0,     0,    35,     0,    49,    56,     0,     0,   103,
       0,    34,     0,    89,     0,   102,    66,    88,     0,    71,
       0,    77,     0,    95,    67,    68,    99,   111,   100,    26,
     112
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
      -1,    18,    19,    20,    55,    21,    58,    59,   147,   194,
     195,   150,   176,   207,   210,   244,   245,    22,    23,    24,
      80,    25,   279,    26,    27,    28,    29,    30,    31,    99,
     100,   101,   231,    32,   102,    33,   183,   184,   145,   287,
     193,    34,    35,    84,   289,    36,   126,    66,   155,   181,
     156,    67,   112,   127,   128,    73,    74,   117,    68,    69,
     157,    70,   196
};

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
#define YYPACT_NINF -187
static const yytype_int16 yypact[] =
{
      21,    27,    40,    58,    64,    79,    80,   104,   106,   107,
     109,   110,   111,   112,   113,   115,   116,   119,    18,  -187,
    -187,  -187,  -187,  -187,  -187,  -187,  -187,  -187,  -187,  -187,
    -187,  -187,  -187,  -187,  -187,  -187,  -187,    12,    53,    19,
     114,   124,    35,    42,    74,     7,    14,    74,    74,    74,
      74,     3,    62,    63,  -187,   117,   120,   127,     6,  -187,
    -187,  -187,  -187,  -187,    74,   128,  -187,  -187,  -187,  -187,
     123,   131,    74,    10,  -187,   132,  -187,  -187,  -187,  -187,
     136,  -187,  -187,  -187,   137,   139,    75,   140,    74,   149,
     148,   152,   153,   154,   155,    74,   156,   156,   157,    29,
    -187,  -187,    66,  -187,   158,    96,   146,   143,   145,  -187,
    -187,  -187,    36,  -187,     9,  -187,   163,   159,  -187,   114,
    -187,  -187,  -187,  -187,   129,  -187,  -187,   181,   180,  -187,
      74,  -187,  -187,  -187,  -187,   186,  -187,  -187,    74,  -187,
       3,  -187,    62,   114,   189,   138,   191,   192,  -187,   194,
     172,  -187,    74,  -187,   199,   188,  -187,  -187,    74,  -187,
    -187,    63,    74,   196,   193,    74,   197,  -187,  -187,    99,
      74,   141,   205,  -187,   133,   201,   176,  -187,   198,   123,
    -187,     9,  -187,   150,  -187,  -187,  -187,   203,   200,    74,
    -187,   208,   210,   182,    30,  -187,   211,  -187,  -187,  -187,
    -187,  -187,  -187,  -187,  -187,  -187,  -187,   213,    20,   212,
      12,  -187,  -187,   160,  -187,   183,   209,  -187,    22,  -187,
    -187,  -187,   126,  -187,    74,   216,   214,    68,   202,   182,
     219,  -187,  -187,    74,   220,   218,  -187,   222,  -187,    74,
    -187,  -187,  -187,  -187,    11,  -187,   206,   223,    32,   224,
    -187,    74,   229,   226,  -187,    68,   143,  -187,    74,  -187,
     221,   231,   228,  -187,   233,  -187,   120,   230,    74,  -187,
     235,  -187,   215,  -187,   232,  -187,   217,  -187,   239,   138,
     114,   185,   100,    63,  -187,   225,   141,   182,  -187,  -187,
    -187
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -187,  -187,    28,  -187,  -187,   204,  -187,   195,  -187,  -187,
      57,  -187,  -187,  -187,  -187,  -187,    -3,   -35,   -55,    33,
    -187,   -18,  -187,   -30,   -45,   170,   142,   -24,    77,  -187,
     122,   -39,  -187,    50,  -187,   -43,   -19,   227,  -187,  -187,
     -21,  -102,    23,  -187,  -187,  -186,   -36,   118,  -187,  -187,
      86,  -187,  -187,  -187,  -126,  -137,   151,  -187,  -187,   234,
    -187,   125,    26
};

/* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule which
   number is the opposite.  If zero, do what YYDEFACT says.
   If YYTABLE_NINF, syntax error.  */
#define YYTABLE_NINF -1
static const yytype_uint16 yytable[] =
{
      86,   107,    56,    65,   164,   148,   169,   219,    85,   103,
      60,    91,    92,    93,    94,   109,   153,    95,    54,   118,
     254,   119,    60,    61,    62,    63,    88,   154,   111,    57,
     255,    64,   224,    60,   233,    37,   116,     4,   139,   220,
     140,     1,     2,   247,   258,     3,     4,     5,    38,   151,
       6,     7,     8,   152,     9,    89,    90,   136,   137,   135,
      10,   225,   226,   234,   235,    71,    39,    11,    96,    97,
      98,    87,    40,   259,   260,   141,    57,   142,    61,    62,
      63,    11,    12,    13,    14,    15,    64,    41,    42,    16,
      17,    76,    77,    78,    79,    81,    82,    83,   237,   168,
     171,   290,   166,   240,   241,   242,   243,   249,   190,   284,
     119,   119,    43,   253,    44,    45,   177,    46,    47,    48,
      49,    50,   182,    51,    52,   262,   185,    53,    72,   188,
      63,    17,   267,   104,   191,   108,    12,   113,     2,   114,
     115,   120,   274,   282,     3,   121,   122,     2,   123,   125,
       3,     4,     5,   216,   266,     6,     7,     8,   129,     9,
     130,   131,   132,   133,   134,    10,   143,   144,   146,     5,
      95,   138,   149,   158,   159,   228,   197,   198,   199,   200,
     201,   202,   203,   204,   205,   206,    11,    12,    13,    14,
      15,    13,   162,   163,    16,    17,   165,   170,    11,   172,
     175,   173,   174,    61,   180,   186,   187,   189,    60,   208,
     209,   272,   214,   192,    15,   215,   211,   217,   218,   222,
     227,    10,   223,   230,   232,   238,   239,   248,    16,   250,
     251,     6,   257,   268,   281,   252,     7,   261,   263,   264,
     269,   270,   271,   273,   275,   277,     8,   280,    14,   278,
     236,   221,   265,   110,   276,   286,   124,   283,     9,   106,
     213,   246,   167,   229,   285,   288,   161,   212,     0,   256,
     160,     0,   178,     0,     0,    75,     0,     0,     0,   179,
     105
};

static const yytype_int16 yycheck[] =
{
      45,    56,    37,    39,   130,   107,   143,   193,    44,    52,
       3,    47,    48,    49,    50,     9,     7,    14,     0,     9,
       9,    11,     3,     4,     5,     6,    12,    18,    64,    23,
      19,    12,    12,     3,    12,     8,    72,    25,     9,     9,
      11,    20,    21,   229,    12,    24,    25,    26,     8,    13,
      29,    30,    31,    17,    33,    41,    42,    96,    97,    95,
      39,    41,    42,    41,    42,    39,     8,    60,    65,    66,
      67,    45,     8,    41,    42,     9,    23,    11,     4,     5,
       6,    60,    61,    62,    63,    64,    12,     8,     8,    68,
      69,    56,    57,    58,    59,    53,    54,    55,   224,   142,
     145,   287,   138,    35,    36,    37,    38,   233,     9,     9,
      11,    11,     8,   239,     8,     8,   152,     8,     8,     8,
       8,     8,   158,     8,     8,   251,   162,     8,    14,   165,
       6,    69,   258,    70,   170,     8,    61,     9,    21,    16,
       9,     9,   268,   280,    24,     9,     9,    21,     9,     9,
      24,    25,    26,   189,   256,    29,    30,    31,     9,    33,
      12,     9,     9,     9,     9,    39,     8,    71,    22,    26,
      14,    14,    27,    10,    15,   210,    43,    44,    45,    46,
      47,    48,    49,    50,    51,    52,    60,    61,    62,    63,
      64,    62,    11,    13,    68,    69,    10,     8,    60,     8,
      28,     9,     8,     4,    16,     9,    13,    10,     3,     8,
      34,   266,     9,    72,    64,    15,    18,     9,     8,     8,
       8,    39,     9,    40,    15,     9,    12,     8,    68,     9,
      12,    29,     9,    12,   279,    13,    30,    13,     9,    13,
       9,    13,     9,    13,     9,    13,    31,     8,    63,    32,
     222,   194,   255,    58,   272,   285,    86,   281,    33,    55,
     183,   228,   140,   213,   283,   286,   124,   181,    -1,   246,
     119,    -1,   154,    -1,    -1,    41,    -1,    -1,    -1,   154,
      53
};

/* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
   symbol of state STATE-NUM.  */
static const yytype_uint8 yystos[] =
{
       0,    20,    21,    24,    25,    26,    29,    30,    31,    33,
      39,    60,    61,    62,    63,    64,    68,    69,    74,    75,
      76,    78,    90,    91,    92,    94,    96,    97,    98,    99,
     100,   101,   106,   108,   114,   115,   118,     8,     8,     8,
       8,     8,     8,     8,     8,     8,     8,     8,     8,     8,
       8,     8,     8,     8,     0,    77,    90,    23,    79,    80,
       3,     4,     5,     6,    12,   119,   120,   124,   131,   132,
     134,   135,    14,   128,   129,   132,    56,    57,    58,    59,
      93,    53,    54,    55,   116,   119,    97,   135,    12,    41,
      42,   119,   119,   119,   119,    14,    65,    66,    67,   102,
     103,   104,   107,   108,    70,   110,    78,    91,     8,     9,
      80,   119,   125,     9,    16,     9,   119,   130,     9,    11,
       9,     9,     9,     9,    98,     9,   119,   126,   127,     9,
      12,     9,     9,     9,     9,   119,   104,   104,    14,     9,
      11,     9,    11,     8,    71,   111,    22,    81,   114,    27,
      84,    13,    17,     7,    18,   121,   123,   133,    10,    15,
     129,    99,    11,    13,   127,    10,   119,   103,   108,   128,
       8,    97,     8,     9,     8,    28,    85,   119,   120,   134,
      16,   122,   119,   109,   110,   119,     9,    13,   119,    10,
       9,   119,    72,   113,    82,    83,   135,    43,    44,    45,
      46,    47,    48,    49,    50,    51,    52,    86,     8,    34,
      87,    18,   123,   101,     9,    15,   119,     9,     8,   118,
       9,    83,     8,     9,    12,    41,    42,     8,    90,   106,
      40,   105,    15,    12,    41,    42,    75,   127,     9,    12,
      35,    36,    37,    38,    88,    89,    92,   118,     8,   127,
       9,    12,    13,   127,     9,    19,   115,     9,    12,    41,
      42,    13,   127,     9,    13,    89,   114,   127,    12,     9,
      13,     9,    91,    13,   127,     9,    94,    13,    32,    95,
       8,    97,   128,   100,     9,   109,    96,   112,   113,   117,
     118
};

#define yyerrok		(yyerrstatus = 0)
#define yyclearin	(yychar = YYEMPTY)
#define YYEMPTY		(-2)
#define YYEOF		0

#define YYACCEPT	goto yyacceptlab
#define YYABORT		goto yyabortlab
#define YYERROR		goto yyerrorlab


/* Like YYERROR except do call yyerror.  This remains here temporarily
   to ease the transition to the new meaning of YYERROR, for GCC.
   Once GCC version 2 has supplanted version 1, this can go.  */

#define YYFAIL		goto yyerrlab

#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)					\
do								\
  if (yychar == YYEMPTY && yylen == 1)				\
    {								\
      yychar = (Token);						\
      yylval = (Value);						\
      yytoken = YYTRANSLATE (yychar);				\
      YYPOPSTACK (1);						\
      goto yybackup;						\
    }								\
  else								\
    {								\
      yyerror (YY_("syntax error: cannot back up")); \
      YYERROR;							\
    }								\
while (YYID (0))


#define YYTERROR	1
#define YYERRCODE	256


/* YYLLOC_DEFAULT -- Set CURRENT to span from RHS[1] to RHS[N].
   If N is 0, then set CURRENT to the empty location which ends
   the previous symbol: RHS[0] (always defined).  */

#define YYRHSLOC(Rhs, K) ((Rhs)[K])
#ifndef YYLLOC_DEFAULT
# define YYLLOC_DEFAULT(Current, Rhs, N)				\
    do									\
      if (YYID (N))                                                    \
	{								\
	  (Current).first_line   = YYRHSLOC (Rhs, 1).first_line;	\
	  (Current).first_column = YYRHSLOC (Rhs, 1).first_column;	\
	  (Current).last_line    = YYRHSLOC (Rhs, N).last_line;		\
	  (Current).last_column  = YYRHSLOC (Rhs, N).last_column;	\
	}								\
      else								\
	{								\
	  (Current).first_line   = (Current).last_line   =		\
	    YYRHSLOC (Rhs, 0).last_line;				\
	  (Current).first_column = (Current).last_column =		\
	    YYRHSLOC (Rhs, 0).last_column;				\
	}								\
    while (YYID (0))
#endif


/* YY_LOCATION_PRINT -- Print the location on the stream.
   This macro was not mandated originally: define only if we know
   we won't break user code: when these are the locations we know.  */

#ifndef YY_LOCATION_PRINT
# if defined YYLTYPE_IS_TRIVIAL && YYLTYPE_IS_TRIVIAL
#  define YY_LOCATION_PRINT(File, Loc)			\
     fprintf (File, "%d.%d-%d.%d",			\
	      (Loc).first_line, (Loc).first_column,	\
	      (Loc).last_line,  (Loc).last_column)
# else
#  define YY_LOCATION_PRINT(File, Loc) ((void) 0)
# endif
#endif


/* YYLEX -- calling `yylex' with the right arguments.  */

#ifdef YYLEX_PARAM
# define YYLEX yylex (YYLEX_PARAM)
#else
# define YYLEX yylex ()
#endif

/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)			\
do {						\
  if (yydebug)					\
    YYFPRINTF Args;				\
} while (YYID (0))

# define YY_SYMBOL_PRINT(Title, Type, Value, Location)			  \
do {									  \
  if (yydebug)								  \
    {									  \
      YYFPRINTF (stderr, "%s ", Title);					  \
      yy_symbol_print (stderr,						  \
		  Type, Value, Location); \
      YYFPRINTF (stderr, "\n");						  \
    }									  \
} while (YYID (0))


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

/*ARGSUSED*/
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_symbol_value_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep, YYLTYPE const * const yylocationp)
#else
static void
yy_symbol_value_print (yyoutput, yytype, yyvaluep, yylocationp)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
    YYLTYPE const * const yylocationp;
#endif
{
  if (!yyvaluep)
    return;
  YYUSE (yylocationp);
# ifdef YYPRINT
  if (yytype < YYNTOKENS)
    YYPRINT (yyoutput, yytoknum[yytype], *yyvaluep);
# else
  YYUSE (yyoutput);
# endif
  switch (yytype)
    {
      default:
	break;
    }
}


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_symbol_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep, YYLTYPE const * const yylocationp)
#else
static void
yy_symbol_print (yyoutput, yytype, yyvaluep, yylocationp)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
    YYLTYPE const * const yylocationp;
#endif
{
  if (yytype < YYNTOKENS)
    YYFPRINTF (yyoutput, "token %s (", yytname[yytype]);
  else
    YYFPRINTF (yyoutput, "nterm %s (", yytname[yytype]);

  YY_LOCATION_PRINT (yyoutput, *yylocationp);
  YYFPRINTF (yyoutput, ": ");
  yy_symbol_value_print (yyoutput, yytype, yyvaluep, yylocationp);
  YYFPRINTF (yyoutput, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_stack_print (yytype_int16 *bottom, yytype_int16 *top)
#else
static void
yy_stack_print (bottom, top)
    yytype_int16 *bottom;
    yytype_int16 *top;
#endif
{
  YYFPRINTF (stderr, "Stack now");
  for (; bottom <= top; ++bottom)
    YYFPRINTF (stderr, " %d", *bottom);
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)				\
do {								\
  if (yydebug)							\
    yy_stack_print ((Bottom), (Top));				\
} while (YYID (0))


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_reduce_print (YYSTYPE *yyvsp, YYLTYPE *yylsp, int yyrule)
#else
static void
yy_reduce_print (yyvsp, yylsp, yyrule)
    YYSTYPE *yyvsp;
    YYLTYPE *yylsp;
    int yyrule;
#endif
{
  int yynrhs = yyr2[yyrule];
  int yyi;
  unsigned long int yylno = yyrline[yyrule];
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %lu):\n",
	     yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      fprintf (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr, yyrhs[yyprhs[yyrule] + yyi],
		       &(yyvsp[(yyi + 1) - (yynrhs)])
		       , &(yylsp[(yyi + 1) - (yynrhs)])		       );
      fprintf (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)		\
do {					\
  if (yydebug)				\
    yy_reduce_print (yyvsp, yylsp, Rule); \
} while (YYID (0))

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
# define YY_SYMBOL_PRINT(Title, Type, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef	YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif



#if YYERROR_VERBOSE

# ifndef yystrlen
#  if defined __GLIBC__ && defined _STRING_H
#   define yystrlen strlen
#  else
/* Return the length of YYSTR.  */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static YYSIZE_T
yystrlen (const char *yystr)
#else
static YYSIZE_T
yystrlen (yystr)
    const char *yystr;
#endif
{
  YYSIZE_T yylen;
  for (yylen = 0; yystr[yylen]; yylen++)
    continue;
  return yylen;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined __GLIBC__ && defined _STRING_H && defined _GNU_SOURCE
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static char *
yystpcpy (char *yydest, const char *yysrc)
#else
static char *
yystpcpy (yydest, yysrc)
    char *yydest;
    const char *yysrc;
#endif
{
  char *yyd = yydest;
  const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif

# ifndef yytnamerr
/* Copy to YYRES the contents of YYSTR after stripping away unnecessary
   quotes and backslashes, so that it's suitable for yyerror.  The
   heuristic is that double-quoting is unnecessary unless the string
   contains an apostrophe, a comma, or backslash (other than
   backslash-backslash).  YYSTR is taken from yytname.  If YYRES is
   null, do not copy; instead, return the length of what the result
   would have been.  */
static YYSIZE_T
yytnamerr (char *yyres, const char *yystr)
{
  if (*yystr == '"')
    {
      YYSIZE_T yyn = 0;
      char const *yyp = yystr;

      for (;;)
	switch (*++yyp)
	  {
	  case '\'':
	  case ',':
	    goto do_not_strip_quotes;

	  case '\\':
	    if (*++yyp != '\\')
	      goto do_not_strip_quotes;
	    /* Fall through.  */
	  default:
	    if (yyres)
	      yyres[yyn] = *yyp;
	    yyn++;
	    break;

	  case '"':
	    if (yyres)
	      yyres[yyn] = '\0';
	    return yyn;
	  }
    do_not_strip_quotes: ;
    }

  if (! yyres)
    return yystrlen (yystr);

  return yystpcpy (yyres, yystr) - yyres;
}
# endif

/* Copy into YYRESULT an error message about the unexpected token
   YYCHAR while in state YYSTATE.  Return the number of bytes copied,
   including the terminating null byte.  If YYRESULT is null, do not
   copy anything; just return the number of bytes that would be
   copied.  As a special case, return 0 if an ordinary "syntax error"
   message will do.  Return YYSIZE_MAXIMUM if overflow occurs during
   size calculation.  */
static YYSIZE_T
yysyntax_error (char *yyresult, int yystate, int yychar)
{
  int yyn = yypact[yystate];

  if (! (YYPACT_NINF < yyn && yyn <= YYLAST))
    return 0;
  else
    {
      int yytype = YYTRANSLATE (yychar);
      YYSIZE_T yysize0 = yytnamerr (0, yytname[yytype]);
      YYSIZE_T yysize = yysize0;
      YYSIZE_T yysize1;
      int yysize_overflow = 0;
      enum { YYERROR_VERBOSE_ARGS_MAXIMUM = 5 };
      char const *yyarg[YYERROR_VERBOSE_ARGS_MAXIMUM];
      int yyx;

# if 0
      /* This is so xgettext sees the translatable formats that are
	 constructed on the fly.  */
      YY_("syntax error, unexpected %s");
      YY_("syntax error, unexpected %s, expecting %s");
      YY_("syntax error, unexpected %s, expecting %s or %s");
      YY_("syntax error, unexpected %s, expecting %s or %s or %s");
      YY_("syntax error, unexpected %s, expecting %s or %s or %s or %s");
# endif
      char *yyfmt;
      char const *yyf;
      static char const yyunexpected[] = "syntax error, unexpected %s";
      static char const yyexpecting[] = ", expecting %s";
      static char const yyor[] = " or %s";
      char yyformat[sizeof yyunexpected
		    + sizeof yyexpecting - 1
		    + ((YYERROR_VERBOSE_ARGS_MAXIMUM - 2)
		       * (sizeof yyor - 1))];
      char const *yyprefix = yyexpecting;

      /* Start YYX at -YYN if negative to avoid negative indexes in
	 YYCHECK.  */
      int yyxbegin = yyn < 0 ? -yyn : 0;

      /* Stay within bounds of both yycheck and yytname.  */
      int yychecklim = YYLAST - yyn + 1;
      int yyxend = yychecklim < YYNTOKENS ? yychecklim : YYNTOKENS;
      int yycount = 1;

      yyarg[0] = yytname[yytype];
      yyfmt = yystpcpy (yyformat, yyunexpected);

      for (yyx = yyxbegin; yyx < yyxend; ++yyx)
	if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR)
	  {
	    if (yycount == YYERROR_VERBOSE_ARGS_MAXIMUM)
	      {
		yycount = 1;
		yysize = yysize0;
		yyformat[sizeof yyunexpected - 1] = '\0';
		break;
	      }
	    yyarg[yycount++] = yytname[yyx];
	    yysize1 = yysize + yytnamerr (0, yytname[yyx]);
	    yysize_overflow |= (yysize1 < yysize);
	    yysize = yysize1;
	    yyfmt = yystpcpy (yyfmt, yyprefix);
	    yyprefix = yyor;
	  }

      yyf = YY_(yyformat);
      yysize1 = yysize + yystrlen (yyf);
      yysize_overflow |= (yysize1 < yysize);
      yysize = yysize1;

      if (yysize_overflow)
	return YYSIZE_MAXIMUM;

      if (yyresult)
	{
	  /* Avoid sprintf, as that infringes on the user's name space.
	     Don't have undefined behavior even if the translation
	     produced a string with the wrong number of "%s"s.  */
	  char *yyp = yyresult;
	  int yyi = 0;
	  while ((*yyp = *yyf) != '\0')
	    {
	      if (*yyp == '%' && yyf[1] == 's' && yyi < yycount)
		{
		  yyp += yytnamerr (yyp, yyarg[yyi++]);
		  yyf += 2;
		}
	      else
		{
		  yyp++;
		  yyf++;
		}
	    }
	}
      return yysize;
    }
}
#endif /* YYERROR_VERBOSE */


/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

/*ARGSUSED*/
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yydestruct (const char *yymsg, int yytype, YYSTYPE *yyvaluep, YYLTYPE *yylocationp)
#else
static void
yydestruct (yymsg, yytype, yyvaluep, yylocationp)
    const char *yymsg;
    int yytype;
    YYSTYPE *yyvaluep;
    YYLTYPE *yylocationp;
#endif
{
  YYUSE (yyvaluep);
  YYUSE (yylocationp);

  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yytype, yyvaluep, yylocationp);

  switch (yytype)
    {

      default:
	break;
    }
}


/* Prevent warnings from -Wmissing-prototypes.  */

#ifdef YYPARSE_PARAM
#if defined __STDC__ || defined __cplusplus
int yyparse (void *YYPARSE_PARAM);
#else
int yyparse ();
#endif
#else /* ! YYPARSE_PARAM */
#if defined __STDC__ || defined __cplusplus
int yyparse (void);
#else
int yyparse ();
#endif
#endif /* ! YYPARSE_PARAM */



/* The look-ahead symbol.  */
int yychar;

/* The semantic value of the look-ahead symbol.  */
YYSTYPE yylval;

/* Number of syntax errors so far.  */
int yynerrs;
/* Location data for the look-ahead symbol.  */
YYLTYPE yylloc;



/*----------.
| yyparse.  |
`----------*/

#ifdef YYPARSE_PARAM
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
int
yyparse (void *YYPARSE_PARAM)
#else
int
yyparse (YYPARSE_PARAM)
    void *YYPARSE_PARAM;
#endif
#else /* ! YYPARSE_PARAM */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
int
yyparse (void)
#else
int
yyparse ()

#endif
#endif
{
  
  int yystate;
  int yyn;
  int yyresult;
  /* Number of tokens to shift before error messages enabled.  */
  int yyerrstatus;
  /* Look-ahead token as an internal (translated) token number.  */
  int yytoken = 0;
#if YYERROR_VERBOSE
  /* Buffer for error messages, and its allocated size.  */
  char yymsgbuf[128];
  char *yymsg = yymsgbuf;
  YYSIZE_T yymsg_alloc = sizeof yymsgbuf;
#endif

  /* Three stacks and their tools:
     `yyss': related to states,
     `yyvs': related to semantic values,
     `yyls': related to locations.

     Refer to the stacks thru separate pointers, to allow yyoverflow
     to reallocate them elsewhere.  */

  /* The state stack.  */
  yytype_int16 yyssa[YYINITDEPTH];
  yytype_int16 *yyss = yyssa;
  yytype_int16 *yyssp;

  /* The semantic value stack.  */
  YYSTYPE yyvsa[YYINITDEPTH];
  YYSTYPE *yyvs = yyvsa;
  YYSTYPE *yyvsp;

  /* The location stack.  */
  YYLTYPE yylsa[YYINITDEPTH];
  YYLTYPE *yyls = yylsa;
  YYLTYPE *yylsp;
  /* The locations where the error started and ended.  */
  YYLTYPE yyerror_range[2];

#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N), yylsp -= (N))

  YYSIZE_T yystacksize = YYINITDEPTH;

  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;
  YYLTYPE yyloc;

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY;		/* Cause a token to be read.  */

  /* Initialize stack pointers.
     Waste one element of value and location stack
     so that they stay on the same level as the state stack.
     The wasted elements are never initialized.  */

  yyssp = yyss;
  yyvsp = yyvs;
  yylsp = yyls;
#if defined YYLTYPE_IS_TRIVIAL && YYLTYPE_IS_TRIVIAL
  /* Initialize the default location before parsing starts.  */
  yylloc.first_line   = yylloc.last_line   = 1;
  yylloc.first_column = yylloc.last_column = 0;
#endif

  goto yysetstate;

/*------------------------------------------------------------.
| yynewstate -- Push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
 yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;

 yysetstate:
  *yyssp = yystate;

  if (yyss + yystacksize - 1 <= yyssp)
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYSIZE_T yysize = yyssp - yyss + 1;

#ifdef yyoverflow
      {
	/* Give user a chance to reallocate the stack.  Use copies of
	   these so that the &'s don't force the real ones into
	   memory.  */
	YYSTYPE *yyvs1 = yyvs;
	yytype_int16 *yyss1 = yyss;
	YYLTYPE *yyls1 = yyls;

	/* Each stack pointer address is followed by the size of the
	   data in use in that stack, in bytes.  This used to be a
	   conditional around just the two extra args, but that might
	   be undefined if yyoverflow is a macro.  */
	yyoverflow (YY_("memory exhausted"),
		    &yyss1, yysize * sizeof (*yyssp),
		    &yyvs1, yysize * sizeof (*yyvsp),
		    &yyls1, yysize * sizeof (*yylsp),
		    &yystacksize);
	yyls = yyls1;
	yyss = yyss1;
	yyvs = yyvs1;
      }
#else /* no yyoverflow */
# ifndef YYSTACK_RELOCATE
      goto yyexhaustedlab;
# else
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
	goto yyexhaustedlab;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
	yystacksize = YYMAXDEPTH;

      {
	yytype_int16 *yyss1 = yyss;
	union yyalloc *yyptr =
	  (union yyalloc *) YYSTACK_ALLOC (YYSTACK_BYTES (yystacksize));
	if (! yyptr)
	  goto yyexhaustedlab;
	YYSTACK_RELOCATE (yyss);
	YYSTACK_RELOCATE (yyvs);
	YYSTACK_RELOCATE (yyls);
#  undef YYSTACK_RELOCATE
	if (yyss1 != yyssa)
	  YYSTACK_FREE (yyss1);
      }
# endif
#endif /* no yyoverflow */

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;
      yylsp = yyls + yysize - 1;

      YYDPRINTF ((stderr, "Stack size increased to %lu\n",
		  (unsigned long int) yystacksize));

      if (yyss + yystacksize - 1 <= yyssp)
	YYABORT;
    }

  YYDPRINTF ((stderr, "Entering state %d\n", yystate));

  goto yybackup;

/*-----------.
| yybackup.  |
`-----------*/
yybackup:

  /* Do appropriate processing given the current state.  Read a
     look-ahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to look-ahead token.  */
  yyn = yypact[yystate];
  if (yyn == YYPACT_NINF)
    goto yydefault;

  /* Not known => get a look-ahead token if don't already have one.  */

  /* YYCHAR is either YYEMPTY or YYEOF or a valid look-ahead symbol.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = YYLEX;
    }

  if (yychar <= YYEOF)
    {
      yychar = yytoken = YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yyn == 0 || yyn == YYTABLE_NINF)
	goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the look-ahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);

  /* Discard the shifted token unless it is eof.  */
  if (yychar != YYEOF)
    yychar = YYEMPTY;

  yystate = yyn;
  *++yyvsp = yylval;
  *++yylsp = yylloc;
  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- Do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     `$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];

  /* Default location.  */
  YYLLOC_DEFAULT (yyloc, (yylsp - yylen), yylen);
  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
        case 3:
#line 178 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { parserAdapterBinding = (__bridge FOSAdapterBinding *)((yyvsp[(1) - (1)].object)); }
    break;

  case 4:
#line 179 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { parsedBinding = (yyvsp[(1) - (1)].object) ? (__bridge id)((yyvsp[(1) - (1)].object)) : nil; }
    break;

  case 5:
#line 183 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(1) - (1)].object); }
    break;

  case 6:
#line 184 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(1) - (1)].object); }
    break;

  case 7:
#line 185 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(1) - (1)].object); }
    break;

  case 8:
#line 186 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (__bridge void *)AT_((yyvsp[(1) - (1)].requestMethod)); }
    break;

  case 9:
#line 187 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(1) - (1)].object); }
    break;

  case 10:
#line 188 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(1) - (1)].object); }
    break;

  case 11:
#line 189 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(1) - (1)].object); }
    break;

  case 12:
#line 190 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(1) - (1)].object); }
    break;

  case 13:
#line 191 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(1) - (1)].object); }
    break;

  case 14:
#line 192 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(1) - (1)].object); }
    break;

  case 15:
#line 193 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(1) - (1)].object); }
    break;

  case 16:
#line 194 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(1) - (1)].object); }
    break;

  case 17:
#line 195 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(1) - (1)].object); }
    break;

  case 18:
#line 196 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(1) - (1)].object); }
    break;

  case 19:
#line 197 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (__bridge void *)AT_((yyvsp[(1) - (1)].requestFormat)); }
    break;

  case 20:
#line 198 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(1) - (1)].object); }
    break;

  case 21:
#line 202 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        NSDictionary *adapterFields = (__bridge NSDictionary *)((yyvsp[(3) - (6)].object));
        NSSet *urlBindings = (__bridge NSSet *)((yyvsp[(4) - (6)].object));
        NSArray *sharedBindingsArray = (__bridge NSArray *)((yyvsp[(5) - (6)].object));

        // The shared bindings come in an array of dictionaries, merge them
        NSMutableDictionary *sharedBindings = [NSMutableDictionary dictionary];
        for (NSDictionary *nextDict in sharedBindingsArray) {
            for (id nextKey in nextDict.allKeys) {
                id nextValue = nextDict[nextKey];

                sharedBindings[nextKey] = nextValue;
            }
        }

        (yyval.object) = (__bridge void *)[FOSAdapterBinding adapterBindingWithFields:adapterFields
                                                              urlBindings:urlBindings
                                                     andSharedBindings:sharedBindings];
        CAPTURE_ATOM_INFO(AT_"ADAPTER", (yylsp[(1) - (6)]), (yyval.object));
    }
    break;

  case 22:
#line 225 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        NSArray *headerFields = (__bridge NSArray *)((yyvsp[(1) - (3)].object));
        id<FOSExpression> baseURLExpr = (__bridge id<FOSExpression>)((yyvsp[(2) - (3)].object));
        id<FOSExpression> timeoutIntervalExpr = (__bridge id<FOSExpression>)((yyvsp[(3) - (3)].object));

        (yyval.object) = (__bridge void *)AT_{
            AT_"header_fields" : (headerFields ? headerFields : AT_[]) ,
            AT_"base_url" : baseURLExpr,
            AT_"timeout_interval" : timeoutIntervalExpr
        };
    }
    break;

  case 23:
#line 239 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(3) - (4)].object); }
    break;

  case 24:
#line 243 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        CAPTURE_UNORDERED_VAL((yyval.object), (yyvsp[(1) - (1)].object)); CFBridgingRelease((yyvsp[(1) - (1)].object));
    }
    break;

  case 25:
#line 246 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        COMBINE_UNORDERED_VALS((yyval.object), (yyvsp[(2) - (2)].object)); CFBridgingRelease((yyvsp[(2) - (2)].object));
    }
    break;

  case 26:
#line 271 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {

        FOSLifecyclePhase lifecyclePhase = ((yyvsp[(3) - (18)].lifecyclePhase));
        FOSItemMatcher *lifecycleStyle = (__bridge FOSItemMatcher *)((yyvsp[(4) - (18)].object));
        FOSBindingOptions bindingOptions = ((yyvsp[(5) - (18)].bindingOptions));
        NSDictionary *headerFields = (__bridge NSDictionary *)((yyvsp[(6) - (18)].object));
        FOSRequestMethod requestMethod = ((yyvsp[(7) - (18)].requestMethod));
        FOSRequestFormat requestFormat = ((yyvsp[(8) - (18)].requestFormat));
        NSNumber *timeoutInterval = (__bridge NSNumber *)((yyvsp[(9) - (18)].object));
        id<FOSExpression> baseURLExpr = (__bridge id<FOSExpression>)((yyvsp[(10) - (18)].object));
        id<FOSExpression> endPoint = (__bridge id<FOSExpression>)((yyvsp[(11) - (18)].object));
        NSArray *endPointParameters = (__bridge NSArray *)((yyvsp[(12) - (18)].object));
        id<FOSExpression> jsonWrapperKey = (__bridge id<FOSExpression>)((yyvsp[(13) - (18)].object));
        id<FOSExpression> bulkWrapperKey = (__bridge id<FOSExpression>)((yyvsp[(14) - (18)].object));
        NSArray *jsonBindingExpressions = (__bridge NSArray *)((yyvsp[(15) - (18)].object));
        id binder = (__bridge id)((yyvsp[(16) - (18)].object));
        FOSCMOBinding *cmoBinder = [binder isKindOfClass:[FOSCMOBinding class]]
            ? (FOSCMOBinding *)binder
            : nil;
        FOSSharedBindingReference *bindingReference = [binder isKindOfClass:[FOSSharedBindingReference class]]
            ? (FOSSharedBindingReference *)binder
            : nil;
        FOSItemMatcher *relationshipMatcher = (__bridge FOSItemMatcher *)((yyvsp[(17) - (18)].object));
        FOSItemMatcher *entityMatcher = (__bridge FOSItemMatcher *)((yyvsp[(18) - (18)].object));

        FOSURLBinding *binding = nil;
        if (cmoBinder != nil) {
            binding = [FOSURLBinding bindingForLifeCyclePhase:lifecyclePhase
                                                     endPoint:endPoint
                                                    cmoBinder:cmoBinder
                                             andEntityMatcher:entityMatcher];
        }
        else if (bindingReference != nil) {
           binding = [FOSURLBinding bindingForLifeCyclePhase:lifecyclePhase
                                                    endPoint:endPoint
                                         cmoBindingReference:bindingReference
                                            andEntityMatcher:entityMatcher];
        }
        else if (
            lifecyclePhase != FOSLifecyclePhaseRetrieveServerRecord &&
            requestFormat == FOSRequestFormatNoData
        ) {
            binding = [FOSURLBinding bindingForLifeCyclePhase:lifecyclePhase
                                                     endPoint:endPoint
                                                requestFormat:requestFormat
                                             andEntityMatcher:entityMatcher];
        }
        else if (jsonBindingExpressions == nil) {
            yyerror("Missing CMO binding reference.");
            YYERROR;
        }

        if (jsonBindingExpressions != nil) {
            if (binding == nil) {
                binding = [FOSURLBinding bindingForLifeCyclePhase:lifecyclePhase
                                                         endPoint:endPoint
                                                    requestFormat:requestFormat
                                               andJSONExpressions:jsonBindingExpressions];

// TODO : Review why entityMatcher can be optional
               binding.entityMatcher = entityMatcher;
            }
            else {
                binding.jsonBindingExpressions = jsonBindingExpressions;
            }
        }

        if (lifecyclePhase == FOSLifecyclePhaseRetrieveServerRecordRelationship) {

            // Check the relationship matcher
            if (relationshipMatcher != nil) {
                binding.relationshipMatcher = relationshipMatcher;
            }
            else {
                yyerror("Missing RELATIONSHIPS specification.");
                YYERROR;
            }

            // Check binding options
            if (bindingOptions == FOSBindingOptionsNone) {
                yyerror("Binding options must be specified for Lifecycle RETRIEVE_RELATIONSHIP.");
                YYERROR;
            }

            // Default to unordered if order not specified
            else if ((bindingOptions & (FOSBindingOptionsUnorderedRelationship | FOSBindingOptionsOrderedRelationship)) == FOSBindingOptionsNone) {
                bindingOptions |= FOSBindingOptionsUnorderedRelationship;
            }
        }

        binding.lifecyclePhase = lifecyclePhase;
        binding.lifecycleStyle = lifecycleStyle;
        binding.requestMethod = requestMethod;
        binding.requestFormat = requestFormat;
        binding.headerFields = headerFields;
        binding.timeoutInterval = (NSTimeInterval)[timeoutInterval unsignedIntegerValue];
        binding.bindingOptions = bindingOptions;
        binding.baseURLExpr = baseURLExpr;
        binding.endPointParameters = endPointParameters;
        binding.jsonWrapperKey = jsonWrapperKey;
        binding.bulkWrapperKey = bulkWrapperKey;

        // TODO : Figure out why without this we get a release of binding on exit of this function
        CFBridgingRetain(binding);

        (yyval.object) = (__bridge void *)binding;

        CAPTURE_ATOM_INFO(AT_"URL_BINDING", (yylsp[(1) - (18)]), (yyval.object));
    }
    break;

  case 27:
#line 382 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(3) - (4)].object); }
    break;

  case 28:
#line 386 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { CAPTURE_ORDERED_VAL((yyval.object), (yyvsp[(1) - (1)].object)); }
    break;

  case 29:
#line 387 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { COMBINE_ORDERED_VALS((yyval.object), (yyvsp[(2) - (2)].object)); }
    break;

  case 30:
#line 391 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        (yyval.object) = (__bridge void *)AT_{ (__bridge NSString *)(yyvsp[(1) - (3)].object) : (__bridge id)((yyvsp[(3) - (3)].object)) };
    }
    break;

  case 31:
#line 397 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.lifecyclePhase) = (yyvsp[(3) - (4)].lifecyclePhase); }
    break;

  case 32:
#line 401 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        /* By creating the 'default' atom here, we can still attach line/col info */
        (yyval.object) = (__bridge void *)[FOSItemMatcher matcherMatchingAllItems];

        CAPTURE_ATOM_INFO(AT_"LIFECYCLE_STYLE", yylloc, (yyval.object));
    }
    break;

  case 33:
#line 407 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        (yyval.object) = (__bridge void *)[FOSItemMatcher matcherMatchingAllItems];

        CAPTURE_ATOM_INFO(AT_"LIFECYCLE_STYLE", (yylsp[(1) - (4)]), (yyval.object));
    }
    break;

  case 34:
#line 412 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        (yyval.object) = (__bridge void *)[FOSItemMatcher matcher:FOSItemMatchAllExcept
        forItemExpressions:(__bridge NSSet *)((yyvsp[(5) - (7)].object))];

        CAPTURE_ATOM_INFO(AT_"LIFECYCLE_STYLE", (yylsp[(1) - (7)]), (yyval.object));
    }
    break;

  case 35:
#line 418 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        (yyval.object) = (__bridge void *)[FOSItemMatcher matcher:FOSItemMatchItems
        forItemExpressions:(__bridge NSSet *)((yyvsp[(4) - (6)].object))];

        CAPTURE_ATOM_INFO(AT_"LIFECYCLE_STYLE", (yylsp[(1) - (6)]), (yyval.object));
    }
    break;

  case 36:
#line 428 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.lifecyclePhase) = FOSLifecyclePhaseLogin; }
    break;

  case 37:
#line 429 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.lifecyclePhase) = FOSLifecyclePhaseLogout; }
    break;

  case 38:
#line 430 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.lifecyclePhase) = FOSLifecyclePhasePasswordReset; }
    break;

  case 39:
#line 431 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.lifecyclePhase) = FOSLifecyclePhaseCreateServerRecord; }
    break;

  case 40:
#line 432 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.lifecyclePhase) = FOSLifecyclePhaseUpdateServerRecord; }
    break;

  case 41:
#line 433 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.lifecyclePhase) = FOSLifecyclePhaseDestroyServerRecord; }
    break;

  case 42:
#line 434 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.lifecyclePhase) = FOSLifecyclePhaseRetrieveServerRecord; }
    break;

  case 43:
#line 435 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.lifecyclePhase) = FOSLifecyclePhaseRetrieveServerRecords; }
    break;

  case 44:
#line 436 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.lifecyclePhase) = FOSLifecyclePhaseRetrieveServerRecordCount; }
    break;

  case 45:
#line 437 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.lifecyclePhase) = FOSLifecyclePhaseRetrieveServerRecordRelationship; }
    break;

  case 46:
#line 441 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.bindingOptions) = FOSBindingOptionsNone; }
    break;

  case 47:
#line 442 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.bindingOptions) = (yyvsp[(3) - (4)].bindingOptions); }
    break;

  case 48:
#line 446 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.bindingOptions) = (yyvsp[(1) - (1)].bindingOptions); }
    break;

  case 49:
#line 447 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.bindingOptions) |= (yyvsp[(3) - (3)].bindingOptions); }
    break;

  case 50:
#line 451 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.bindingOptions) = FOSBindingOptionsOneToOneRelationship; }
    break;

  case 51:
#line 452 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.bindingOptions) = FOSBindingOptionsOneToManyRelationship; }
    break;

  case 52:
#line 453 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.bindingOptions) = FOSBindingOptionsUnorderedRelationship; }
    break;

  case 53:
#line 454 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.bindingOptions) = FOSBindingOptionsOrderedRelationship; }
    break;

  case 54:
#line 458 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = nil; }
    break;

  case 55:
#line 459 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(3) - (4)].object); }
    break;

  case 56:
#line 463 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = nil; }
    break;

  case 57:
#line 464 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(3) - (4)].object); }
    break;

  case 58:
#line 465 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        (yyval.object) = (__bridge void *)[FOSSharedBindingReference referenceWithBindingType:AT_"BASE_URL"
                                                                    andIdentifier:(__bridge NSString *)(yyvsp[(3) - (4)].object)];
        CAPTURE_ATOM_INFO(AT_"BASE_URL", (yylsp[(1) - (4)]), (yyval.object));
    }
    break;

  case 59:
#line 473 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.requestMethod) = FOSRequestMethodGET; }
    break;

  case 60:
#line 474 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.requestMethod) = (yyvsp[(3) - (4)].requestMethod); }
    break;

  case 61:
#line 478 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.requestMethod) = FOSRequestMethodGET; }
    break;

  case 62:
#line 479 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.requestMethod) = FOSRequestMethodPOST; }
    break;

  case 63:
#line 480 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.requestMethod) = FOSRequestMethodPUT; }
    break;

  case 64:
#line 481 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.requestMethod) = FOSRequestMethodDELETE; }
    break;

  case 65:
#line 485 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(3) - (4)].object); }
    break;

  case 66:
#line 489 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = nil; }
    break;

  case 67:
#line 490 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(3) - (4)].object); }
    break;

  case 68:
#line 494 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = nil; }
    break;

  case 69:
#line 503 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {

        id<FOSExpression> jsonWrapperKey = (__bridge id<FOSExpression>)((yyvsp[(3) - (10)].object));
        id<FOSExpression> jsonReceiveWrapperKey = (__bridge id<FOSExpression>)((yyvsp[(4) - (10)].object));
        id<FOSExpression> jsonSendWrapperKey = (__bridge id<FOSExpression>)((yyvsp[(5) - (10)].object));
        NSArray *jsonBindingExpressions = (__bridge NSArray *)((yyvsp[(6) - (10)].object));
        NSSet *attributeBindings = (__bridge NSSet *)((yyvsp[(7) - (10)].object));
        NSSet *relationshipBindings = (__bridge NSSet *)((yyvsp[(8) - (10)].object));
        FOSItemMatcher *matchingEntities = (__bridge FOSItemMatcher *)((yyvsp[(9) - (10)].object));

        (yyval.object) = (__bridge void *)[FOSCMOBinding bindingWithAttributeBindings:attributeBindings
                                                     relationshipBindings:relationshipBindings
                                                         andEntityMatcher:matchingEntities];

        ((__bridge FOSCMOBinding *)(yyval.object)).jsonWrapperKey = jsonWrapperKey;
        ((__bridge FOSCMOBinding *)(yyval.object)).jsonReceiveWrapperKey = jsonReceiveWrapperKey;
        ((__bridge FOSCMOBinding *)(yyval.object)).jsonSendWrapperKey = jsonSendWrapperKey;
        ((__bridge FOSCMOBinding *)(yyval.object)).jsonBindingExpressions = jsonBindingExpressions;

        CAPTURE_ATOM_INFO(AT_"CMO_BINDING", (yylsp[(1) - (10)]), (yyval.object));
    }
    break;

  case 70:
#line 524 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        (yyval.object) = (__bridge void *)[FOSSharedBindingReference referenceWithBindingType:AT_"CMO_BINDING" andIdentifier:(__bridge NSString *)(yyvsp[(3) - (4)].object)];

        CAPTURE_ATOM_INFO(AT_"CMO_BINDING", (yylsp[(1) - (4)]), (yyval.object));
    }
    break;

  case 71:
#line 532 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = nil; }
    break;

  case 72:
#line 533 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(3) - (4)].object); }
    break;

  case 73:
#line 537 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = nil; }
    break;

  case 74:
#line 538 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(3) - (4)].object); }
    break;

  case 75:
#line 542 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = nil; }
    break;

  case 76:
#line 543 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(3) - (4)].object); }
    break;

  case 77:
#line 547 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = nil; }
    break;

  case 78:
#line 548 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(3) - (4)].object); }
    break;

  case 79:
#line 552 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(3) - (4)].object); }
    break;

  case 80:
#line 556 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { CAPTURE_UNORDERED_VAL((yyval.object), (yyvsp[(1) - (1)].object)); }
    break;

  case 81:
#line 557 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { COMBINE_UNORDERED_VALS((yyval.object), (yyvsp[(3) - (3)].object)); }
    break;

  case 82:
#line 561 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        [(__bridge FOSAttributeBinding *)(yyvsp[(2) - (2)].object) setIsIdentityAttribute:YES];

        (yyval.object) = (yyvsp[(2) - (2)].object);

        CAPTURE_ATOM_INFO(AT_"ID_ATTRIBUTE", (yylsp[(1) - (2)]), (yyval.object));
    }
    break;

  case 83:
#line 568 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        [(__bridge FOSAttributeBinding *)(yyvsp[(2) - (2)].object) setIsReceiveOnlyAttribute:YES];

        (yyval.object) = (yyvsp[(2) - (2)].object);

        CAPTURE_ATOM_INFO(AT_"RECEIVE_ONLY_ATTRIBUTE", (yylsp[(1) - (2)]), (yyval.object));
    }
    break;

  case 84:
#line 575 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        (yyval.object) = (__bridge void *)[FOSAttributeBinding sendOnlyBindingWithJsonKeyExpression:(__bridge id)((yyvsp[(3) - (6)].object))
                                                                   cmoKeyPathExpression:(__bridge id)((yyvsp[(5) - (6)].object))];

        CAPTURE_ATOM_INFO(AT_"SEND_ONLY_ATTRIBUTE", (yylsp[(1) - (6)]), (yyval.object));
    }
    break;

  case 85:
#line 581 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(1) - (1)].object); }
    break;

  case 86:
#line 585 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        (yyval.object) = (__bridge void *)[FOSAttributeBinding bindingWithJsonKeyExpression:(__bridge id)((yyvsp[(2) - (6)].object))
                                                          cmoKeyPathExpression:(__bridge id)((yyvsp[(4) - (6)].object))
                                                           andAttributeMatcher:(__bridge id)((yyvsp[(6) - (6)].object))];

        CAPTURE_ATOM_INFO(AT_"ATTRIBUTE_BINDING", (yylsp[(1) - (6)]), (yyval.object));
    }
    break;

  case 87:
#line 595 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        (yyval.object) = (__bridge void *)[FOSItemMatcher matcherMatchingAllItems];

        CAPTURE_ATOM_INFO(AT_"ATTRIBUTES", (yylsp[(1) - (3)]), (yyval.object));
    }
    break;

  case 88:
#line 600 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        (yyval.object) = (__bridge void *)[FOSItemMatcher matcher:FOSItemMatchAllExcept
                                             forItemExpressions:(__bridge NSSet *)((yyvsp[(5) - (6)].object))];

        CAPTURE_ATOM_INFO(AT_"ATTRIBUTES", (yylsp[(1) - (6)]), (yyval.object));
    }
    break;

  case 89:
#line 606 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        (yyval.object) = (__bridge void *)[FOSItemMatcher matcher:FOSItemMatchItems
                                             forItemExpressions:(__bridge NSSet *)((yyvsp[(4) - (5)].object))];

        CAPTURE_ATOM_INFO(AT_"ATTRIBUTES", (yylsp[(1) - (5)]), (yyval.object));
    }
    break;

  case 90:
#line 615 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = nil; }
    break;

  case 91:
#line 616 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(3) - (4)].object); }
    break;

  case 92:
#line 620 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { CAPTURE_UNORDERED_VAL((yyval.object), (yyvsp[(1) - (1)].object)); }
    break;

  case 93:
#line 621 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { COMBINE_UNORDERED_VALS((yyval.object), (yyvsp[(3) - (3)].object)); }
    break;

  case 94:
#line 625 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        NSArray *jsonBindingExpressions = (__bridge NSArray *)((yyvsp[(3) - (7)].object));
        id<FOSExpression> destCMOBindingExpr = (__bridge id<FOSExpression>)((yyvsp[(4) - (7)].object));
        id<FOSExpression> jsonWrapperKey = (__bridge id<FOSExpression>)((yyvsp[(5) - (7)].object));
        FOSItemMatcher *relationshipMatcher = (__bridge FOSItemMatcher *)((yyvsp[(6) - (7)].object));
        FOSItemMatcher *entityMatcher = (__bridge FOSItemMatcher *)((yyvsp[(7) - (7)].object));

        (yyval.object) = (__bridge void *)
            [FOSRelationshipBinding bindingWithJsonBindings:jsonBindingExpressions
                                    jsonIdBindingExpression:destCMOBindingExpr
                                        relationshipMatcher:relationshipMatcher
                                              entityMatcher:entityMatcher];
        ((__bridge FOSRelationshipBinding *)(yyval.object)).jsonWrapperKey = jsonWrapperKey;

        CAPTURE_ATOM_INFO(AT_"RELATIONSHIP_BINDING", (yylsp[(1) - (7)]), (yyval.object));
    }
    break;

  case 95:
#line 644 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = nil; }
    break;

  case 96:
#line 645 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(1) - (1)].object); }
    break;

  case 97:
#line 649 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(3) - (4)].object); }
    break;

  case 98:
#line 653 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(3) - (4)].object); }
    break;

  case 99:
#line 657 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = nil; }
    break;

  case 100:
#line 658 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(1) - (1)].object); }
    break;

  case 101:
#line 662 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        (yyval.object) = (__bridge void *)[FOSItemMatcher matcherMatchingAllItems];

        CAPTURE_ATOM_INFO(AT_"RELATIONSHIPS", (yylsp[(1) - (4)]), (yyval.object));
    }
    break;

  case 102:
#line 667 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        (yyval.object) = (__bridge void *)[FOSItemMatcher matcher:FOSItemMatchAllExcept
                                             forItemExpressions:(__bridge NSSet *)((yyvsp[(5) - (7)].object))];

        CAPTURE_ATOM_INFO(AT_"RELATIONSHIPS", (yylsp[(1) - (7)]), (yyval.object));
    }
    break;

  case 103:
#line 673 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        (yyval.object) = (__bridge void *)[FOSItemMatcher matcher:FOSItemMatchItems
                                             forItemExpressions:(__bridge NSSet *)((yyvsp[(4) - (6)].object))];

        CAPTURE_ATOM_INFO(AT_"RELATIONSHIPS", (yylsp[(1) - (6)]), (yyval.object));
    }
    break;

  case 104:
#line 682 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = nil; }
    break;

  case 105:
#line 683 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(3) - (4)].object); }
    break;

  case 106:
#line 687 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.requestFormat) = FOSRequestFormatJSON; }
    break;

  case 107:
#line 688 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.requestFormat) = (yyvsp[(3) - (4)].requestFormat); }
    break;

  case 108:
#line 692 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.requestFormat) = FOSRequestFormatJSON; }
    break;

  case 109:
#line 693 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.requestFormat) = FOSRequestFormatWebform; }
    break;

  case 110:
#line 694 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.requestFormat) = FOSRequestFormatNoData; }
    break;

  case 111:
#line 698 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = nil; }
    break;

  case 112:
#line 699 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(1) - (1)].object); }
    break;

  case 113:
#line 702 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        (yyval.object) = (__bridge void *)[FOSItemMatcher matcherMatchingAllItems];

        CAPTURE_ATOM_INFO(AT_"ENTITIES", (yylsp[(1) - (4)]), (yyval.object));
    }
    break;

  case 114:
#line 707 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        (yyval.object) = (__bridge void *)[FOSItemMatcher matcher:FOSItemMatchAllExcept
                                             forItemExpressions:(__bridge NSSet *)((yyvsp[(5) - (7)].object))];

        CAPTURE_ATOM_INFO(AT_"ENTITIES", (yylsp[(1) - (7)]), (yyval.object));
    }
    break;

  case 115:
#line 713 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        (yyval.object) = (__bridge void *)[FOSItemMatcher matcher:FOSItemMatchItems
                                             forItemExpressions:(__bridge NSSet *)((yyvsp[(4) - (6)].object))];

        CAPTURE_ATOM_INFO(AT_"ENTITIES", (yylsp[(1) - (6)]), (yyval.object));
    }
    break;

  case 121:
#line 731 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        NSArray *exprList = (__bridge NSArray *)(yyvsp[(3) - (3)].object);
        id<FOSExpression> rhsExpr = nil;

        // This is a simple optimization; not strictly necessary.
        if (exprList.count == 1) {
            rhsExpr = exprList.lastObject;
        }
        else {
            rhsExpr = [FOSConcatExpression concatExpressionWithExpressions:exprList];

            CAPTURE_ATOM_INFO(AT_"CONCAT_EXPR", (yylsp[(1) - (3)]), (yyval.object));
        }

        (yyval.object) = (__bridge void *)[FOSKeyPathExpression keyPathExpressionWithLHS:(__bridge id<FOSExpression>)(yyvsp[(1) - (3)].object)
                                                                    andRHS:rhsExpr];

        CAPTURE_ATOM_INFO(AT_"KEY_PATH_EXPR", (yylsp[(1) - (3)]), (yyval.object));
    }
    break;

  case 122:
#line 753 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { CAPTURE_ORDERED_VAL((yyval.object), (yyvsp[(1) - (1)].object)); }
    break;

  case 123:
#line 754 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        COMBINE_ORDERED_VALS2((yyval.object), (yyvsp[(3) - (3)].object), (yyvsp[(2) - (3)].object));
    }
    break;

  case 124:
#line 760 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        (yyval.object) = (__bridge void *)[FOSConstantExpression constantExpressionWithValue:AT_"."];

        CAPTURE_ATOM_INFO(AT_"CONSTANT_EXPR", (yylsp[(1) - (1)]), (yyval.object));
    }
    break;

  case 125:
#line 768 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        (yyval.object) = (__bridge void *) [FOSConstantExpression constantExpressionWithValue:(__bridge id)(yyvsp[(1) - (1)].object)];

        CAPTURE_ATOM_INFO(AT_"CONSTANT_EXPR", (yylsp[(1) - (1)]), (yyval.object));
    }
    break;

  case 126:
#line 773 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(2) - (3)].object); }
    break;

  case 127:
#line 777 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        (yyval.object) = (__bridge void *)[FOSConcatExpression concatExpressionWithExpressions:(__bridge NSArray*)(yyvsp[(2) - (3)].object)];

        CAPTURE_ATOM_INFO(AT_"CONCAT_EXPR", (yylsp[(1) - (3)]), (yyval.object));
    }
    break;

  case 128:
#line 785 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { CAPTURE_ORDERED_VAL((yyval.object), (yyvsp[(1) - (1)].object)); }
    break;

  case 129:
#line 786 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { COMBINE_ORDERED_VALS((yyval.object), (yyvsp[(3) - (3)].object)); }
    break;

  case 130:
#line 790 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { CAPTURE_ORDERED_VAL((yyval.object), (yyvsp[(1) - (1)].object)); }
    break;

  case 131:
#line 791 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { COMBINE_ORDERED_VALS((yyval.object), (yyvsp[(3) - (3)].object)); }
    break;

  case 132:
#line 795 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        (yyval.object) = (__bridge void *)[NSMutableSet setWithArray:(__bridge NSArray *)((yyvsp[(1) - (1)].object))];
    }
    break;

  case 133:
#line 801 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { CAPTURE_ORDERED_VAL((yyval.object), (yyvsp[(1) - (1)].object)); }
    break;

  case 134:
#line 802 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { COMBINE_ORDERED_VALS((yyval.object), (yyvsp[(3) - (3)].object)); }
    break;

  case 135:
#line 806 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    { (yyval.object) = (yyvsp[(2) - (3)].object); }
    break;

  case 136:
#line 815 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        (yyval.object) = (__bridge void *)AT_[(__bridge id)(yyvsp[(1) - (3)].object), ((__bridge id)(yyvsp[(3) - (3)].object))];
    }
    break;

  case 137:
#line 821 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        char *cStr = &((char *)(yyvsp[(1) - (1)].string))[1];
        cStr[strlen(cStr)-1] = '\0';

        NSString *str = [NSString stringWithCString:cStr encoding:NSASCIIStringEncoding];
        (yyval.object) = (__bridge void *)[FOSConstantExpression constantExpressionWithValue:str];

        CAPTURE_ATOM_INFO(AT_"STRING_EXPR", (yylsp[(1) - (1)]), (yyval.object));
    }
    break;

  case 138:
#line 833 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        NSString *intStr = [NSString stringWithCString:(yyvsp[(1) - (1)].string) encoding:NSASCIIStringEncoding];
        int intVal = intStr.integerValue;

        (yyval.object) = (__bridge void *)[FOSConstantExpression constantExpressionWithValue:AT_(intVal)];

        CAPTURE_ATOM_INFO(AT_"INTEGER_EXPR", (yylsp[(1) - (1)]), (yyval.object));
    }
    break;

  case 139:
#line 844 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        (yyval.object) = (__bridge void *)[NSString stringWithCString:(yyvsp[(1) - (1)].string) encoding:NSASCIIStringEncoding];
    }
    break;

  case 140:
#line 850 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        NSString *identifier = [NSString stringWithCString:&((yyvsp[(1) - (1)].string)[1]) encoding:NSASCIIStringEncoding];
        (yyval.object) = (__bridge void *)[FOSVariableExpression variableExpressionWithIdentifier:identifier];

        CAPTURE_ATOM_INFO(AT_"VARIABLE_EXPR", (yylsp[(1) - (1)]), (yyval.object));
    }
    break;

  case 141:
#line 859 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"
    {
        (yyval.object) = (__bridge void *)[NSString stringWithCString:(yyvsp[(1) - (1)].string) encoding:NSASCIIStringEncoding];
    }
    break;


/* Line 1267 of yacc.c.  */
#line 2883 "/Users/david/Library/Developer/Xcode/DerivedData/FOSREST-fodkpoehriibrldqgafemiosbmld/Build/Intermediates/Pods.build/Debug-iphonesimulator/Pods-FOSRESTApp-fosrest.build/DerivedSources/y.tab.c"
      default: break;
    }
  YY_SYMBOL_PRINT ("-> $$ =", yyr1[yyn], &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);

  *++yyvsp = yyval;
  *++yylsp = yyloc;

  /* Now `shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTOKENS] + *yyssp;
  if (0 <= yystate && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTOKENS];

  goto yynewstate;


/*------------------------------------.
| yyerrlab -- here on detecting error |
`------------------------------------*/
yyerrlab:
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
#if ! YYERROR_VERBOSE
      yyerror (YY_("syntax error"));
#else
      {
	YYSIZE_T yysize = yysyntax_error (0, yystate, yychar);
	if (yymsg_alloc < yysize && yymsg_alloc < YYSTACK_ALLOC_MAXIMUM)
	  {
	    YYSIZE_T yyalloc = 2 * yysize;
	    if (! (yysize <= yyalloc && yyalloc <= YYSTACK_ALLOC_MAXIMUM))
	      yyalloc = YYSTACK_ALLOC_MAXIMUM;
	    if (yymsg != yymsgbuf)
	      YYSTACK_FREE (yymsg);
	    yymsg = (char *) YYSTACK_ALLOC (yyalloc);
	    if (yymsg)
	      yymsg_alloc = yyalloc;
	    else
	      {
		yymsg = yymsgbuf;
		yymsg_alloc = sizeof yymsgbuf;
	      }
	  }

	if (0 < yysize && yysize <= yymsg_alloc)
	  {
	    (void) yysyntax_error (yymsg, yystate, yychar);
	    yyerror (yymsg);
	  }
	else
	  {
	    yyerror (YY_("syntax error"));
	    if (yysize != 0)
	      goto yyexhaustedlab;
	  }
      }
#endif
    }

  yyerror_range[0] = yylloc;

  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse look-ahead token after an
	 error, discard it.  */

      if (yychar <= YYEOF)
	{
	  /* Return failure if at end of input.  */
	  if (yychar == YYEOF)
	    YYABORT;
	}
      else
	{
	  yydestruct ("Error: discarding",
		      yytoken, &yylval, &yylloc);
	  yychar = YYEMPTY;
	}
    }

  /* Else will try to reuse look-ahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:

  /* Pacify compilers like GCC when the user code never invokes
     YYERROR and the label yyerrorlab therefore never appears in user
     code.  */
  if (/*CONSTCOND*/ (0))
     goto yyerrorlab;

  yyerror_range[0] = yylsp[1-yylen];
  /* Do not reclaim the symbols of the rule which action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;	/* Each real token shifted decrements this.  */

  for (;;)
    {
      yyn = yypact[yystate];
      if (yyn != YYPACT_NINF)
	{
	  yyn += YYTERROR;
	  if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYTERROR)
	    {
	      yyn = yytable[yyn];
	      if (0 < yyn)
		break;
	    }
	}

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
	YYABORT;

      yyerror_range[0] = *yylsp;
      yydestruct ("Error: popping",
		  yystos[yystate], yyvsp, yylsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  *++yyvsp = yylval;

  yyerror_range[1] = yylloc;
  /* Using YYLLOC is tempting, but would change the location of
     the look-ahead.  YYLOC is available though.  */
  YYLLOC_DEFAULT (yyloc, (yyerror_range - 1), 2);
  *++yylsp = yyloc;

  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", yystos[yyn], yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturn;

/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturn;

#ifndef yyoverflow
/*-------------------------------------------------.
| yyexhaustedlab -- memory exhaustion comes here.  |
`-------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  /* Fall through.  */
#endif

yyreturn:
  if (yychar != YYEOF && yychar != YYEMPTY)
     yydestruct ("Cleanup: discarding lookahead",
		 yytoken, &yylval, &yylloc);
  /* Do not reclaim the symbols of the rule which action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
		  yystos[*yyssp], yyvsp, yylsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
#if YYERROR_VERBOSE
  if (yymsg != yymsgbuf)
    YYSTACK_FREE (yymsg);
#endif
  /* Make sure YYID is used.  */
  return YYID (yyresult);
}


#line 864 "/Users/david/Repository/FOSPods/FOSREST/Pod/Classes/Private/FOSAdapterBinding.ym"


extern NSError *parser_error;
extern NSMutableString *currentLine;

void yyerror(char *s, ...) {

    va_list ap;
    va_start(ap, s);

    char buf1[4096];
    char buf2[4096];

    buf1[0] = '\0';
    buf2[0] = '\0';

    if (yylloc.first_line) {
        sprintf(buf1, "Error: (%d:%d) - ", yylloc.first_line, yylloc.first_column);
    }
    vsprintf(buf2, s, ap);

    NSString *buf1Str = [NSString stringWithCString:buf1 encoding:NSASCIIStringEncoding];
    NSString *buf2Str = [NSString stringWithCString:buf2 encoding:NSASCIIStringEncoding];
    NSString *errorMessage = [buf1Str stringByAppendingString:buf2Str];

    // Remove linebreaks from line
    NSRange range = NSMakeRange(0, currentLine.length);
    [currentLine replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range];

    NSString *msg = [NSString stringWithFormat:@"%@ IN: '%@'", errorMessage, currentLine];

    parser_error = [NSError errorWithMessage:msg];

    FOSLogError(@"***************************************");
    FOSLogError(@"*** PARSER ERROR: %@", msg);
    FOSLogError(@"***************************************");
}


#pragma clang diagnostic pop

