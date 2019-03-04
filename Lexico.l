%{
	#include <stdio.h>
	#include <stdbool.h>
	#include <string.h>
    #include <math.h>
	#include "y.tab.h"

	// definiciones tabla de símbolos
	// --------------------------------------------------------
	#define TAM_COL_NOMBRE (24)
	#define TAM_COL_TIPO_DE_DATO (20)
	#define TAM_COL_VALOR (20)
	#define TAM_COL_LONGITUD (18)

	// estructuras pila
	// --------------------------------------------------------
	// TODO:

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

	// estructuras lista
	// --------------------------------------------------------
	typedef enum {
		LS_PRIMERO,
		LS_SIGUIENTE,
		LS_ANTERIOR
	} lista_movimiento_t;

	typedef struct lista_nodo {
		void* elemento;
		struct lista_nodo *siguiente;
	} lista_nodo_t;

	typedef struct {
		lista_nodo_t *primero, *actual;
		int tam_elemento;
	} lista_t;

	// estructuras tabla de símbolos
	// --------------------------------------------------------
	typedef struct ts_registro {
		char nombre[TAM_COL_NOMBRE];
		char tipo_de_dato[TAM_COL_TIPO_DE_DATO];
		char valor[TAM_COL_VALOR];
		char longitud[TAM_COL_LONGITUD];
	} ts_registro_t;

	lista_t tabla_de_simbolos;

	// funciones cola
	// --------------------------------------------------------
	void cola_crear(cola_t *p_cola, int tam_elemento);
	void cola_vaciar(cola_t *p_cola);
	bool cola_vacia(cola_t cola);
	bool cola_agregar(cola_t *p_cola, void *p_elemento);
	bool cola_sacar(cola_t *p_cola, void *p_elemento);

	// funciones lista
	// --------------------------------------------------------
	void lista_crear(lista_t *p_lista, int tam_elemento);
	void lista_vaciar(lista_t *p_lista);
	bool lista_vacia(lista_t lista);
	void lista_elemento_actual(lista_t lista, void *p_elemento);
	void lista_modificar_actual(lista_t *p_lista, void *p_elemento);
	bool lista_mover_actual(lista_t *p_lista, lista_movimiento_t movimiento);
	void lista_borrar_actual(lista_t *p_lista);
	bool lista_insertar(lista_t *p_lista, lista_movimiento_t movimiento, void *p_elemento);

	// funciones tabla de símbolos
	// --------------------------------------------------------
	bool ts_inicializar();
	void ts_imprimir_titulos(FILE * f_ts);
	void ts_imprimir_separador(FILE * f_ts, char separador);
	void ts_guardar();
	void ts_registro_inicializar(ts_registro_t *registro);
	// insertar un valor en alguna columna de las que figuran en TS_COLUMNAS
	void ts_insertar_valor_en_columna(const char * columna, const char * valor);
	// busca el valor "val_busqueda" en la columna "col_busqueda",
	// luego inserta el valor "valor" en la columna "columna".
	// retorna false si no pudo encontrar una coincidencia con "val_busqueda"
	bool ts_insertar_valor_buscando(const char * col_busqueda, const char * val_busqueda, const char * columna, const char * valor);

	// constantes tabla de símbolos
	// --------------------------------------------------------	
	const char TS_COLUMNAS[][100] = {
		"NOMBRE",
		"TIPO DE DATO",
		"VALOR",
		"LONGITUD"
	};
	const int TS_TAMS_COLUMNA[] = {
		TAM_COL_NOMBRE,
		TAM_COL_TIPO_DE_DATO,
		TAM_COL_VALOR,
		TAM_COL_LONGITUD
	};

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
"cadena" {
	return CADENA;
}
{ID} {
	ts_insertar_valor_en_columna(TS_COLUMNAS[0], yytext);
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
	return (cola.primero == NULL);
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

// lista
// --------------------------------------------------------

void lista_crear(lista_t *p_lista, int tam_elemento) {
	p_lista->actual = NULL;
	p_lista->primero = NULL;
	p_lista->tam_elemento = tam_elemento;
}

void lista_vaciar(lista_t *p_lista) {
	lista_nodo_t *p_nodo, *siguiente;
	for(p_nodo = p_lista->primero; (p_nodo); p_nodo = siguiente) {
		siguiente = p_nodo->siguiente;
		free(p_nodo->elemento);
		free(p_nodo);
	}
	p_lista->primero = p_lista->actual = NULL;
}

bool lista_vacia(lista_t lista) {
	return (lista.primero == NULL);
}

void lista_elemento_actual(lista_t lista, void *p_elemento) {
	memcpy(p_elemento, lista.actual->elemento, lista.tam_elemento);
}

void lista_modificar_actual(lista_t *p_lista, void *p_elemento) {
	memcpy(p_lista->actual->elemento, p_elemento, p_lista->tam_elemento);
}

bool lista_mover_actual(lista_t *p_lista, lista_movimiento_t movimiento) {
	switch (movimiento) {
		case LS_PRIMERO: 
			p_lista->actual=p_lista->primero;
		break;
		case LS_SIGUIENTE: 
			if (p_lista->actual->siguiente==NULL)
				return false;
			else
				p_lista->actual=p_lista->actual->siguiente;
		break;
		case LS_ANTERIOR:
			return false;
	}
	return true;
}

void lista_borrar_actual(lista_t *p_lista) {
	lista_nodo_t *p_nodo=p_lista->actual;
	lista_nodo_t *p_aux;
	if (p_lista->actual==p_lista->primero) {
		p_lista->primero = p_lista->actual->siguiente;
		p_lista->actual = p_lista->primero;
	} else {
		p_aux = p_lista->primero;
		while (p_aux->siguiente!=p_lista->actual)
			p_aux = p_aux->siguiente;
		p_aux->siguiente=p_lista->actual->siguiente;
		if (p_aux->siguiente) //Si no es el último
			p_lista->actual = p_aux->siguiente;
		else
			p_lista->actual = p_aux; //Si es el último queda en el anterior al
		//borrado
	}
	free(p_nodo->elemento);
	free(p_nodo);
}

bool lista_insertar(lista_t *p_lista, lista_movimiento_t movimiento, void *p_elemento) {
	lista_nodo_t *p_nodo = (lista_nodo_t*) malloc(sizeof(lista_nodo_t));
	lista_nodo_t *p_aux;
	if (!p_nodo)
		return false; //No hay memoria disponible
	if ((p_lista->primero == NULL) || (movimiento==LS_PRIMERO) || ((movimiento==LS_ANTERIOR) && (p_lista->primero==p_lista->actual))) {
		// Si está vacía o hay que insertar en el primero o
		// hay que insertar en el anterior y el actual es el primero
		p_nodo->siguiente = p_lista->primero;
		p_lista->primero = p_lista->actual = p_nodo;
	} else {
		if (movimiento == LS_SIGUIENTE) {
			p_nodo->siguiente = p_lista->actual->siguiente;
			p_lista->actual->siguiente = p_nodo;
		} else { // LS_ANTERIOR 
			p_aux=p_lista->primero;
			while (p_aux->siguiente!=p_lista->actual)
				p_aux = p_aux->siguiente;
			p_aux->siguiente = p_nodo;
			p_nodo->siguiente = p_lista->actual;
		}
	}
	p_nodo->elemento = malloc(p_lista->tam_elemento);
	memcpy(p_nodo->elemento, p_elemento, p_lista->tam_elemento);
	p_lista->actual=p_nodo;
	return true;
} 

// tabla de símbolos
// --------------------------------------------------------

void ts_imprimir_separador(FILE * f_ts, char separador) {
	int i, f, contador;	
	char * linea;
	unsigned int longitud_linea = 0;
	int ts_cantidad_columnas = sizeof(TS_TAMS_COLUMNA)/sizeof(int);

	// asignación de memoria
	for(i = 0; i < ts_cantidad_columnas; i++) {
		longitud_linea += TS_TAMS_COLUMNA[i] + 2;
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
		for(f = 0; f < TS_TAMS_COLUMNA[i] + 1; f++) {
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
	int ts_cantidad_columnas = sizeof(TS_TAMS_COLUMNA)/sizeof(int);

	// asignación de memoria
	for(i = 0; i < ts_cantidad_columnas; i++) {
		longitud_linea += TS_TAMS_COLUMNA[i] + 2;
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
		sprintf(&linea[contador], "%d", TS_TAMS_COLUMNA[i]);
		contador += (int)((ceil(log10(TS_TAMS_COLUMNA[i]))) * sizeof(char));
		linea[contador++] = 's';
		linea[contador++] = '\0';
		fprintf(f_ts, linea, TS_COLUMNAS[i]);
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
	lista_crear(&tabla_de_simbolos, sizeof(ts_registro_t));
	return true;
}

void ts_insertar_valor_en_columna(const char * columna, const char * valor) {	
	int i, offset_bytes;
	int ts_cantidad_columnas = sizeof(TS_TAMS_COLUMNA)/sizeof(int);	
	ts_registro_t registro;
	char * p_registro = (char *)&registro;
	ts_registro_inicializar(&registro);
	for(i = 0, offset_bytes = 0; i < ts_cantidad_columnas; i++) {
		if(strcmp(columna, TS_COLUMNAS[i]) == 0) {
			strcpy((p_registro + offset_bytes), valor);
			break;
		}		
		offset_bytes += TS_TAMS_COLUMNA[i];
	}
	lista_insertar(&tabla_de_simbolos, LS_SIGUIENTE, &registro);
}

bool ts_insertar_valor_buscando(const char * col_busqueda, const char * val_busqueda, const char * columna, const char * valor) {
	int i;
	// offset en bytes del registro al valor buscado
	int offset_bytes_buscar;
	// offset en bytes del registro al valor para insertar
	int offset_bytes_insertar;
	int ts_cantidad_columnas = sizeof(TS_TAMS_COLUMNA)/sizeof(int);
	ts_registro_t registro;
	char * p_registro = (char *)&registro;
	bool valor_encontrado = false;
	ts_registro_inicializar(&registro);

	// buscar cuantos bytes hay hasta la columna para buscar
	for(i = 0, offset_bytes_buscar = 0; i < ts_cantidad_columnas; i++) {
		if(strcmp(TS_COLUMNAS[i], col_busqueda) == 0)
			break;
		offset_bytes_buscar += TS_TAMS_COLUMNA[i];
	}
	// buscar cuantos bytes hay hasta la columna para insertar
	for(i = 0, offset_bytes_insertar = 0; i < ts_cantidad_columnas; i++) {
		if(strcmp(TS_COLUMNAS[i], columna) == 0)
			break;
		offset_bytes_insertar += TS_TAMS_COLUMNA[i];
	}

	if(lista_mover_actual(&tabla_de_simbolos, LS_PRIMERO)) {		
		do {
			lista_elemento_actual(tabla_de_simbolos, &registro);
			// si encontramos la fila buscada
			if(strcmp((p_registro + offset_bytes_buscar), val_busqueda) == 0) {
				strcpy((p_registro + offset_bytes_insertar), valor);
				lista_modificar_actual(&tabla_de_simbolos, &registro);
				valor_encontrado = true;
				break;
			}
		} while(lista_mover_actual(&tabla_de_simbolos, LS_SIGUIENTE));
	}

	return valor_encontrado;
}

void ts_guardar() {
	FILE * f_ts = fopen("tabla_de_simbolos.txt", "a+");
	ts_registro_t registro;
	int i, contador, offset_bytes;	
	char * linea;
	char * p_registro;
	unsigned int longitud_linea = 0;
	int ts_cantidad_columnas = sizeof(TS_TAMS_COLUMNA)/sizeof(int);

	// asignación de memoria
	for(i = 0; i < ts_cantidad_columnas; i++) {
		longitud_linea += TS_TAMS_COLUMNA[i] + 2;
	}
	longitud_linea+=2;
	linea = malloc(sizeof(char) * longitud_linea);
	for(i = 0; i < longitud_linea - 1; i++) {
		linea[i] = ' ';
	}
	linea[i] = '\0';

	lista_mover_actual(&tabla_de_simbolos, LS_PRIMERO);
	while(!lista_vacia(tabla_de_simbolos)) {
		lista_elemento_actual(tabla_de_simbolos, &registro);
		p_registro = (char *)&registro;
		// valores del registro
		for(i = 0, offset_bytes = 0; i < ts_cantidad_columnas; i++) {
			contador = 0;
			linea[contador++] = '|';
			linea[contador++] = ' ';
			linea[contador++] = '%';
			linea[contador++] = '-';
			sprintf(&linea[contador], "%d", TS_TAMS_COLUMNA[i]);
			contador += (int)((ceil(log10(TS_TAMS_COLUMNA[i]))) * sizeof(char));
			linea[contador++] = 's';
			linea[contador++] = '\0';
			fprintf(f_ts, linea, p_registro + offset_bytes);
			offset_bytes += TS_TAMS_COLUMNA[i];
		}
		fprintf(f_ts, "|\n");
		ts_imprimir_separador(f_ts, '-');
		lista_borrar_actual(&tabla_de_simbolos);
	}

	free(f_ts);
}

void ts_registro_inicializar(ts_registro_t *registro) {
	int i, offset_bytes;
	int ts_cantidad_columnas = sizeof(TS_TAMS_COLUMNA)/sizeof(int);
	char * p_registro = (char *)registro;	
	for(i = 0, offset_bytes = 0; i < ts_cantidad_columnas; i++) {
		*(p_registro + offset_bytes) = '\0';
		offset_bytes += TS_TAMS_COLUMNA[i];
	}
}