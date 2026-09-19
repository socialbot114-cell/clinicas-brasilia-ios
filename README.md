# Clínicas Brasília iOS

MVP SwiftUI offline-first para busca de clínicas e especialidades no Distrito
Federal. Não oferece diagnóstico ou aconselhamento médico.

- Bundle ID: `br.com.clinicas.brasilia`
- App Store ID: `6813989729`
- SKU: `clinicas-brasilia`
- Projeto gerado com XcodeGen
- Catálogo local, busca, filtros, favoritos, telefone, WhatsApp e mapa

## Desenvolvimento

```bash
xcodegen generate --spec project.yml
xcodebuild test -project ClinicasBrasilia.xcodeproj -scheme ClinicasBrasilia -destination 'platform=iOS Simulator,name=iPhone 17,OS=latest'
python3 tools/jerv_cli.py validate app.yml
```

O release fica bloqueado até a revisão editorial e a confirmação dos dados.
