grammar Calculator;

main: (expr NEWLINE | NEWLINE)* EOF;

expr: expr op=('*' | '/') expr 		#MulDiv
	| expr op=('+' | '-') expr 		#AddSub
	| ID '=' expr					#Assign
	| ID							#Id
	| INT							#Int
	| '(' expr ')'					#Parens
	;

ID : [a-zA-Z]+([a-zA-Z_0-9]+)?;
INT: [0-9]+('.'[0-9+])?;
NEWLINE: '\r'? '\n';
WS: [ \t]+ -> skip;