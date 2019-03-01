%{
	#include <stdio.h>
	#include "y.tab.h"
%}

%option noyywrap
%option yylineno

DIGITO ([0-9])+
LETRA [a-zA-Z]
ID {LETRA}({LETRA}|{DIGITO}|_)*

%%

"DIM" {
	return DIM;
}
"AS" {
	return AS;
}
"," {
	return COMA;
}
"real" {
	return REAL;
}
{ID} {
	return ID;
}
"(" {
	return PARENTESIS_ABRE;
}
")" {
	return PARENTESIS_CIERRA;
}
"[" {
	return CORCHETE_ABRE;
}
"]" {
	return CORCHETE_CIERRA;
}
[" "\t\r\n] { 
	/* ignorar espaciado */ 
}
. {
	printf("ERROR: linea [%d], no se reconoce [%s]\n", yylineno, yytext);
	exit(1);
}

%%

void yyerror(const char *s) {
	printf("ERROR: linea [%d], [%s]\n", yylineno, s);
}