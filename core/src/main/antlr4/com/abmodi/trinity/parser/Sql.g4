grammar Sql;

@members {

  /**
   * Verify whether current token is a valid decimal token (which contains dot).
   * Returns true if the character that follows the token is not a digit or letter or underscore.
   *
   * For example:
   * For char stream "2.3", "2." is not a valid decimal token, because it is followed by digit '3'.
   * For char stream "2.3_", "2.3" is not a valid decimal token, because it is followed by '_'.
   * For char stream "2.3W", "2.3" is not a valid decimal token, because it is followed by 'W'.
   * For char stream "12.0D 34.E2+0.12 "  12.0D is a valid decimal token because it is followed
   * by a space. 34.E2 is a valid decimal token because it is followed by symbol '+'
   * which is not a digit or letter or underscore.
   */
  public boolean isValidDecimal() {
    int nextChar = _input.LA(1);
    if (nextChar >= 'A' && nextChar <= 'Z' || nextChar >= '0' && nextChar <= '9' ||
      nextChar == '_') {
      return false;
    } else {
      return true;
    }
  }
}

singleStatement
    : statement EOF
    ;

singleExpression
    : namedExpression EOF
    ;

singleTableIdentifier
    : tableIdentifier EOF
    ;


statement
    : query                                                            #statementDefault
    ;

query
    : queryNoWith
    ;

constantList
    : '(' constant (',' constant)* ')'
    ;

nestedConstantList
    : '(' constantList (',' constantList)* ')'
    ;

resource
    : identifier STRING
    ;

queryNoWith
    : queryTerm queryOrganization
    ;

queryOrganization
    : (ORDER BY order+=sortItem (',' order+=sortItem)*)?
      (SORT BY sort+=sortItem (',' sort+=sortItem)*)?
      (LIMIT (ALL | limit=expression))?
    ;

queryTerm
    : queryPrimary                                                                       #queryTermDefault
    ;

queryPrimary
    : querySpecification                                                    #queryPrimaryDefault
    ;

sortItem
    : expression ordering=(ASC | DESC)?
    ;

querySpecification
    : (SELECT setQuantifier? namedExpressionSeq fromClause?
       (WHERE where=booleanExpression)?
       aggregation?
       (HAVING having=booleanExpression)?
       windows?)
    ;

fromClause
    : FROM relation (',' relation)*
    ;

aggregation
    : GROUP BY groupingExpressions+=expression (',' groupingExpressions+=expression)* (
      WITH kind=ROLLUP
    | WITH kind=CUBE
    | kind=GROUPING SETS '(' groupingSet (',' groupingSet)* ')')?
    | GROUP BY kind=GROUPING SETS '(' groupingSet (',' groupingSet)* ')'
    ;

groupingSet
    : '(' (expression (',' expression)*)? ')'
    | expression
    ;

setQuantifier
    : DISTINCT
    | ALL
    ;

relation
    : relationPrimary joinRelation*
    ;

joinRelation
    : (joinType) JOIN right=relationPrimary joinCriteria?
    | NATURAL joinType JOIN right=relationPrimary
    ;

joinType
    : INNER?
    | CROSS
    | LEFT OUTER?
    | LEFT SEMI
    | RIGHT OUTER?
    | FULL OUTER?
    | LEFT? ANTI
    ;

joinCriteria
    : ON booleanExpression
    | USING '(' identifier (',' identifier)* ')'
    ;

identifierList
    : '(' identifierSeq ')'
    ;

identifierSeq
    : identifier (',' identifier)*
    ;

orderedIdentifierList
    : '(' orderedIdentifier (',' orderedIdentifier)* ')'
    ;

orderedIdentifier
    : identifier ordering=(ASC | DESC)?
    ;

identifierCommentList
    : '(' identifierComment (',' identifierComment)* ')'
    ;

identifierComment
    : identifier (COMMENT STRING)?
    ;

relationPrimary
    : tableIdentifier      #tableName
    ;

tableIdentifier
    : table=identifier
    ;

namedExpression
    : expression (AS? (identifier | identifierList))?
    ;

namedExpressionSeq
    : namedExpression (',' namedExpression)*
    ;

expression
    : booleanExpression
    ;

booleanExpression
    : NOT booleanExpression                                        #logicalNot
    | EXISTS '(' query ')'                                         #exists
    | valueExpression predicate?                                   #predicated
    | left=booleanExpression operator=AND right=booleanExpression  #logicalBinary
    | left=booleanExpression operator=OR right=booleanExpression   #logicalBinary
    ;

predicate
    : NOT? kind=BETWEEN lower=valueExpression AND upper=valueExpression
    | NOT? kind=IN '(' expression (',' expression)* ')'
    | NOT? kind=IN '(' query ')'
    | NOT? kind=(RLIKE | LIKE) pattern=valueExpression
    | IS NOT? kind=NULL
    | IS NOT? kind=DISTINCT FROM right=valueExpression
    ;

valueExpression
    : primaryExpression                                                                      #valueExpressionDefault
    | operator=(MINUS | PLUS | TILDE) valueExpression                                        #arithmeticUnary
    | left=valueExpression operator=(ASTERISK | SLASH | PERCENT | DIV) right=valueExpression #arithmeticBinary
    | left=valueExpression operator=(PLUS | MINUS | CONCAT_PIPE) right=valueExpression       #arithmeticBinary
    | left=valueExpression operator=AMPERSAND right=valueExpression                          #arithmeticBinary
    | left=valueExpression operator=HAT right=valueExpression                                #arithmeticBinary
    | left=valueExpression operator=PIPE right=valueExpression                               #arithmeticBinary
    | left=valueExpression comparisonOperator right=valueExpression                          #comparison
    ;

primaryExpression
    : CASE whenClause+ (ELSE elseExpression=expression)? END                                   #searchedCase
    | CASE value=expression whenClause+ (ELSE elseExpression=expression)? END                  #simpleCase
    | STRUCT '(' (argument+=namedExpression (',' argument+=namedExpression)*)? ')'             #struct
    | FIRST '(' expression (IGNORE NULLS)? ')'                                                 #first
    | LAST '(' expression (IGNORE NULLS)? ')'                                                  #last
    | POSITION '(' substr=valueExpression IN str=valueExpression ')'                           #position
    | constant                                                                                 #constantDefault
    | ASTERISK                                                                                 #star
    | qualifiedName '.' ASTERISK                                                               #star
    | '(' namedExpression (',' namedExpression)+ ')'                                           #rowConstructor
    | '(' query ')'                                                                            #subqueryExpression
    | qualifiedName '(' (setQuantifier? argument+=expression (',' argument+=expression)*)? ')'
       (OVER windowSpec)?                                                                      #functionCall
    | qualifiedName '(' trimOption=(BOTH | LEADING | TRAILING) argument+=expression
      FROM argument+=expression ')'                                                            #functionCall
    | IDENTIFIER '->' expression                                                               #lambda
    | '(' IDENTIFIER (',' IDENTIFIER)+ ')' '->' expression                                     #lambda
    | value=primaryExpression '[' index=valueExpression ']'                                    #subscript
    | identifier                                                                               #columnReference
    | base=primaryExpression '.' fieldName=identifier                                          #dereference
    | '(' expression ')'                                                                       #parenthesizedExpression
    | EXTRACT '(' field=identifier FROM source=valueExpression ')'                             #extract
    ;

constant
    : NULL                                                                                     #nullLiteral
    | interval                                                                                 #intervalLiteral
    | identifier STRING                                                                        #typeConstructor
    | number                                                                                   #numericLiteral
    | booleanValue                                                                             #booleanLiteral
    | STRING+                                                                                  #stringLiteral
    ;

comparisonOperator
    : EQ | NEQ | NEQJ | LT | LTE | GT | GTE | NSEQ
    ;

arithmeticOperator
    : PLUS | MINUS | ASTERISK | SLASH | PERCENT | DIV | TILDE | AMPERSAND | PIPE | CONCAT_PIPE | HAT
    ;

predicateOperator
    : OR | AND | IN | NOT
    ;

booleanValue
    : TRUE | FALSE
    ;

interval
    : INTERVAL intervalField*
    ;

intervalField
    : value=intervalValue unit=identifier (TO to=identifier)?
    ;

intervalValue
    : (PLUS | MINUS)? (INTEGER_VALUE | DECIMAL_VALUE)
    | STRING
    ;

whenClause
    : WHEN condition=expression THEN result=expression
    ;

windows
    : WINDOW namedWindow (',' namedWindow)*
    ;

namedWindow
    : identifier AS windowSpec
    ;

windowSpec
    : name=identifier  #windowRef
    | '('name=identifier')'  #windowRef
    | '('
      ( CLUSTER BY partition+=expression (',' partition+=expression)*
      | ((PARTITION | DISTRIBUTE) BY partition+=expression (',' partition+=expression)*)?
        ((ORDER | SORT) BY sortItem (',' sortItem)*)?)
      windowFrame?
      ')'              #windowDef
    ;

windowFrame
    : frameType=RANGE start=frameBound
    | frameType=ROWS start=frameBound
    | frameType=RANGE BETWEEN start=frameBound AND end=frameBound
    | frameType=ROWS BETWEEN start=frameBound AND end=frameBound
    ;

frameBound
    : UNBOUNDED boundType=(PRECEDING | FOLLOWING)
    | boundType=CURRENT ROW
    | expression boundType=(PRECEDING | FOLLOWING)
    ;

qualifiedName
    : identifier ('.' identifier)*
    ;

identifier
    : strictIdentifier
    | ANTI | FULL | INNER | LEFT | SEMI | RIGHT | NATURAL | JOIN | CROSS | ON
    | UNION | INTERSECT | EXCEPT | SETMINUS
    ;

strictIdentifier
    : IDENTIFIER             #unquotedIdentifier
    | quotedIdentifier       #quotedIdentifierAlternative
    | nonReserved            #unquotedIdentifier
    ;

quotedIdentifier
    : BACKQUOTED_IDENTIFIER
    ;

number
    : MINUS? DECIMAL_VALUE            #decimalLiteral
    | MINUS? INTEGER_VALUE            #integerLiteral
    | MINUS? BIGINT_LITERAL           #bigIntLiteral
    | MINUS? SMALLINT_LITERAL         #smallIntLiteral
    | MINUS? TINYINT_LITERAL          #tinyIntLiteral
    | MINUS? DOUBLE_LITERAL           #doubleLiteral
    | MINUS? BIGDECIMAL_LITERAL       #bigDecimalLiteral
    ;

nonReserved
    : SHOW | TABLES | COLUMNS | COLUMN | PARTITIONS | FUNCTIONS | DATABASES
    | ADD
    | OVER | PARTITION | RANGE | ROWS | PRECEDING | FOLLOWING | CURRENT | ROW | LAST | FIRST | AFTER
    | MAP | ARRAY | STRUCT
    | PIVOT | LATERAL | WINDOW | REDUCE | TRANSFORM | SERDE | SERDEPROPERTIES | RECORDREADER
    | DELIMITED | FIELDS | TERMINATED | COLLECTION | ITEMS | KEYS | ESCAPED | LINES | SEPARATED
    | EXTENDED | REFRESH | CLEAR | CACHE | UNCACHE | LAZY | GLOBAL | TEMPORARY | OPTIONS
    | GROUPING | CUBE | ROLLUP
    | EXPLAIN | FORMAT | LOGICAL | FORMATTED | CODEGEN | COST
    | TABLESAMPLE | USE | TO | BUCKET | PERCENTLIT | OUT | OF
    | SET | RESET
    | VIEW | REPLACE
    | IF
    | POSITION
    | EXTRACT
    | NO | DATA
    | START | TRANSACTION | COMMIT | ROLLBACK | IGNORE
    | SORT | CLUSTER | DISTRIBUTE | UNSET | TBLPROPERTIES | SKEWED | STORED | DIRECTORIES | LOCATION
    | EXCHANGE | ARCHIVE | UNARCHIVE | FILEFORMAT | TOUCH | COMPACT | CONCATENATE | CHANGE
    | CASCADE | RESTRICT | BUCKETS | CLUSTERED | SORTED | PURGE | INPUTFORMAT | OUTPUTFORMAT
    | DBPROPERTIES | DFS | TRUNCATE | COMPUTE | LIST
    | STATISTICS | ANALYZE | PARTITIONED | EXTERNAL | DEFINED | RECORDWRITER
    | REVOKE | GRANT | LOCK | UNLOCK | MSCK | REPAIR | RECOVER | EXPORT | IMPORT | LOAD | VALUES | COMMENT | ROLE
    | ROLES | COMPACTIONS | PRINCIPALS | TRANSACTIONS | INDEX | INDEXES | LOCKS | OPTION | LOCAL | INPATH
    | ASC | DESC | LIMIT | RENAME | SETS
    | AT | NULLS | OVERWRITE | ALL | ANY | ALTER | AS | BETWEEN | BY | CREATE | DELETE
    | DESCRIBE | DROP | EXISTS | FALSE | FOR | GROUP | IN | INSERT | INTO | IS |LIKE
    | NULL | ORDER | OUTER | TABLE | TRUE | WITH | RLIKE
    | AND | CASE | CAST | DISTINCT | DIV | ELSE | END | FUNCTION | INTERVAL | MACRO | OR | STRATIFY | THEN
    | UNBOUNDED | WHEN
    | DATABASE | SELECT | FROM | WHERE | HAVING | TO | TABLE | WITH | NOT
    | DIRECTORY
    | BOTH | LEADING | TRAILING
    ;

SELECT: 'SELECT';
FROM: 'FROM';
ADD: 'ADD';
AS: 'AS';
ALL: 'ALL';
ANY: 'ANY';
DISTINCT: 'DISTINCT';
WHERE: 'WHERE';
GROUP: 'GROUP';
BY: 'BY';
GROUPING: 'GROUPING';
SETS: 'SETS';
CUBE: 'CUBE';
ROLLUP: 'ROLLUP';
ORDER: 'ORDER';
HAVING: 'HAVING';
LIMIT: 'LIMIT';
AT: 'AT';
OR: 'OR';
AND: 'AND';
IN: 'IN';
NOT: 'NOT' | '!';
NO: 'NO';
EXISTS: 'EXISTS';
BETWEEN: 'BETWEEN';
LIKE: 'LIKE';
RLIKE: 'RLIKE' | 'REGEXP';
IS: 'IS';
NULL: 'NULL';
TRUE: 'TRUE';
FALSE: 'FALSE';
NULLS: 'NULLS';
ASC: 'ASC';
DESC: 'DESC';
FOR: 'FOR';
INTERVAL: 'INTERVAL';
CASE: 'CASE';
WHEN: 'WHEN';
THEN: 'THEN';
ELSE: 'ELSE';
END: 'END';
JOIN: 'JOIN';
CROSS: 'CROSS';
OUTER: 'OUTER';
INNER: 'INNER';
LEFT: 'LEFT';
SEMI: 'SEMI';
RIGHT: 'RIGHT';
FULL: 'FULL';
NATURAL: 'NATURAL';
ON: 'ON';
PIVOT: 'PIVOT';
LATERAL: 'LATERAL';
WINDOW: 'WINDOW';
OVER: 'OVER';
PARTITION: 'PARTITION';
RANGE: 'RANGE';
ROWS: 'ROWS';
UNBOUNDED: 'UNBOUNDED';
PRECEDING: 'PRECEDING';
FOLLOWING: 'FOLLOWING';
CURRENT: 'CURRENT';
FIRST: 'FIRST';
AFTER: 'AFTER';
LAST: 'LAST';
ROW: 'ROW';
WITH: 'WITH';
VALUES: 'VALUES';
CREATE: 'CREATE';
TABLE: 'TABLE';
DIRECTORY: 'DIRECTORY';
VIEW: 'VIEW';
REPLACE: 'REPLACE';
INSERT: 'INSERT';
DELETE: 'DELETE';
INTO: 'INTO';
DESCRIBE: 'DESCRIBE';
EXPLAIN: 'EXPLAIN';
FORMAT: 'FORMAT';
LOGICAL: 'LOGICAL';
CODEGEN: 'CODEGEN';
COST: 'COST';
CAST: 'CAST';
SHOW: 'SHOW';
TABLES: 'TABLES';
COLUMNS: 'COLUMNS';
COLUMN: 'COLUMN';
USE: 'USE';
PARTITIONS: 'PARTITIONS';
FUNCTIONS: 'FUNCTIONS';
DROP: 'DROP';
UNION: 'UNION';
EXCEPT: 'EXCEPT';
SETMINUS: 'MINUS';
INTERSECT: 'INTERSECT';
TO: 'TO';
TABLESAMPLE: 'TABLESAMPLE';
STRATIFY: 'STRATIFY';
ALTER: 'ALTER';
RENAME: 'RENAME';
ARRAY: 'ARRAY';
MAP: 'MAP';
STRUCT: 'STRUCT';
COMMENT: 'COMMENT';
SET: 'SET';
RESET: 'RESET';
DATA: 'DATA';
START: 'START';
TRANSACTION: 'TRANSACTION';
COMMIT: 'COMMIT';
ROLLBACK: 'ROLLBACK';
MACRO: 'MACRO';
IGNORE: 'IGNORE';
BOTH: 'BOTH';
LEADING: 'LEADING';
TRAILING: 'TRAILING';

IF: 'IF';
POSITION: 'POSITION';
EXTRACT: 'EXTRACT';

EQ  : '=' | '==';
NSEQ: '<=>';
NEQ : '<>';
NEQJ: '!=';
LT  : '<';
LTE : '<=' | '!>';
GT  : '>';
GTE : '>=' | '!<';

PLUS: '+';
MINUS: '-';
ASTERISK: '*';
SLASH: '/';
PERCENT: '%';
DIV: 'DIV';
TILDE: '~';
AMPERSAND: '&';
PIPE: '|';
CONCAT_PIPE: '||';
HAT: '^';

PERCENTLIT: 'PERCENT';
BUCKET: 'BUCKET';
OUT: 'OUT';
OF: 'OF';

SORT: 'SORT';
CLUSTER: 'CLUSTER';
DISTRIBUTE: 'DISTRIBUTE';
OVERWRITE: 'OVERWRITE';
TRANSFORM: 'TRANSFORM';
REDUCE: 'REDUCE';
USING: 'USING';
SERDE: 'SERDE';
SERDEPROPERTIES: 'SERDEPROPERTIES';
RECORDREADER: 'RECORDREADER';
RECORDWRITER: 'RECORDWRITER';
DELIMITED: 'DELIMITED';
FIELDS: 'FIELDS';
TERMINATED: 'TERMINATED';
COLLECTION: 'COLLECTION';
ITEMS: 'ITEMS';
KEYS: 'KEYS';
ESCAPED: 'ESCAPED';
LINES: 'LINES';
SEPARATED: 'SEPARATED';
FUNCTION: 'FUNCTION';
EXTENDED: 'EXTENDED';
REFRESH: 'REFRESH';
CLEAR: 'CLEAR';
CACHE: 'CACHE';
UNCACHE: 'UNCACHE';
LAZY: 'LAZY';
FORMATTED: 'FORMATTED';
GLOBAL: 'GLOBAL';
TEMPORARY: 'TEMPORARY' | 'TEMP';
OPTIONS: 'OPTIONS';
UNSET: 'UNSET';
TBLPROPERTIES: 'TBLPROPERTIES';
DBPROPERTIES: 'DBPROPERTIES';
BUCKETS: 'BUCKETS';
SKEWED: 'SKEWED';
STORED: 'STORED';
DIRECTORIES: 'DIRECTORIES';
LOCATION: 'LOCATION';
EXCHANGE: 'EXCHANGE';
ARCHIVE: 'ARCHIVE';
UNARCHIVE: 'UNARCHIVE';
FILEFORMAT: 'FILEFORMAT';
TOUCH: 'TOUCH';
COMPACT: 'COMPACT';
CONCATENATE: 'CONCATENATE';
CHANGE: 'CHANGE';
CASCADE: 'CASCADE';
RESTRICT: 'RESTRICT';
CLUSTERED: 'CLUSTERED';
SORTED: 'SORTED';
PURGE: 'PURGE';
INPUTFORMAT: 'INPUTFORMAT';
OUTPUTFORMAT: 'OUTPUTFORMAT';
DATABASE: 'DATABASE' | 'SCHEMA';
DATABASES: 'DATABASES' | 'SCHEMAS';
DFS: 'DFS';
TRUNCATE: 'TRUNCATE';
ANALYZE: 'ANALYZE';
COMPUTE: 'COMPUTE';
LIST: 'LIST';
STATISTICS: 'STATISTICS';
PARTITIONED: 'PARTITIONED';
EXTERNAL: 'EXTERNAL';
DEFINED: 'DEFINED';
REVOKE: 'REVOKE';
GRANT: 'GRANT';
LOCK: 'LOCK';
UNLOCK: 'UNLOCK';
MSCK: 'MSCK';
REPAIR: 'REPAIR';
RECOVER: 'RECOVER';
EXPORT: 'EXPORT';
IMPORT: 'IMPORT';
LOAD: 'LOAD';
ROLE: 'ROLE';
ROLES: 'ROLES';
COMPACTIONS: 'COMPACTIONS';
PRINCIPALS: 'PRINCIPALS';
TRANSACTIONS: 'TRANSACTIONS';
INDEX: 'INDEX';
INDEXES: 'INDEXES';
LOCKS: 'LOCKS';
OPTION: 'OPTION';
ANTI: 'ANTI';
LOCAL: 'LOCAL';
INPATH: 'INPATH';

STRING
    : '\'' ( ~('\''|'\\') | ('\\' .) )* '\''
    | '"' ( ~('"'|'\\') | ('\\' .) )* '"'
    ;

BIGINT_LITERAL
    : DIGIT+ 'L'
    ;

SMALLINT_LITERAL
    : DIGIT+ 'S'
    ;

TINYINT_LITERAL
    : DIGIT+ 'Y'
    ;

INTEGER_VALUE
    : DIGIT+
    ;

DECIMAL_VALUE
    : DIGIT+ EXPONENT
    | DECIMAL_DIGITS EXPONENT? {isValidDecimal()}?
    ;

DOUBLE_LITERAL
    : DIGIT+ EXPONENT? 'D'
    | DECIMAL_DIGITS EXPONENT? 'D' {isValidDecimal()}?
    ;

BIGDECIMAL_LITERAL
    : DIGIT+ EXPONENT? 'BD'
    | DECIMAL_DIGITS EXPONENT? 'BD' {isValidDecimal()}?
    ;

IDENTIFIER
    : (LETTER | DIGIT | '_')+
    ;

BACKQUOTED_IDENTIFIER
    : '`' ( ~'`' | '``' )* '`'
    ;

fragment DECIMAL_DIGITS
    : DIGIT+ '.' DIGIT*
    | '.' DIGIT+
    ;

fragment EXPONENT
    : 'E' [+-]? DIGIT+
    ;

fragment DIGIT
    : [0-9]
    ;

fragment LETTER
    : [A-Z]
    ;

SIMPLE_COMMENT
    : '--' ~[\r\n]* '\r'? '\n'? -> channel(HIDDEN)
    ;

BRACKETED_EMPTY_COMMENT
    : '/**/' -> channel(HIDDEN)
    ;

BRACKETED_COMMENT
    : '/*' ~[+] .*? '*/' -> channel(HIDDEN)
    ;

WS
    : [ \r\n\t]+ -> channel(HIDDEN)
    ;

// Catch-all for anything we can't recognize.
// We use this to be able to ignore and recover all the text
// when splitting statements with DelimiterLexer
UNRECOGNIZED
    : .
    ;
