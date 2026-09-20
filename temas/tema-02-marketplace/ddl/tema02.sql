-- =====================================================================
-- Tema 2 — Plataforma de comercio electrónico (marketplace)
-- Modelo lógico (relacional) — Oracle Database 11g
-- Derivado del modelo conceptual y del modelo entidad-relación.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Catálogo de usuarios y vendedores
-- ---------------------------------------------------------------------

CREATE TABLE usuario (
    usuario_id       NUMBER NOT NULL,
    correo           VARCHAR2(120) NOT NULL,
    contrasena_hash  VARCHAR2(255) NOT NULL,
    nombres          VARCHAR2(60) NOT NULL,
    apellidos        VARCHAR2(60) NOT NULL,
    telefono         VARCHAR2(20),
    fecha_registro   DATE DEFAULT SYSDATE NOT NULL,
    estado           VARCHAR2(12) DEFAULT 'activo' NOT NULL
);

ALTER TABLE usuario ADD CONSTRAINT usuario_pk PRIMARY KEY ( usuario_id );

ALTER TABLE usuario ADD CONSTRAINT usuario_correo_un UNIQUE ( correo );

ALTER TABLE usuario
    ADD CHECK ( estado IN ( 'activo', 'inactivo', 'suspendido' ) );

CREATE TABLE vendedor (
    vendedor_id   NUMBER NOT NULL,
    nombre_tienda VARCHAR2(80) NOT NULL,
    nit           VARCHAR2(20),
    descripcion   VARCHAR2(500),
    fecha_alta    DATE DEFAULT SYSDATE NOT NULL,
    estado        VARCHAR2(12) DEFAULT 'activo' NOT NULL,
    usuario_id    NUMBER NOT NULL
);

ALTER TABLE vendedor ADD CONSTRAINT vendedor_pk PRIMARY KEY ( vendedor_id );

ALTER TABLE vendedor ADD CONSTRAINT vendedor_tienda_un UNIQUE ( nombre_tienda );

ALTER TABLE vendedor ADD CONSTRAINT vendedor_nit_un UNIQUE ( nit );

ALTER TABLE vendedor ADD CONSTRAINT vendedor_usuario_un UNIQUE ( usuario_id );

ALTER TABLE vendedor
    ADD CHECK ( estado IN ( 'activo', 'suspendido' ) );

CREATE TABLE direccion (
    direccion_id      NUMBER NOT NULL,
    etiqueta          VARCHAR2(40) NOT NULL,
    destinatario      VARCHAR2(120) NOT NULL,
    linea_direccion   VARCHAR2(200) NOT NULL,
    ciudad            VARCHAR2(60) NOT NULL,
    departamento      VARCHAR2(60) NOT NULL,
    codigo_postal     VARCHAR2(10),
    telefono_contacto VARCHAR2(20) NOT NULL,
    predeterminada    VARCHAR2(1) DEFAULT 'N' NOT NULL,
    usuario_id        NUMBER NOT NULL
);

ALTER TABLE direccion ADD CONSTRAINT direccion_pk PRIMARY KEY ( direccion_id );

ALTER TABLE direccion
    ADD CHECK ( predeterminada IN ( 'N', 'S' ) );

-- ---------------------------------------------------------------------
-- Catálogo de productos
-- ---------------------------------------------------------------------

CREATE TABLE categoria (
    categoria_id       NUMBER NOT NULL,
    nombre_categoria   VARCHAR2(60) NOT NULL,
    descripcion        VARCHAR2(300),
    activa             VARCHAR2(1) DEFAULT 'S' NOT NULL,
    categoria_padre_id NUMBER
);

ALTER TABLE categoria ADD CONSTRAINT categoria_pk PRIMARY KEY ( categoria_id );

ALTER TABLE categoria ADD CONSTRAINT categoria_nombre_un UNIQUE ( nombre_categoria );

ALTER TABLE categoria
    ADD CHECK ( activa IN ( 'N', 'S' ) );

CREATE TABLE producto (
    producto_id       NUMBER NOT NULL,
    sku               VARCHAR2(30) NOT NULL,
    nombre_producto   VARCHAR2(150) NOT NULL,
    descripcion       VARCHAR2(2000),
    precio_actual     NUMBER(12, 2) NOT NULL,
    stock_disponible  NUMBER(10) DEFAULT 0 NOT NULL,
    estado            VARCHAR2(12) DEFAULT 'borrador' NOT NULL,
    fecha_publicacion DATE DEFAULT SYSDATE NOT NULL,
    categoria_id      NUMBER NOT NULL,
    vendedor_id       NUMBER NOT NULL
);

ALTER TABLE producto ADD CONSTRAINT producto_pk PRIMARY KEY ( producto_id );

ALTER TABLE producto ADD CONSTRAINT producto_sku_un UNIQUE ( sku );

ALTER TABLE producto
    ADD CHECK ( estado IN ( 'agotado', 'borrador', 'publicado', 'retirado' ) );

ALTER TABLE producto
    ADD CHECK ( precio_actual > 0 );

ALTER TABLE producto
    ADD CHECK ( stock_disponible >= 0 );

-- ---------------------------------------------------------------------
-- Actividad transaccional
-- ---------------------------------------------------------------------

CREATE TABLE carrito (
    carrito_id           NUMBER NOT NULL,
    fecha_creacion       DATE DEFAULT SYSDATE NOT NULL,
    fecha_actualizacion  DATE,
    usuario_id           NUMBER NOT NULL
);

ALTER TABLE carrito ADD CONSTRAINT carrito_pk PRIMARY KEY ( carrito_id );

ALTER TABLE carrito ADD CONSTRAINT carrito_usuario_un UNIQUE ( usuario_id );

CREATE TABLE pedido (
    pedido_id     NUMBER NOT NULL,
    numero_pedido VARCHAR2(20) NOT NULL,
    fecha_pedido  DATE DEFAULT SYSDATE NOT NULL,
    total         NUMBER(12, 2) NOT NULL,
    estado        VARCHAR2(12) DEFAULT 'pendiente' NOT NULL,
    usuario_id    NUMBER NOT NULL
);

ALTER TABLE pedido ADD CONSTRAINT pedido_pk PRIMARY KEY ( pedido_id );

ALTER TABLE pedido ADD CONSTRAINT pedido_numero_un UNIQUE ( numero_pedido );

ALTER TABLE pedido
    ADD CHECK ( estado IN ( 'cancelado', 'entregado', 'enviado', 'pagado', 'pendiente' ) );

ALTER TABLE pedido
    ADD CHECK ( total >= 0 );

CREATE TABLE pago (
    pago_id          NUMBER NOT NULL,
    referencia_pago  VARCHAR2(40) NOT NULL,
    metodo_pago      VARCHAR2(12) NOT NULL,
    monto            NUMBER(12, 2) NOT NULL,
    fecha_pago       DATE DEFAULT SYSDATE NOT NULL,
    estado           VARCHAR2(12) DEFAULT 'pendiente' NOT NULL,
    pedido_id        NUMBER NOT NULL
);

ALTER TABLE pago ADD CONSTRAINT pago_pk PRIMARY KEY ( pago_id );

ALTER TABLE pago ADD CONSTRAINT pago_referencia_un UNIQUE ( referencia_pago );

ALTER TABLE pago ADD CONSTRAINT pago_pedido_un UNIQUE ( pedido_id );

ALTER TABLE pago
    ADD CHECK ( metodo_pago IN ( 'billetera', 'efectivo', 'pse', 'tarjeta' ) );

ALTER TABLE pago
    ADD CHECK ( estado IN ( 'aprobado', 'pendiente', 'rechazado', 'reembolsado' ) );

ALTER TABLE pago
    ADD CHECK ( monto > 0 );

CREATE TABLE envio (
    envio_id               NUMBER NOT NULL,
    numero_guia            VARCHAR2(40) NOT NULL,
    transportadora         VARCHAR2(60) NOT NULL,
    fecha_despacho         DATE,
    fecha_entrega_estimada DATE,
    costo_envio            NUMBER(12, 2) DEFAULT 0 NOT NULL,
    pedido_id              NUMBER NOT NULL,
    vendedor_id            NUMBER NOT NULL,
    direccion_id           NUMBER NOT NULL
);

ALTER TABLE envio ADD CONSTRAINT envio_pk PRIMARY KEY ( envio_id );

ALTER TABLE envio ADD CONSTRAINT envio_guia_un UNIQUE ( numero_guia );

ALTER TABLE envio
    ADD CHECK ( costo_envio >= 0 );

CREATE TABLE seguimiento (
    seguimiento_id NUMBER NOT NULL,
    fecha_hora     DATE DEFAULT SYSDATE NOT NULL,
    estado         VARCHAR2(15) NOT NULL,
    ubicacion      VARCHAR2(120),
    observacion    VARCHAR2(300),
    envio_id       NUMBER NOT NULL
);

ALTER TABLE seguimiento ADD CONSTRAINT seguimiento_pk PRIMARY KEY ( seguimiento_id );

ALTER TABLE seguimiento
    ADD CHECK ( estado IN ( 'devuelto', 'en_preparacion', 'en_reparto', 'en_transito', 'entregado' ) );

-- ---------------------------------------------------------------------
-- Tablas que resuelven las relaciones N:N
-- ---------------------------------------------------------------------

-- Resuelve la N:N Carrito–Producto
CREATE TABLE item_carrito (
    carrito_id  NUMBER NOT NULL,
    producto_id NUMBER NOT NULL,
    cantidad    NUMBER(6) DEFAULT 1 NOT NULL
);

ALTER TABLE item_carrito ADD CONSTRAINT item_carrito_pk PRIMARY KEY ( carrito_id,
                                                                      producto_id );

ALTER TABLE item_carrito
    ADD CHECK ( cantidad > 0 );

-- Resuelve la N:N Pedido–Producto; conserva el precio al momento de la compra
CREATE TABLE detalle_pedido (
    pedido_id       NUMBER NOT NULL,
    producto_id     NUMBER NOT NULL,
    cantidad        NUMBER(6) NOT NULL,
    precio_unitario NUMBER(12, 2) NOT NULL,
    descuento       NUMBER(12, 2) DEFAULT 0 NOT NULL
);

ALTER TABLE detalle_pedido ADD CONSTRAINT detalle_pedido_pk PRIMARY KEY ( pedido_id,
                                                                          producto_id );

ALTER TABLE detalle_pedido
    ADD CHECK ( cantidad > 0 );

ALTER TABLE detalle_pedido
    ADD CHECK ( precio_unitario > 0 );

ALTER TABLE detalle_pedido
    ADD CHECK ( descuento >= 0 );

-- Resuelve la N:N Usuario–Producto
CREATE TABLE valoracion_producto (
    usuario_id    NUMBER NOT NULL,
    producto_id   NUMBER NOT NULL,
    calificacion  NUMBER(1) NOT NULL,
    comentario    VARCHAR2(1000),
    fecha_emision DATE DEFAULT SYSDATE NOT NULL
);

ALTER TABLE valoracion_producto ADD CONSTRAINT valoracion_producto_pk PRIMARY KEY ( usuario_id,
                                                                                    producto_id );

ALTER TABLE valoracion_producto
    ADD CHECK ( calificacion BETWEEN 1 AND 5 );

-- Resuelve la N:N Usuario–Vendedor
CREATE TABLE calificacion_vendedor (
    usuario_id    NUMBER NOT NULL,
    vendedor_id   NUMBER NOT NULL,
    calificacion  NUMBER(1) NOT NULL,
    comentario    VARCHAR2(1000),
    fecha_emision DATE DEFAULT SYSDATE NOT NULL
);

ALTER TABLE calificacion_vendedor ADD CONSTRAINT calificacion_vendedor_pk PRIMARY KEY ( usuario_id,
                                                                                        vendedor_id );

ALTER TABLE calificacion_vendedor
    ADD CHECK ( calificacion BETWEEN 1 AND 5 );

-- ---------------------------------------------------------------------
-- Claves foráneas
-- ---------------------------------------------------------------------

ALTER TABLE vendedor
    ADD CONSTRAINT vendedor_usuario_fk FOREIGN KEY ( usuario_id )
        REFERENCES usuario ( usuario_id );

ALTER TABLE direccion
    ADD CONSTRAINT direccion_usuario_fk FOREIGN KEY ( usuario_id )
        REFERENCES usuario ( usuario_id );

ALTER TABLE categoria
    ADD CONSTRAINT categoria_padre_fk FOREIGN KEY ( categoria_padre_id )
        REFERENCES categoria ( categoria_id );

ALTER TABLE producto
    ADD CONSTRAINT producto_categoria_fk FOREIGN KEY ( categoria_id )
        REFERENCES categoria ( categoria_id );

ALTER TABLE producto
    ADD CONSTRAINT producto_vendedor_fk FOREIGN KEY ( vendedor_id )
        REFERENCES vendedor ( vendedor_id );

ALTER TABLE carrito
    ADD CONSTRAINT carrito_usuario_fk FOREIGN KEY ( usuario_id )
        REFERENCES usuario ( usuario_id );

ALTER TABLE pedido
    ADD CONSTRAINT pedido_usuario_fk FOREIGN KEY ( usuario_id )
        REFERENCES usuario ( usuario_id );

ALTER TABLE pago
    ADD CONSTRAINT pago_pedido_fk FOREIGN KEY ( pedido_id )
        REFERENCES pedido ( pedido_id );

ALTER TABLE envio
    ADD CONSTRAINT envio_pedido_fk FOREIGN KEY ( pedido_id )
        REFERENCES pedido ( pedido_id );

ALTER TABLE envio
    ADD CONSTRAINT envio_vendedor_fk FOREIGN KEY ( vendedor_id )
        REFERENCES vendedor ( vendedor_id );

ALTER TABLE envio
    ADD CONSTRAINT envio_direccion_fk FOREIGN KEY ( direccion_id )
        REFERENCES direccion ( direccion_id );

ALTER TABLE seguimiento
    ADD CONSTRAINT seguimiento_envio_fk FOREIGN KEY ( envio_id )
        REFERENCES envio ( envio_id );

ALTER TABLE item_carrito
    ADD CONSTRAINT item_carrito_carrito_fk FOREIGN KEY ( carrito_id )
        REFERENCES carrito ( carrito_id );

ALTER TABLE item_carrito
    ADD CONSTRAINT item_carrito_producto_fk FOREIGN KEY ( producto_id )
        REFERENCES producto ( producto_id );

ALTER TABLE detalle_pedido
    ADD CONSTRAINT detalle_pedido_pedido_fk FOREIGN KEY ( pedido_id )
        REFERENCES pedido ( pedido_id );

ALTER TABLE detalle_pedido
    ADD CONSTRAINT detalle_pedido_producto_fk FOREIGN KEY ( producto_id )
        REFERENCES producto ( producto_id );

ALTER TABLE valoracion_producto
    ADD CONSTRAINT valoracion_usuario_fk FOREIGN KEY ( usuario_id )
        REFERENCES usuario ( usuario_id );

ALTER TABLE valoracion_producto
    ADD CONSTRAINT valoracion_producto_fk FOREIGN KEY ( producto_id )
        REFERENCES producto ( producto_id );

ALTER TABLE calificacion_vendedor
    ADD CONSTRAINT calificacion_usuario_fk FOREIGN KEY ( usuario_id )
        REFERENCES usuario ( usuario_id );

ALTER TABLE calificacion_vendedor
    ADD CONSTRAINT calificacion_vendedor_fk FOREIGN KEY ( vendedor_id )
        REFERENCES vendedor ( vendedor_id );
