# MONSTER DISSECTION: arte

## Status: faltam as imagens do laboratório

| Grupo | Qtde | Situação |
|---|---|---|
| Monstros | 10 | **Pronto**, em alta resolução |
| Partes anatômicas | 30 | **Pronto** |
| Cartas | 43 | **Pronto** |
| Mutações | 7 | **Pronto** |
| Eventos | 6 | **Pronto** |
| Fundos (paisagens) | 6 | **Pronto** |
| Estações do laboratório | 6 | Folha L1 |
| Melhorias da Oficina | 5 | Folha L2 |

As imagens ficam em `assets/art/<monsters|cards|parts|mutations|events|backgrounds>/<id>.png` e o jogo as carrega
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

## Laboratório: pedir agora

O jogo já aceita estas imagens. Sem o arquivo, continua o desenho atual.

- **Estações** (6): o quadro ilustrado de cada estação no laboratório. Ficam em `assets/art/stations/`.
- **Melhorias da Oficina** (5): o ícone de cada melhoria. Ficam em `assets/art/upgrades/`.

Peça em **folha**, como as cartas: objetos isolados, fundo transparente ou liso, **na ordem da lista** e sem
texto. Anexe a folha de partes como referência de estilo. Eu recorto e coloco cada um no lugar.

### Folha L1: Estações do laboratório (6)

```
Dark fantasy hand-painted game icon sheet, same style as the attached reference: bold dark outlines, cel shading, rich defined colors, gothic naturalist laboratory theme, bold simple readable silhouettes. Transparent or plain blurred background. Exactly 6 separate isolated objects in a 3x2 grid with wide spacing, in the exact order listed, left to right, top to bottom. Draw exactly these objects and nothing else. No text, no numbers, no labels, no frames, no people, no gore.
1. an expedition table: an unrolled old map with a compass, a lantern and a hunting satchel on top
2. a card-sorting desk: a wooden writing desk with neat stacks of illustrated cards, an inkwell and a quill
3. an alchemy experiment bench: two glass flasks with different colored fluids (crimson and violet) joined by brass tubes into a glowing green flask
4. a mutation chamber: a tall glass vat with brass fittings filled with glowing violet liquid, a dark creature organ floating inside
5. a workshop: an anvil with a hammer, tongs and a half-finished bone-handled surgical blade, a few sparks
6. a specimen archive: a tall wooden cabinet with many small labeled drawers, one drawer open showing a pinned creature eye
```

| Ordem | Arquivo | Estação |
|---|---|---|
| 1 | `expedition.png` | Mesa de Expedição |
| 2 | `deck.png` | Bancada de Baralho |
| 3 | `experiment.png` | Estação de Experimentação |
| 4 | `mutation.png` | Câmara de Mutação |
| 5 | `workshop.png` | Oficina |
| 6 | `archive.png` | Arquivo de Espécimes |

### Folha L2: Melhorias da Oficina (5)

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

## Próximas artes possíveis

Precisa de um ajuste pequeno no código antes; me avise que eu preparo e escrevo o pedido.

| Item | Onde aparece |
|---|---|
| O Pesquisador (personagem do jogador) | Combate, ao lado da vida; hoje é um vulto desenhado em código |

## Ferramentas (para mim)

- `tools/remove_bg.gd`: tira o fundo liso ou borrado de uma folha.
- `tools/slice_sheet.gd`: recorta uma folha pela ordem das figuras.
- `tools/crop_items.gd`: recorta por caixas marcadas à mão, para figuras encostadas.
