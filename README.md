# Integrantes
Zarko Kuljis, 201823523-7
Obtuve un 100.
# Comentarios y consideraciones
Hago uso del plugin integrado de ARMSim# *LegacySWIInstructions* para usar Inputs, Outputs y terminar el programa.

Instrucciones de uso de los programas:
## Función Coseno
Recibe un parámetro entre 0 y 360, entero.

Muestra el resultado de la función coseno de ese parámetro.
## Función Máximo
Primero ingrese el largo del arreglo, este debe ser un número natural menor o igual a 100.

Luego se deben ingresar, separados por un salto de línea, tantos valores enteros como especifique el largo (Correspondientes a los valores del arreglo).

Finalmente se mostrará aquel valor correspondiente al máximo de todos los ingresados.

# Teoría
La función coseno se puede aproximar mediante la serie de taylor:

![](/taylor.png)

Sabemos que, para una aproximación en un punto por serie de Taylor, el error crece mientras más te alejas de el pivote (En nuestro caso 0) y se comporta de forma estrictamente creciente.
Ahora, conociendo que la serie de taylor de tercer grado de la función coseno nos da un error de 0,0008 para x = 90 (calculado mediante abs(cos(x)-taylorCoseno(x))), siendo el pivote 0, podemos afirmar que el máximo error de la aproximación de Taylor del coseno en el intervalo [-π/2,π/2], con grado 3, es de ±0,0008.

Ya que se nos pide una presición del 0.001, abarcando la sumatoria desde n=0 hasta n=3 basta.

Ahora, ¿Qué pasa con el resto del intervalo, es decir [π/2, 3π/3]? Bueno, aprovechandonos de que la función coseno es par y periodica, podemos decir simplemente tomar el valor del coseno del angulo opuesto (es decir, restar π) y multiplicarlo por -1. Adjunto un GeoGebra que muestra más gráficamente la teoría. https://www.geogebra.org/calculator/jchwpscz

Fuente: https://www.ck12.org/book/ck-12-conceptos-de-c%c3%a1lculo-en-espa%c3%b1ol/section/9.16/
