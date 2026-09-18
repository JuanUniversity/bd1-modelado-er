# Bases de Datos I — Actividad: Modelado Entidad-Relacion

Repositorio del grupo para las ocho tematicas modeladas en los tres niveles
(conceptual, entidad-relacion y logico) y construidas en Oracle SQL Developer
Data Modeler.

## Integrantes
| Nombre | Temas a cargo |
| --- | --- |
|  | |
|  | |
|  | |
|  | |

## Estructura

```
temas/tema-XX-nombre/
  modelo.md                   los tres modelos en texto
  justificacion.md            los cuatro puntos de la justificacion
  datamodeler/                diseno de Data Modeler (.dmd + carpeta hermana)
  diagramas/                  PNG exportados (logico y relacional)
  ddl/                        script SQL generado
entrega/                      PDF final (Actividad_Modelado_ER.pdf)
```

## Reglas de trabajo

1. Una rama por tema: `tema-03-gestion-academica`.
2. **Un solo editor por diseno a la vez.** Los XML de Data Modeler no se
   fusionan bien; si dos personas editan el mismo `.dmd`, hay que descartar
   una version completa.
3. Cerrar Data Modeler antes de hacer `commit` (evita archivos a medio escribir).
4. Al terminar un tema: exportar PNG a `diagramas/` y el DDL a `ddl/`, luego
   abrir un Pull Request hacia `main`.

## Convencion de commits

```
tema-03: modelo conceptual
tema-03: entidades y atributos en Data Modeler
tema-03: engineer to relational + DDL
tema-03: justificacion
```
