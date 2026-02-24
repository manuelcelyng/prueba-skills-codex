# Contexto General (multi-proyecto)

Este directorio consolida las reglas comunes que se repiten en los servicios Java y Python.
Si un servicio tiene `context/` propio, esas reglas tienen prioridad para ese modulo.

## Como usar este contexto
- Para una HU: leer `context/hu/<id>/` del servicio afectado y complementar con estas reglas globales.
- Para cambios en varios servicios: aplicar reglas comunes aqui + reglas especificas del servicio.
- La IA no gestiona git/ramas/PRs; eso se coordina manualmente.

## Contenido
- `java-rules.md`: arquitectura, clean code y reglas reactivas para servicios Java.
- `python-rules.md`: reglas de ETL/Lambda y estilo para servicios Python.

