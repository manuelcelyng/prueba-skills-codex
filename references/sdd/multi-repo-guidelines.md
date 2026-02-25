# SmartPay SDD — Multi-repo guidelines

En SmartPay, un “cambio” puede impactar múltiples microservicios clonados en un workspace local.

## Regla de persistencia

- Cada microservicio mantiene su propio `openspec/`.
- Si un change impacta 2+ micros, se repite el mismo `change-name` por repo (si aplica).

## Consistencia mínima entre micros

Para evitar drift, mantener consistentes:
- Intent (por qué)
- Scope (in/out)
- Success criteria
- Contratos entre servicios (si cambian)

## Estrategia recomendada

1) Elegir micros participantes.
2) Correr `smartpay-sdd-orchestrator` por micro con el mismo `change-name`.
3) Verificar por micro con tests/build reales.
4) Archivar por micro.

