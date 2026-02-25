# OpenSpec Layout (por microservicio)

SmartPay (multi-repo) persiste artefactos SDD **dentro del repo del micro**.

Estructura:

```
openspec/
├── config.yaml
├── specs/
│   └── <domain>/
│       └── spec.md
└── changes/
    ├── <change-name>/
    │   ├── exploration.md          (opcional)
    │   ├── proposal.md
    │   ├── design.md
    │   ├── tasks.md
    │   ├── specs/
    │   │   └── <domain>/
    │   │       └── spec.md         (delta spec del change)
    │   └── verify-report.md        (solo si mode=openspec)
    └── archive/
        └── YYYY-MM-DD-<change-name>/
            └── ...
```

Convención:
- `openspec/specs/` es el **source of truth** “main”.
- `openspec/changes/<change>/specs/` son **delta specs** del change.

