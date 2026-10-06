# `Array#bsearch` sin bloque

## Problema

La RubySpec `core/array/bsearch_spec.rb:5` espera que `[1].bsearch` devuelva
un `Enumerator` cuando no se pasa bloque, y que su tamaño sea desconocido
(`nil`). En el barrido de compatibilidad Spinel respondió `NoMethodError`.

## Reproducción

`test/array_bsearch_without_block.rb` comprueba la búsqueda con bloque y la
clase, tamaño, `next`, `rewind` y `each` del Enumerator sin bloque. El
`.expected` refleja CRuby 4.0.7.

## Alcance

Agregar el camino sin bloque para `Array#bsearch`, que conserva el receptor y
el predicado para `Enumerator#next` y `Enumerator#each`; reporta tamaño
desconocido; y valida que el bloque de búsqueda devuelva Integer, Float,
booleano o nil.

## Validación

`core/array/bsearch_spec.rb`: 13 PASS, 0 FAIL, 0 ERROR y 3 REJECT. Los tres
REJECT corresponden a los ejemplos con `break` (líneas 70, 74 y 78), cuya
expresión el compilador todavía no soporta. El test local de regresión pasa.
