# Justificación del modelo — Tema 1: Sistema de gestión clínica-hospitalaria

## 1. Supuestos y alcance

Se modela el recorrido asistencial de un paciente dentro de una institución de
salud: su registro como persona, la historia clínica que lo acompaña de forma
permanente, cada episodio de atención que recibe, los profesionales que
intervienen en él, lo que ese episodio produce en términos de diagnósticos,
medicamentos prescritos y exámenes ordenados, y la hospitalización con
asignación de cama cuando el episodio lo amerita.

El supuesto central es que **la atención es el episodio que ancla todo el
modelo**. Cualquier hecho clínico relevante ocurre dentro de una atención y se
registra colgando de ella, lo que permite reconstruir el recorrido completo de
un paciente recorriendo las atenciones de su historia en orden cronológico. Esta
decisión es la que da coherencia al resto: si los diagnósticos o las
prescripciones colgaran directamente del paciente, se perdería el contexto de en
qué consulta se produjeron.

Se asume además que la institución opera con un único registro por persona: un
paciente tiene una sola historia clínica y esa historia no se duplica aunque el
paciente ingrese por urgencias en lugar de por consulta programada. También se
asume que los diagnósticos, medicamentos y exámenes son catálogos administrados
centralmente, no texto libre que cada profesional escribe a su manera.

Quedan **fuera del alcance** los siguientes aspectos, por no ser necesarios para
ilustrar el recorrido asistencial que el ejercicio plantea:

- La agenda de citas previas. El modelo registra que una atención ocurrió y de
  qué tipo fue (urgencias, consulta externa o control), pero no la solicitud que
  la originó, su reprogramación o su cancelación.
- Los tratamientos como entidad propia. El plan terapéutico se considera
  cubierto por la combinación de diagnósticos y prescripciones del episodio.
- La facturación, los contratos con aseguradoras y los costos de la atención.
- La nómina del personal, sus turnos y su disponibilidad horaria.
- Los resultados clínicos de los exámenes. El modelo registra que un examen fue
  ordenado, no el valor que arrojó.

## 2. Decisiones de cardinalidad

**Paciente – Historia_clinica (1:1).** Se fijó en 1:1 porque el supuesto de
registro único lo exige: si un paciente pudiera tener dos historias, el recorrido
clínico quedaría partido y consultarlo completo requeriría unir registros que la
base considera independientes, con el riesgo asistencial que eso implica. La
obligatoriedad es asimétrica: la historia no existe sin paciente, pero un
paciente puede registrarse antes de que se le abra la historia. Esa asimetría es
la que determina que la clave foránea viva en HISTORIA_CLINICA y no al revés.

**Historia_clinica – Atencion (1:N).** Una historia acumula todas las atenciones
del paciente a lo largo de los años, y cada atención pertenece a una sola
historia. No podría ser N:N porque una misma atención no puede pertenecer a dos
pacientes distintos. La atención es obligatoria del lado de la historia: ninguna
atención existe sin historia que la contenga.

**Especialidad – Doctor (1:N).** Se decidió que cada doctor ejerce una única
especialidad dentro del alcance definido. Si la institución reconociera
subespecialidades o doble titulación simultánea, la relación pasaría a N:N y
exigiría una tabla intermedia, igual que las cuatro que sí tiene el modelo.

**Atencion – Doctor (N:N).** La narrativa establece que una atención puede
involucrar a uno o varios profesionales — piénsese en una urgencia atendida por
un médico general que interconsulta a un especialista. Y un doctor atiende
muchos pacientes. Ambas direcciones son "muchos", así que la relación es N:N y
requiere tabla intermedia.

**Atencion – Diagnostico, Medicamento y Examen (N:N).** Las tres siguen la misma
lógica. Una atención produce varios diagnósticos, prescribe varios medicamentos
y ordena varios exámenes; y cada elemento del catálogo se usa en muchas
atenciones distintas. Son N:N precisamente porque los tres son catálogos
compartidos: un medicamento existe una sola vez en el sistema y se referencia
desde todas las atenciones que lo prescriben.

**Atencion – Hospitalizacion (1:1).** Se fijó en 1:1 para preservar el rol de la
atención como episodio. Si fuera 1:N, una misma atención podría generar varias
hospitalizaciones y dejaría de ser la unidad que ancla el recorrido. Es opcional
del lado de la atención — la mayoría de las atenciones no derivan en
internación — y obligatoria del lado de la hospitalización, ya que ningún
paciente se hospitaliza sin una atención que lo justifique. Sin el UNIQUE sobre
`atencion_id` en HOSPITALIZACION, nada impediría crear dos hospitalizaciones para
la misma atención y la relación degradaría, sin darse cuenta, a una 1:N.

**Cama – Hospitalizacion (1:N) y Area – Cama (1:N).** Una cama aloja muchas
hospitalizaciones a lo largo del tiempo, y un área reúne muchas camas. Ambas
foráneas son obligatorias: no hay hospitalización sin cama asignada ni cama que
no pertenezca a un área.

## 3. Decisiones de diseño con alternativas

**Clave primaria de Paciente: identificador propio frente a número de
documento.** Se consideraron dos alternativas: (a) usar `numero_documento` como
clave primaria, ya que identifica a la persona en la vida real, o (b) introducir
un `paciente_id` interno y dejar el documento como atributo único. Se eligió (b)
por tres razones: el documento puede corregirse por error de digitación o
cambiar de tipo cuando un menor pasa de tarjeta de identidad a cédula, y ese
cambio se propagaría a todas las tablas que lo referencian; un paciente que
ingresa inconsciente por urgencias puede no tener documento al momento del
registro; y el identificador numérico es más eficiente como referencia en las
claves foráneas. La misma lógica se aplicó a `registro_medico` en DOCTOR. La
alternativa (a) sería preferible solo en un sistema donde el documento nunca
cambia y siempre se conoce, condición que un servicio de urgencias no cumple.

**Ubicación de las atenciones: colgando de la historia clínica frente a colgando
del paciente.** El borrador inicial planteaba ambas opciones. Se eligió que las
atenciones cuelguen de HISTORIA_CLINICA porque el vínculo paciente-historia ya
es 1:1: hacer que las atenciones referencien también al paciente crearía dos
caminos distintos para llegar al mismo dato, con el riesgo de que una atención
quedara asociada a un paciente y a la historia de otro. La alternativa sería
válida si la historia clínica no existiera como entidad y el paciente fuera el
contenedor directo del recorrido.

**Catálogos frente a texto libre.** Para diagnósticos, medicamentos y exámenes se
consideró (a) registrarlos como campos de texto dentro de la atención, o (b)
modelarlos como catálogos referenciados mediante tablas intermedias. Se eligió
(b) porque es lo único que permite consultas agregadas confiables — cuántos
pacientes fueron diagnosticados con determinada patología, qué medicamento se
prescribe con más frecuencia — y porque evita que la misma entidad clínica se
escriba de cinco formas distintas. El costo es mayor complejidad: cuatro tablas
adicionales que no estaban en la narrativa. La opción (a) sería aceptable solo en
un sistema de registro puramente documental, sin necesidad de explotar los datos.

**Asignación de cama: referencia simple frente a historial de traslados.** Se
consideró (a) una clave foránea `cama_id` en HOSPITALIZACION, que conserva la
cama actual, o (b) una tabla de historial de ocupación con fechas de inicio y
fin, que permitiría reconstruir los traslados de un paciente entre camas o áreas
durante su internación. Se eligió (a) por ser suficiente para el alcance
definido en el punto 1; la opción (b) sería necesaria si el sistema tuviera que
auditar la trazabilidad de ocupación hospitalaria, por ejemplo para control de
infecciones asociadas a la atención en salud.

**Estado explícito frente a estado deducido.** En HOSPITALIZACION se incluyó la
columna `estado` además de `fecha_egreso`, aunque el estado podría deducirse de
si la fecha está vacía. Se prefirió el atributo explícito porque hace la consulta
directa y legible, y porque permite estados futuros — una hospitalización anulada
o trasladada a otra institución — sin cambiar la estructura. El riesgo asumido es
la posible inconsistencia entre ambos campos, que se controla desde la
aplicación.

**Representación del valor booleano.** El atributo `activo` de MEDICAMENTO se
modeló como `VARCHAR2(1)` con valores S y N y su restricción CHECK, porque Oracle
no ofrece un tipo booleano usable como columna en las versiones de referencia. La
alternativa era `NUMBER(1)` con 0 y 1; se eligió la primera por legibilidad
directa al consultar la tabla.

## 4. Coherencia entre los tres niveles

Los tres niveles describen el mismo sistema con distinto grado de detalle, y cada
elemento de uno tiene correspondencia verificable en el siguiente.

**Del conceptual al entidad-relación.** Las once entidades identificadas en el
conceptual son exactamente las once que aparecen en el entidad-relación, con los
mismos nombres y las mismas diez relaciones con idéntica cardinalidad. Lo único
que se añade en este nivel son los atributos propios de cada entidad y sus
restricciones. Deliberadamente no se agregaron en este nivel las claves foráneas:
incluir `historia_id` dentro de ATENCION habría duplicado lo que la relación
"registra" ya expresa. Este punto se verificó de forma explícita durante la
construcción, cuando se detectó y eliminó un atributo `historia_id` que se había
colado en PACIENTE.

**Del entidad-relación al lógico.** La traducción sigue tres reglas aplicadas sin
excepción. Cada relación 1:N se resolvió con una clave foránea en el lado
"muchos": `historia_id` en ATENCION, `especialidad_id` en DOCTOR, `cama_id` en
HOSPITALIZACION y `area_id` en CAMA. Cada relación 1:1 se resolvió con una clave
foránea acompañada de restricción de unicidad: `paciente_id` en HISTORIA_CLINICA
y `atencion_id` en HOSPITALIZACION, ambas marcadas U, NN. Y cada relación N:N
generó una tabla intermedia con clave primaria compuesta por las dos foráneas:
PARTICIPACION_MEDICA, DIAGNOSTICO_ATENCION, PRESCRIPCION y ORDEN_EXAMEN. Las once
entidades más estas cuatro tablas dan las quince tablas del modelo lógico.

**Verificación mediante la herramienta.** El modelo se construyó en Oracle SQL
Developer Data Modeler y el modelo relacional se generó automáticamente con
"Engineer to Relational Model", lo que permitió contrastar la traducción manual
contra la que produce la herramienta. El proceso detectó dos inconsistencias que
se corrigieron en el modelo lógico y no en el relacional, para no romper la
correspondencia entre niveles: la relación 1:1 entre paciente e historia había
generado claves foráneas en ambas tablas, haciendo imposible insertar el primer
registro de cualquiera de las dos, lo que se resolvió estableciendo la
opcionalidad asimétrica descrita en el punto 2; y la relación 1:1 con
hospitalización había quedado orientada al revés, obligando a que toda atención
tuviera una hospitalización asociada. Tras las correcciones, la validación con
Design Rules no reportó errores y el script DDL se genera sin errores ni
advertencias.

**Correspondencia con el script generado.** Las restricciones declaradas en el
entidad-relación tienen su equivalente exacto en el DDL: las marcas NN
corresponden a las cláusulas NOT NULL, las marcas U a las restricciones UNIQUE,
las listas de valores permitidos C(...) a las restricciones CHECK, y los valores
por defecto D= a las cláusulas DEFAULT. El documento y el script se ajustaron
mutuamente donde diferían: se retiraron del documento los valores por defecto de
las tres fechas, que no se cargaron en la herramienta. Las tablas intermedias,
que la herramienta nombró con el verbo de la relación que resolvían, se
renombraron con sustantivos del negocio y sus columnas se ajustaron al estándar
del resto del modelo. Las relaciones conservan su nombre de verbo en los niveles
conceptual y entidad-relación, porque en esos niveles son relaciones; solo al
resolverse en el nivel lógico se convierten en tablas con nombre propio.
