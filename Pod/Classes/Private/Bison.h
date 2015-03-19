//
//  Bison.h
//  FOSRest
//
//  Created by David Hunt on 3/21/14.
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
