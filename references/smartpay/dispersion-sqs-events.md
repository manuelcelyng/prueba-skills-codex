# SmartPay — Dispersión (SQS) — notas operativas

## Eventos relevantes

### `CIERRE_LOTE_DIS_AUT`

**Regla (Bug 25137):** El micro `dispersion` debe consumir el evento SQS `CIERRE_LOTE_DIS_AUT` y disparar la ejecución automática de controles para lotes en estado esperado con fecha de corte vencida.

