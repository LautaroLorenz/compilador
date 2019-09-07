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

	// funciones auxiliares
	// --------------------------------------------------------
	extern void consola_log(const char * log_msj);

	// variables de Flex y Bison
	// --------------------------------------------------------
	extern char * yytext;
    FILE *yyin;

	// variables auxiliares
	// --------------------------------------------------------
	extern unsigned int tab_nivel;
	extern char error_mensaje[1000];
	extern char log_mensaje[1000];
%}

%locations
%start programa
%token PARENTESIS_ABRE PARENTESIS_CIERRA
%token CORCHETE_ABRE CORCHETE_CIERRA
%token ID
%token REAL ENTERO CADENA
%token CONSTANTE_REAL
%token DIM AS COMA
%token OPERADOR_ASIGNACION

%%

programa:
	declaraciones sentencias
	| {
		consola_log("programa vacio");
	}
	;

declaraciones: {
		consola_log("declaraciones-comienza");
		tab_nivel++;
		dec_inicializar();
	}
	lista_declaraciones {
		dec_guardar_imprimir(CANTIDAD_IDS_POR_TIPO);
		tab_nivel--;
		consola_log("declaraciones-finaliza");
	}
	;

lista_declaraciones:
	lista_declaraciones declaracion
	| declaracion
	| {
		consola_log("programa sin declaraciones");
	}
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

sentencias: {
		consola_log("setencias-comienza");
		tab_nivel++;
	} 
	lista_sentencias {
		tab_nivel--;
		consola_log("setencias-finaliza");
	}
	;

lista_sentencias:
	lista_sentencias setencia
	| setencia
	| {
		consola_log("programa sin sentencias");
		
	}
	;

setencia:
	asignacion 
	;

asignacion:
	id_declarado {
		printf("ID [%s]\n", yytext);
	} OPERADOR_ASIGNACION id_declarado
	;

id_declarado: 
	ID {
		// validar que el id esté declarado
		if(dec_buscar_id(yytext) == 0) {
			sprintf(error_mensaje, "el ID [%s] no se puede utilizar porque no fue declarado", yytext);
			yyerror(error_mensaje);
		}
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