%{
#include "listas.h"

int n_lineas;

%}

%x COM1

digito [0-9]
entero {digito}+
letra [a-zA-Z]
real1 {entero}[.]{entero}?
real2 {entero}?[.]{entero}
real ({real1}|{real2})([eE][+-]?{entero})?
operador [+]|[-]|[*]|[/]|%|<|>|y|o
cadena ["][^"]*["]
nombreLista [A-Z]({letra}|{digito}|_){0,23}
identificador [a-z]({letra}|{digito}|_){0,23}

%option noyywrap
 
%%

"#"					BEGIN(COM1);
<COM1>"\n"				BEGIN(0); n_lineas++; return '\n';
<COM1>.				;


^[ \t]*LISTAS				return LISTAS;
^[ \t]*VARIABLES			return VARIABLES;
^[ \t]*INICIO				return INICIO;
^[ \t]*FIN 				return FIN;
cierto					return CIERTO;
falso					return FALSO;
Entero					return TIPO_ENTERO;
Real					return TIPO_REAL;
Logico					return TIPO_LOGICO;
Escribir				return ESCRIBIR;
NuevaLinea				return NUEVA_LINEA;
primero				return PRIMERO;
ultimo					return ULTIMO;
enesimo				return ENESIMO;
Si					return SI;
[ \t\n]*Si_no				return SI_NO;
"=="					return IGUAL;
"<>"					return DISTINTO;
"<="					return MENOR_IGUAL;
">="					return MAYOR_IGUAL;
no					return NEGACION;
"<-"					return ASIGNACION;
" .. "					return PUNTO_PUNTO;
{entero}				yylval.c_entero = atoi(yytext);return ENTERO;
\n					n_lineas++; return (yytext[0]);
[\t ]					;
{real}					yylval.c_real = atof(yytext);return REAL;
{operador}				return (yytext[0]);
{nombreLista}				memset(yylval.c_cadena, 0, sizeof(yylval.c_cadena));strncpy(yylval.c_cadena, yytext, yyleng);return NOMBRE_LISTA;
{identificador}			memset(yylval.c_cadena, 0, sizeof(yylval.c_cadena));strncpy(yylval.c_cadena, yytext, yyleng);return IDENTIFICADOR;
{cadena} 				memset(yylval.c_cadena_caracteres, 0, sizeof(yylval.c_cadena_caracteres));strncpy(yylval.c_cadena_caracteres, yytext+1, yyleng-2);return CADENA;
. 					return (yytext[0]);
%%

