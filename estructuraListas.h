#include <map>
#include <string>
#include <cstring>
#include <iostream>
#include <vector>

using namespace std;

/**
 * Este struct almacena las principales características que describen una lista.
 *	tipo: entero que describe el tipo de elementos que almacena la lista. Sus valores pueden ser
 *		0 - entero
 *		1 - real
 *		2 - booleano
 *		3 - identificador
 *	n_linea: número de línea en la que se ha definido la lista.
 *	vector<xxxx> lista_xxxx: vector encargado de almacenar los elementos definidos en la lista. Cada objeto Lista solo tendrá valores 
 *		     		  útiles en uno de los cuatro vectores. Es decir, si una lista, por ejemplo, se define sobre valores enteros, 
 *				  solo lista_enteros contendrá valores útiles.
 */
struct Lista{
	int tipo; // 0 - lista enteros, 1 - lista reales, 2 - lista lógicos, 3 - lista identificadores
	int n_linea;
	vector<int> lista_enteros;
	vector<float> lista_reales;
	vector<bool> lista_logicos;
	vector<string> lista_identificadores;
};

/**
 * Si la lista no se encuentra dentro de la estructura se inserta un nuevo nodo en el mapa con los valores pasados como parámetro.
 * Si la lista ya se encontraba en la estructura no se hace nada, puesto que una lista no puede ser actualizada. 
 * @param nombreLista Nombre de la lista que se desea insertar en la estructura. Dicho nombre actuará como clave, 
 *                    por lo que solo estará registrado una vez a lo sumo.
 * @param lista Objeto Lista que contiene todas las propiedades asociadas a la lista de nombre nombreLista.
 * @return Devuelve True si la operación ha sido llevada a cabo con éxito. Devuelve False en caso contrario.
 */
bool insertarLista(string nombreLista, Lista lista);

/**
 * Determina si la lista cuyo nombre es introducido por parámetro existe en la estructura. En caso afirmativo, se devuelven todos
 * sus datos en el objeto lista.
 * @param nombreLista Nombre de la lista que se desea buscar dentro de la estructura. 
 * @param lista Objeto Lista en el que se devuelven los datos de la lista buscada en caso de ser encontrado.
 * @return Devuelve True si la lista ha sido encontrada. Devuelve False en caso contrario.
 */
bool buscarLista(string nombreLista, Lista &lista);

/**
 * Muestra el contenido de la estructura. Para cada elemento (lista) se muestra su nombre (clave asociada a cada elemento insertado en la 
 * estructura) y sus valores (valores almacenados en el vector correspondiente). 
 * En caso de que la estructura se encuentre vacía, se imprime un mensaje informando de ello al usuario.
 */
void mostrarListas();

/**
 * Devuelve el primer elemento de la lista pasada como parámetro.
 * @param lista Objeto Lista del que se quiere obtener el primer elemento. Para determinar el vector que hay que consultar se recurre al 
 *              campo tipo. 
 * @param aux Objeto en el que se devuelve el elemento recuperado en forma de cadena.
 */
void primeroLista(Lista lista, string &aux);

/**
 * Devuelve el último elemento de la lista pasada como parámetro.
 * @param lista Objeto Lista del que se quiere obtener el último elemento. Para determinar el vector que hay que consultar se recurre al 
 *              campo tipo. 
 * @param aux Objeto en el que se devuelve el elemento recuperado en forma de cadena.
 */
void ultimoLista(Lista lista, string &aux);

/**
 * Devuelve el elemento enesimo de la lista pasada como parámetro.
 * @param lista Objeto Lista del que se quiere obtener el elemento enesimo. Para determinar el vector que hay que consultar se recurre al 
 *              campo tipo.
 * @param index Entero que determina la posición que ocupa el elemento a buscar dentro de la lista. Su valor debe encontrarse entre 1 y el 
 *              tamaño máximo de la lista.
 * @param aux Objeto en el que se devuelve el elemento recuperado en forma de cadena.
 * @return Devuelve True si el elemento con posición index ha podido ser accedido. Devuelve False en caso contrario.
 */
bool enesimoLista(Lista lista, int index, string &aux);

/**
 * Elimina el contenido de la lista pasada como parámetro. El vector a resetear dependerá del tipo de lista del que se trate.
 * @param lista Objeto Lista que se quiere limpiar.
 */
void limpiarLista(Lista &lista);
