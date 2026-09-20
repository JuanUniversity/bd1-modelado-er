# Actividad de Modelado ER — Bases de Datos I

Repositorio de los tres niveles de modelado de ocho sistemas, construidos
en Oracle SQL Developer Data Modeler. Trabajo individual: un solo autor en
todo el repositorio.

## Estructura por tema

temas/tema-XX-nombre/
  modelo.md          los tres modelos en texto
  justificacion.md   los cuatro puntos de la justificacion
  datamodeler/       diseño de Data Modeler (.dmd + carpeta hermana)
  diagramas/         SVG por nivel: 01-conceptual, 02-entidad-relacion, 03-logico
  ddl/               script SQL generado

## Reglas de commits

- Rama por tema (`tema-01-clinica-hospitalaria`): opcional. Se puede trabajar
  directo sobre `main` o aislar el tema en su propia rama y fusionarla después;
  cualquiera de los dos es válido.
- Prefija siempre el mensaje con el tema: `tema-01: modelo conceptual`.
- Nunca edites a mano los XML de `datamodeler/`. Se modifican solo desde la
  herramienta; un cambio manual rompe las referencias internas del diseño.
- Al comitear `datamodeler/`, agrega la carpeta completa, no archivos sueltos:
  el `.dmd` sin su carpeta hermana es un diseño que no abre.
- Los archivos `.local` están ignorados a propósito (caché de interfaz).
- No hagas commit automático: espera a que yo lo pida explícitamente.

## Flujo por tema

1. Modelo conceptual en `modelo.md` → commit
2. Construcción en Data Modeler → export `01-conceptual.svg` → commit
3. Atributos y restricciones → export `02-entidad-relacion.svg` → commit
4. Engineer to Relational Model → export `03-logico.svg` y DDL → commit
5. Justificación en `justificacion.md` → commit

Si el tema se trabajó en su propia rama, el último paso es fusionarla en
`main` y borrarla (local y remota); no se abren pull requests.
