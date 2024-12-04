%{
#include "estructura.h"
#include "estructuraListas.h"
#include <stack> /* Librería que proporciona las herramientas necesarias para trabajar con pilas. Esto es necesario para implementar la 
                    anidación de condicionales */

// Elementos externos al analizador sintáctico      			
extern int n_lineas;
extern int yylex();
extern FILE* yyin;
extern FILE* yyout;

// Variables auxiliares empleadas para el control de acciones en la gramática
bool errorSemantico = false; // Bandera para el control de errores semánticos
bool errorAux = false;
int tipo_variable; // 0 - entero, 1 - real, 2 - booleano, 3 - lista
bool definicionLista = true; // Bandera para determinar si la ejecución del programa se encuentra por el bloque de definición de LISTAS
bool esIdentificador = false; // Bandera para el control de cómo están formadas expresiones aritméticas
bool noSoloId = false; // Bandera para el control de cómo están formadas expresiones aritméticas
string nombreLista, valorAux; // Gestión de referencias a listas e inserción de identificadores en la definición de listas 
stack<bool> banderasCondicional, aux; // Pilas para la implementación de condicionales anidados
vector<string> vAux; // Gestión de definición de variables y ejecución de Escribir() al haber errores sintácticos 

// Objetos auxiliares asociados a las estructuras implementadas
Identificador id;
Lista lista;

// Definición de procedimientos auxiliares
void yyerror(const char* s){         /* llamada por cada error sintactico de yacc */
	cerr <<"> Error sintáctico en la instrucción "<<n_lineas<<endl;	
} 

%}

%union{
	int c_entero;
	float c_real;
	char c_cadena[25];
	char c_cadena_caracteres[101];
	bool c_bool;
	struct {
		float valor;
		bool esReal;
	} c_expr_aritmetica;
}

%start inicio

%token CIERTO FALSO IGUAL DISTINTO MENOR_IGUAL MAYOR_IGUAL NEGACION ASIGNACION LISTAS VARIABLES INICIO FIN TIPO_ENTERO TIPO_REAL TIPO_LOGICO ESCRIBIR NUEVA_LINEA PRIMERO ULTIMO ENESIMO PUNTO_PUNTO SI SI_NO
%token <c_entero> ENTERO
%token <c_real> REAL
%token <c_cadena> IDENTIFICADOR
%token <c_cadena> NOMBRE_LISTA
%token <c_cadena_caracteres> CADENA

%type <c_bool> expr_logica
%type <c_expr_aritmetica> expr_aritmetica

%left 'o'
%left 'y'
%left IGUAL DISTINTO
%left '<' '>' MENOR_IGUAL MAYOR_IGUAL
%left '+' '-'   /* asociativo por la izquierda, misma prioridad */
%left '*' '/' '%'  /* asociativo por la izquierda, prioridad alta */
%left menos
%left NEGACION

%%

inicio: bloqueListas bloqueVariables bloqueCodigo				{cout<<"	return 0;"<<endl<<"}"<<endl;}
	;

bloqueListas: saltoOpcional LISTAS saltoObligatorio secuenciaListas		{definicionLista = false;}
	;
	
secuenciaListas:									
	| secuenciaListas lista saltoObligatorio					
	;
	
lista:	error 	{yyerror; errorSemantico = false; esIdentificador = false; noSoloId = false; limpiarLista(lista);}
	| NOMBRE_LISTA '=' '{' secuenciaValoresLista '}' 		{if(!errorSemantico){
												if(!buscarLista($1, lista)){
													insertarLista($1, lista);
												} else {
													cerr<<"> Error semántico en la instrucción "<<n_lineas<<": la lista '"<<$1<<"' ya está definida"<<endl;
												}
											} else {
												errorSemantico = false;
											}
											limpiarLista(lista);}				
	| NOMBRE_LISTA '=' '{' expr_aritmetica PUNTO_PUNTO expr_aritmetica '}' 
											{if(!errorSemantico){
											// Las expresiones aritméticas son correctas. Hay que comprobar que sean expresiones enteras y que no contengan identificadores
											
											if(!esIdentificador){
												// No contienen identificadores
												if($4.esReal || $6.esReal){
													// Si algunas de las expresiones es real, se lanza un error
													cerr<<"> Error semántico en la instrucción "<<n_lineas<<": el rango debe definirse con expresiones enteras"<<endl;
												} else {
													// Ambas expresiones son enteras. Ahora se comprueba que el rango sea válido
													if($6.valor < $4.valor){
														cerr<<"> Error semántico en la instrucción "<<n_lineas<<": el valor de inicio del rango debe ser menor o igual que el valor final"<<endl;
													} else {
														// La lista se ha definido adecuadamente, se forma y se inserta en la estructura de listas		
														if(!buscarLista($1, lista)){
															lista.tipo = 0;
															lista.n_linea = n_lineas;
															for(int i = $4.valor; i <= $6.valor; i++){
																lista.lista_enteros.push_back(i);
															}
															insertarLista($1, lista);
															lista.lista_enteros.clear();
														} else {
															cerr<<"> Error semántico en la instrucción "<<n_lineas<<": la lista '"<<$1<<"' ya está definida"<<endl;
														}
														
													}
												}
											} else {
												esIdentificador = false;
												cerr<<"> Error semántico en la instrucción "<<n_lineas<<": no es posible emplear identificadores en las expresiones enteras que determinan un rango al definir listas"<<endl;
											}
										} else {
											errorSemantico = false;
										};
										noSoloId = false;}
	;

secuenciaValoresLista: secuenciaValoresAritmeticos				
	| secuenciaBooleanos
	;
	
secuenciaValoresAritmeticos: expr_aritmetica			{if(!errorSemantico){
									if(esIdentificador && !noSoloId){
									// En la expr aritmetica solo aparece un identificador aislado
										lista.tipo = 3;
										lista.lista_identificadores.push_back(valorAux);
									} else {
										if(!esIdentificador){
										// No aparece un identificador 
											if($1.esReal){
												lista.tipo = 1;
												lista.lista_reales.push_back($1.valor);
											} else {
												lista.tipo = 0;
												lista.lista_enteros.push_back($1.valor);
											}
										} else {
										// Aparece un identificador acompañado de algo más
											cerr<<"> Error semántico en la instrucción "<<n_lineas<<": no es posible emplear identificadores junto a expresiones numéricas en la definición de listas"<<endl;
											errorSemantico = true;
										}
									}
								}
								noSoloId = false;
								esIdentificador = false;}
	| secuenciaValoresAritmeticos ',' expr_aritmetica	{if(!errorSemantico){
									if(esIdentificador && !noSoloId){
									// En la expr aritmetica solo aparece un identificador aislado
										if(lista.tipo == 3){
											lista.lista_identificadores.push_back(valorAux);
											
										} else {
											cerr<<"> Error semántico en la instrucción "<<n_lineas<<": no es posible insertar un identificador en una lista definida sobre valores no identificadores"<<endl;
											errorSemantico = true;
										}
									} else {
										if(!esIdentificador){
										// No aparece un identificador
											if($3.esReal){
												if(lista.tipo == 1){
													lista.lista_reales.push_back($3.valor);
												} else {
													cerr<<"> Error semántico en la instrucción "<<n_lineas<<": no es posible insertar un valor real en una lista definida sobre valores no reales"<<endl;
													errorSemantico = true;
												}
											} else {
												if(lista.tipo == 0){
													lista.lista_enteros.push_back($3.valor);
												} else {
													cerr<<"> Error semántico en la instrucción "<<n_lineas<<": no es posible insertar un valor entero en una lista definida sobre valores no enteros"<<endl;
													errorSemantico = true;
												}
											}
										} else {
										// Aparece un identificador acompañado de algo más
											cerr<<"> Error semántico en la instrucción "<<n_lineas<<": no es posible emplear identificadores junto a expresiones numéricas en la definición de listas"<<endl;
											errorSemantico = true;
										}
									}
								}
								noSoloId = false;
								esIdentificador = false;}
	;
	
secuenciaBooleanos: expr_logica			{if(!errorSemantico){
								if(!esIdentificador){
									lista.tipo = 2;
									lista.lista_logicos.push_back($1);
								} else {
									cerr<<"> Error semántico en la instrucción "<<n_lineas<<": no es posible emplear identificadores en expresiones lógicas al definir una lista"<<endl;
									errorSemantico = true;
									esIdentificador = false;
								}
							}
							noSoloId = false;}			
	| secuenciaBooleanos ',' expr_logica		{if(!errorSemantico){
								if(!esIdentificador){
									lista.lista_logicos.push_back($3);
								} else {
									cerr<<"> Error semántico en la instrucción "<<n_lineas<<": no es posible emplear identificadores en expresiones lógicas al definir una lista"<<endl;
									errorSemantico = true;
									esIdentificador = false;
								};
							}
							noSoloId = false;}
	;
		
bloqueVariables: VARIABLES saltoObligatorio secuenciaVariables	{cout<<"#include <iostream>"<<endl;
									cout<<"using namespace std;"<<endl;
									cout<<"int main(){"<<endl;
									cout<<"	// Inicio del bloque de código"<<endl;}
		;

secuenciaVariables:
	| secuenciaVariables defVariables saltoOpcional
	;

defVariables: tipoVariable secuenciaIdentificadores ';' 	{ for(int i=0; i < vAux.size(); i++){
									if(!buscarIdentificador(vAux[i], id)){
									id.tipo = tipo_variable;
									id.n_linea = n_lineas;
										if(tipo_variable == 3){
										if(buscarLista(nombreLista, lista)){
											id.nombreLista = nombreLista;
											id.tipo_lista = lista.tipo;
											insertarIdentificador(vAux[i], id);
										} else {
											cerr<<"> Error semántico en la instrucción "<<n_lineas<<": la lista '"<<nombreLista<<"' no está definida"<<endl;
										}
									} else {
										insertarIdentificador(vAux[i], id);
									}
								} else {
									cerr<<"> Error semántico en la instrucción "<<n_lineas<<": la variable '"<<vAux[i]<<"' ya está definida"<<endl;
								}} vAux.clear();}
	| error  	{yyerror; errorSemantico = false; esIdentificador = false; noSoloId = false; limpiarLista(lista); vAux.clear();}
	;

secuenciaIdentificadores: IDENTIFICADOR 			{vAux.push_back(string($1));} 
	| secuenciaIdentificadores ',' IDENTIFICADOR		{vAux.push_back(string($3));}
	;
	
tipoVariable: NOMBRE_LISTA	{tipo_variable = 3; nombreLista = $1;}
	| TIPO_ENTERO		{tipo_variable = 0;}
	| TIPO_REAL		{tipo_variable = 1;}
	| TIPO_LOGICO		{tipo_variable = 2;}
	;
		
bloqueCodigo: INICIO saltoObligatorio secuenciaInstrucciones FIN saltoObligatorio	{cout<<"	// Final del bloque de código"<<endl;}				
	;
		
secuenciaInstrucciones: 
	| secuenciaInstrucciones instruccion saltoOpcional
	;
		 
instruccion: NUEVA_LINEA ';' 				{if(banderasCondicional.top()){cout<<"	cout << endl;"<<endl;};}
	| asignacion  					{/* El ';' se encuentra definido en las asignaciones por el control de errores sintácticos*/}		
	| ESCRIBIR '(' secuenciaEscribir ')' ';' 	{for(int i=0; i < vAux.size(); i++){cout<<vAux[i]<<endl;} vAux.clear();}
	| condicional					{banderasCondicional.pop();aux.pop();errorSemantico=false;}
	| error  	{yyerror; errorSemantico = false; esIdentificador = false; noSoloId = false; limpiarLista(lista); vAux.clear();}
	;

secuenciaEscribir: valor
	| secuenciaEscribir ',' valor
	;
 
valor: expr_aritmetica			{if(banderasCondicional.top()){
						if(!errorSemantico){
							// Entra una expresión aritmética sin errores en la que aparecen únicamente identificadores enteros y/o reales, o directamente no aparecen identificadores
							if($1.esReal){
								vAux.push_back("	cout << \""+to_string($1.valor)+"\";");
							}
							else{
								vAux.push_back("	cout << \""+to_string((int)$1.valor)+"\";");
							}
							
						} else {
							// La expresión está mal formada (algún id no existe o problemas con operaciones) o aprecen identificadores lógicos o de tipo lista
							if(esIdentificador && !noSoloId){
								// La expresión contiene un solo identificador que existe, ya sea del tipo lógico o lista
								vAux.push_back("	cout << \""+valorAux+"\";");
							} else {
								if(errorAux){
									cerr<<"> Error semántico en la instrucción "<<n_lineas<<": variables de tipo lógico o lista no pueden aparecer en expresiones"<<endl;
									errorAux=false;
								}
							}	
						}
					}
					errorSemantico = false;
					esIdentificador = false;
					noSoloId = false;}
	| CADENA			{if(banderasCondicional.top()){vAux.push_back("	cout << \""+string($1)+"\";");};}
	| referencia			{if(!errorSemantico){
						if(banderasCondicional.top()){
							vAux.push_back("	cout << \""+valorAux+"\";");
						}
					}
					else{
						errorSemantico=false;
					};}
	;

referencia: PRIMERO'('NOMBRE_LISTA')'			{nombreLista = $3;
							if(buscarLista(nombreLista, lista)){
								primeroLista(lista, valorAux);
							} else {
								cerr<<"> Error semántico en la instrucción "<<n_lineas<<": la lista referenciada ("<<nombreLista<<") no está definida"<<endl;
								errorSemantico = true;
							};}
	| ULTIMO'('NOMBRE_LISTA')'			{nombreLista = $3;
							if(buscarLista(nombreLista, lista)){
								ultimoLista(lista, valorAux);
							} else {
								cerr<<"> Error semántico en la instrucción "<<n_lineas<<": la lista referenciada ("<<nombreLista<<") no está definida"<<endl;
								errorSemantico = true;
							}
							}
	| ENESIMO'('NOMBRE_LISTA','expr_aritmetica')'	{if(!errorSemantico){
								if(!$5.esReal){
									nombreLista = $3;
									if(buscarLista(nombreLista, lista)){
										if(!enesimoLista(lista, $5.valor, valorAux)){cerr<<"> Error semántico en la instrucción "<<n_lineas<<": el índice introducido en la función se encuentra fuera de rango -> [1, tamaño lista]"<<endl;errorSemantico=true;}
									} else {
										cerr<<"> Error semántico en la instrucción "<<n_lineas<<": la lista referenciada ("<<nombreLista<<") no está definida"<<endl;
										errorSemantico = true;
									}
								} else {
									cerr<<"> Error semántico en la instrucción "<<n_lineas<<": el índice introducido debe tratarse de una expresión aritmética de tipo entero"<<endl;
									errorSemantico = true;
								}
							} else {
								cerr<<"> Error semántico en la instrucción "<<n_lineas<<": el índice introducido en la función no es correcto"<<endl;
								if(errorAux){
									cerr<<"> Error semántico en la instrucción "<<n_lineas<<": variables de tipo lógico o lista no pueden aparecer en expresiones"<<endl;
									errorAux=false;
								}
							};
							esIdentificador = false;
							noSoloId=false;}
	;
	
condicional: parteSi parteSiNo
	;
	
parteSi: SI '(' expr_logica ')' {if(banderasCondicional.top() && !errorSemantico){banderasCondicional.push($3);aux.push(false);}
 else {banderasCondicional.push(false);aux.push(true);if(errorAux){cerr<<"> Error semántico en la instrucción "<<n_lineas<<": variables de tipo lógico o lista no pueden aparecer en expresiones"<<endl;errorAux=false;}}noSoloId=false;esIdentificador=false;} saltoOpcional bloque {if(!banderasCondicional.top() && aux.top()){banderasCondicional.top()=true;aux.top()=false;}}
	;
	
parteSiNo: 									
	| SI_NO {banderasCondicional.top() = !banderasCondicional.top();} saltoOpcional bloque 		
	;

bloque: '[' saltoOpcional secuenciaInstruccionesBloque ']'
	;

secuenciaInstruccionesBloque: 
	| secuenciaInstruccionesBloque instruccion saltoObligatorio
	;  
	
saltoObligatorio: '\n'
	| saltoObligatorio '\n'
	;
	
saltoOpcional: 
	| saltoOpcional '\n'
	;
	
asignacion:  IDENTIFICADOR ASIGNACION expr_aritmetica ';' {if(!errorSemantico){
								if(buscarIdentificador($1, id)){
									//IDENTIFICADOR ya existía, hay que comprobar que el tipo de la expresión sea igual a su tipo
									if(id.tipo != $3.esReal){
										//los tipos NO coinciden, se tiene un error semántico
										cerr<<"> Error semántico en la instrucción "<<n_lineas<<": el tipo de '"<<$1<<"' es ";		
										switch(id.tipo){
										case 0:
											cerr<<"entero";
											break;
										case 1:
											cerr<<"real";
											break;
										case 2:
											cerr<<"booleano";
											break;
										case 3:
											cerr<<"lista";
										}
										cerr<<" y no se le puede asignar un valor de tipo ";
										if($3.esReal) {cerr<<"real";}
										else {cerr<<"entero";}
										cerr<<endl;
									} else {
										//los tipos SÍ coinciden, se inserta con los nuevos valores (valor y línea)
										if(banderasCondicional.top()){
											if($3.esReal) {id.valor.valor_real=$3.valor;}
											else {id.valor.valor_entero=$3.valor;}
											id.n_linea = n_lineas;
											if(!insertarIdentificador($1, id)) {cerr<<"No se ha podido insertar"<<endl;}
										}
									}
								} else {
									//IDENTIFICADOR NO existía, no se hace nada
									cerr<<"> Error semántico en la instrucción "<<n_lineas<<": el identificador '"<<$1<<"' no se ha definido y no se puede operar con él"<<endl;
								}
							} else {
								errorSemantico = false;
								if(errorAux){
									cerr<<"> Error semántico en la instrucción "<<n_lineas<<": variables de tipo lógico o lista no pueden aparecer en expresiones"<<endl;
									errorAux=false;
								}
							}
							esIdentificador=false;
							noSoloId=false;}
	|IDENTIFICADOR ASIGNACION expr_logica ';' 	{if(!errorSemantico){
								if(buscarIdentificador($1, id)){
								//IDENTIFICADOR ya existía, hay que comprobar que el tipo de la expresión sea igual a su tipo
									if(id.tipo != 2){//2 es el valor numérico que se ha asignado al tipo booleano
										//los tipos NO coinciden, se tiene un error semántico
										cerr<<"> Error semántico en la instrucción "<<n_lineas<<": el tipo de '"<<$1<<"' es ";
										if(id.tipo == 1) {
											cerr<<"real";
										} else {
											if(id.tipo == 0){
												cerr<<"entero";
											} else {
												cerr<<"lista";
											}
										}
										cerr<<" y no se le puede asignar un valor de tipo booleano"<<endl;
									} else {
										//los tipos SÍ coinciden, se inserta con los nuevos valores (valor y línea)
										if(banderasCondicional.top()){
											id.valor.valor_booleano = $3;
											id.n_linea = n_lineas;
											insertarIdentificador($1, id);
										}
									}
								} else {
									//IDENTIFICADOR NO existía, no se hace nada
									cerr<<"> Error semántico en la instrucción "<<n_lineas<<": el identificador '"<<$1<<"' no se ha definido y no se puede operar con él"<<endl;
								}
							} else {
								errorSemantico = false;
								if(errorAux){
									cerr<<"> Error semántico en la instrucción "<<n_lineas<<": variables de tipo lógico o lista no pueden aparecer en expresiones"<<endl;
									errorAux=false;
								}
							};
							esIdentificador = false;
							noSoloId = false;}
	| IDENTIFICADOR ASIGNACION referencia ';'  	{if(!errorSemantico){
								if(buscarIdentificador($1, id)){
									if(id.tipo != 3){
										cerr<<"> Error semántico en la instrucción "<<n_lineas<<": el identificador '"<<$1<<"' no es del tipo lista"<<endl;
									} else {
										//controlar aquí que la lista del identificador tenga el nombre de la lista referenciada
										if(id.nombreLista == nombreLista){
											if(banderasCondicional.top()){
												switch(id.tipo_lista){
												case 0:
													id.valor.valor_entero = atoi(valorAux.c_str());
													break;
												case 1:
													id.valor.valor_real = atof(valorAux.c_str());
													break;
												case 2:
													if(valorAux == "cierto"){id.valor.valor_booleano = 1;}
													else{id.valor.valor_booleano = 0;}
													break;
												case 3:
													strncpy(id.valor.valor_identificador, valorAux.c_str(), sizeof(id.valor.valor_identificador));
													break;
												}
												insertarIdentificador($1, id);
												memset(id.valor.valor_identificador, 0, sizeof(id.valor.valor_identificador));
											}
										} else {
											cerr<<"> Error semántico en la instrucción "<<n_lineas<<": la lista sobre la que se ha definido el identificador '"<<$1<<"' ("<<id.nombreLista<<") no coincide con la lista referenciada ("<<nombreLista<<")"<<endl;
										}
									}
								} else {
									//IDENTIFICADOR NO existía, no se hace nada
									cerr<<"> Error semántico en la instrucción "<<n_lineas<<": el identificador '"<<$1<<"' no se ha definido y no se puede operar con él"<<endl;
								}
							} else {
								errorSemantico = false;
							};}
	;
expr_logica: expr_aritmetica '<' expr_aritmetica 	{$$=$1.valor < $3.valor;}
	| CIERTO 					{$$=true;}
	| FALSO 					{$$=false;}
     	| expr_aritmetica MENOR_IGUAL expr_aritmetica {$$=$1.valor<=$3.valor;}
      	| expr_aritmetica '>' expr_aritmetica 	{$$=$1.valor>$3.valor;}
    	| expr_aritmetica MAYOR_IGUAL expr_aritmetica	{$$=$1.valor>=$3.valor;}
   	| expr_aritmetica IGUAL expr_aritmetica 	{$$=$1.valor==$3.valor;}
     	| expr_aritmetica DISTINTO expr_aritmetica 	{$$=$1.valor!=$3.valor;}
  	| expr_logica IGUAL expr_logica 		{$$=$1==$3;}
   	| expr_logica DISTINTO expr_logica 		{$$=$1!=$3;}
   	| expr_logica 'y' expr_logica 		{$$=$1&&$3;}
      	| expr_logica 'o' expr_logica 		{$$=$1||$3;}
      	| NEGACION expr_logica				{$$=!$2;}
      	| '('expr_logica')'				{$$=$2;}
	;
expr_aritmetica: ENTERO				{$$.esReal=false;$$.valor=$1;noSoloId=true;}
      	| REAL						{$$.esReal=true;$$.valor=$1;noSoloId=true;}
      	| IDENTIFICADOR				{if(definicionLista){
      								valorAux = $1; // Para inserción de identificadores en listas
      								esIdentificador = true;
      							} else {
	      							if(!buscarIdentificador($1, id)){
			       					// IDENTIFICADOR NO está definido
			       					errorSemantico = true;
			       					cerr<<"> Error semántico en la instrucción "<<n_lineas<<": la variable '"<<$1<<"' no está definida y no se puede operar con ella"<<endl;
			       				} else {
			       					// IDENTIFICADOR SÍ está definido
			       					esIdentificador = true;
			       					switch (id.tipo) {
			       					case 0:
			       						$$.valor=id.valor.valor_entero; 
			       						$$.esReal = false;
			       						break;
			       					case 1:
			       						$$.valor=id.valor.valor_real; 
			       						$$.esReal = true;
			       						break;
			       					case 2:
			       						errorSemantico = true;
			       						errorAux = true;
			       						if(id.valor.valor_booleano){
			       							valorAux = "cierto";
			       						} else {valorAux="falso";}
			       						break;
			       					case 3:
			       						errorSemantico = true;
			       						errorAux = true;
			       						switch(id.tipo_lista){
			       							case 0:
				       							valorAux = to_string(id.valor.valor_entero);
				       							break;
			       							case 1:
			       								valorAux = to_string(id.valor.valor_real);
				       							break;
			       							case 2:
			       								if(id.valor.valor_booleano){
			       									valorAux = "cierto";
			       								} else {valorAux="falso";}
				       							break;
			       							case 3:
			       								valorAux = string(id.valor.valor_identificador);
			       						}
			       					}
			       				}
		       				};}
      	| expr_aritmetica '+' expr_aritmetica		{$$.esReal=$1.esReal||$3.esReal;$$.valor=$1.valor+$3.valor;noSoloId=true;}              
      	| expr_aritmetica '-' expr_aritmetica    	{$$.esReal=$1.esReal||$3.esReal; $$.valor=$1.valor-$3.valor;noSoloId=true;}            
      	| expr_aritmetica '*' expr_aritmetica     	{$$.esReal = $1.esReal||$3.esReal;$$.valor=$1.valor*$3.valor;noSoloId=true;} 
      	| expr_aritmetica '/' expr_aritmetica      	{if($3.valor == 0){
			       				errorSemantico = true;
			       				cerr<<"> Error semántico en la instrucción "<<n_lineas<<": división por 0"<<endl;
			       			}else{
			       				$$.esReal = $1.esReal || $3.esReal;
			       				if($$.esReal){
			       					$$.valor = $1.valor/$3.valor;
			       				}else{
			       					$$.valor = (int)$1.valor/(int)$3.valor;
			       				}
			       			}
			       			noSoloId=true;}
     	| expr_aritmetica '%' expr_aritmetica					{if($3.valor == 0){
       							errorSemantico = true;
       							cerr<<"> Error semántico en la instrucción "<<n_lineas<<": % con división por 0"<<endl;
       						}else{
       							$$.esReal = $1.esReal || $3.esReal;
       							if(!$$.esReal){
       								$$.valor = (int)$1.valor%(int)$3.valor;
       							}else{
       								errorSemantico = true;
       								cerr<<"> Error semántico en la instrucción "<<n_lineas<<": se usa la operación % con operandos reales"<<endl;
       							}
       						}
       						noSoloId=true;}
   	|'-' expr_aritmetica %prec menos		{$$.esReal=$2.esReal;$$.valor=-$2.valor;noSoloId=true;}
    	| '('expr_aritmetica')' 			{$$.esReal=$2.esReal;$$.valor=$2.valor;}
    	;


%%

int main(int argc, char *argv[]){
	// Si el ejecutable (listas) no ha sido llamado con 1 parámetro, se lanza el error y finaliza el programa
	if(argc != 2){ 
		cout<<"ERROR - La llamada al ejecutable debe ser de la siguiente forma: ./listas *nombre_fichero_entrada*.list"<<endl;
		return 0;
	}
	
	// Si el fichero pasado como primer argumento (fichero de entrada) no tiene extensión .list finaliza el programa
	string ficheroEntrada = argv[1];
	if(ficheroEntrada.substr(ficheroEntrada.find_last_of(".")+1) != "list"){
		cout<<"ERROR - La extensión del fichero pasado como argumento debe ser .list"<<endl;
		return 0;
	}
	
	// Se abre el flujo de lectura sobre el fichero pasado como argumento
	yyin = fopen(argv[1], "r");

	/* Si yyin == NULL quiere decir que el fichero de entrada (argv[1]) no existe, por lo que !yyin se hace true, se muestra el error 
	y finaliza el programa */
	if(!yyin){ 
		cout<<"ERROR - El fichero de entrada no existe"<<endl;
		return 0;
	}
	
	// Se muestra por consola el siguiente mensaje antes de la redirección del flujo de escritura y la ejecución del analizador
	cout<<endl<<"-----------------------------------------------------------"<<endl;
	cout<<"Errores detectados durante la traducción al lenguaje LISTAS"<<endl;
	cout<<"-----------------------------------------------------------"<<endl<<endl;
	
	/* Se abre el flujo de escritura sobre un fichero con mismo nombre que el fichero de entrada, pero con extensión .cpp,
	redireccionando la salida estándar del programa a dicho flujo */
	string nombreFicheroSalida = ficheroEntrada.substr(0, ficheroEntrada.find_last_of(".")) + ".cpp";
	yyout = freopen(nombreFicheroSalida.c_str(), "w", stdout);
	
	/* Se inicializan las variables necesarias:
	 * 	n_lineas Entero que almacena el número de líneas que han sido procesadas hasta el momento. Como mínimo su valor será 1.
	 *	banderasCondicional Pila principal empleada para el control de la ejecución de instrucciones. Siempre debe tener un valor 
	 *	                    que sea True como fondo, ya que en un inicio toda instrucción puede ser ejecutada.
	 */
	n_lineas = 1;
	banderasCondicional.push(true);
	
	// Procedimiento del analizador sintáctico que realiza, a su vez, una llamada al procedimiento del analizador léxico
	yyparse();
	
	// Finalizado el proceso, se cierran los flujos de lectura y escritura
	fclose(yyin);
	fclose(yyout);
	
	// Se restaura el flujo estándar a la consola del sistema
	freopen ("/dev/tty", "a", stdout);
	
	// Se muestra por consola el estado de las tablas de símbolos tras la ejecución
	cout<<endl<<"----------------------------"<<endl;
	cout<<"Tablas de símbolos generadas"<<endl;
	cout<<"----------------------------"<<endl<<endl;
	mostrarListas();
	cout<<endl;
	mostrarIdentificadores();
	return 0;
}
