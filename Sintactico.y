%{
	#include <stdio.h>
    #include <stdbool.h>
    #include <string.h>
	#include "y.tab.h"

	// definiciones declaraciones
	// --------------------------------------------------------
	// relación cuantos id se declaran por cada tipo
	#define CANTIDAD_IDS_POR_TIPO (1)

	// definiciones declaraciones
	// --------------------------------------------------------
	extern struct cola_t declaracion_ids;
	extern struct cola_t declaracion_tipos;

	// funciones tabla de símbolos
	// --------------------------------------------------------
	extern bool ts_inicializar();
	extern void ts_guardar();

	// funciones declaraciones
	// --------------------------------------------------------
	extern void dec_inicializar();
	extern void dec_insertar(struct cola_t *p_cola, const char *descripcion);
	extern void dec_guardar_imprimir(const int cant_ids_por_tipo);
	extern int dec_buscar_id(const char * id);

	// funciones de Flex y Bison
	// --------------------------------------------------------
	extern void yyerror(const char *mensaje);
	extern int yylex(void);

	// variables de Flex y Bison
	// --------------------------------------------------------
	extern char * yytext;
    FILE *yyin;

	// variables auxiliares
	// --------------------------------------------------------
	extern unsigned int tab_nivel;
	extern char error_mensaje[1000];
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
		dec_inicializar();
	}
	lista_declaraciones {
		tab_nivel++;
		dec_guardar_imprimir(CANTIDAD_IDS_POR_TIPO);
		tab_nivel--;
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
		// si el id aún no fue declarado
		if(dec_buscar_id(yytext) == 0) {
			// id declarado
			dec_insertar(&declaracion_ids, yytext);
		} else {
			sprintf(error_mensaje, "el ID [%s] ya fue declarado previamente", yytext);
			yyerror(error_mensaje);
		}
	}
	;

tipo_id:
	REAL tipo
	| ENTERO tipo
	| CADENA tipo
	;

tipo: {
		// tipo de dato para "CANTIDAD_IDS_POR_TIPO" ids declarados
		dec_insertar(&declaracion_tipos, yytext);
	}
	;

%%

int main(int argc, char *argv[]) {
	printf("\n");
	printf("==============================================================\n");
	printf("analisis-comienza\n");
	printf("==============================================================\n");
    if ((yyin = fopen(argv[1], "rt")) == NULL) {
		printf("ERROR: abriendo archivo [%s]\n", argv[1]);
	} else {
		if(ts_inicializar() == true) {
			yyparse();
			fclose(yyin);
			ts_guardar();
		}
	}
	printf("==============================================================\n");
	printf("analisis-finaliza\n");
	printf("==============================================================\n");
	return 0;
}