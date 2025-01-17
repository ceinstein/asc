/*
 * Copyright (c) 2006, Adam Dunkels
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the author nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS LONGERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 */

#define DEBUG 0

#if DEBUG
#define DEBUG_PRINTF(...)  printf(__VA_ARGS__)
#else
#define DEBUG_PRINTF(...)
#endif


#include "ubasic.h"
#include "tokenizer.h"

#include <stdio.h> /* printf() */
#include <stdlib.h> /* exit() */

static char const *program_ptr;
#define MAX_STRINGLEN 40
static char string[MAX_STRINGLEN];

#define MAX_GOSUB_STACK_DEPTH 10
static long gosub_stack[MAX_GOSUB_STACK_DEPTH];
static long gosub_stack_ptr;

struct for_state {
  long line_after_for;
  long for_variable;
  long to;
};
#define MAX_FOR_STACK_DEPTH 4
static struct for_state for_stack[MAX_FOR_STACK_DEPTH];
static long for_stack_ptr;

#define MAX_VARNUM 26
static long variables[MAX_VARNUM];

static long ended;

static long expr(void);
static void line_statement(void);
static void statement(void);
/*---------------------------------------------------------------------------*/
void
ubasic_init(const char *program)
{
  program_ptr = program;
  for_stack_ptr = gosub_stack_ptr = 0;
  tokenizer_init(program);
  ended = 0;
}
/*---------------------------------------------------------------------------*/
static void
accept(long token)
{
  if(token != tokenizer_token()) {
    DEBUG_PRINTF("Token not what was expected (expected %ld, got %ld)\n",
		 token, tokenizer_token());
    tokenizer_error_print();
    exit(1);
  }
  DEBUG_PRINTF("Expected %ld, got it\n", token);
  tokenizer_next();
}
/*---------------------------------------------------------------------------*/
static long
varfactor(void)
{
  long r;
  DEBUG_PRINTF("varfactor: obtaining %ld from variable %ld\n", variables[tokenizer_variable_num()], tokenizer_variable_num());
  r = ubasic_get_variable(tokenizer_variable_num());
  accept(TOKENIZER_VARIABLE);
  return r;
}
/*---------------------------------------------------------------------------*/
static long
factor(void)
{
  long r;

  DEBUG_PRINTF("factor: token %ld\n", tokenizer_token());
  switch(tokenizer_token()) {
  case TOKENIZER_NUMBER:
    r = tokenizer_num();
    DEBUG_PRINTF("factor: number %ld\n", r);
    accept(TOKENIZER_NUMBER);
    break;
  case TOKENIZER_LEFTPAREN:
    accept(TOKENIZER_LEFTPAREN);
    r = expr();
    accept(TOKENIZER_RIGHTPAREN);
    break;
  default:
    r = varfactor();
    break;
  }
  return r;
}
/*---------------------------------------------------------------------------*/
static long
term(void)
{
  long f1, f2;
  long op;

  f1 = factor();
  op = tokenizer_token();
  DEBUG_PRINTF("term: token %ld\n", op);
  while(op == TOKENIZER_ASTR ||
	op == TOKENIZER_SLASH ||
	op == TOKENIZER_MOD) {
    tokenizer_next();
    f2 = factor();
    DEBUG_PRINTF("term: %ld %ld %ld\n", f1, op, f2);
    switch(op) {
    case TOKENIZER_ASTR:
      f1 = f1 * f2;
      break;
    case TOKENIZER_SLASH:
      f1 = f1 / f2;
      break;
    case TOKENIZER_MOD:
      f1 = f1 % f2;
      break;
    }
    op = tokenizer_token();
  }
  DEBUG_PRINTF("term: %ld\n", f1);
  return f1;
}
/*---------------------------------------------------------------------------*/
static long
expr(void)
{
  long t1, t2;
  long op;
  
  t1 = term();
  op = tokenizer_token();
  DEBUG_PRINTF("expr: token %ld\n", op);
  while(op == TOKENIZER_PLUS ||
	op == TOKENIZER_MINUS ||
	op == TOKENIZER_AND ||
	op == TOKENIZER_OR) {
    tokenizer_next();
    t2 = term();
    DEBUG_PRINTF("expr: %ld %ld %ld\n", t1, op, t2);
    switch(op) {
    case TOKENIZER_PLUS:
      t1 = t1 + t2;
      break;
    case TOKENIZER_MINUS:
      t1 = t1 - t2;
      break;
    case TOKENIZER_AND:
      t1 = t1 & t2;
      break;
    case TOKENIZER_OR:
      t1 = t1 | t2;
      break;
    }
    op = tokenizer_token();
  }
  DEBUG_PRINTF("expr: %ld\n", t1);
  return t1;
}
/*---------------------------------------------------------------------------*/
static long
relation(void)
{
  long r1, r2;
  long op;
  
  r1 = expr();
  op = tokenizer_token();
  DEBUG_PRINTF("relation: token %ld\n", op);
  while(op == TOKENIZER_LT ||
	op == TOKENIZER_GT ||
	op == TOKENIZER_EQ) {
    tokenizer_next();
    r2 = expr();
    DEBUG_PRINTF("relation: %ld %ld %ld\n", r1, op, r2);
    switch(op) {
    case TOKENIZER_LT:
      r1 = r1 < r2;
      break;
    case TOKENIZER_GT:
      r1 = r1 > r2;
      break;
    case TOKENIZER_EQ:
      r1 = r1 == r2;
      break;
    }
    op = tokenizer_token();
  }
  return r1;
}
/*---------------------------------------------------------------------------*/
static void
jump_linenum(long linenum)
{
  tokenizer_init(program_ptr);
  while(tokenizer_num() != linenum) {
    do {
      do {
	tokenizer_next();
      } while(tokenizer_token() != TOKENIZER_CR &&
	      tokenizer_token() != TOKENIZER_ENDOFINPUT);
      if(tokenizer_token() == TOKENIZER_CR) {
	tokenizer_next();
      }
    } while(tokenizer_token() != TOKENIZER_NUMBER);
    DEBUG_PRINTF("jump_linenum: Found line %ld\n", tokenizer_num());
  }
}
/*---------------------------------------------------------------------------*/
static void
goto_statement(void)
{ 
#ifdef TRACE_GOTO
  asm volatile ("xchgw %%bx, %%bx; xchgw %%bx, %%bx" :::);
#endif
  accept(TOKENIZER_GOTO);
  jump_linenum(tokenizer_num());
}
/*---------------------------------------------------------------------------*/
static void
print_statement(void)
{
  accept(TOKENIZER_PRINT);
  do {
    DEBUG_PRINTF("Print loop\n");
    if(tokenizer_token() == TOKENIZER_STRING) {
      tokenizer_string(string, sizeof(string));
      printf("%s", string);
      tokenizer_next();
    } else if(tokenizer_token() == TOKENIZER_COMMA) {
      printf(" ");
      tokenizer_next();
    } else if(tokenizer_token() == TOKENIZER_SEMICOLON) {
      tokenizer_next();
    } else if(tokenizer_token() == TOKENIZER_VARIABLE ||
	      tokenizer_token() == TOKENIZER_NUMBER) {
      printf("%ld", expr());
    } else {
      break;
    }
  } while(tokenizer_token() != TOKENIZER_CR &&
	  tokenizer_token() != TOKENIZER_ENDOFINPUT);
  printf("\n");
  DEBUG_PRINTF("End of print\n");
  tokenizer_next();
}
/*---------------------------------------------------------------------------*/
static void
if_statement(void)
{
  long r;
  
  accept(TOKENIZER_IF);

  r = relation();
  DEBUG_PRINTF("if_statement: relation %ld\n", r);
  accept(TOKENIZER_THEN);
  if(r) {
    statement();
  } else {
    do {
      tokenizer_next();
    } while(tokenizer_token() != TOKENIZER_ELSE &&
	    tokenizer_token() != TOKENIZER_CR &&
	    tokenizer_token() != TOKENIZER_ENDOFINPUT);
    if(tokenizer_token() == TOKENIZER_ELSE) {
      tokenizer_next();
      statement();
    } else if(tokenizer_token() == TOKENIZER_CR) {
      tokenizer_next();
    }
  }
}
/*---------------------------------------------------------------------------*/
static void
let_statement(void)
{
  long var;

  var = tokenizer_variable_num();

  accept(TOKENIZER_VARIABLE);
  accept(TOKENIZER_EQ);
  ubasic_set_variable(var, expr());
  DEBUG_PRINTF("let_statement: assign %ld to %ld\n", variables[var], var);
  accept(TOKENIZER_CR);

}
/*---------------------------------------------------------------------------*/
static void
gosub_statement(void)
{
  long linenum;
  accept(TOKENIZER_GOSUB);
  linenum = tokenizer_num();
  accept(TOKENIZER_NUMBER);
  accept(TOKENIZER_CR);
  if(gosub_stack_ptr < MAX_GOSUB_STACK_DEPTH) {
    gosub_stack[gosub_stack_ptr] = tokenizer_num();
    gosub_stack_ptr++;
    jump_linenum(linenum);
  } else {
    DEBUG_PRINTF("gosub_statement: gosub stack exhausted\n");
  }
}
/*---------------------------------------------------------------------------*/
static void
return_statement(void)
{
  accept(TOKENIZER_RETURN);
  if(gosub_stack_ptr > 0) {
    gosub_stack_ptr--;
    jump_linenum(gosub_stack[gosub_stack_ptr]);
  } else {
    DEBUG_PRINTF("return_statement: non-matching return\n");
  }
}
/*---------------------------------------------------------------------------*/
static void
next_statement(void)
{
  long var;
  
  accept(TOKENIZER_NEXT);
  var = tokenizer_variable_num();
  accept(TOKENIZER_VARIABLE);
  if(for_stack_ptr > 0 &&
     var == for_stack[for_stack_ptr - 1].for_variable) {
    ubasic_set_variable(var,
			ubasic_get_variable(var) + 1);
    if(ubasic_get_variable(var) <= for_stack[for_stack_ptr - 1].to) {
      jump_linenum(for_stack[for_stack_ptr - 1].line_after_for);
    } else {
      for_stack_ptr--;
      accept(TOKENIZER_CR);
    }
  } else {
    DEBUG_PRINTF("next_statement: non-matching next (expected %ld, found %ld)\n", for_stack[for_stack_ptr - 1].for_variable, var);
    accept(TOKENIZER_CR);
  }

}
/*---------------------------------------------------------------------------*/
static void
for_statement(void)
{
  long for_variable, to;
  
  accept(TOKENIZER_FOR);
  for_variable = tokenizer_variable_num();
  accept(TOKENIZER_VARIABLE);
  accept(TOKENIZER_EQ);
  ubasic_set_variable(for_variable, expr());
  accept(TOKENIZER_TO);
  to = expr();
  accept(TOKENIZER_CR);

  if(for_stack_ptr < MAX_FOR_STACK_DEPTH) {
    for_stack[for_stack_ptr].line_after_for = tokenizer_num();
    for_stack[for_stack_ptr].for_variable = for_variable;
    for_stack[for_stack_ptr].to = to;
    DEBUG_PRINTF("for_statement: new for, var %ld to %ld\n",
		 for_stack[for_stack_ptr].for_variable,
		 for_stack[for_stack_ptr].to);
		 
    for_stack_ptr++;
  } else {
    DEBUG_PRINTF("for_statement: for stack depth exceeded\n");
  }
}
/*---------------------------------------------------------------------------*/
static void
end_statement(void)
{
  accept(TOKENIZER_END);
  ended = 1;
}
/*---------------------------------------------------------------------------*/
static void
statement(void)
{
  long token;
  
  token = tokenizer_token();
  
  switch(token) {
  case TOKENIZER_PRINT:
    print_statement();
    break;
  case TOKENIZER_IF:
    if_statement();
    break;
  case TOKENIZER_GOTO:
    goto_statement();
    break;
  case TOKENIZER_GOSUB:
    gosub_statement();
    break;
  case TOKENIZER_RETURN:
    return_statement();
    break;
  case TOKENIZER_FOR:
    for_statement();
    break;
  case TOKENIZER_NEXT:
    next_statement();
    break;
  case TOKENIZER_END:
    end_statement();
    break;
  case TOKENIZER_LET:
    accept(TOKENIZER_LET);
    /* Fall through. */
  case TOKENIZER_VARIABLE:
    let_statement();
    break;
  default:
    DEBUG_PRINTF("ubasic.c: statement(): not implemented %ld\n", token);
    exit(1);
  }
}
/*---------------------------------------------------------------------------*/
static void
line_statement(void)
{
  DEBUG_PRINTF("----------- Line number %ld ---------\n", tokenizer_num());
  /*    current_linenum = tokenizer_num();*/
  accept(TOKENIZER_NUMBER);
  statement();
  return;
}
/*---------------------------------------------------------------------------*/
void
ubasic_run(void)
{
  if(tokenizer_finished()) {
    DEBUG_PRINTF("uBASIC program finished\n");
    return;
  }

  line_statement();
}
/*---------------------------------------------------------------------------*/
long
ubasic_finished(void)
{
  return ended || tokenizer_finished();
}
/*---------------------------------------------------------------------------*/
void
ubasic_set_variable(long varnum, long value)
{
  if(varnum > 0 && varnum <= MAX_VARNUM) {
    variables[varnum] = value;
  }
}
/*---------------------------------------------------------------------------*/
long
ubasic_get_variable(long varnum)
{
  if(varnum > 0 && varnum <= MAX_VARNUM) {
    return variables[varnum];
  }
  return 0;
}
/*---------------------------------------------------------------------------*/
