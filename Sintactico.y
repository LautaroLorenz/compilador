%{
	#include <stdio.h>
    #include <stdbool.h>
    #include <string.h>
	#include "y.tab.h"

	// definiciones tabla de símbolos
	// --------------------------------------------------------
	extern const char TS_COLUMNAS[][100];

	// definiciones declaraciones
	// --------------------------------------------------------
	// TODO: mostrar en pantalla ids y tipos declarados, hacer lo de "tabs global"
	extern struct cola_t declaracion_ids;
	extern struct cola_t declaracion_tipos;

	// funciones tabla de símbolos
	// --------------------------------------------------------
	extern bool ts_inicializar();
	extern void ts_guardar();
	extern bool ts_insertar_valor_buscando(const char * col_busqueda, const char * val_busqueda, const char * columna, const char * valor);

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
%token REAL ENTERO CADENA
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
		// TODO: validar ID repetido (cantidad de apariciones menor a 2)
		printf("ID [%s]\n", yytext);
	}
	;

tipo_id:
	REAL tipo
	| ENTERO tipo
	| CADENA tipo
	;

tipo: {
		// TODO: agregar el tipo de dato a la ts
		// buscar el ID en la columna "0" e insertar el TIPO en la columna "1"
		// ts_insertar_valor_buscando(TS_COLUMNAS[0], "a", TS_COLUMNAS[1], yytext);
		printf("TIPO [%s]\n", yytext);
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