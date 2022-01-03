/** A simple language for use with this sample plugin.
 *  It's C-like but without semicolons. Symbol resolution semantics are
 *  C-like: resolve symbol in current scope. If not in this scope, ask
 *  enclosing scope to resolve (recurse up tree until no more scopes or found).
 *  Forward refs allowed for functions but not variables. Globals must
 *  appear first syntactically.
 *
 *  Generate the parser via "mvn compile" from root dir of project.
 */
grammar SampleLanguage;

/** The start rule must be whatever you would normally use, such as script
 *  or compilationUnit, etc...
 */
script
	:	(function|statement)* EOF
	;

function
	:	'def' ID '(' formal_args? ')' block
	;

formal_args : formal_arg (',' formal_arg)* ;

formal_arg : ID ;

block
	: BLOCK_START? statement* BLOCK_END;

statement
	:	'if' '('? expr ')'? statement ('else' statement)?	# If
	|	'while' '(' expr ')' statement						# While
	|	vardef  											# Assign
	|	ID '[' expr ']' TO expr							    # ElementAssign
	|	call_expr											# CallStatement
    |   'print' '(' expr? ')'								# Print
	|	'return' expr										# Return
    |   BLOCK_END                                           # NestedBlockEnd
	;

vardef : SET ID TO expr ;

expr
	:	expr operator expr									# Op
	|	'-' expr											# Negate
	|	'!' expr											# Not
	|	call_expr											# Call
	|	ID '[' expr ']'										# Index
	|	LPAREN expr RPAREN									# Parens
	|	primary												# Atom
	;

operator  : MUL|DIV|ADD|SUB|GT|GE|LT|LE|EQUAL_EQUAL|NOT_EQUAL|OR|AND|DOT ; // no implicit precedence

call_expr
	: ID LPAREN expr_list? RPAREN ;

expr_list : expr (',' expr)* ;

primary
	:	ID													# Identifier
	|	INT													# Integer
	|	FLOAT												# Float
	|	STRING												# String
	|	'[' expr_list ']'									# Vector
	|	'true'												# TrueLiteral
	|	'false'												# FalseLiteral
	;

// custom (custom rules also at the end?):

LPAREN : '(' ;
RPAREN : ')' ;
COLON : 'COLON' ;
COMMA : ',' ;
LBRACK : '[' ;
RBRACK : ']' ;
BLOCK_START : ':' ;
BLOCK_END : 'end' ;
IF : 'if' ;
ELSE : 'else' ;
WHILE : 'while' ;
SET : 'set' ;
TO : 'to' ;
RETURN : 'return' ;
DEF : 'def' ;
PRINT : 'print' ;
TYPEINT : 'int' ;
TYPEFLOAT : 'float' ;
TYPESTRING : 'string' ;
TYPEBOOLEAN : 'boolean' ;
TRUE : 'true' ;
FALSE : 'false' ;
SUB : '-' ;
BANG : '!' ;
MUL : '*' ;
DIV : '/' ;
ADD : '+' ;
LT : '<' ;
LE : '<=' ;
EQUAL_EQUAL : '==' ;
NOT_EQUAL : '!=' ;
GT : '>' ;
GE : '>=' ;
OR : '||' ;
AND : '&&' ;
DOT : ' . ' ;

LINE_COMMENT : '--' .*? ('\n'|EOF)	-> channel(HIDDEN) ;
COMMENT      : '---' .*? '---'    	-> channel(HIDDEN) ;

ID  : [a-zA-Z_] [a-zA-Z0-9_]* ;
INT : [0-9]+ ;
FLOAT
	:   '-'? INT '.' INT EXP?   // 1.35, 1.35E-9, 0.3, -4.5
	|   '-'? INT EXP            // 1e10 -3e4
	;
fragment EXP :   [Ee] [+\-]? INT ;

STRING : (STRING_BASIC|STRING_ALT|STRING_INTERPOL) ;
fragment STRING_BASIC :  '"' STRING_CONTENT '"' ; // "string"
fragment STRING_ALT :  '\'' STRING_CONTENT '\'' ; // 'string'
fragment STRING_INTERPOL :  '`' STRING_CONTENT '`' ; // `string`
fragment STRING_CONTENT : (ESC | ~["\\])*;
fragment ESC :   '\\' ["\bfnrt] ;

WS : [ \t\n\r]+ -> channel(HIDDEN) ;

/** "catch all" rule for any char not matche in a token rule of your
 *  grammar. Lexers in Intellij must return all tokens good and bad.
 *  There must be a token to cover all characters, which makes sense, for
 *  an IDE. The parser however should not see these bad tokens because
 *  it just confuses the issue. Hence, the hidden channel.
 */
ERRCHAR
	:	.	-> channel(HIDDEN)
	;