# ClipboardFormatter

[![build](https://github.com/andremrod/clipboard-formatter/actions/workflows/build.yml/badge.svg)](https://github.com/andremrod/clipboard-formatter/actions/workflows/build.yml)
![macOS 14+](https://img.shields.io/badge/macOS-14%2B-black)
![Swift](https://img.shields.io/badge/Swift-SwiftUI-orange)

App da barra de menus do Mac que **reconhece o que você copiou** e oferece, com um clique, a formatação certa para aquilo:

- JSON formatado ou minificado;
- CPF e CNPJ com ou sem máscara;
- link limpo de UTM;
- data convertida para ISO ou Unix;
- cor em hex, rgb ou hsl;
- payload de um JWT;
- e outros formatos.

O resultado já volta para a área de transferência, pronto para colar.

*English: a macOS menu bar app (Swift + SwiftUI). It detects what's on your clipboard among 16 kinds of content (JSON, JWT, UUID, XML, Base64, colors, dates, URLs and Brazilian formats such as CPF, CNPJ, CEP, phone numbers, PIX keys and R$ amounts) and offers 48 one-click transformations. Everything runs locally: no network access and no clipboard history.*

---

## Sumário

- [Para que serve](#para-que-serve)
- [Instalar](#instalar)
- [Como usar](#como-usar)
- [O que ele reconhece](#o-que-ele-reconhece)
- [Ajustes](#ajustes)
- [Privacidade](#privacidade)
- [Como funciona por dentro](#como-funciona-por-dentro)
- [Compilar a partir do código](#compilar-a-partir-do-código)
- [Publicar uma versão nova](#publicar-uma-versão-nova)
- [Desinstalar](#desinstalar)
- [Limitações](#limitações)

## Para que serve

No dia a dia de quem programa, testa ou trabalha com dados, é comum copiar um JSON todo em uma linha, um CPF sem pontos, um link cheio de `utm_` ou uma data em timestamp. Para arrumar isso, normalmente você abre um site, um editor ou o terminal.

O ClipboardFormatter elimina esse passo:

1. Você copia (⌘C).
2. Clica no ícone na barra de menus.
3. Ele já diz o que é ("JSON", "CPF", "URL"…) e lista as ações que fazem sentido para aquele conteúdo.
4. Um clique aplica a ação e substitui o que está copiado.
5. Você cola (⌘V).

## Instalar

**Requisitos:** macOS 14 (Sonoma) ou mais recente, em Mac com Apple Silicon (M1 ou superior).

1. Baixe o `ClipboardFormatter-<versão>.dmg` na [última Release](https://github.com/andremrod/clipboard-formatter/releases/latest).
2. Abra o `.dmg` e arraste o **ClipboardFormatter** para **Aplicativos**.
3. Abra o app. Ele não aparece no Dock, só como um ícone de prancheta na barra de menus.

**Na primeira vez, o macOS vai bloquear a abertura.** O app não é assinado com um certificado de desenvolvedor da Apple (Developer ID). Para liberar:

- Abra **Ajustes do Sistema → Privacidade e Segurança**, role até o aviso sobre o ClipboardFormatter e clique em **Abrir Mesmo Assim**.
- Ou rode no Terminal:
  ```bash
  xattr -dr com.apple.quarantine /Applications/ClipboardFormatter.app
  ```

## Como usar

1. Copie qualquer texto.
2. Clique no ícone 📋 na barra de menus. O painel mostra:
   - o **tipo detectado**, por exemplo "CNPJ";
   - uma **prévia** do conteúdo, com até 72 caracteres;
   - as **ações** disponíveis. Para cores, cada ação já mostra o resultado ao lado, como `#2C46D6` ou `rgb(44, 70, 214)`.
3. Clique numa ação. O texto convertido substitui o que estava copiado e aparece uma confirmação verde por 2 segundos, como "Máscara aplicada".
4. O resultado é analisado de novo. Dá para encadear ações: por exemplo, decodificar um JWT e em seguida formatar o JSON que saiu dele.

## O que ele reconhece

A detecção segue a ordem da tabela: o primeiro tipo que bate é o escolhido. Quando nada bate, o conteúdo é tratado como texto.

| Tipo | Como reconhece | Ações |
|---|---|---|
| **JSON** | Começa com `{` ou `[` e é JSON válido. Também aceita objeto JavaScript com chaves sem aspas, como `{nome: "Ana"}` | Formatar (indentado, chaves em ordem) · Minificar |
| **JWT** | Três partes separadas por ponto, começando com `ey` | Decodificar o payload como JSON |
| **UUID** | Formato `8-4-4-4-12` hexadecimal, versões 1 a 5 | Minúsculo com hífens · maiúsculo com hífens · compacto sem hífens |
| **Chave PIX aleatória** | 32 caracteres hexadecimais | Normalizar |
| **XML / HTML** | Começa com `<` e tem tag de fechamento, `<?xml` ou `<!doctype` | Formatar · Minificar |
| **Base64** | 16 caracteres ou mais, só caracteres de Base64, e decodifica para texto UTF‑8 | Decodificar · Codificar |
| **Data e hora** | `dd/MM/aaaa`, `MM/dd/aaaa`, `aaaa/MM/dd`, `aaaa-MM-dd`, ISO 8601 (com ou sem milissegundos e fuso), com ou sem hora, ou carimbo Unix de 12 a 13 dígitos | `dd/MM/aaaa` · `dd/MM/aa` · `MM/dd/aaaa` · `aaaa/MM/dd` · ISO 8601 · Unix em segundos · por extenso em português |
| **Cor** | `#RGB`, `#RRGGBB`, `#RRGGBBAA`, `rgb()`, `rgba()`, `hsl()`, `hsla()` | Hex · `rgb()` · `rgba()` · `hsl()` · `hsla()` |
| **E-mail** | Um endereço sozinho, sem espaços. Não é confundido com link | Ações de texto |
| **URL** | Tem esquema e domínio, ou parece domínio, como `site.com.br/página` | Limpar rastreamento · Só o domínio · Codificar · Decodificar · Query string → JSON |
| **CNPJ** | 14 dígitos com dígitos verificadores válidos | Aplicar máscara `00.000.000/0000-00` · Só números |
| **CPF** | 11 dígitos com dígitos verificadores válidos, sem todos iguais | Aplicar máscara `000.000.000-00` · Só números |
| **CEP** | 8 dígitos, sem letras | Aplicar máscara `00000-000` · Só números |
| **Telefone (Brasil)** | 10 ou 11 dígitos com DDD de 11 a 99. Ignora parágrafos longos | Máscara `(11) 91234-5678` ou `(11) 1234-5678` · Só números |
| **Valor em R$** | `1.234,56` ou `1234,56` | Para decimal com ponto `1234.56` · Para formato brasileiro `1.234,56` |
| **Texto** | Qualquer outra coisa | MAIÚSCULAS · minúsculas · Title Case · Remover espaços duplicados · Remover quebras de linha · Aspas curvas e travessões → `"` `'` `-` · Linhas → separadas por vírgula · Vírgulas → uma por linha · Tab → 4 espaços · 4 espaços → tab · Normalizar chave PIX |

O que algumas ações fazem:

- **Limpar rastreamento** remove todos os `utm_*` e mais de 20 parâmetros de anúncio e analytics, como `fbclid`, `gclid`, `msclkid`, `ttclid`, `igshid`, `_ga`, `_gl` e `mc_cid`.
- **Query string → JSON** transforma `?a=1&b=2` em `{"a": "1", "b": "2"}`.
- **Normalizar chave PIX** depende do tipo de chave:
  - e-mail: vira minúsculo;
  - CPF, CNPJ ou telefone: fica só com os números;
  - chave aleatória: vira hexadecimal minúsculo.
- **As datas sem fuso** são interpretadas no horário de Brasília (`America/Sao_Paulo`).

## Ajustes

Clique em **Ajustes** (⚙︎) no painel:

- **Monitorar área de transferência:** desligue para que o app pare de olhar o que você copia.
- **Abrir ao iniciar o login:** usa o mecanismo oficial do macOS (`SMAppService`). O app também aparece em Ajustes do Sistema → Geral → Itens de Início.
- **Sobre:** mostra a versão instalada.

## Privacidade

- **Nada sai do seu Mac.** O app não faz nenhuma requisição de rede.
- **Não guarda histórico.** Só o conteúdo copiado no momento fica na memória, e nada é gravado em disco.
- **Só lê texto.** Imagens e arquivos copiados são ignorados.
- **O conteúdo só muda quando você clica numa ação.** O app nunca altera o que você copiou sozinho.

## Como funciona por dentro

Feito em **Swift + SwiftUI**, com Swift Package Manager e sem nenhuma dependência externa.

```
Sources/ClipboardFormatter/
  ClipboardFormatterApp.swift   ponto de entrada: MenuBarExtra (painel) + Settings; sem ícone no Dock
  ClipboardService.swift        observa a área de transferência e aplica as ações (@Observable)
  ContentDetector.swift         decide o tipo do conteúdo e quais ações oferecer
  FormatterService.swift        executa cada ação (switch sobre ActionKind)
  JSONInputNormalizer.swift     aceita objeto JavaScript com chaves sem aspas como JSON
  BrazilPIXFormats.swift        telefone, CEP, chave PIX, valores em R$
  WebDataFormats.swift          URL (rastreamento, encode, query), JWT, Base64, XML, UUID
  ColorFormats.swift            leitura e conversão hex / rgb(a) / hsl(a)
  DateFormats.swift             leitura de datas, ISO 8601, Unix
  TextExtraFormats.swift        aspas, vírgulas/linhas, tabs/espaços
  MenuBarView.swift             painel da barra de menus
  SettingsView.swift            janela de ajustes
  LaunchAtLogin.swift           abrir ao iniciar sessão (SMAppService)
  GlassChrome.swift             estilo visual (materiais translúcidos)
  MenuBarHostWindowFix.swift    deixa a janela do painel transparente para o vidro aparecer
  AppVersion.swift              versão exibida e usada no pacote
  Models/                       ClipboardType, ActionKind, ClipboardItem
Support/Info.plist              Info.plist do .app (LSUIElement = sem Dock)
scripts/package.sh              compila e monta o .app e o .dmg
```

Os pontos principais:

- **Monitoramento:** o macOS não avisa quando a área de transferência muda. Por isso o app confere o `changeCount` do `NSPasteboard` a cada ~0,8 s, com tolerância de 0,3 s para o sistema poder agrupar o trabalho e economizar bateria. Só analisa o conteúdo quando esse número muda.
- **Detecção:** usa regras simples e rápidas, como expressões regulares, dígitos verificadores de CPF e CNPJ e tentativas de leitura. Textos com mais de 320 mil caracteres vão direto para "Texto", para não travar.
- **Ações:** cada uma é uma função pura de `String` para `String`. Se a entrada não servir para a ação, o texto volta igual.

## Compilar a partir do código

Requisitos: Xcode 15 ou mais recente (ou as Command Line Tools com Swift 5.9+) e macOS 14+.

```bash
git clone https://github.com/andremrod/clipboard-formatter.git
cd clipboard-formatter

swift run                      # compila e abre direto (modo debug)
./scripts/package.sh           # gera dist/ClipboardFormatter.app e dist/ClipboardFormatter-<versão>.dmg
```

O `package.sh` faz isto:

1. Compila em modo release.
2. Monta o `.app` com o `Support/Info.plist`, usando a versão de `AppVersion.swift`.
3. Assina de forma ad-hoc (`codesign --sign -`).
4. Cria o `.dmg` com o atalho para Aplicativos.

Para abrir no Xcode: `open Package.swift`.

## Publicar uma versão nova

1. Atualize `marketing` e `build` em `Sources/ClipboardFormatter/AppVersion.swift`.
2. Faça commit e crie a tag com a mesma versão:
   ```bash
   git tag v1.2.7 && git push origin main v1.2.7
   ```

O GitHub Actions compila num runner macOS, gera o `.dmg` e cria a Release com ele anexado. Nos outros pushes, ele só compila e guarda o `.dmg` como artefato da execução.

## Desinstalar

1. Se você ligou **Abrir ao iniciar o login**, desligue antes nos Ajustes do app.
2. Encerre o app pelo botão **Encerrar ClipboardFormatter** no painel.
3. Arraste `/Applications/ClipboardFormatter.app` para o Lixo.

## Limitações

- **A detecção é por regras.** Um número de 11 dígitos que por acaso tenha dígitos verificadores válidos aparece como CPF. Em caso de dúvida, as ações de texto continuam disponíveis no tipo "Texto".
- **O app não é notarizado pela Apple.** Por isso aparece o aviso na primeira abertura (veja [Instalar](#instalar)).
- **Só funciona em Apple Silicon.** O `.dmg` da Release é compilado para arm64. Em Mac com Intel, compile a partir do código.
- **A interface está só em português.**

## Licença

[MIT](LICENSE) © André Macedo Rodrigues
