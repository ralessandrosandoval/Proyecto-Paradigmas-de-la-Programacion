PROYECTO PARADIGMAS - SISTEMA INTELIGENTE DE RECOMENDACION ACADEMICA

ARCHIVOS:
- main.cpp: modulo C++ para registrar datos y generar CSV.
- Main.hs: modulo Haskell para analizar historial.csv.
- recomendador.pl: modulo Prolog para reglas logicas y recomendaciones.
- cursos.csv, prerrequisitos.csv, historial.csv, intereses.csv: datos generados por el modulo C++.

ORDEN DE EJECUCION:
1) Compilar y ejecutar C++:
   g++ -std=c++17 main.cpp -o sistema
   ./sistema
   Elegir opcion 11 para generar los CSV.

2) Ejecutar Haskell:
   runhaskell Main.hs
   o tambien:
   ghc Main.hs -o haskell_reporte
   ./haskell_reporte

3) Ejecutar Prolog:
   swipl recomendador.pl
   Dentro de Prolog ejecutar:
   cargar_todo.
   mostrar_reporte(estudiante1).
   mostrar_reporte(estudiante2).

IMPORTANTE:
Todos los archivos deben estar en la misma carpeta, porque Haskell y Prolog leen los CSV generados por C++.
