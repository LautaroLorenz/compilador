%{
	#include <stdio.h>
    #include <stdbool.h>
    #include <string.h>
	#include "y.tab.h"

	// funciones tabla de símbolos
	// --------------------------------------------------------
	extern bool ts_inicializar();
	extern void ts_guardar();

	// funciones de Flex y Bison
	// --------------------------------------------------------
	extern void yyerror(const char *s);
	extern int yylex(void);

	// variables de Flex y Bison
	// --------------------------------------------------------
	extern char * yytext;
    FILE *yyin;

	// funciones auxiliares
	// --------------------------------------------------------
	void tabs(int cant_tabs);

%}

%locations
%start programa
%token PARENTESIS_ABRE PARENTESIS_CIERRA
%token CORCHETE_ABRE CORCHETE_CIERRA
%token ID
%token REAL ENTERO
%token DIM AS COMA

%%

programa:
	declaraciones
	| {
		printf("programa vacio\n");
	}
	;

declaraciones: {
		printf("declaraciones-comienza\n");
	}
	lista_declaraciones {
		printf("declaraciones-finaliza\n");
	}
	;

lista_declaraciones:
	lista_declaraciones declaracion
	| declaracion
	;

declaracion:
	DIM CORCHETE_ABRE lista_definiciones CORCHETE_CIERRA
	;

lista_definiciones:
	definicion_id CORCHETE_CIERRA AS CORCHETE_ABRE tipo_id
	| definicion_id COMA lista_definiciones COMA tipo_id
	;

definicion_id: 
	ID {
		// TODO: validar ID repetido
	}
	;

tipo_id:
	REAL tipo
	| ENTERO tipo
	;

tipo: {
		
	}
	;

%%

int main(int argc, char *argv[]) {
	printf("\n");
	printf("========================================================\n");
	printf("analisis-comienza\n");
	printf("========================================================\n");
    if ((yyin = fopen(argv[1], "rt")) == NULL) {
		printf("ERROR: abriendo archivo [%s]\n", argv[1]);
	} else {
		if(ts_inicializar() == true) {
			yyparse();
			fclose(yyin);
			ts_guardar();
		}
	}
	printf("========================================================\n");
	printf("analisis-finaliza\n");
	printf("========================================================\n");
	return 0;
}

// auxiliares
// --------------------------------------------------------

void tabs(int cant_tabs) {
    int i;
    for(i = 0; i < cant_tabs; i++) {
		// manejamos tabs como espacios para que se vea igual 
		// en todos los tipos de pantallas y configuraciones
        printf(" ");
    }
}