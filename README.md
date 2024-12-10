# Translator - LISTAS

## What is Translator - LISTAS?

This proyect consists in the development of a translator whose target is to translate a made up programming language called "LISTAS" to C++. This provides a way to run code using custom directives.

## How to run the translator

The translator can be run using the "make" command. It requires one parameter, referenced as "ficheroEntrada", which is the input file that contains the LISTAS directives we want to execute. That file must have the extension ".list". As output, we will obtain a new file named as the input one but with ".cpp" extension.

Command line example: `make ficheroEntrada=input.list`

### Input files

Three input files are provided to test the translator:

* **entrada.list**: contains basic directives.
* **errores.list**: contains directives that cover all possible semantic errors and most of the syntatic ones. 
* **entradaAmpliacion.list**: contains only conditional statements, testing nesting.

### System requirements

The syntax parser (lists.y) uses the function `freopen (“/dev/tty”, “a”, stdout)`. This function is used to restore the standard output stream to the system terminal after having previously performed a redirection of this stream. This functions works as intended in GNU/Linux systems, environment used to work on the development. However, on other systems it may not work properly.

## About documentation

:warning: Except for this README file, the rest of the documentation is written in Spanish.

External documentation can be found in [Doc_TranslatorListas.pdf](https://github.com/xFranMe/translator-LISTAS/blob/main/Doc_TranslatorLISTAS.pdf), file located in this repository. This covers how the translator works and which design decisions have been made, including data structures, the lexical parser, the syntactic parser and the error control. In addition, internal documentation is provided as comments within the source code to cover details about specific implementations.
