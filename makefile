# Autor: Francisco Javier Mesa Martín

OBJ = listas.o lexico.o estructura.cpp estructuraListas.cpp

salida.txt : listas
	./listas $(ficheroEntrada)
	
listas : $(OBJ) 					# Segunda fase de la traducción. Generación del código ejecutable 
	g++ -olistas $(OBJ) 

listas.o : listas.c        				# Primera fase de la traducción del analizador sintáctico
	g++ -c -olistas.o  listas.c 
	
lexico.o : lex.yy.c					# Primera fase de la traducción del analizador léxico
	g++ -c -olexico.o  lex.yy.c 	

listas.c : listas.y       				# Obtenemos el analizador sintáctico en C
	bison -d -v -olistas.c listas.y

lex.yy.c : lexico.l					# Obtenemos el analizador léxico en C
	flex lexico.l

clean : 
	rm  -f *.c *.o
