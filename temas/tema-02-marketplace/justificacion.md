# Justificación del modelo — Tema 2: Plataforma de comercio electrónico

## 1. Supuestos y alcance

Se modela el ciclo completo de una transacción en un marketplace: el registro de
los usuarios y de quienes además venden, el catálogo de productos organizado por
categorías, la construcción del carrito, la conversión de ese carrito en un
pedido, el pago que lo liquida, los envíos en que se divide y su seguimiento
hasta la entrega, y las valoraciones que los compradores dejan sobre productos y
vendedores.

El enunciado pide explícitamente separar el catálogo de la actividad
transaccional, y esa separación es el eje del modelo. El **catálogo** —categoría
y producto— describe lo que la plataforma ofrece y cambia por decisión de los
vendedores. La **actividad transaccional** —carrito, pedido, detalle, pago,
envío y seguimiento— registra hechos que ocurrieron y que no deben alterarse
después. Esta distinción es la que obliga a la decisión más importante del
modelo, tratada en el punto 3: el precio se almacena dos veces, una vez como
valor vigente del catálogo y otra como valor congelado de la compra.

El segundo supuesto de fondo es que **un usuario puede comprar y vender con un
mismo registro**. Se modela una única entidad Usuario, con un perfil de Vendedor
opcional asociado uno a uno. Quien solo compra no tiene ese perfil; quien vende
lo tiene y conserva su capacidad de comprar sin duplicar sus datos.

El tercero es que **un pedido puede reunir productos de varios vendedores**, tal
como exige el enunciado. De ahí se desprende que el pedido no puede tener un
único envío: cada vendedor despacha por su cuenta, con su propia guía y su
propio recorrido, y el comprador recibe varios paquetes de una sola compra.

Quedan **fuera del alcance**:

- La gestión de devoluciones y reembolsos como proceso. El modelo contempla el
  estado `reembolsado` en el pago y `devuelto` en el seguimiento, pero no las
  entidades que registrarían la solicitud, su aprobación y el reingreso al
  inventario.
- Las promociones y cupones como entidad propia. El descuento se registra como
  valor aplicado en cada línea del pedido, no como campaña con vigencia y
  condiciones.
- La facturación electrónica y las obligaciones tributarias derivadas.
- La mensajería entre comprador y vendedor, y las disputas.
- Las imágenes de los productos y cualquier gestión de archivos.
- El historial de precios del catálogo. Solo se conserva el precio vigente y el
  precio de cada compra, no la serie completa de cambios.

## 2. Decisiones de cardinalidad

**Usuario – Vendedor (1:1).** Un usuario tiene como máximo un perfil de
vendedor, y cada perfil pertenece a un único usuario. La obligatoriedad es
asimétrica: el perfil no existe sin usuario, pero la mayoría de los usuarios no
tienen perfil. Esa asimetría determina que la clave foránea viva en VENDEDOR. Sin
el UNIQUE sobre `usuario_id`, un mismo usuario podría registrar dos tiendas y la
relación degradaría a 1:N sin que nada lo advirtiera.

**Usuario – Carrito (1:1).** Se fijó en 1:1 porque el carrito se entiende como
el espacio de compra activo del usuario, no como un histórico. La alternativa se
discute en el punto 3.

**Usuario – Direccion (1:N).** Un usuario guarda varias direcciones y elige una
al momento de comprar. No podría ser 1:1 sin obligar a reescribir la dirección
en cada pedido, ni N:N porque una dirección registrada pertenece a quien la
creó.

**Usuario – Pedido (1:N).** Un usuario acumula muchos pedidos; cada pedido es de
un solo usuario. La foránea es obligatoria: no existe pedido anónimo en el
alcance definido.

**Categoria – Producto (1:N).** Cada producto se clasifica en una única
categoría. La alternativa N:N —un producto en varias categorías a la vez— es
común en plataformas reales, pero complica la navegación del catálogo y no
aporta al ciclo transaccional que el ejercicio busca ilustrar.

**Categoria – Categoria (1:N recursiva).** Una categoría contiene subcategorías
y cada una tiene como máximo una categoría padre. Es lo que permite un catálogo
jerárquico sin crear una entidad por cada nivel. La foránea `categoria_padre_id`
es opcional, y esa opcionalidad es la que identifica a las categorías raíz.

**Vendedor – Producto (1:N).** Cada producto pertenece a un único vendedor. Esta
decisión tiene una alternativa importante que se desarrolla en el punto 3.

**Carrito – Producto (N:N) y Pedido – Producto (N:N).** Ambas son N:N por la
misma razón: un carrito o un pedido reúne varios productos, y un producto
aparece en muchos carritos y muchos pedidos. Las dos requieren tabla intermedia,
y en ambos casos esa tabla tiene atributos propios —la cantidad, y en el pedido
además el precio unitario y el descuento— que no pertenecen ni al pedido ni al
producto.

**Pedido – Pago (1:1).** Un pedido se liquida con un único pago. Se consideró
permitir pagos parciales, lo que haría la relación 1:N; se descartó porque el
enunciado describe un flujo donde el usuario paga y recibe, sin financiación ni
abonos. El UNIQUE sobre `pedido_id` es lo que sostiene esa regla.

**Pedido – Envio (1:N).** Es la consecuencia directa del requisito de que un
pedido puede incluir productos de varios vendedores. Si fuera 1:1, el modelo
estaría afirmando que todo el pedido viaja junto, lo que contradice el
enunciado.

**Vendedor – Envio (1:N) y Direccion – Envio (1:N).** Cada envío tiene un único
vendedor que lo despacha y una única dirección de destino. Ambas foráneas son
obligatorias.

**Envio – Seguimiento (1:N).** Un envío acumula muchos registros de seguimiento,
ordenados por fecha. Es lo que convierte el estado del paquete en un recorrido
reconstruible.

**Usuario – Producto (N:N) y Usuario – Vendedor (N:N).** Las valoraciones son
N:N en ambos casos. Las claves primarias compuestas de las tablas resultantes
cumplen además una función de negocio: impiden que un usuario valore dos veces
el mismo producto o califique dos veces al mismo vendedor.

## 3. Decisiones de diseño con alternativas

**Conservación del precio: valor congelado frente a lectura del catálogo.** Es
la decisión central del modelo. Se consideraron dos alternativas: (a) que el
detalle del pedido guarde solo la referencia al producto y el precio se consulte
del catálogo cuando se necesite, o (b) que el detalle almacene el precio
unitario vigente al momento de la compra. Se eligió (b), porque (a) hace que el
valor histórico de un pedido cambie cada vez que el vendedor ajusta su precio:
una factura emitida hace seis meses mostraría hoy un total distinto al que el
cliente pagó, y cualquier devolución o reclamo se calcularía sobre un valor
equivocado. El costo de (b) es la aparente redundancia entre `precio_actual` en
PRODUCTO y `precio_unitario` en DETALLE_PEDIDO; no es redundancia real, porque
son dos hechos distintos: lo que el producto cuesta hoy y lo que costó entonces.
El mismo razonamiento se aplicó al campo `descuento`.

**Un vendedor por producto frente a catálogo común con ofertas.** Se
consideraron dos modelos: (a) cada vendedor publica sus propios productos, de
modo que el mismo artículo físico aparece como registros distintos si lo venden
tres vendedores, o (b) un catálogo unificado de productos donde cada vendedor
crea una oferta con su precio y su inventario, resolviendo una N:N entre
producto y vendedor. Se eligió (a) por su simplicidad estructural: en (b) el
carrito y el detalle del pedido no podrían referenciar al producto sino a la
oferta, encadenando dos niveles de intermediación en las relaciones más usadas
del sistema. La opción (b) es la que usan las plataformas grandes, y sería
necesaria si el requisito incluyera comparar precios de varios vendedores para
un mismo artículo o mantener una ficha de producto compartida.

**Estados del envío: bitácora frente a atributo.** Se consideró (a) un campo
`estado` dentro de ENVIO con el estado actual, o (b) una entidad SEGUIMIENTO con
un registro por cada cambio, con su fecha, ubicación y observación. Se eligió
(b) porque el enunciado pide registrar los envíos con sus estados a lo largo del
recorrido, y con (a) solo se conoce el último: no habría forma de saber cuándo
salió el paquete ni por dónde pasó. El costo es una tabla más y la necesidad de
consultar el registro más reciente para conocer el estado actual.

**Total almacenado frente a total calculado.** El atributo `total` de PEDIDO es
derivable sumando las líneas de su detalle. Se consideró (a) omitirlo y
calcularlo siempre, o (b) almacenarlo. Se eligió (b) por dos razones: evita
recalcular en cada consulta de la lista de pedidos del usuario, y sobre todo
congela el valor efectivamente cobrado, que debe coincidir con el monto del pago
aunque después se corrija una línea. El riesgo asumido es la posible
inconsistencia entre el total y la suma de sus líneas, que debe controlarse desde
la aplicación o con un disparador.

**Carrito único frente a carrito histórico.** Se consideró (a) un carrito activo
por usuario, relación 1:1, o (b) muchos carritos por usuario con marca de estado,
conservando los abandonados. Se eligió (a) porque el carrito es un espacio de
trabajo previo a la compra y su valor histórico ya queda registrado en el pedido.
La opción (b) tendría sentido en un sistema que analizara tasas de abandono de
carrito, lo cual está fuera del alcance.

**Identificadores propios frente a claves naturales.** Todas las entidades usan
un identificador numérico propio, y los valores que identifican en el mundo real
—el correo del usuario, el SKU del producto, el número de guía del envío, el
nombre de la tienda— se declaran como restricciones de unicidad. La alternativa
sería usar esos valores como clave primaria. Se descartó porque son mutables: un
usuario cambia de correo, un vendedor renombra su tienda, y ese cambio se
propagaría a todas las tablas que los referencian.

**Estados como texto con restricción frente a tablas de catálogo.** Los estados
de usuario, producto, pedido, pago y envío se modelaron como columnas de texto
con restricción CHECK. La alternativa sería una tabla de catálogo por cada
conjunto de estados, con su clave foránea. Se eligió la primera por economía: son
conjuntos pequeños, estables y sin atributos propios. La segunda sería preferible
si los estados tuvieran que administrarse desde la aplicación sin modificar el
esquema.

## 4. Coherencia entre los tres niveles

Los tres niveles describen el mismo sistema con distinto grado de detalle, y cada
elemento de uno se corresponde con el siguiente de forma verificable.

**Del conceptual al entidad-relación.** Las diez entidades del conceptual
—Usuario, Vendedor, Direccion, Categoria, Producto, Carrito, Pedido, Pago, Envio
y Seguimiento— son las mismas diez del entidad-relación, con idénticos nombres y
las mismas dieciséis relaciones con su cardinalidad sin alterar. Lo que se añade
en este nivel son los atributos propios de cada entidad y sus restricciones. Las
claves foráneas no se listan aquí: incluir `categoria_id` dentro de Producto
duplicaría lo que la relación "clasifica" ya expresa. Las cuatro relaciones N:N
siguen planteadas sin resolver, y los atributos que les pertenecen —la cantidad
del carrito, el precio congelado del pedido, la calificación de las
valoraciones— se declaran pendientes para el nivel siguiente.

**Del entidad-relación al lógico.** La traducción sigue tres reglas aplicadas sin
excepción. Cada relación 1:N se resolvió con una clave foránea en el lado
"muchos": `usuario_id` en DIRECCION y PEDIDO, `categoria_id` y `vendedor_id` en
PRODUCTO, `categoria_padre_id` en CATEGORIA para la recursiva, `pedido_id`,
`vendedor_id` y `direccion_id` en ENVIO, y `envio_id` en SEGUIMIENTO. Cada
relación 1:1 se resolvió con una clave foránea acompañada de restricción de
unicidad: `usuario_id` en VENDEDOR y en CARRITO, y `pedido_id` en PAGO. Y cada
relación N:N generó una tabla intermedia con clave primaria compuesta:
ITEM_CARRITO, DETALLE_PEDIDO, VALORACION_PRODUCTO y CALIFICACION_VENDEDOR. Las
diez entidades más estas cuatro tablas dan las catorce del modelo lógico.

**Verificación mediante la herramienta.** El modelo se construyó en Oracle SQL
Developer Data Modeler importando el script DDL, lo que generó el modelo
relacional con sus catorce tablas, sus claves y sus relaciones. Desde ese modelo
se generó por ingeniería inversa el modelo lógico de la herramienta, que
corresponde al nivel entidad-relación de la teoría. Esa generación tiene una
limitación conocida: las cuatro tablas intermedias aparecen como entidades, ya
que en el script ya son tablas y nada en ellas indica que representaban
relaciones N:N. Se corrigieron manualmente eliminándolas del modelo lógico y
trazando en su lugar las cuatro relaciones N:N correspondientes, de modo que ese
nivel refleje lo que el documento declara. El modelo conceptual se obtuvo del
mismo modelo lógico reduciendo el nivel de detalle de visualización, lo que deja
las diez entidades con sus relaciones y sin atributos.

**Correspondencia con el script generado.** Las restricciones declaradas en el
entidad-relación tienen su equivalente exacto en el DDL: las marcas NN
corresponden a NOT NULL, las marcas U a restricciones UNIQUE, las listas de
valores permitidos C(...) a restricciones CHECK, y los valores por defecto D= a
cláusulas DEFAULT. Se añadieron además restricciones CHECK sobre los valores
numéricos —precios y montos mayores que cero, inventario y costos no negativos,
calificaciones entre uno y cinco— que expresan reglas del negocio que la
cardinalidad por sí sola no puede capturar. El script se genera sin errores ni
advertencias, y todos los nombres de restricción respetan el límite de treinta
caracteres de Oracle.
