grammar JSL;

script: expr_sequence? EOF;

expr_sequence: expr ((';' expr) | ';')*;

expr:
	func_call
	| expr '[' (expr (',' expr)?)? ']'
	| (func_call | paren_expr) ':' (name | func_call)
	| expr ('++' | '--')
	| <assoc = right> expr '^' expr
	| ('-' | '!') expr
	| expr '`'
	| expr ('>>' | '>?') expr
	| expr ('*' | '/' | ':*' | ':/') expr
	| expr ('+' | '-') expr
	| expr '||' expr
	| expr '|/' expr
	| expr '::' expr
	| expr message
	| message
	| expr ('==' | '!=' | '<=' | '>=' | '>' | '<') expr
	| expr ('&' | '|') expr
	| <assoc = right> expr (
		'='
		| '+='
		| '-='
		| '*='
		| '/='
		| '||='
		| '|/='
	) expr
	| paren_expr
	| '{' list_elements? '}'
	| '[' (
		aa_entry (',' aa_entry)* (',' aa_default)?
		| aa_default
		| '=>'
	) ']'
	| '[' (matrix_row ((',' | ';') matrix_row)*)? ']'
  | STRING
  | NUMBER
  | name;

func_call: (name | STRING) '(' arg_list? ')'; // STRING only in the case of NewObject

arg_list: ','* expr_sequence (','+ expr_sequence)* ','*; // Extra commas allowed in function calls
list_elements: ','* expr_sequence (',' expr_sequence)*; // Extra commas allowed at beginning
paren_expr: '(' expr_sequence ')';
message: '<<' expr;

matrix_row: ('-'? NUMBER)+;

aa_entry: expr '=>' expr;
aa_default: '=>' expr;

atom: NUMBER | STRING | name;

name: NAME | scoped_name;

scoped_name:
	':::' NAME (':' NAME)*
	| '::' NAME (':' NAME)*
	| ':' NAME
	| NAME (':' NAME)+
	| STRING (':' NAME)+;

INC:                '++';
DEC:                '--';
POWER:              '^';
NOT:                '!';
MUL:                '*';
EMUL:               ':*';
DIV:                '/';
EDIV:               ':/';
ADD:                '+';
MINUS:              '-';
CONCAT:             '||';
VCONCAT:            '|/';
SEND:               '<<';
EQUAL:              '==';
NOT_EQUAL:          '!=';
LESS:               '<';
LESS_EQUAL:         '<=';
GREATER:            '>';
GREATER_EQUAL:      '>=';
AND:                '&';
OR:                 '|';
ASSIGN:             '=';
ADD_TO:             '+=';
SUBTRACT_TO:        '-=';
MUL_TO:             '*=';
DIV_TO:             '/=';
CONCAT_TO:          '||=';
VCONCAT_TO:         '|/=';
GLUE:               ';';
COLON:              ':';
DOUBLE_COLON:       '::';
TRIPLE_COLON:       ':::';
COMMA:              ',';
BACK_QUOTE:         '`';
ARROW:              '=>';
PAT_CONDITIONAL:    '>?';
PAT_IMMEDIATE:      '>>';

OPEN_PAREN:         '(';
CLOSE_PAREN:        ')';
OPEN_BRACE:         '{';
CLOSE_BRACE:        '}';
OPEN_BRACKET:       '[';
CLOSE_BRACKET:      ']';

// Each nested comment must be closed
BLOCK_COMMENT:
	'/*' ('/'*? BLOCK_COMMENT | ('/'* | '*'*) ~[/*])*? '*'*? '*/' -> channel(HIDDEN);

LINE_COMMENT: '//' ~[\r\n]* -> channel(HIDDEN);

STRING: '"' ( ESCAPE_SEQUENCE | RAW | ~["])* '"';

NUMBER:
	[0-9]+ '.'? EXPONENT_PART?
	| [0-9]* '.' [0-9]+ EXPONENT_PART?
	| MISSING
	| DATE;

DATE:
	[0-3]? [0-9] (
		[jJ][aA][nN]
		| [fF][eE][bB]
		| [mM][aA][rR]
		| [aA][pP][rR]
		| [mM][aA][yY]
		| [jJ][uU][nN]
		| [jJ][uU][lL]
		| [aA][uU][gG]
		| [sS][eE][pP]
		| [oO][cC][tT]
		| [nN][oO][vV]
		| [dD][eE][cC]
	) [0-9]+;

MISSING: '.';

// Currently includes trailing whitespace in names
NAME:
  [_A-Za-z][_'%.\\0-9A-Za-z\u0080-\uFFFF \n\t\r]*
  | STRING 'n';

WS: [ \t\r\n]+ -> channel(HIDDEN);

// TODO: Don't allow "\["
fragment RAW: '\\[' .*? ']\\';
fragment ESCAPE_SEQUENCE:
	'\\!' [btrnNf0"\\]
	| '\\!' [uU] [0-9A-Fa-f] [0-9A-Fa-f] [0-9A-Fa-f] [0-9A-Fa-f];

fragment EXPONENT_PART: [eE] [+-]? [0-9];
