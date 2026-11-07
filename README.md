# MONSTER DISSECTION — protótipo 0.2

Roguelite de cartas dark fantasy (Godot 4.7, GDScript). Cace criaturas, disseque seus corpos e transforme
órgãos em cartas, cartas híbridas e mutações.

## Como abrir

1. Abra o Godot 4.7 → **Importar** → selecione `project.godot` nesta pasta.
2. **F5** roda o jogo. Também dá para rodar qualquer tela isolada com **F6**
   (combate, mapa, evento, dissecação e acampamento criam uma expedição de teste sozinhos).

## O que existe

| Sistema | Onde |
|---|---|
| Combate por turnos: energia, mão, compra/descarte/banidas, intenções visíveis, **vários monstros por encontro** (clique na carta, depois no alvo) | `scripts/combat/combat_manager.gd` |
| Efeitos combináveis (dano, sangramento, corrupção, armadura, cura, compra, custo, espinhos, por carta jogada, condicional, devolver do descarte) | `scripts/cards/effects/` |
| **Instinto**: 3 cartas seguidas da mesma família ativam o efeito de conjunto. Híbridas contam para as duas famílias | `CombatManager._register_instinct` |
| **Condição do corpo**: o jeito de matar define o que sobra para dissecar | `scripts/dissection/body_condition.gd` |
| Dissecação com incisões, chance visível e motivo explicado | `scripts/ui/screens/dissection_screen.gd` |
| **Cartas aprimoradas** ("+"), geradas automaticamente: cada efeito sabe se melhorar | `CardEffect.upgrade()`, `CardData.make_upgraded()` |
| Mapa com encontros, covis, **mistérios (eventos)**, acampamentos (descansar, **aprimorar**, purgar) e chefe | `scripts/progression/map_generator.gd` |
| **Eventos** 100% em dados (escolhas, chance, vida, partes, cartas, remover/aprimorar, combate) | `data/events/`, `EventChoice` |
| **Estação de Experimentação**: combine 2 partes de famílias diferentes → carta híbrida. Caderno com pistas | `data/recipes/`, `experiment_station_screen.gd` |
| **Oficina**: melhorias permanentes (incisões, preservação, vida) pagas com partes de uma família | `data/lab_upgrades/`, `workshop_screen.gd` |
| Câmara de mutação com medidor de Corrupção | `mutation_chamber_screen.gd` |
| **2 regiões**: Charneca dos Ossos → libera Catacumbas Alagadas | `data/expeditions/` |
| **Continuar expedição**: salva ao voltar ao mapa (`user://run.json`) | `RunState.save_run/load_run` |
| **Opções**: volumes, tela cheia (padrão; **F11** ou **Alt+Enter** alterna), efeitos de impacto (`user://settings.cfg`) | `scripts/managers/settings.gd` |
| **Áudio sintetizado** (efeitos + ambiente) e **impacto** (partículas, hit-stop, tremor) | `scripts/managers/sfx.gd`, `scripts/ui/fx.gd` |

Conteúdo: 43 cartas (8 híbridas), 30 partes, 10 monstros de 4 famílias (Bloodfang, Ironback, Voidspawn, Rotwalker),
7 mutações, 8 receitas, 6 eventos, 5 melhorias de laboratório, 2 regiões com chefes próprios.

## Arquitetura

- **Autoloads**: `Database` (carrega `res://data`), `Profile` (progresso permanente), `RunState` (expedição atual),
  `Settings` (preferências), `Sfx` (áudio), `Game` (fluxo entre telas, tema e som de clique).
- **Dados separados da lógica**: tudo em `data/*.tres` com Resources próprios. Edite no Inspector.
- **Cartas não têm código próprio**: cada carta é uma lista de `CardEffect`; intenções de monstros, mutações e
  versões aprimoradas reutilizam os mesmos efeitos.
- **Regras sem UI**: `CombatManager` só emite sinais; a tela de combate apenas reage.

### Arte, fontes e áudio

- **Arte provisória procedural** (`scripts/ui/procedural_art.gd`). Todo Resource tem um campo `Texture2D`
  (`illustration`, `portrait`, `icon`): preenchido, a arte final substitui o desenho automaticamente.
  `MonsterData.tint` cria variações (elite/chefe) da mesma silhueta.
- **Fontes** (licença SIL OFL, em `assets/fonts/`): Cormorant Garamond (títulos) e Source Sans 3 (texto e números).
- **Áudio**: gerado em código, sem arquivos. Para usar sons gravados, coloque um `AudioStream` em
  `Sfx.CUSTOM[&"hit"]` (mesmas chaves: `click`, `card`, `hit`, `hit_big`, `block`, `heal`, `cut`, `fail`,
  `unlock`, `turn`, `death`, `instinct`).

### Adicionar conteúdo

- **Carta**: `CardData` em `data/cards/` com efeitos na lista `effects`. Descrição e versão "+" são geradas sozinhas.
- **Carta híbrida**: `CardData` com `secondary_family` + uma `HybridRecipe` em `data/recipes/`.
- **Efeito**: estenda `CardEffect`, implemente `apply()`, `describe()` e (opcional) `upgrade()`.
- **Status**: entrada em `scripts/combat/status_library.gd`.
- **Monstro / encontro**: `MonsterData`; inclua num `EncounterData` dentro da expedição.
- **Evento**: `EventData` com `EventChoice`s em `data/events/`; adicione à lista `events` da expedição.

### Arte final

Veja [docs/ARTE.md](docs/ARTE.md): lista exata de imagens, tamanhos e prompts. Arquivos em `assets/art/<tipo>/<id>.png` são ligados automaticamente.

## Ferramentas (`tools/`)

Use o executável **console** do Godot para ver a saída no terminal.

- `smoke_test.tscn` — regras, conteúdo, aprimoramento, híbridas, oficina, save/load, eventos, simulações de
  balanceamento (3 estágios de baralho), todas as telas e o fluxo completo. Preserva seu progresso.
  `Godot_v4.7.2-stable_win64_console.exe --headless --path . res://tools/smoke_test.tscn`
- `screenshot_tour.tscn` — capturas de todas as telas: `... --path . res://tools/screenshot_tour.tscn -- <pasta>`
- `seed_data.gd` — gerou o conteúdo. **Sobrescreve `data/`**; depois de editar os `.tres` à mão, não rode de novo.

## Limitações conhecidas

- O personagem do jogador, os fundos e a tela inicial ainda são desenhados em código (veja docs/ARTE.md).
- Sair no meio de um combate ou dissecação volta ao mapa salvo antes desse nó (o combate pode ser refeito).
- Balanceamento validado só por simulação com IA simples — precisa de testes jogando.
