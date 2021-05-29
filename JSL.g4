lexer grammar JSL;

INC                : '++';
DEC                : '--';
POWER              : '^';
NOT                : '!';
MUL                : '*';
EMUL               : ':*';
DIV                : '/';
EDIV               : ':/';
ADD                : '+';
MINUS              : '-';
MOD                : '%';
CONCAT             : '||';
VCONCAT            : '|/';
SEND               : '<<';
EQUAL              : '==';
NOT_EQUAL          : '!=';
LESS               : '<';
LESS_EQUAL         : '<=';
GREATER            : '>';
GREATER_EQUAL      : '>='; // Range checks allowed ( a < b <= c)
AND                : '&';
OR                 : '|';
ASSIGN             : '=';
ADD_TO             : '+=';
SUBTRACT_TO        : '-=';
MUL_TO             : '*=';
DIV_TO             : '/=';
MOD_TO             : '%=';
CONCAT_TO          : '||=';
VCONCAT_TO         : '|/=';
GLUE               : ';';
COLON              : ':';
DOUBLE_COLON       : '::';
COMMA              : ',';
BACK_QUOTE         : '`';


OPEN_PAREN         : '(';
CLOSE_PAREN        : ')';
OPEN_BRACE         : '{';
CLOSE_BRACE        : '}';
OPEN_BRACKET       : '[';
CLOSE_BRACKET      : ']';

BLOCK_COMMENT
    : '/*' ( BLOCK_COMMENT | . )*? '*/'
      -> channel(HIDDEN)
    ;

LINE_COMMENT
    :'//' ~[\r\n]*
      -> channel(HIDDEN)
    ;


STRING: '"' (~["] | ESCAPE_SEQUENCE)* '"';


MISSING: '.';
NUMBER // Can it start with 0?
    : [0-9]+ '.'? EXPONENT_PART?
    | [0-9]* '.' [0-9]+ EXPONENT_PART?;

// TODO: quoted name syntax i.e. "###"n and Name("###")
// Currently includes trailing whitespace in names
NAME: [_A-Za-z][_'%.\\0-9A-Za-z\u0080-\uFFFF \n\t\r]*;

WS: [ \t\r\n\u000C]+ -> channel(HIDDEN);

// TODO: fragment \[...]\

fragment ESCAPE_SEQUENCE
    : '\\!' [btrnNf0"\\]
    | '\\!' [uU] [0-9A-Fa-f] [0-9A-Fa-f] [0-9A-Fa-f] [0-9A-Fa-f]
    ;

fragment EXPONENT_PART
    : [eE] [+-]? [0-9]
    ;