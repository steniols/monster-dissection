# MONSTER DISSECTION — protótipo 0.1

Roguelite de cartas dark fantasy (Godot 4.7, GDScript). Cace criaturas, disseque seus corpos e transforme
órgãos em cartas e mutações.

## Como abrir

1. Abra o Godot 4.7 → **Importar** → selecione `project.godot` nesta pasta.
2. **F5** roda o jogo. Também dá para rodar qualquer tela isolada com **F6**
   (combate, mapa, dissecação e acampamento criam uma expedição de teste sozinhos).

## O que já funciona (ciclo completo do GDD)

| Sistema | Onde |
|---|---|
| Combate por turnos: energia, mão, compra/descarte/banidas, intenções visíveis | `scripts/combat/combat_manager.gd` |
| Efeitos combináveis (dano, sangramento, corrupção, armadura, cura, compra, custo, espinhos, por carta jogada, condicional ao matar) | `scripts/cards/effects/` |
| **Instinto**: 3 cartas seguidas da mesma família ativam Frenesi / Fortificação / Corrupção | `CombatManager._register_instinct` |
| **Condição do corpo**: o jeito de matar define o que sobra (excesso de dano destrói a cabeça, morte por status contamina fluidos, etc.) | `scripts/dissection/body_condition.gd` |
| Dissecação com incisões limitadas, chance visível e motivo explicado | `scripts/ui/screens/dissection_screen.gd` |
| Partes desbloqueiam cartas permanentemente; escolha 1 carta para o baralho da expedição | `RunState.gather` |
| Mapa ramificado (encontros, covis de elite, acampamentos, chefe) | `scripts/progression/map_generator.gd` |
| Laboratório: montar baralho inicial, câmara de mutação (com medidor de Corrupção), arquivo/bestiário | `scripts/ui/screens/` |
| Persistência em `user://profile.json` | `scripts/progression/profile.gd` |

Conteúdo: 25 cartas, 20 partes anatômicas, 5 monstros (3 comuns, 1 elite, 1 chefe) de 3 famílias, 5 mutações, 1 região.

## Arquitetura

- **Autoloads**: `Database` (carrega `res://data`), `Profile` (progresso permanente), `RunState` (expedição atual), `Game` (fluxo entre telas e tema).
- **Dados separados da lógica**: tudo em `data/*.tres` usando Resources próprios (`CardData`, `MonsterData`, `AnatomyPart`, `MutationData`, `ExpeditionData`). Edite no Inspector.
- **Cartas não têm código próprio**: cada carta é uma lista de `CardEffect`. Intenções de monstros e mutações reutilizam os mesmos efeitos.
- **Regras sem UI**: `CombatManager` só emite sinais; a tela de combate apenas reage.
- **Arte provisória procedural** (`scripts/ui/procedural_art.gd`). Todo Resource tem um campo `Texture2D` (`illustration`, `portrait`, `icon`) — preenchido, a arte final substitui o desenho automaticamente.

### Adicionar conteúdo

- **Carta nova**: crie um `CardData` em `data/cards/` e adicione efeitos na lista `effects`. A descrição é gerada sozinha.
- **Efeito novo**: estenda `CardEffect`, implemente `apply()` e `describe()`.
- **Status novo**: adicione uma entrada em `scripts/combat/status_library.gd` (o "tick" e o decaimento são dados).
- **Monstro novo**: `MonsterData` com intenções, partes e `visual`; inclua-o em `data/expeditions/bone_moor.tres`.

## Ferramentas (`tools/`)

Use o executável **console** do Godot para ver a saída no terminal.

- `smoke_test.tscn` — testa regras, simula combates (relatório de balanceamento), abre todas as telas e percorre o fluxo de uma expedição. Preserva seu save.
  `Godot_v4.7.2-stable_win64_console.exe --headless --path . res://tools/smoke_test.tscn`
- `screenshot_tour.tscn` — salva capturas de todas as telas: `... --path . res://tools/screenshot_tour.tscn -- <pasta>`
- `seed_data.gd` — gerou o conteúdo inicial. **Sobrescreve `data/`**; depois da semeadura, os `.tres` são a fonte da verdade.

## Próximos passos sugeridos

1. Cartas híbridas (estação de experimentação combinando partes de famílias diferentes).
2. Família Rotwalker (regeneração / reutilizar cartas — `ReturnFromDiscardEffect` já existe).
3. Melhorias de laboratório (ferramentas que aumentam incisões ou chance de preservação).
4. Eventos no mapa, upgrade de cartas, salvar expedição em andamento.
5. Arte final, fontes próprias, áudio e efeitos de partículas.
