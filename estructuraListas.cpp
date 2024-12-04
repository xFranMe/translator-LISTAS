#include "estructuraListas.h"

/**
 * Se emplea un Map (Mapa: Clave-Valor) como tabla de símbolos para las listas.
 * La Clave se ha definido como un 'string', puesto que va a almacenar el "nombre" de la lista.
 * Como Valor se tiene un objeto del tipo 'Lista', definido en estructuraLista.h. Este contiene los parámetros de interés que describen
 * una lista.
 * La siguiente declaración del mapa inicia, de forma interna, la estructura dinámicamente.
 */
map<string, Lista> listasMap;

bool insertarLista(string nombreLista, Lista lista){
	bool encontrado = (listasMap.count(nombreLista) == 1);
	bool insertado = false;
	if(!encontrado){
		// La lista NO se ha encontrado -> se inserta tal cual
		listasMap.insert(map<string, Lista>::value_type(nombreLista, lista));
		insertado = true;
	}
	// La lista SÍ se ha encontrado y no se hace nada
	// El mensaje de error pertinente se muestra en el analizador sintáctico listas.y
	return insertado;
}

bool buscarLista(string nombreLista, Lista &lista){
	bool encontrado = (listasMap.count(nombreLista) == 1);
	if(encontrado){
		// La lista SÍ se ha encontrado -> se devuelve su información en lista
		auto iterador = listasMap.find(nombreLista);
		lista = iterador->second;
	}
	return encontrado;
}

void mostrarListas(){
	if(listasMap.empty()){
		cout<<"TABLA DE SÍMBOLOS (LISTAS) VACÍA: no se han definido listas"<<endl;
	} else {
		auto iterador = listasMap.begin();
		cout<<"Tabla de símbolos (Listas):"<<endl;
	    	while (iterador != listasMap.end()) {
	    		string nombreLista = iterador->first;
	    		Lista atributosAux = iterador->second;
			cout<<"    "<<"Lista: "<<nombreLista<<"		";
			switch(atributosAux.tipo){
			case 0:
				cout<<"Tipo: enteros		";
				cout<<"Valores: {";
				for(int item : atributosAux.lista_enteros)
					cout<<" "<<item;
				cout<<" }"<<endl;
				break;
			case 1:
				cout<<"Tipo: reales		";
				cout<<"Valores: {";
				for(float item : atributosAux.lista_reales)
					cout<<" "<<item;
				cout<<" }"<<endl;
				break;
			case 2:
				cout<<"Tipo: lógicos		";
				cout<<"Valores: {";
				for(bool item : atributosAux.lista_logicos)
					if(item == 1){cout<<" cierto";}
					else{cout<<" falso";}
				cout<<" }"<<endl;
				break;
			case 3:
				cout<<"Tipo: identificadores		";
				cout<<"Valores: {";
				for(string item : atributosAux.lista_identificadores)
					cout<<" "<<item;
				cout<<" }"<<endl;
			}
			++iterador;
		}
    	}
	return;
}

void primeroLista(Lista lista, string &aux){
	switch(lista.tipo){
	case 0:
		aux = to_string(lista.lista_enteros.front());
		break;
	case 1:
		aux = to_string(lista.lista_reales.front());
		break;
	case 2:
		if(lista.lista_logicos.front() == 1){aux = "cierto";}
		else{aux = "falso";}
		break;
	case 3:
		aux = string(lista.lista_identificadores.front());
		break;
	}
}

void ultimoLista(Lista lista, string &aux){
	switch(lista.tipo){
	case 0:
		aux = to_string(lista.lista_enteros.back());
		break;
	case 1:
		aux = to_string(lista.lista_reales.back());
		break;
	case 2:
		if(lista.lista_logicos.back() == 1){aux = "cierto";}
		else{aux = "falso";}
		break;
	case 3:
		aux = string(lista.lista_identificadores.back());
		break;
	}
}

bool enesimoLista(Lista lista, int index, string &aux){
	switch(lista.tipo){
	case 0:
		if(index >= 1 && index <= lista.lista_enteros.size()){
			aux = to_string(lista.lista_enteros.at(index-1));
			return true;
		} else {
			return false;
		}
		break;
	case 1:
		if(index >= 1 && index <= lista.lista_reales.size()){
			aux = to_string(lista.lista_reales.at(index-1));
			return true;
		} else {
			return false;
		}
		break;
	case 2:
		if(index >= 1 && index <= lista.lista_logicos.size()){
			if(lista.lista_logicos.at(index-1) == 1){aux = "cierto";}
			else{aux = "falso";}
			return true;
		} else {
			return false;
		}
		break;
	case 3:
		if(index >= 1 && index <= lista.lista_identificadores.size()){
			aux = string(lista.lista_identificadores.at(index-1));
			return true;
		} else {
			return false;
		}
		break;
	default:
		return NULL;
	}
}
	
void limpiarLista(Lista &lista){
	switch(lista.tipo){
		case 0:
			lista.lista_enteros.clear();
			break;
		case 1:
			lista.lista_reales.clear();
			break;
		case 2:
			lista.lista_logicos.clear();
			break;
		case 3:
			lista.lista_identificadores.clear();
	};
}

