#include "estructura.h"

/**
 * Se emplea un Map (Mapa: Clave-Valor) como tabla de símbolos para los identificadores.
 * La Clave se ha definido como un 'string', puesto que va a almacenar el "nombre" del identificador.
 * Como Valor se tiene un objeto del tipo 'Identificador', definido en estructura.h. Este contiene los parámetros de interés que describen
 * un identificador.
 * La siguiente declaración del mapa inicia, de forma interna, la estructura dinámicamente.
 */
map<string, Identificador> identificadoresMap;

bool insertarIdentificador(string nombreIdentificador, Identificador id){
	bool encontrado = (identificadoresMap.count(nombreIdentificador) == 1);
	bool insertado = false;
	if(!encontrado){
		// El identificador NO se ha encontrado -> se inserta tal cual
		identificadoresMap.insert(map<string, Identificador>::value_type(nombreIdentificador, id));
		insertado = true;
	} else {
		// El identificador SÍ se ha encontrado -> se recupera el elemento, se comprueba su tipo y se modifica su valor (y nº línea)
		auto iterador = identificadoresMap.find(nombreIdentificador);
		if(iterador->second.tipo == id.tipo){ // nos aseguramos de que el tipo sea el mismo
			iterador->second.valor = id.valor;
			iterador->second.n_linea = id.n_linea;
			insertado = true;
		}
		/* En caso de que los tipos no coincidan, el mensaje de error se muestra en la acción pertinente definida en la gramática 
		   del analizador sintáctico */
	}
	return insertado;
}

bool buscarIdentificador(string nombreIdentificador, Identificador &id){
	bool encontrado = (identificadoresMap.count(nombreIdentificador) == 1);
	if(encontrado){
		// El identificador SÍ se ha encontrado -> se devuelve su información en id
		auto iterador = identificadoresMap.find(nombreIdentificador);
		id = iterador->second;
	}
	return encontrado;
}

void mostrarIdentificadores(){
	if(identificadoresMap.empty()){
		// La tabla de símbolos está vacía
		cout<<"TABLA DE SÍMBOLOS VACÍA: no se han definido identificadores"<<endl;
	} else {
		// La tabla de símbolos NO está vacía
		auto iterador = identificadoresMap.begin();
		cout<<"Tabla de símbolos (Identificadores):"<<endl;
	    	while (iterador != identificadoresMap.end()) {
	    		string nombreID = iterador->first;
	    		Identificador atributosAux = iterador->second;
			cout<<"    "<<"ID: "<<nombreID<<"		";
			switch(atributosAux.tipo){
			case 0:
				cout<<"Tipo: entero		Valor: "<<atributosAux.valor.valor_entero<<endl;
				break;
			case 1:
				cout<<"Tipo: real		Valor: "<<atributosAux.valor.valor_real<<endl;
				break;
			case 2:
				cout<<"Tipo: lógico		Valor: ";
				if(atributosAux.valor.valor_booleano){
					cout<<"cierto"<<endl;
				} else {
					cout<<"falso"<<endl;
				}
				break;
			case 3:
				// Se trata de un tipo lista, por lo que se procede a mostrar también los atributos nombreLista y tipo_lista
				cout<<"Tipo: lista "<<atributosAux.nombreLista;
				switch(atributosAux.tipo_lista){
				case 0:
					cout<<" (enteros)		Valor: "<<atributosAux.valor.valor_entero<<endl;
					break;
				case 1:
					cout<<" (reales)		Valor: "<<atributosAux.valor.valor_real<<endl;
					break;
				case 2:
					cout<<" (lógicos)		Valor: ";
					if(atributosAux.valor.valor_booleano){
						cout<<"cierto"<<endl;
					} else {
						cout<<"falso"<<endl;
					}
					break;
				case 3:
					cout<<" (identificadores)		Valor: ";
					for(int i = 0; i < strlen(atributosAux.valor.valor_identificador); i++){
						cout<<atributosAux.valor.valor_identificador[i];
					}
					cout<<endl;
				}
			}
			++iterador;
		}
    	}
	return;
}
