//
//  Bison.h
//  FOSFoundation
//
//  Created by David Hunt on 3/21/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#ifndef FOSFoundation_Bison_h
#define FOSFoundation_Bison_h

typedef void* YY_BUFFER_STATE;
typedef void* yyscan_t;
extern YY_BUFFER_STATE yy_scan_buffer(char *, size_t);
extern void yylex_init(yyscan_t*);
extern YY_BUFFER_STATE yy_scan_string(const char */*, yyscan_t*/);
extern void yylex(yyscan_t);
extern void yylex_destroy(yyscan_t);

void yyrestart (FILE *input_file  );
void yy_switch_to_buffer (YY_BUFFER_STATE new_buffer  );
YY_BUFFER_STATE yy_create_buffer (FILE *file,int size  );
void yy_delete_buffer (YY_BUFFER_STATE b  );
void yy_flush_buffer (YY_BUFFER_STATE b  );
void yypush_buffer_state (YY_BUFFER_STATE new_buffer  );
void yypop_buffer_state (void );

extern void yyensure_buffer_stack (void );
extern void yy_load_buffer_state (void );
extern void yy_init_buffer (YY_BUFFER_STATE b,FILE *file  );

extern void yyparse();
extern void yyreset_state();

#endif
