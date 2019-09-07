%{
	#include <stdio.h>
	#include <stdbool.h>
	#include <string.h>
    #include <math.h>
	#include "y.tab.h"

	// definiciones tabla de símbolos
	// --------------------------------------------------------
	#define COL_NOMBRE ("NOMBRE")
	#define COL_TIPO_DE_DATO ("TIPO DE DATO")
	#define COL_VALOR ("VALOR")
	#define COL_LONGITUD ("LONGITUD")
	#define TAM_COL_NOMBRE (20)
	#define TAM_COL_TIPO_DE_DATO (20)
	#define TAM_COL_VALOR (20)
	#define TAM_COL_LONGITUD (20)

	// estructuras pila
	// --------------------------------------------------------
	typedef struct pila_nodo {
		void* elemento;
		struct pila_nodo *siguiente;
	} pila_nodo_t;

	typedef struct pila {
		pila_nodo_t *tope;
		int tam_elemento;
	} pila_t;

	// estructuras cola
	// --------------------------------------------------------
	typedef struct cola_nodo {
		void *elemento;
		struct cola_nodo *siguiente;
	} cola_nodo_t;

	typedef struct cola {
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

	typedef struct lista {
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

	// estructuras declaraciones
	// --------------------------------------------------------
	typedef struct dec_registro {
		char descripcion[100];
	} dec_registro_t;

	// declaraciones
	// --------------------------------------------------------
	cola_t declaracion_ids;
	cola_t declaracion_tipos;

	// tabla de símbolos
	// --------------------------------------------------------	
	lista_t tabla_de_simbolos;

	// funciones pila
	// --------------------------------------------------------
	void pila_crear(pila_t *p_pila, int tam_elemento);
	void pila_vaciar(pila_t *p_pila);
	bool pila_vacia(pila_t pila);
	bool pila_agregar(pila_t *p_pila, void *p_elemento);
	bool pila_sacar(pila_t *p_pila, void *p_elemento);

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
	void ts_error(const char *mensaje);
	void ts_registro_inicializar(ts_registro_t *registro);
	void ts_insertar_registro(ts_registro_t *registro);
	// insertar un valor en alguna columna de las que figuran en TS_COLUMNAS
	void ts_insertar_valor_en_columna(const char * columna, const char * valor);
	// busca el valor "val_busqueda" en la columna "col_busqueda",
	// luego inserta el valor "valor" en la columna "columna".
	// retorna false si no pudo encontrar una coincidencia con "val_busqueda"
	void ts_insertar_valor_buscando(const char * col_busqueda, const char * val_busqueda, const char * columna, const char * valor);

	// funciones declaraciones
	// --------------------------------------------------------
	void dec_inicializar();
	void dec_insertar(cola_t *p_cola, const char *descripcion);
	void dec_guardar_imprimir(const int cant_ids_por_tipo);
	// retorna la cantidad de veces que un id fue declarado
	int dec_buscar_id(const char * id);

	// funciones auxiliares
	// --------------------------------------------------------
	void tabs();
	void consola_log(const char * log_msj);
	void yyerror(const char *mensaje);
	// agrega un guión bajo al principio de la cadena
	char *guionizar(const char * cadena);

	// variables auxiliares
	// --------------------------------------------------------
	unsigned int tab_nivel = 0;
	char error_mensaje[1000];
	char log_mensaje[1000];
	// contiene la última cadena que fue guionizada
	char guionizada[1000];

	// constantes tabla de símbolos
	// --------------------------------------------------------	
	const char TS_COLUMNAS[][100] = {
		COL_NOMBRE,
		COL_TIPO_DE_DATO,
		COL_VALOR,
		COL_LONGITUD
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
CONSTANTE_REAL (({DIGITO})+("."{1})({DIGITO})*)|(({DIGITO})*("."{1})({DIGITO})+)

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
"=" {
	return OPERADOR_ASIGNACION;
}
{ID} {
	ts_insertar_valor_en_columna(COL_NOMBRE, yytext);
	return ID;
}
{CONSTANTE_REAL} {
	ts_registro_t registro;
	ts_registro_inicializar(&registro);
	strcpy(registro.nombre, guionizar(yytext));
	strcpy(registro.tipo_de_dato, "constante_real");
	strcpy(registro.valor, yytext);
	ts_insertar_registro(&registro);
	return CONSTANTE_REAL;
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
	sprintf(error_mensaje, "no se esperaba encontrar la expresion [%s]", yytext);
	yyerror(error_mensaje);
}

%%

void yyerror(const char *mensaje) {
	char error[1001];
	char aux_msj[1000];
	if(strcmp(mensaje, "syntax error") == 0)
		strcpy(aux_msj, "sintaxis incorrecta");
	else 
		strcpy(aux_msj, mensaje);
	sprintf(error, "\n\n>>>> FIN INESPERADO: linea [%d] del programa <<<<\nERROR: %s\n", yylineno, aux_msj);
	printf(error);
	ts_error(error);
	exit(1);
}

// auxiliares
// --------------------------------------------------------

void tabs() {
    int i;
    for(i = 0; i < tab_nivel * 4; i++) {
		// manejamos tabs como espacios para que se vea igual 
		// en todos los tipos de pantallas y configuraciones
        printf(" ");
    }
}

void consola_log(const char * log_msj) {
	tabs();
	printf("%s\n", log_msj);
};

char *guionizar(const char * cadena) {
	sprintf(guionizada, "_%s", cadena);
	return guionizada;
}

// pila
// --------------------------------------------------------

void pila_crear(pila_t *p_pila, int tam_elemento) {
	p_pila->tope = NULL;
	p_pila->tam_elemento = tam_elemento;
}

void pila_vaciar(pila_t *p_pila) {
	pila_nodo_t *p_aux = p_pila->tope;
	pila_nodo_t *p_sig;
	while (p_aux) {
		p_sig = p_aux->siguiente;
		free(p_aux->elemento);
		free(p_aux);
		p_aux = p_sig;
	}
	p_pila->tope = NULL;
}

bool pila_vacia(pila_t pila) {
	return (pila.tope == NULL);
}

bool pila_agregar(pila_t *p_pila, void *p_elemento) {
	pila_nodo_t *p_nodo = (pila_nodo_t*) malloc(sizeof(pila_nodo_t));
	if (!p_nodo)
		return false;
	else {
		p_nodo->siguiente = p_pila->tope;
		p_pila->tope = p_nodo;
		p_nodo->elemento = malloc (p_pila->tam_elemento);
		memcpy(p_nodo->elemento, p_elemento, p_pila->tam_elemento);
		return true;
	}
}

bool pila_sacar(pila_t *p_pila, void *p_elemento) {
	pila_nodo_t *p_aux = p_pila->tope;
	p_pila->tope = p_pila->tope->siguiente;
	memcpy(p_elemento, p_aux->elemento, p_pila->tam_elemento);
	free(p_aux->elemento);
	free(p_aux);
	return true;
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

void ts_registro_inicializar(ts_registro_t *registro) {
	int i, offset_bytes;
	int ts_cantidad_columnas = sizeof(TS_TAMS_COLUMNA)/sizeof(int);
	char * p_registro = (char *)registro;	
	for(i = 0, offset_bytes = 0; i < ts_cantidad_columnas; i++) {
		*(p_registro + offset_bytes) = '\0';
		offset_bytes += TS_TAMS_COLUMNA[i];
	}
}

void ts_insertar_registro(ts_registro_t *registro) {
	lista_insertar(&tabla_de_simbolos, LS_SIGUIENTE, registro);
}

void ts_insertar_valor_en_columna(const char * columna, const char * valor) {	
	int i, offset_bytes;
	int ts_cantidad_columnas = sizeof(TS_TAMS_COLUMNA)/sizeof(int);	
	ts_registro_t registro, aux_registro;
	char * p_registro = (char *)&registro;
	bool valor_encontrado = false;
	ts_registro_inicializar(&registro);
	for(i = 0, offset_bytes = 0; i < ts_cantidad_columnas; i++) {
		if(strcmp(columna, TS_COLUMNAS[i]) == 0) {
			strcpy((p_registro + offset_bytes), valor);
			break;
		}		
		offset_bytes += TS_TAMS_COLUMNA[i];
	}

	// si el valor ya existe no hace falta insertar de nuevo
	// TODO: continuar desde acá
	if(lista_mover_actual(&tabla_de_simbolos, LS_PRIMERO)) {
		//	do {
		lista_elemento_actual(tabla_de_simbolos, &aux_registro);
		// 		// si encontramos la fila buscada
		// 		if(strcmp((p_registro + offset_bytes), valor) == 0) {
		// 			valor_encontrado = true;
		// 			break;
		// 		}
		//	} while(lista_mover_actual(&tabla_de_simbolos, LS_SIGUIENTE));
	}
	// si el valor no existia, lo agregamos a la columna
	if(valor_encontrado == false)
		lista_insertar(&tabla_de_simbolos, LS_SIGUIENTE, &registro);
}

void ts_insertar_valor_buscando(const char * col_busqueda, const char * val_busqueda, const char * columna, const char * valor) {
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

	if(valor_encontrado == false) {
		sprintf(error_mensaje, "buscando [%s]==[%s] en la tabla de simbolos, 0 coincidencias", col_busqueda, val_busqueda);
		yyerror(error_mensaje);
	}
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

void ts_error(const char *mensaje) {
	FILE * f_ts;
	ts_guardar();	
	f_ts = fopen("tabla_de_simbolos.txt", "a+");
	fprintf(f_ts, mensaje);
	free(f_ts);
}

// declaraciones
// --------------------------------------------------------

void dec_inicializar() {
	cola_crear(&declaracion_ids, sizeof(dec_registro_t));
	cola_crear(&declaracion_tipos, sizeof(dec_registro_t));
}

void dec_insertar(cola_t *p_cola, const char *descripcion) {
	dec_registro_t registro;
	strcpy(registro.descripcion, descripcion);
	cola_agregar(p_cola, &registro);
}

void dec_guardar_imprimir(const int cant_ids_por_tipo) {
	int i;
	dec_registro_t reg_id;
	dec_registro_t reg_tipo;
	// para no perder las declaraciones de ids
	cola_t cola_aux;
	cola_crear(&cola_aux, sizeof(dec_registro_t));
	while(!cola_vacia(declaracion_tipos)) {
		cola_sacar(&declaracion_tipos, &reg_tipo);
		for(i = 0; i < cant_ids_por_tipo; i++) {
			cola_sacar(&declaracion_ids, &reg_id);
			sprintf(log_mensaje, "ID [%s] TIPO [%s]", reg_id.descripcion, reg_tipo.descripcion);
			consola_log(log_mensaje);
			ts_insertar_valor_buscando(COL_NOMBRE, reg_id.descripcion, COL_TIPO_DE_DATO, reg_tipo.descripcion);			
			cola_agregar(&cola_aux, &reg_id);
		}
	}
	while(!cola_vacia(cola_aux)) {
		cola_sacar(&cola_aux, &reg_id);
		cola_agregar(&declaracion_ids, &reg_id);
	}
}

int dec_buscar_id(const char * id) {
	int apariciones = 0;
	dec_registro_t reg_id;
	cola_t cola_aux;
	cola_crear(&cola_aux, sizeof(dec_registro_t));
	while(!cola_vacia(declaracion_ids)) {
		cola_sacar(&declaracion_ids, &reg_id);
		if(strcmp(reg_id.descripcion, id) == 0)
			apariciones++;
		cola_agregar(&cola_aux, &reg_id);
	}
	while(!cola_vacia(cola_aux)) {
		cola_sacar(&cola_aux, &reg_id);
		cola_agregar(&declaracion_ids, &reg_id);
	}

	return apariciones;
}