# Bases de Datos I — Actividad: Modelado Entidad-Relacion

Repositorio de la actividad de modelado ER: ocho tematicas modeladas en los
tres niveles (conceptual, entidad-relacion y logico) y construidas en Oracle
SQL Developer Data Modeler. Trabajo individual.

## Estructura

```
temas/tema-XX-nombre/
  modelo.md                   los tres modelos en texto
  justificacion.md            los cuatro puntos de la justificacion
  datamodeler/                diseno de Data Modeler (.dmd + carpeta hermana)
  diagramas/                  SVG por nivel: 01-conceptual, 02-entidad-relacion, 03-logico
  ddl/                        script SQL generado
entrega/                      PDF final (Actividad_Modelado_ER.pdf)
```

## Reglas de trabajo

- Rama por tema: opcional. Se puede trabajar directo sobre `main` o aislar
  el tema en su propia rama y fusionarla despues.
- **Nunca edites a mano los XML de `datamodeler/`.** Se modifican solo desde
  la herramienta; un cambio manual rompe las referencias internas del diseno.
- Cerrar Data Modeler antes de hacer `commit` (evita archivos a medio escribir).

## Flujo por tema

1. Modelo conceptual en `modelo.md` → commit
2. Construccion en Data Modeler → export `01-conceptual.svg` → commit
3. Atributos y restricciones → export `02-entidad-relacion.svg` → commit
4. Engineer to Relational Model → export `03-logico.svg` y DDL → commit
5. Justificacion en `justificacion.md` → commit

## Convencion de commits

```
tema-03: modelo conceptual
tema-03: entidades y atributos en Data Modeler
tema-03: engineer to relational + DDL
tema-03: justificacion
```
