#include <map>
#include <string>
#include <cstring>
#include <iostream>

using namespace std;

union tipo_valor {
	int valor_entero;
	float valor_real;
	bool valor_booleano;
	char valor_identificador[25];
};

/**
 * Este struct almacena las principales características que describen un identificador.
 *	tipo: entero que almacena alguno de los siguientes valores
 *		0 - entero
 *		1 - real
 *		2 - booleano
 *		3 - lista
 *	valor: almacena el valor del identificador. Este puede ser entero, real, booleano o un vector de 25 caracteres (nombre identificador 
 *	       procedente de una lista).
 *	n_linea: número de la última línea en la que se aplicó una asignación sobre el identificador.
 *	nombreLista: cadena que tomará valor únicamente si el identificador se trata de una lista (tipo = 3).
 *	tipo_lista: entero que indica el tipo de valores que almacena la lista referenciada en nombreLista. Su valores pueden ser
 *		0 - entero
 *		1 - real
 *		2 - booleano
 *		3 - identificador
 */
struct Identificador{
	int tipo; // 0-entero, 1-real, 2-booleano, 3-lista
	tipo_valor valor;
	int n_linea;
	string nombreLista; //nombreLista y tipo_lista únicamente tomarán un valor si el identificador es del tipo lista
	int tipo_lista; // 0-entero, 1-real, 2-booleano, 3-identificador
};

/**
 * Si el identificador no se encuentra dentro de la estructura se inserta un nuevo nodo en el mapa con los valores pasados como parámetro.
 * Si el identificador ya se encontraba en la estructura se comprueba que los datos que se quieren insertar sean del mismo tipo. En 
 * caso afirmativo, se actualizan los valores 'valor' (valor de la variable) y 'n_linea' (número de línea en el que se ha referenciado al
 * identificador). El campo 'tipo_valor' no varía, puesto que es una de las condiciones para actualizar los datos de 
 * un identificador. Lo mismo ocurre con los campos 'nombreLista' y 'tipo_lista'.
 * @param nombreIdentificador Nombre del identificador que se desea insertar en la estructura. Dicho nombre actuará como clave, 
 *                            por lo que solo estará registrado una vez a lo sumo.
 * @param id Objeto Identificador que contiene todas las propiedades asociadas al identificador de nombre nombreIdentificador.
 * @return Devuelve True si la operación ha sido llevada a cabo con éxito. Devuelve False en caso contrario.
 */
bool insertarIdentificador(string nombreIdentificador, Identificador id);

/**
 * Determina si el identificador cuyo nombre es introducido por parámetro existe en la estructura. En caso afirmativo, se devuelven todos
 * sus datos en el objeto id.
 * @param nombreIdentificador Nombre del identificador que se desea buscar dentro de la estructura. 
 * @param id Objeto Identificador en el que se devuelven los datos del identificador buscado en caso de ser encontrado.
 * @return Devuelve True si el identificador ha sido encontrado. Devuelve False en caso contrario.
 */
bool buscarIdentificador(string nombreIdentificador, Identificador &id);

/**
 * Muestra el contenido de la estructura. Para cada elemento (identificador) se muestra su nombre (clave del elemento insertado en la 
 * estructura), su tipo (int tipo) y su valor (tipo_valor valor). En caso de que el identificador sea del tipo lista (tipo = 3), se muestra 
 * también el nombre de la lista (string nombreLista) y el tipo de elementos que contiene (int tipo_lista).
 * Por el contrario, en caso de que la estructura se encuentre vacía, se imprime un mensaje informando de ello al usuario.
 */
void mostrarIdentificadores();
