%{
	#include <stdio.h>
	#include <stdbool.h>
	#include <string.h>
    #include <math.h>
	#include "y.tab.h"

	// definiciones tabla de símbolos
	// --------------------------------------------------------
	#define TAM_COL_NOMBRE (24)
	#define TAM_COL_TIPO_DE_DATO (16)
	#define TAM_COL_VALOR (20)
	#define TAM_COL_LONGITUD (18)

	// estructuras cola
	// --------------------------------------------------------
	typedef struct cola_nodo {
		void *elemento;
		struct cola_nodo *siguiente;
	} cola_nodo_t;

	typedef struct {
		cola_nodo_t *primero, *ultimo;
		int tam_elemento;
	} cola_t;

	// estructuras tabla de símbolos
	// --------------------------------------------------------
	typedef struct ts_registro {
		char nombre[TAM_COL_NOMBRE];
		char tipo_de_dato[TAM_COL_TIPO_DE_DATO];
		char valor[TAM_COL_VALOR];
		char longitud[TAM_COL_LONGITUD];
	} ts_registro_t;

	cola_t tabla_de_simbolos;

	// funciones cola
	// --------------------------------------------------------
	void cola_crear(cola_t *p_cola, int tam_elemento);
	void cola_vaciar(cola_t *p_cola);
	bool cola_vacia(cola_t cola);
	bool cola_agregar(cola_t *p_cola, void *p_elemento);
	bool cola_sacar(cola_t *p_cola, void *p_elemento);

	// funciones tabla de símbolos
	// --------------------------------------------------------
	bool ts_inicializar();
	void ts_imprimir_titulos(FILE * f_ts);
	void ts_imprimir_separador(FILE * f_ts, char separador);
	void ts_insertar(ts_registro_t *registro);
	void ts_guardar();
	void ts_registro_inicializar(ts_registro_t *registro);

	// constantes tabla de símbolos
	// --------------------------------------------------------
	const char TS_TITULOS[][100] = { "NOMBRE", "TIPO DE DATO", "VALOR", "LONGITUD" };
	const int TS_TAM_COLUMNAS[] = { TAM_COL_NOMBRE, TAM_COL_TIPO_DE_DATO, TAM_COL_VALOR, TAM_COL_LONGITUD };
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
"entero" {
	return ENTERO;
}
{ID} {
	ts_registro_t registro;
	ts_registro_inicializar(&registro);
	strcpy(registro.nombre, yytext);
	ts_insertar(&registro);
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

// cola
// --------------------------------------------------------

void cola_crear(cola_t *p_cola, int tam_elemento) {
	p_cola->primero = p_cola->ultimo = NULL;
	p_cola->tam_elemento = tam_elemento;
}

void cola_vaciar(cola_t *p_cola) {
	cola_nodo_t *p_aux = p_cola->primero;
	cola_nodo_t *p_sig;
	while (p_aux) {
		p_sig = p_aux->siguiente;
		free(p_aux->elemento);
		free(p_aux);
		p_aux = p_sig;
	}
	p_cola->primero = p_cola->ultimo = NULL;
}

bool cola_vacia(cola_t cola) {
	return (cola.primero==NULL);
}

bool cola_agregar(cola_t *p_cola, void *p_elemento) {
	cola_nodo_t *p_nodo = (cola_nodo_t*) malloc(sizeof(cola_nodo_t));
	if (!p_nodo)
		return false;
	else {
		if (p_cola->ultimo)
			p_cola->ultimo->siguiente = p_nodo;
		if (!p_cola->primero) // está vacía
			p_cola->primero = p_nodo;
		p_nodo->siguiente = NULL;
		p_cola->ultimo = p_nodo;
		p_nodo->elemento = malloc (p_cola->tam_elemento);
		memcpy(p_nodo->elemento, p_elemento, p_cola->tam_elemento);
		return true;
	}
}

bool cola_sacar(cola_t *p_cola, void *p_elemento) {
	cola_nodo_t *p_aux = p_cola->primero;
	p_cola->primero = p_cola->primero->siguiente;
	if (!p_cola->primero)
		p_cola->ultimo = NULL;
	memcpy(p_elemento, p_aux->elemento, p_cola->tam_elemento);
	free(p_aux->elemento);
	free(p_aux);
	return true;
} 

// tabla de símbolos
// --------------------------------------------------------

void ts_imprimir_separador(FILE * f_ts, char separador) {
	int i, f, contador;	
	char * linea;
	unsigned int longitud_linea = 0;
	int ts_cantidad_columnas = sizeof(TS_TAM_COLUMNAS)/sizeof(int);

	// asignación de memoria
	for(i = 0; i < ts_cantidad_columnas; i++) {
		longitud_linea += TS_TAM_COLUMNAS[i] + 2;
	}
	longitud_linea+=2;
	linea = malloc(sizeof(char) * longitud_linea);
	for(i = 0; i < longitud_linea - 1; i++) {
		linea[i] = ' ';
	}
	linea[i] = '\0';

	// separador
	contador = 0;
	linea[contador++] = '|';
	for(i = 0; i < ts_cantidad_columnas; i++) {
		for(f = 0; f < TS_TAM_COLUMNAS[i] + 1; f++) {
			linea[contador++] = separador;
		}
		linea[contador++] = '|';
	}
	fprintf(f_ts, linea);
	fprintf(f_ts, "\n");
	free(linea);
}

void ts_imprimir_titulos(FILE * f_ts) {
	int i, contador;	
	char * linea;
	unsigned int longitud_linea = 0;
	int ts_cantidad_columnas = sizeof(TS_TAM_COLUMNAS)/sizeof(int);

	// asignación de memoria
	for(i = 0; i < ts_cantidad_columnas; i++) {
		longitud_linea += TS_TAM_COLUMNAS[i] + 2;
	}
	longitud_linea+=2;
	linea = malloc(sizeof(char) * longitud_linea);
	for(i = 0; i < longitud_linea - 1; i++) {
		linea[i] = ' ';
	}
	linea[i] = '\0';
	
	// títulos	
	for(i = 0; i < ts_cantidad_columnas; i++) {
		contador = 0;
		linea[contador++] = '|';
		linea[contador++] = ' ';
		linea[contador++] = '%';
		linea[contador++] = '-';
		sprintf(&linea[contador], "%d", TS_TAM_COLUMNAS[i]);
		contador += (int)((ceil(log10(TS_TAM_COLUMNAS[i]))) * sizeof(char));
		linea[contador++] = 's';
		linea[contador++] = '\0';
		fprintf(f_ts, linea, TS_TITULOS[i]);
	}
	fprintf(f_ts, "|\n");	
	free(linea);
}

bool ts_inicializar() {
	// abrir tabla para lectura/escritura, sobrescribir si ya existe
	FILE * f_ts = fopen("tabla_de_simbolos.txt", "w+");
	if(f_ts == NULL) {
		printf("ERROR: creando tabla de simbolos\n");
		return false;
	}
	ts_imprimir_separador(f_ts, '=');
	ts_imprimir_titulos(f_ts);
	ts_imprimir_separador(f_ts, '=');
	fclose(f_ts);
	cola_crear(&tabla_de_simbolos, sizeof(ts_registro_t));
	return true;
}

void ts_insertar(ts_registro_t *registro) {
	cola_agregar(&tabla_de_simbolos, registro);
}

void ts_guardar() {
	FILE * f_ts = fopen("tabla_de_simbolos.txt", "a+");
	ts_registro_t registro;
	int i, contador, bytes_leidos;	
	char * linea;
	char * p_byte_registro;
	unsigned int longitud_linea = 0;
	int ts_cantidad_columnas = sizeof(TS_TAM_COLUMNAS)/sizeof(int);

	// asignación de memoria
	for(i = 0; i < ts_cantidad_columnas; i++) {
		longitud_linea += TS_TAM_COLUMNAS[i] + 2;
	}
	longitud_linea+=2;
	linea = malloc(sizeof(char) * longitud_linea);
	for(i = 0; i < longitud_linea - 1; i++) {
		linea[i] = ' ';
	}
	linea[i] = '\0';

	while(!cola_vacia(tabla_de_simbolos)) {
		cola_sacar(&tabla_de_simbolos, &registro);
		p_byte_registro = (char *)&registro;
		// valores del registro
		for(i = 0, bytes_leidos = 0; i < ts_cantidad_columnas; i++) {
			contador = 0;
			linea[contador++] = '|';
			linea[contador++] = ' ';
			linea[contador++] = '%';
			linea[contador++] = '-';
			sprintf(&linea[contador], "%d", TS_TAM_COLUMNAS[i]);
			contador += (int)((ceil(log10(TS_TAM_COLUMNAS[i]))) * sizeof(char));
			linea[contador++] = 's';
			linea[contador++] = '\0';
			fprintf(f_ts, linea, p_byte_registro + bytes_leidos);
			bytes_leidos += TS_TAM_COLUMNAS[i];
		}
		fprintf(f_ts, "|\n");
		ts_imprimir_separador(f_ts, '-');
	}

	free(f_ts);
}

void ts_registro_inicializar(ts_registro_t *registro) {
	int i, bytes_leidos;
	int ts_cantidad_columnas = sizeof(TS_TAM_COLUMNAS)/sizeof(int);
	char * p_byte_registro = (char *)registro;	
	for(i = 0, bytes_leidos = 0; i < ts_cantidad_columnas; i++) {
		*(p_byte_registro + bytes_leidos) = '\0';
		bytes_leidos += TS_TAM_COLUMNAS[i];
	}
}