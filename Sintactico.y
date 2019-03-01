%{
	#include <stdio.h>
    #include <stdbool.h>
	#include "y.tab.h"

	int yyerror();
	extern int yylex(void);
    FILE  *yyin;
%}

%%

programa: ;

%%

void tabs(int cant_tabs) {
    int i;
    for(i = 0; i < cant_tabs; i++) {
        printf("\t");
    }
}

int main(int argc, char *argv[])
{
	printf("inicio-analisis\n");
	printf("========================================================\n");
    if ((yyin = fopen(argv[1], "rt")) == NULL)
	{
		printf("ERROR: abriendo archivo [%s]\n", argv[1]);
	}
	else
	{
		yyparse();
	}
	fclose(yyin);
	printf("========================================================\n");
	printf("fin-analisis\n");
	return 0;
}

int yyerror(char *s){
	printf("yyerror [%s]\n", s);
}