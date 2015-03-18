/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton interface for Bison's Yacc-like parsers in C

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
/* Line 1529 of yacc.c.  */
#line 202 "/Users/david/Library/Developer/Xcode/DerivedData/FOSREST-fodkpoehriibrldqgafemiosbmld/Build/Intermediates/Pods.build/Debug-iphonesimulator/Pods-FOSRESTApp-fosrest.build/DerivedSources/y.tab.h"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;

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

extern YYLTYPE yylloc;
