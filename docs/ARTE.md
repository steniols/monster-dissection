# MONSTER DISSECTION: arte

## Status: conteúdo atual pronto; pedir as artes das fases 3 e 4 (78 imagens)

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
| Acampamento: barraca com fogueira no centro | 1 | **Pronto** (recortada da folha "Fogueiras e Acampamento"; a fogueira avulsa está em `assets/art/extra/camp/`; o fundo alternativo está em `assets/art/extra/backgrounds/camp_v2.png`) |
| Acampamento: ícones das opções | 3 | **Pronto** (os três da folha 3; as outras versões estão em `assets/art/extra/camp/alt/`) |
| **Fases 3 e 4** (monstros, fundos, partes, cartas, mutações, eventos) | 78 | **Pedir**: ver "Fases 3 e 4" abaixo |

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

## Fases 3 e 4: pedir agora

Duas regiões novas, cada uma com **uma família nova de monstros**. As famílias atuais também aparecem nelas,
misturadas. Esta seção lista **só as artes**; o código (dados, mecânicas, cartas) eu faço em paralelo, e os
nomes de arquivo abaixo já são os definitivos.

| Fase | Região | Família nova | Cores da família | Clima |
|---|---|---|---|---|
| 3 | **Bosque dos Esporos** (`fungal_grove`) | **Sporemaw**: criaturas-fungo | verde-água bioluminescente + bege/ocre de cogumelo | floresta úmida e escura, cogumelos gigantes que brilham |
| 4 | **Pináculos de Cinza** (`ash_peaks`) | **Ashwing**: aves-morcego de cinza e brasa | laranja-brasa + cinza-carvão | picos vulcânicos, cinza caindo, tempestade |

As cores novas foram escolhidas para não se confundir com as atuais (vermelho, verde-musgo, violeta,
oliva/osso).

### Quanto falta, em ordem de prioridade

| Folha | O que é | Qtde | Formato |
|---|---|---|---|
| **M3** | Monstros novos | 8 | um por pedido, alta resolução |
| **F3** | Fundos das regiões + fundos de batalha | 4 | um por pedido, 16:9 |
| **P6 / P7** | Partes anatômicas (Sporemaw / Ashwing) | 12 + 12 | folha 4x3 |
| **C5 / C6** | Cartas das partes (Sporemaw / Ashwing) | 12 + 12 | folha 4x3 |
| **C7** | Cartas híbridas novas | 8 | folha 4x2 |
| **MU2** | Mutações novas | 4 | folha 4x1 |
| **E3** | Eventos novos | 6 | um por pedido (ou folha 3x2) |
| | **Total** | **78** | |

Comece pelos **monstros** e **fundos**: com eles eu já consigo montar as fases jogáveis (as partes e
cartas usam desenho provisório até a arte chegar).

### Folha M3: monstros novos (8)

**Um monstro por pedido**, PNG na resolução máxima (ideal 1536×1024; os altos podem ser 1024×1536). Anexe
como referência de estilo **dois monstros atuais** (ex.: `assets/art/monsters/bloodfang.png` e
`voidspawn.png`). Fundo transparente ou liso e claro. **Olhando para a esquerda**, corpo inteiro.

Cabeçalho de todo pedido:

```
Create a NEW creature in exactly the same art style as the attached reference creatures: dark fantasy hand-painted game art, bold dark outlines, cel shading, rich defined colors, natural history museum specimen theme. Full body, side view facing LEFT, centered with a small margin, nothing cropped. Transparent background (or plain flat light background). No ground, no shadow, no scenery, no text, no frame, no gore. Single image, maximum resolution.
```

| Arquivo | Nome no jogo | Papel | Complemento |
|---|---|---|---|
| `sporeling.png` | Sporeling | comum (vem em dupla) | A small fungal creature the size of a cat walking on four root-like legs, a round ochre mushroom cap as its body with glowing teal spots, tiny bead eyes under the cap, wisps of teal spores. |
| `sporemaw.png` | Sporemaw | comum | A quadruped fungal beast the size of a bear: a huge ochre-beige mushroom cap as its back, a wide gilled maw with fibrous teeth underneath, thick root legs, glowing teal gills and spots, teal spore puffs. |
| `mycostalker.png` | Mycostalker | elite | A tall thin mantis-like fungal hunter: long fibrous stalk body, two scythe arms made of hard shelf-fungus, a head of clustered glowing teal puffball eyes, ochre and pale beige tones. |
| `mycelium_mother.png` | Matriz Micélica | chefe | An enormous bloated fungal mound with dozens of mushroom caps forming a crown, glowing teal lace-like veils hanging down, thick root tentacles, a pulsing teal heart-like core visible in the center. Larger and more imposing than the others. |
| `ash_hatchling.png` | Ash Hatchling | comum (vem em dupla) | A small featherless bat-bird chick, wrinkled ash-grey skin with glowing ember cracks, oversized hooked beak, stubby leathery wings, bright ember-orange eyes. |
| `ashwing.png` | Ashwing | comum | A bat-winged raptor: leathery ash-grey wings spread, glowing ember-orange cracks along wings and body, hooked bone beak, sharp talons, smoke trailing from the wing tips. |
| `stormtalon.png` | Stormtalon | elite | A large storm raptor: crest of bone spikes, metallic dark feathers like blades, oversized talons crackling with small orange-white lightning, a glowing sac at the throat. |
| `ember_roc.png` | Roca de Brasa | chefe | A colossal roc with huge wings with molten lava cracks, bone-armored beak, a glowing ember heart visible through the chest, trails of smoke and falling ash. Larger and more imposing than the others. |

### Folha F3: fundos (4)

Um por pedido, como em **Fundos (paisagens)** abaixo: mesmo cabeçalho de fundo, 16:9, cena vazia, e as
mesmas regras de composição dos fundos de combate (horizonte na metade, chão aberto no centro e à direita,
metade de baixo mais escura).

| Arquivo | Onde aparece | Complemento |
|---|---|---|
| `fungal_grove.png` | Mapa, eventos e combate do **Bosque dos Esporos** | A dark damp forest of giant mushrooms at night, huge ochre caps overhead, glowing teal bioluminescent spots and spore motes in the air, twisted roots, soft teal mist. Horizon at the middle, open mossy ground in the center and right, darker simpler lower half. |
| `ash_peaks.png` | Mapa, eventos e combate dos **Pináculos de Cinza** | Jagged volcanic peaks under a stormy sky, falling grey ash, faint orange lava glow in the cracks, a narrow rocky plateau, distant lightning. Horizon at the middle, open flat rocky ground in the center and right, darker simpler lower half. |
| `battle_fungal_hollow.png` | Combate contra **Sporemaw** (fundo neutro da família) | A quiet hollow under giant mushrooms, dim teal glow, soft spore motes, very simple and calm, mostly empty dark ground. Neutral and low-contrast so creatures stand out. |
| `battle_ash_ridge.png` | Combate contra **Ashwing** (fundo neutro da família) | A bare ash-covered ridge under a dark orange-grey sky, a few distant peaks, faint ember glow, very simple and calm, mostly empty dark ground. Neutral and low-contrast so creatures stand out. |

### Folhas P6 e P7: partes anatômicas (12 + 12)

Mesmo cabeçalho de folha de ícones do **Estilo aprovado** (com `Exactly 12 ... in a 4x3 grid`). Anexe a
folha de partes atual como referência. Partes são **objetos isolados**, como espécimes de museu.

**P6, Sporemaw:**

```
1. a round ochre mushroom cap with glowing teal spots
2. a small translucent sac full of glowing teal spores
3. the underside of a mushroom cap: radiating gills glowing teal
4. a fungal jaw with fibrous pale teeth
5. a bundle of thick twisting root legs
6. a tangle of glowing white-teal mycelium threads
7. a curved scythe blade made of hard shelf-fungus
8. a long fibrous fungal stalk coiled like a spring
9. a cluster of glowing teal puffball eyes
10. a pulsing teal heart-like fungal core
11. a hanging glowing lace-like fungal veil
12. a small crown made of a ring of mushroom caps
```

| Ordem | Arquivo | Parte | Monstro |
|---|---|---|---|
| 1 | `sl_cap.png` | Chapéu Luminoso | Sporeling |
| 2 | `sl_spores.png` | Saco de Esporos | Sporeling |
| 3 | `sm_gills.png` | Lamelas | Sporemaw |
| 4 | `sm_maw.png` | Mandíbula Fúngica | Sporemaw |
| 5 | `sm_roots.png` | Raízes-Pernas | Sporemaw |
| 6 | `sm_mycelium.png` | Rede de Micélio | Sporemaw |
| 7 | `ms_scythe.png` | Foice de Orelha-de-pau | Mycostalker |
| 8 | `ms_stalk.png` | Haste Fibrosa | Mycostalker |
| 9 | `ms_eyes.png` | Olhos-Bufa | Mycostalker |
| 10 | `mm_core.png` | Núcleo Pulsante | Matriz Micélica |
| 11 | `mm_veil.png` | Véu Luminoso | Matriz Micélica |
| 12 | `mm_crown.png` | Coroa de Chapéus | Matriz Micélica |

**P7, Ashwing:**

```
1. a tuft of ash-grey down feathers with tiny glowing embers
2. a small hooked hatchling beak with an egg tooth
3. a folded leathery ash-grey wing membrane with ember cracks
4. a hooked bone beak
5. a pair of sharp black talons
6. a glowing ember-orange gland, like a hot coal in a membrane
7. a crest of bone spikes
8. a throat sac crackling with small orange-white lightning
9. three dark metallic feathers shaped like blades
10. a heart glowing like molten lava, with dark cracked crust
11. a huge wing bone with molten lava cracks
12. a massive bone-armored beak
```

| Ordem | Arquivo | Parte | Monstro |
|---|---|---|---|
| 1 | `ah_down.png` | Penugem Fumegante | Ash Hatchling |
| 2 | `ah_beak.png` | Bico de Filhote | Ash Hatchling |
| 3 | `aw_wing.png` | Membrana da Asa | Ashwing |
| 4 | `aw_beak.png` | Bico Curvo | Ashwing |
| 5 | `aw_talons.png` | Garras de Mergulho | Ashwing |
| 6 | `aw_gland.png` | Glândula de Brasa | Ashwing |
| 7 | `st_crest.png` | Crista de Ossos | Stormtalon |
| 8 | `st_storm_sac.png` | Bolsa de Tempestade | Stormtalon |
| 9 | `st_feathers.png` | Penas de Aço | Stormtalon |
| 10 | `er_heart.png` | Coração de Brasa | Roca de Brasa |
| 11 | `er_wing.png` | Asa Fundida | Roca de Brasa |
| 12 | `er_beak.png` | Bico Blindado | Roca de Brasa |

### Folhas C5 e C6: cartas das partes (12 + 12)

Cartas são **ilustrações de ação** do mesmo objeto da parte (como a "Mordida Profunda" mostra as presas e o
"Rasgar" mostra as garras com rastros de corte). Mesmo cabeçalho de folha de ícones, `4x3 grid`. Anexe a
folha de cartas atual como referência, se tiver; senão, a de partes.

**C5, Sporemaw:**

```
1. a glowing ochre mushroom cap radiating teal light rays
2. a burst cloud of glowing teal spores
3. mushroom gills exhaling a soft teal mist
4. a fungal jaw with fibrous teeth snapping shut
5. thick roots gripping the ground and spreading out, like an anchor
6. a web of glowing mycelium threads spreading outward
7. a shelf-fungus scythe blade mid-slash with a teal arc
8. a fibrous stalk springing up like a coiled spring
9. glowing teal puffball eyes with a beam of light
10. a pulsing teal fungal core sending out rings of light
11. a glowing lace veil fluttering like a curtain
12. a crown of mushroom caps glowing from within
```

| Ordem | Arquivo | Carta | Parte |
|---|---|---|---|
| 1 | `cap_glow.png` | Brilho do Chapéu | Chapéu Luminoso |
| 2 | `spore_cloud.png` | Nuvem de Esporos | Saco de Esporos |
| 3 | `filter_gills.png` | Lamelas Filtrantes | Lamelas |
| 4 | `fungal_bite.png` | Bocada Fúngica | Mandíbula Fúngica |
| 5 | `take_root.png` | Enraizar | Raízes-Pernas |
| 6 | `mycelial_web.png` | Rede Micélica | Rede de Micélio |
| 7 | `shelf_scythe.png` | Ceifa Fúngica | Foice de Orelha-de-pau |
| 8 | `spring_stalk.png` | Haste Elástica | Haste Fibrosa |
| 9 | `glow_gaze.png` | Olhar Bioluminescente | Olhos-Bufa |
| 10 | `matrix_pulse.png` | Pulso da Matriz | Núcleo Pulsante |
| 11 | `luminous_veil.png` | Véu Luminoso | Véu Luminoso |
| 12 | `cap_crown.png` | Coroa Micélica | Coroa de Chapéus |

**C6, Ashwing:**

```
1. ash-grey down feathers swirling with glowing embers
2. a small hooked beak pecking through an eggshell
3. a leathery wing beating with gust lines and ash
4. a hooked bone beak striking downward with a motion arc
5. black talons diving down with speed lines
6. a glowing ember gland bursting into sparks
7. a crest of bone spikes raised and bristling
8. a throat sac discharging orange-white lightning
9. metallic blade feathers fanned out like knives
10. a molten heart pulsing with heat waves
11. a molten-cracked wing spreading a wave of fire
12. a bone-armored beak ramming forward, cracks of impact
```

| Ordem | Arquivo | Carta | Parte |
|---|---|---|---|
| 1 | `smoldering_down.png` | Penugem Fumegante | Penugem Fumegante |
| 2 | `hatchling_peck.png` | Bicada de Filhote | Bico de Filhote |
| 3 | `wing_gust.png` | Rajada de Asas | Membrana da Asa |
| 4 | `hooked_strike.png` | Golpe de Bico | Bico Curvo |
| 5 | `dive_talons.png` | Mergulho | Garras de Mergulho |
| 6 | `ember_burst.png` | Explosão de Brasa | Glândula de Brasa |
| 7 | `bristling_crest.png` | Crista Eriçada | Crista de Ossos |
| 8 | `storm_discharge.png` | Descarga | Bolsa de Tempestade |
| 9 | `steel_feathers.png` | Penas de Aço | Penas de Aço |
| 10 | `molten_heart.png` | Coração Fundido | Coração de Brasa |
| 11 | `molten_wing.png` | Asa Fundida | Asa Fundida |
| 12 | `armored_ram.png` | Investida Blindada | Bico Blindado |

### Folha C7: cartas híbridas novas (8)

Combinações das famílias novas com as atuais (Experimentação). `Exactly 8 ... in a 4x2 grid`.

```
1. an olive-grey bone with glowing teal mushrooms sprouting from it
2. a violet spore cloud with small amber eyes inside it
3. a moss-green armored chitin plate overgrown with glowing teal fungus
4. a pair of crimson fangs covered with pale fuzzy mold
5. a crimson fang glowing ember-hot, with small flames
6. a moss-green chitin plate with glowing molten lava cracks
7. an ash-grey feather dissolving into violet smoke at the tip
8. a glowing teal mushroom cap burning with orange embers
```

| Ordem | Arquivo | Carta | Combinação |
|---|---|---|---|
| 1 | `hb_rot_bloom.png` | Flor da Podridão | Sporemaw + Rotwalker |
| 2 | `hb_void_spores.png` | Esporos do Vazio | Sporemaw + Voidspawn |
| 3 | `hb_moss_plate.png` | Placa Micélica | Sporemaw + Ironback |
| 4 | `hb_blood_mold.png` | Mofo Sanguíneo | Sporemaw + Bloodfang |
| 5 | `hb_ember_fang.png` | Presa de Brasa | Ashwing + Bloodfang |
| 6 | `hb_kiln_shell.png` | Casco de Forno | Ashwing + Ironback |
| 7 | `hb_void_feather.png` | Pena do Vazio | Ashwing + Voidspawn |
| 8 | `hb_burning_spores.png` | Esporos Ardentes | Ashwing + Sporemaw |

### Folha MU2: mutações novas (4)

Como as atuais: **o órgão dentro de um frasco ou relicário** de vidro e latão. `Exactly 4 ... in a single row`.
Anexe uma mutação atual (ex.: `assets/art/mutations/mut_bf_heart.png`) como referência.

```
1. a glass jar with a cork lid containing glowing teal mushroom gills in clear fluid
2. an ornate brass-and-glass reliquary holding a pulsing teal fungal core
3. a glass jar with a cork lid containing a glowing ember-orange gland in amber fluid
4. an ornate brass-and-glass reliquary holding a heart glowing like molten lava
```

| Ordem | Arquivo | Mutação |
|---|---|---|
| 1 | `mut_sm_gills.png` | Lamelas Implantadas |
| 2 | `mut_mm_core.png` | Núcleo Micélico |
| 3 | `mut_aw_gland.png` | Glândula Ardente |
| 4 | `mut_er_heart.png` | Coração da Roca |

### E3: eventos novos (6)

Cenas quadradas que preenchem o quadro inteiro, como em **Eventos em alta resolução** (mesmo cabeçalho de
evento). O ideal é **um por pedido**, 1024×1024 ou mais; uma folha 3x2 também serve, mas sai menos nítida.

| Arquivo | Evento | Região | Complemento |
|---|---|---|---|
| `ev_fairy_ring.png` | Círculo de Cogumelos | Bosque | A perfect ring of glowing teal mushrooms in a dark forest clearing, spore motes floating, an eerie calm. |
| `ev_spore_cocoon.png` | Casulo Fúngico | Bosque | A large creature-shaped cocoon wrapped in white mycelium hanging from a giant mushroom, faint teal glow inside. |
| `ev_overgrown_cart.png` | Carroça Tomada | Bosque | An old wooden supply cart overgrown with mushrooms, crates and jars still on it, half-sunk in moss. |
| `ev_cliff_nest.png` | Ninho no Penhasco | Pináculos | A huge nest of bones and branches on a cliff ledge, three eggs glowing ember-orange, ash falling. |
| `ev_storm_shrine.png` | Santuário da Tempestade | Pináculos | A small ancient stone shrine on a mountain peak, struck by orange-white lightning, carved bird motifs. |
| `ev_abandoned_gear.png` | Equipamento Abandonado | Pináculos | Abandoned climbing gear in grey ash: a pickaxe, coiled rope, a lantern and a backpack at the foot of a cliff. Nobody visible. |

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

## Acampamento: pronto

A **barraca com fogueira** no centro já está no jogo (recortada da folha "Fogueiras e Acampamento"), com o fundo e a
distribuição originais. O fundo alternativo, com a fogueira no meio, ficou guardado em
`assets/art/extra/backgrounds/camp_v2.png`.

Os **ícones das opções** (3) também estão no jogo, escolhidos entre 4 folhas: os três da folha 3. As 12 versões ficam em `assets/art/extra/camp/alt/` (`<opção>_v<folha>.png`);
para trocar, copie a escolhida para `assets/art/camp/<opção>.png`. O pedido abaixo fica para refazer.

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
