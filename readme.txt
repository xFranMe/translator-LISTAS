# Translator - LISTAS

Este proyecto consiste en la elaboración de un traductor cuya misión sea la de traducir un lenguaje ficticio denominado "LISTAS" a C++. En la documentación en formato PDF que se puede encontrar en este mismo repositorio se aportan más detalles sobre el trabajo desarrollado.

A continuación, se anotan una serie de puntos a considerar para una correcta ejecución del programa.

----------------------
Ejecución del programa
----------------------

La ejecución del programa con el comando 'make' requiere del paso de un parámetro referenciado como 'ficheroEntrada'.
El valor indicado en el anterior parámetro debe ser un fichero con extensión 'list'. Como resultado de la ejecución del programa se obtendrá un fichero de salida con mismo nombre pero con extensión 'cpp'.

	>Ejemplo de ejecución con línea de comandos: $make ficheroEntrada=entrada.list

-------------------	
Ficheros de entrada
-------------------

Se proporcionan tres ficheros de entrada ya formados para la prueba del programa:

	-> entrada.list: el contenido es exactamente el mismo que el del fichero 'basica_completa.list' disponible en el aula virtual.
	-> errores.list: fichero con todos los errores semánticos controlados y gran parte de los sintácticos.
	-> entradaAmpliacion.list: fichero con cinco ejemplos de condicionales anidados para mostrar la magnitud de la ampliación llevada a cabo.
	
-------------------------------
Flujos y requisitos del sistema
-------------------------------

En el main del analizador sintáctico (listas.y) se ha hecho uso de la función 'freopen ("/dev/tty", "a", stdout)'. Esta función es empleada para restablecer el flujo de salida estándar a la terminal del sistema tras haber realizado una redirección de dicho flujo previamente también a través de freopen().

La anterior función es correcta en sistemas GNU/Linux, entorno sobre el que se ha trabajado. Sin embargo, en sistemas con otras bases es posible que no funcione adecuadamente.
