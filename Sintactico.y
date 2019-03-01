%{
	#include <stdio.h>
    #include <stdbool.h>
	#include "y.tab.h"

	int yyerror();
	extern int yylex(void);
    FILE *yyin;
%}

%locations
%start programa
%token PARENTESIS_ABRE PARENTESIS_CIERRA
%token CORCHETE_ABRE CORCHETE_CIERRA
%token ID
%token REAL
%token DIM AS COMA

%%

programa:
	declaraciones
	| {
		printf("programa vacio\n");
	}
	;

declaraciones: 
	lista_declaraciones
	;

lista_declaraciones:
	lista_declaraciones declaracion
	| declaracion
	;

declaracion:
	DIM CORCHETE_ABRE lista_definiciones CORCHETE_CIERRA
	;

lista_definiciones:
	ID CORCHETE_CIERRA AS CORCHETE_ABRE tipo_id
	| ID COMA lista_definiciones COMA tipo_id
	;

tipo_id:
	REAL
	;

%%

void tabs(int cant_tabs) {
    int i;
    for(i = 0; i < cant_tabs; i++) {
        printf("\t");
    }
}

int main(int argc, char *argv[]) {
	printf("\n");
	printf("========================================================\n");
	printf("inicio-analisis\n");
	printf("========================================================\n");
    if ((yyin = fopen(argv[1], "rt")) == NULL) {
		printf("ERROR: abriendo archivo [%s]\n", argv[1]);
	} else {
		yyparse();
	}
	fclose(yyin);
	printf("========================================================\n");
	printf("fin-analisis\n");
	printf("========================================================\n");
	return 0;
}