# MONSTER DISSECTION: arte

## Status: falta a folha A1 (ícones das opções do acampamento); a L1b é opcional

| Grupo | Qtde | Situação |
|---|---|---|
| Monstros | 10 | **Pronto**, em alta resolução |
| Partes anatômicas | 30 | **Pronto** |
| Cartas | 43 | **Pronto** |
| Mutações | 7 | **Pronto** |
| Eventos | 6 | **Pronto** (1024 px, ampliados de ~485 px; dá para refazer um por um) |
| Fundos (paisagens) | 6 | **Pronto** |
| Fundos de batalha (neutros, por família) | 4 | **Pronto** |
| Logo | 1 | **Pronto** (`assets/art/ui/logo.png`) |
| Ícones das estações do laboratório | 6 | **Pronto** (versão alternativa: folha L1b) |
| Melhorias da Oficina | 5 | **Pronto** |
| Acampamento: fundo novo | 1 | **Pronto** (fogueira no centro; a versão antiga está em `assets/art/extra/backgrounds/`) |
| Acampamento: ícones das opções | 3 | **Pedir: folha A1** |

As imagens ficam em `assets/art/<monsters|cards|parts|mutations|events|backgrounds|stations|upgrades|camp|ui>/<id>.png` e o jogo as carrega
sozinho pelo nome do arquivo. Para trocar uma imagem, basta substituir o arquivo com o mesmo nome.

Sobras que podem virar conteúdo novo ficam em `assets/art/extra/`: um Voidspawn de um olho só, o espectro
com lanternas (o Carniçal antigo) e 3 partes avulsas.

## Estilo aprovado

- arte de jogo pintada à mão, dark fantasy, com cara de cartoon;
- contorno escuro marcado e sombra em cel shading;
- cores por família: vermelho para Bloodfang, verde-musgo para Ironback, violeta para Voidspawn, oliva e osso
  para Rotwalker.

Para pedir arte nova, anexe como referência de estilo a folha de partes ("Sprite de Monstros Fantásticos em
PNG-4.png") e use este cabeçalho:

```
Dark fantasy hand-painted game icon sheet, same style as the attached reference: bold dark outlines, cel shading, rich defined colors, natural history museum specimen theme, educational, bold simple readable silhouettes. Transparent or plain blurred background. Exactly N separate isolated objects in a grid with wide spacing, in the exact order listed, left to right, top to bottom. Draw exactly these objects and nothing else. No text, no numbers, no labels, no frames, no people, no gore.
```

Regras que funcionaram:

- **Vocabulário de museu** (espécime, frasco, fluido carmesim) em vez de sangue ou ferida, para não esbarrar
  no filtro de violência.
- **Ordem fixa e número exato de itens.** É a ordem que diz qual figura é qual.
- Fundo transparente ou liso funciona; eu removo. Peça sempre a **folha original inteira**, mesmo que o
  ChatGPT também mande recortes.

## Fundos (paisagens)

**Prontos.** Ficam em `assets/art/backgrounds/<nome>.png` e cada tela usa o seu. Os pedidos abaixo ficam
aqui para refazer ou criar regiões novas. O jogo escurece
o fundo o quanto for preciso para as cartas e os textos continuarem legíveis. Sem o arquivo, fica o fundo
atual.

| Arquivo | Onde aparece | Prioridade |
|---|---|---|
| `bone_moor.png` | Combate, mapa e eventos da **Charneca dos Ossos** | Alta |
| `flooded_catacombs.png` | Combate, mapa e eventos das **Catacumbas Alagadas** | Alta |
| `menu.png` | Tela inicial, opções e fim de expedição | Média |
| `camp.png` | Acampamento (descansar, aprimorar, purgar) | Média |
| `lab.png` | Laboratório e as telas das estações | Opcional |
| `dissection.png` | Mesa de dissecação | Opcional |

**Uma imagem por vez, em arquivo próprio e na resolução máxima** (nada de prévia ou miniatura; o ideal é ter
pelo menos 1536 px de largura). Formato **16:9 ou 3:2, preenchendo a imagem inteira**, sem faixas pretas e
sem panorama muito largo: o jogo corta as laterais do que passar de 16:9. Mesmo estilo da
folha de monstros. Anexe a folha de monstros como referência. Comece todo pedido com:

```
Dark fantasy hand-painted game background, same painted style as the attached reference: bold shapes, cel shading, rich but muted colors, atmospheric depth, wide 16:9 landscape. Empty scene: no creatures, no people, no text, no UI, no frame.
```

**Regras de composição para os fundos de combate** (as duas regiões): o horizonte e o chão ficam na metade
da altura, porque é ali que os monstros pisam. O centro e a direita precisam de um **chão aberto e plano**
para os monstros, e a metade de baixo fica **mais escura e simples**, porque as cartas ficam por cima. Os
detalhes vão para as bordas e para o fundo distante.

| Arquivo | Complemento do pedido |
|---|---|
| `bone_moor.png` | A desolate peat bog moor at dusk, giant ancient ribcages and bones half-sunk in the marsh, dead twisted trees, low fog, distant ruined watchtower, crimson and bone tones. Horizon at the middle of the image, open flat muddy ground in the center and right for creatures to stand on, darker and simpler lower half, details at the edges. |
| `flooded_catacombs.png` | Vast underground flooded catacombs, shallow dark water over stone floor, arched tunnels and burial niches along the walls, faint green light from above, olive green and stone tones. Horizon at the middle of the image, open flat flooded floor in the center and right for creatures to stand on, darker and simpler lower half, details at the edges. |
| `menu.png` | A vast dark-fantasy landscape at night seen from a cliff: a lonely gothic laboratory tower with one lit window on the left, misty moor below, a huge pale moon behind clouds, violet and bone tones. Keep the right half of the image calm and dark (a creature illustration goes there). |
| `camp.png` | A small campfire at night in a clearing of a misty swamp, bedroll and backpack by the fire, lantern hanging from a dead branch, warm orange firelight against cold blue-green fog. Campfire at the bottom center, calm dark space around it. |
| `lab.png` | Interior of a gothic naturalist laboratory: wooden shelves full of specimen jars, brass instruments, anatomical charts, candlelight, stone walls, warm bone and moss tones, slightly blurred, calm composition without a strong center. |
| `dissection.png` | A dim dissection room: a heavy wooden examination table under a hanging lamp, surgical tools on a tray, specimen jars on shelves in the background, the table empty and covered with a cloth. Warm lamp light, dark corners. |

Depois de gerar, salve na pasta Downloads e me diga qual arquivo é qual. Eu ajusto o corte e o
escurecimento de cada tela olhando as capturas.

## Monstros em alta resolução

**Prontos** (1100 a 1900 px). As versões antigas, de baixa resolução, ficaram em `assets/art/extra/lowres/`.
Os pedidos abaixo servem para refazer um monstro ou criar novos.

Os retratos antigos tinham sido recortados de uma folha com os 11 monstros juntos, então cada um tinha só de 360 a
710 px de largura. No combate em tela cheia eles aparecem com uns 600 px, e na dissecação com uns 1000 px, então
ficam ampliados e um pouco borrados. A ideia é **redesenhar cada um sozinho, em alta resolução, mantendo o
mesmo visual**.

**Como pedir:**

- **Um monstro por pedido**, em arquivo PNG próprio, na resolução máxima. O ideal é pelo menos 1536×1024
  (paisagem); para os altos, como o Rotwalker, 1024×1536 também serve.
- **Anexe o retrato atual daquele monstro** (`assets/art/monsters/<id>.png`) e peça para manter o mesmo
  design, só com mais detalhe. Se der, anexe também a folha "Ficha de Monstros do Vazio-1.png".
- **Fundo transparente**, ou um fundo liso e claro, que eu removo.
- O monstro **olha para a esquerda**, de corpo inteiro, sem chão nem sombra, com uma margem pequena em volta.

Cabeçalho de todo pedido:

```
Redraw the creature from the attached image at much higher resolution, keeping exactly the same design, colors, pose and proportions; add finer painted detail and crisp edges. Dark fantasy hand-painted game art, bold dark outlines, cel shading. Full body, side view facing LEFT, centered with a small margin, nothing cropped. Transparent background (or plain flat light background). No ground, no shadow, no scenery, no text, no frame. Single image, maximum resolution.
```

Complemento de cada um (cole depois do cabeçalho):

| Arquivo | Hoje | Complemento |
|---|---|---|
| `bloodfang.png` | 545 px | Lean quadruped predator with tall hunched shoulders, oversized jaw with serrated fangs, scarred pale hide streaked with crimson, bristling spines along the back. |
| `bloodfang_pup.png` | 359 px | Young version of the same predator: smaller, gangly, oversized paws and jaw, fewer scars. |
| `bloodfang_alpha.png` | 656 px | Massive pack-leader version: dozens of old scars, a mane of bone spines along neck and back, heavier jaw, lunging stance. |
| `ironback.png` | 392 px | Boar-sized armored beetle: overlapping moss-green chitin plates with spikes, heavy mandibles, thick legs, glowing yellow-green fluid sac at the rear. |
| `iron_colossus.png` | 527 px | Ancient colossal version of the armored beetle: huge spiked plates caked with rust and dried mud, giant mandibles, large glowing yellow-green sac at the rear. |
| `voidspawn.png` | 429 px | Violet tentacled aberration with one large amber eye and several smaller eyes on a lumpy body, many curling suckered tentacles. |
| `void_matriarch.png` | 640 px | Towering violet mother-aberration with bat-like wings, a cluster of amber eyes above a round toothed maw, a mass of thick curling tentacles. |
| `rotwalker.png` | 507 px | Gaunt upright walking corpse, grey-green rotting skin with knitting wounds, hunched posture, long clawed hands, skull-like face. |
| `stitched_abomination.png` | 595 px | Hulking mass of stitched corpses: huge round belly with pustules, thick arms, a howling skull-like head, crude stitches and loose tubes. |
| `ghoul.png` | 710 px | Gaunt crawling catacomb creature on all fours, long thin limbs and fingers, olive-grey skin, spiny back, ragged cloth at the waist, small glowing yellow eyes. |

**Ordem sugerida:** comece pelos que estão menores (Filhote, Ironback, Voidspawn) e pelos chefes (Matriarca,
Colosso), que aparecem maiores na tela. Depois de gerar, me diga qual arquivo é qual. Eu removo o fundo, coloco
no jogo e recalibro os pontos de dissecação.

## Laboratório: falta só a L1b (opcional)

O jogo já aceita estas imagens. Sem o arquivo, continua o desenho atual.

- **Ícones das estações** (6): o ícone de cada estação no laboratório. Ficam em `assets/art/stations/`.
- **Melhorias da Oficina** (5): o ícone de cada melhoria. Ficam em `assets/art/upgrades/`.

Peça em **folha**, como as cartas: objetos isolados, fundo transparente ou liso, **na ordem da lista** e sem
texto. Anexe a folha de partes como referência de estilo. Eu recorto e coloco cada um no lugar.

### Folha L1: Ícones das estações do laboratório (6): pronta

São **ícones**, não cenários: um único objeto simples por estação, como os ícones das partes e das cartas.
Substituem os desenhos de hoje (bisturi, caderno, gota, coração, placas, olho) no quadro de cada estação.

```
Dark fantasy hand-painted game icon sheet, same style as the attached reference: bold dark outlines, cel shading, rich defined colors, one single simple object per icon, bold readable silhouettes that work at small size. Transparent or plain blurred background. Exactly 6 separate isolated icons in a 3x2 grid with wide spacing, in the exact order listed, left to right, top to bottom. Draw exactly these objects and nothing else, no scenery, no tables, no rooms. No text, no numbers, no labels, no frames, no people, no gore.
1. an antique brass compass lying on a small rolled-up parchment map
2. a small fanned stack of three illustrated playing cards with a quill pen
3. a round alchemy flask with a glowing green liquid and a cork stopper
4. a crimson creature heart with violet veins inside a small brass-and-glass capsule
5. a crossed blacksmith hammer and tongs
6. a closed leather-bound tome with a brass eye emblem on the cover
```

| Ordem | Arquivo | Estação |
|---|---|---|
| 1 | `expedition.png` | Mesa de Expedição |
| 2 | `deck.png` | Bancada de Baralho |
| 3 | `experiment.png` | Estação de Experimentação |
| 4 | `mutation.png` | Câmara de Mutação |
| 5 | `workshop.png` | Oficina |
| 6 | `archive.png` | Arquivo de Espécimes |

### Folha L1b: outras versões dos ícones das estações (12)

A primeira versão (L1) está no jogo, mas veio com composições cheias (mochila + mapa + lanterna, bigorna +
engrenagem). Esta folha pede **2 opções por estação**, cada uma com **um objeto só**, mais limpo, para você
escolher. A ordem é: estação 1 opção A, estação 1 opção B, estação 2 opção A, e assim por diante.

```
Dark fantasy hand-painted game icon sheet, same style as the attached reference: bold dark outlines, cel shading, rich defined colors. Each icon is ONE single object only, centered, simple bold silhouette that reads clearly at 100 pixels; no extra props, no piles of items, no scenery. Transparent or plain blurred background. Exactly 12 separate isolated icons in a 4x3 grid with wide spacing, in the exact order listed, left to right, top to bottom. No text, no numbers, no labels, no frames, no people, no gore.
1. a brass compass, open, with a red needle
2. a rolled parchment map tied with a red ribbon
3. three illustrated cards fanned out
4. a single quill pen in an inkwell
5. a round glass alchemy flask with glowing green liquid
6. a small glass vial with crimson and violet liquids swirling together
7. a crimson creature heart inside a small brass-and-glass capsule
8. a large curved syringe-like brass injector with violet fluid
9. a blacksmith hammer
10. a brass gear crossed with a wrench
11. a closed leather tome with a brass eye emblem on the cover
12. a brass magnifying glass
```

| Ordem | Arquivo | Estação |
|---|---|---|
| 1 / 2 | `expedition_a.png` / `expedition_b.png` | Mesa de Expedição |
| 3 / 4 | `deck_a.png` / `deck_b.png` | Bancada de Baralho |
| 5 / 6 | `experiment_a.png` / `experiment_b.png` | Estação de Experimentação |
| 7 / 8 | `mutation_a.png` / `mutation_b.png` | Câmara de Mutação |
| 9 / 10 | `workshop_a.png` / `workshop_b.png` | Oficina |
| 11 / 12 | `archive_a.png` / `archive_b.png` | Arquivo de Espécimes |

Mande a folha inteira; eu recorto as 12, mostro lado a lado com a versão atual e você escolhe qual fica em
cada estação (pode até manter a atual em algumas).

### Folha L2: Melhorias da Oficina (5): pronta

```
Dark fantasy hand-painted game icon sheet, same style as the attached reference: bold dark outlines, cel shading, rich defined colors, gothic naturalist laboratory tools, bold simple readable silhouettes. Transparent or plain blurred background. Exactly 5 separate isolated objects in a single row with wide spacing, in the exact order listed, left to right. Draw exactly these objects and nothing else. No text, no numbers, no labels, no frames, no people, no gore.
1. a worn leather survival kit pouch, open, with bandages, a small flask and rope
2. a row of three glass preservation jars with cork lids and greenish liquid
3. a surgical scalpel with a glossy black obsidian blade and a bone handle
4. a heavy wooden examination table with leather restraint straps and iron buckles
5. two identical curved surgical blades crossed, polished steel with brass handles
```

| Ordem | Arquivo | Melhoria |
|---|---|---|
| 1 | `up_field_kit.png` | Kit de Sobrevivência |
| 2 | `up_jars.png` | Frascos de Conservação |
| 3 | `up_obsidian.png` | Bisturi de Obsidiana |
| 4 | `up_table.png` | Mesa de Contenção |
| 5 | `up_twin_blades.png` | Lâminas Gêmeas |

## Eventos em alta resolução: prontos (opcional refazer)

**No jogo desde a folha "EVENTS_HIRES"**: as 6 cenas vieram numa folha 3x2 (cada uma com ~485 px reais) e
foram ampliadas para 1024 px. Já é quase o dobro da versão antiga; para nitidez máxima, peça **um evento por
pedido**, como abaixo. As versões antigas estão em `assets/art/extra/lowres/events/`.

A versão anterior tinha só uns **265 px**. Em tela cheia o quadro do evento aparece com uns 760 px, quase 3 vezes ampliado, por isso fica
borrado. A ideia é **redesenhar cada uma sozinha, em alta resolução, mantendo a mesma cena**.

**Como pedir:**

- **Um evento por pedido**, em arquivo PNG próprio, na resolução máxima. **Quadrado**, de pelo menos
  1024×1024.
- **Anexe a arte atual daquele evento** (`assets/art/events/<id>.png`) e peça para manter a mesma cena, só
  com mais detalhe.
- Diferente dos ícones, aqui é uma **cena que preenche o quadrado inteiro**, com fundo pintado (como a
  atual), sem moldura e sem bordas arredondadas.

Cabeçalho de todo pedido:

```
Redraw the scene from the attached image at much higher resolution, keeping the same composition, subject, colors and mood; add finer painted detail and crisp edges. Dark fantasy hand-painted game illustration, bold dark outlines, cel shading, rich but muted colors, natural history museum specimen theme. Square image, the painted scene fills the whole square edge to edge: no frame, no border, no rounded corners, no text, no UI, no gore. Single image, maximum resolution.
```

Complemento de cada um (cole depois do cabeçalho):

| Arquivo | Evento | Complemento |
|---|---|---|
| `ev_violet_pool.png` | Poça Violeta | A cold glowing violet liquid flowing upward from a crack in a dark cave rock wall, pooling into a luminous swirling violet pool, purple crystals and wet stone around it. |
| `ev_bone_altar.png` | Altar de Ossos | An old altar built from stacked giant ribcages and bones on a misty moor, ancient offerings (candles, small jars, dried flowers) at its base, bone and crimson tones. |
| `ev_hermit.png` | Eremita Alquimista | An old hooded alchemist's camp: bubbling glass flasks hanging over a small blue-flamed fire, a worn leather satchel and bottles around it, nobody visible, warm and blue light. |
| `ev_ironback_nest.png` | Ninho de Ironback | A nest of large eggs with metallic moss-green shells, still warm with a faint glow, nestled among gnawed old bones and dry roots. |
| `ev_old_carcass.png` | Carcaça Antiga | The long-dead remains of a large predator creature half-sunk in dark peat, mostly covered by moss and earth, its pale scarred hide still intact, a museum-specimen look, no blood. |
| `ev_wounded_researcher.png` | Pesquisador Ferido | An exhausted researcher in a long coat resting against a dead tree trunk, face hidden by a hood, holding a stained leather field notebook, a dropped lantern beside him, somber mood, no blood. |

**Ordem sugerida:** comece pela Poça Violeta e pelo Altar de Ossos, que são os que mais aparecem. Depois de
gerar, me diga qual arquivo é qual. Eu ajusto o corte e coloco no jogo; a versão de hoje fica guardada em
`assets/art/extra/lowres/`.

## Acampamento: pedir agora (folha A1, 3 ícones)

O **fundo novo** (com a fogueira no centro) já está no jogo, e a tela foi reorganizada: título em cima,
fogueira do fundo livre no meio, opções embaixo. Por isso a fogueira avulsa **não é mais necessária** (a
recortada da folha "Fogueiras e Acampamento" ficou guardada em `assets/art/extra/camp/`).

Faltam só os **ícones das opções** (3), um no topo de cada quadro (Descansar, Aprimorar, Purgar). O jogo já
aceita as imagens em `assets/art/camp/`; sem o arquivo, o quadro fica sem ícone.

Peça em **folha**, como as outras: objetos isolados, fundo transparente ou liso, **na ordem da lista** e sem
texto. Anexe a folha de partes como referência de estilo. Eu recorto e coloco cada um no lugar.

```
Dark fantasy hand-painted game icon sheet, same style as the attached reference: bold dark outlines, cel shading, rich defined colors, warm firelight tones against a dark night palette. Each icon is ONE single object, centered, simple bold silhouette that reads clearly at 100 pixels; no scenery, no ground plane, no people. Transparent or plain blurred background. Exactly 3 separate isolated icons in a single row with wide spacing, in the exact order listed, left to right. No text, no numbers, no labels, no frames, no gore.
1. a rolled-up leather bedroll tied with straps, with a small steaming tin cup beside it
2. a whetstone with a surgical scalpel being sharpened on it, a small bright spark at the blade edge
3. a single illustrated playing card curling and burning at one corner, with orange embers and a wisp of smoke
```

| Ordem | Arquivo | Onde aparece |
|---|---|---|
| 1 | `rest.png` | Opção Descansar |
| 2 | `upgrade.png` | Opção Aprimorar |
| 3 | `purge.png` | Opção Purgar |

## Próximas artes possíveis

Precisa de um ajuste pequeno no código antes; me avise que eu preparo e escrevo o pedido.

| Item | Onde aparece |
|---|---|
| O Pesquisador (personagem do jogador) | Combate, ao lado da vida; hoje é um vulto desenhado em código |

## Ferramentas (para mim)

- `tools/remove_bg.gd`: tira o fundo liso ou borrado de uma folha.
- `tools/slice_sheet.gd`: recorta uma folha pela ordem das figuras.
- `tools/crop_items.gd`: recorta por caixas marcadas à mão, para figuras encostadas.
