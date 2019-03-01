%{
	#include <stdio.h>
	#include "y.tab.h"
%}

%option noyywrap  
%option yylineno

%%

.					{   
						printf("ERROR: linea [%d], no se reconoce [%s]\n", yylineno, yytext);
						exit(1); 
					}

%%