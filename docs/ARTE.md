# MONSTER DISSECTION: arte

## Status: as fases 3 e 4 já estão no jogo; faltam 18 imagens e há ajustes opcionais (ver "Novos pedidos")

| Grupo | Qtde | Situação |
|---|---|---|
| Monstros | 21 | **Pronto**, em alta resolução |
| Partes anatômicas | 54 de 62 | **Faltam 8** (monstros extras) |
| Cartas | 75 de 83 | **Faltam 8** (monstros extras) |
| Mutações | 11 | **Pronto** (as 4 novas com líquido a ajustar) |
| Eventos | 12 | **Pronto** (1024 px, ampliados de ~485 px; dá para refazer um por um) |
| Fundos (paisagens) | 8 | **Pronto** |
| Fundos de batalha (neutros, por família) | 6 | **Pronto** |
| Logo | 1 | **Pronto** (`assets/art/ui/logo.png`) |
| Ícones das estações do laboratório | 6 | **Pronto** (versão alternativa: folha L1b) |
| Melhorias da Oficina | 5 de 7 | **Faltam 2** (novas) |
| Acampamento: barraca com fogueira no centro | 1 | **Pronto** (recortada da folha "Fogueiras e Acampamento"; a fogueira avulsa está em `assets/art/extra/camp/`; o fundo alternativo está em `assets/art/extra/backgrounds/camp_v2.png`) |
| Acampamento: ícones das opções | 3 | **Pronto** (os três da folha 3; as outras versões estão em `assets/art/extra/camp/alt/`) |
| Ícones de navegação | 10 de 12 | **Faltam 2** (elite e chefe) (`assets/art/ui/nav_*.png`, 96 px; originais em `assets/art/extra/fases34/nav_full/`). Em uso: `nav_dissect`, `nav_camp`, `nav_event`, `nav_map`, `nav_lab`, `nav_settings`, `nav_pack`. Ainda sem uso: `nav_book`, `nav_forge`, `nav_loot` |

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

## Fases 3 e 4: no jogo, com novos pedidos

Duas regiões novas, cada uma com **uma família nova de monstros**. O código já está pronto e os nomes de arquivo abaixo
são os definitivos: arte nova entra sozinha, sem mexer no código.

| Fase | Região | Família nova | Cores (como a arte aprovada saiu) |
|---|---|---|---|
| 3 | **Bosque dos Esporos** (`fungal_grove`) | **Sporemaw**: criaturas-fungo | chapéu laranja-avermelhado, lamelas verde-água, estrutura cor de osso |
| 4 | **Pináculos de Cinza** (`ash_peaks`) | **Ashwing**: aves-morcego de cinza e brasa | laranja-brasa + cinza-carvão |

### Situação de cada folha

**As 78 imagens do plano original estão prontas.** Os monstros extras e as melhorias novas pedem mais 18 (ver "Novos pedidos").

| Folha | O que é | Qtde | Situação |
|---|---|---|---|
| **M3 Ashwing** | `ash_hatchling`, `ashwing`, `stormtalon`, `ember_roc` | 4 | **Pronta**, instalada. O Stormtalon ficou parecido com o Ashwing; refazer é opcional |
| **F3 Pináculos** | `ash_peaks`, `battle_ash_ridge` | 2 | **Pronta**, instalada. `ash_peaks` aparece no mapa e nos eventos; `battle_ash_ridge`, no combate contra Ashwing |
| **MU2** | Mutações | 4 | **Pronta**, instalada. O estilo está certo, mas os 4 frascos vieram com líquido vermelho; ajuste opcional abaixo |
| **E3 Pináculos** | `ev_cliff_nest`, `ev_storm_shrine`, `ev_abandoned_gear` | 3 | **Pronta**, instalada. `ev_abandoned_gear` veio como uma mina abandonada, então o evento passa a se chamar **Mina Abandonada** |
| **E3 Bosque** | `ev_fairy_ring`, `ev_spore_cocoon`, `ev_overgrown_cart` | 3 | **Pronta**, instalada |
| **M3 Sporemaw** | `sporeling`, `sporemaw`, `mycostalker`, `mycelium_mother` | 4 | **Pronta**, instalada |
| **F3 Bosque** | `fungal_grove`, `battle_fungal_hollow` | 2 | **Pronta**, instalada |
| **P6 / P7** | Partes Sporemaw e Ashwing | 12 + 12 | **Pronta**, instalada |
| **C5 / C6** | Cartas das partes | 12 + 12 | **Pronta**, instalada: serve no tamanho da carta (ver abaixo) |
| **C7** | Cartas híbridas | 8 | **Pronta**, instalada: serve no tamanho da carta (ver abaixo) |

As cartas vieram da "Prancha de dissecação Ashwing e Sporemaw". O estilo ficou certo e o tamanho basta, porque a arte
aparece com cerca de 140×80 px na carta. Elas mostram a peça parada, sem ação; ver o pedido 7.

### Como pedir

Pranchas com tudo junto, com títulos como "M3" e "C5" escritos na imagem, deixam as figuras
pequenas; um pedido por vez deu os melhores resultados.

1. **Não cole este arquivo no ChatGPT.** Cole só **um** bloco de pedido por conversa, sem os códigos das folhas.
2. **Anexe as imagens indicadas em cada pedido.** Os caminhos são relativos a `assets/art/`.
3. **Confira o primeiro resultado** antes de pedir o resto. O resultado precisa ser uma imagem só, na resolução máxima.

### Novos pedidos: o que ainda falta

As fases já funcionam sem estes pedidos: o que não tem arte usa um desenho provisório. Em cada pedido, os caminhos
são relativos a `assets/art/`. Anexe as imagens **na ordem indicada**.

| Prioridade | Pedido | Qtde | Por quê |
|---|---|---|---|
| **1** | Partes dos monstros extras (P8) | 8 | **Faltam de verdade:** hoje usam desenho provisório |
| **2** | Cartas dos monstros extras (C8) | 8 | **Faltam de verdade:** hoje usam desenho provisório |
| **3** | Melhorias novas da Oficina (L3) | 2 | **Faltam de verdade:** hoje usam desenho provisório |
| **4** | Líquido das mutações | 4 | Frascos vermelhos, iguais aos do Bloodfang |
| **5** | Ícones de elite e chefe no mapa | 2 | Ainda usam o desenho antigo |
| **6** | Stormtalon | 1 | Parecido com o Ashwing |
| **7** | Cartas com ação (C5, C6, C7) | 32 | As atuais mostram a peça parada |
| **8** | Ovos do Ninho e raio do Santuário | 2 | Cores diferentes do pedido |

#### 1. P8: partes dos monstros extras (8, em uma folha)

Anexe `parts/bf_fangs.png`, `parts/bf_heart.png`, `monsters/spore_stag.png` e `monsters/spore_carrier.png`.

```
Dark fantasy hand-painted game icon sheet, same style as the first two attached images: matte painted surfaces, natural colors, thick dark outline, simple cel shading, natural history museum specimen theme. The creatures in the other attached images show where these parts come from. Exactly 8 separate isolated objects in a 4x2 grid with wide spacing, in this exact order, left to right, top to bottom.
1. a large bone antler overgrown with small orange mushrooms
2. a section of lace-like bone ribs eaten away by fungus
3. a single glowing teal eye in a socket of pale bone
4. a cluster of large swollen green-yellow spore sacs
5. a thick gnarled root leg ending in bone claws
6. a mantle of thick green moss with small roots
7. a small round lantern-like fungal heart with a soft teal light
8. a bundle of long thin floating orange and teal filaments
Plain flat light grey background, never black or checkered. No text, no numbers, no labels, no frames, no people, no gore. One image, maximum resolution, at least 2000 pixels wide.
```

| Ordem | Arquivo | Parte | Monstro |
|---|---|---|---|
| 1 | `sg_antlers.png` | Galhada Fúngica | Cervo de Esporos |
| 2 | `sg_ribs.png` | Costelas Rendadas | Cervo de Esporos |
| 3 | `sg_eye.png` | Olho Verde-Água | Cervo de Esporos |
| 4 | `sc_sacs.png` | Bolsas Cheias | Carregador de Esporos |
| 5 | `sc_legs.png` | Pernas de Raiz | Carregador de Esporos |
| 6 | `sc_moss.png` | Manto de Musgo | Carregador de Esporos |
| 7 | `sw_core.png` | Coração-Lanterna | Fogo-Fátuo de Esporos |
| 8 | `sw_tendrils.png` | Filamentos | Fogo-Fátuo de Esporos |

#### 2. C8: cartas dos monstros extras (8, em uma folha)

Anexe `cards/bloodthirst.png`, `cards/abyssal_gaze.png` e a folha P8 que você acabou de gerar.

```
Dark fantasy hand-painted game icon sheet, same style as the first two attached images: matte painted surfaces, natural colors, thick dark outline, simple cel shading. The third attached image shows the objects to use. Each figure is one simple object in action, readable at small size. Only the art: no card frame, no title, no text, no cost, no icons. Exactly 8 separate isolated figures in a 4x2 grid with wide spacing, in this exact order, left to right, top to bottom.
1. a fungal bone antler charging forward with speed lines and small spores
2. lace-like bone ribs closed like a cage, with small spikes
3. a teal eye staring, with a thin beam of light
4. a green-yellow spore sac bursting into a cloud
5. a root leg stepping down and gripping the ground
6. a green moss mantle wrapping like a cloak
7. a lantern-like fungal heart pulsing with rings of teal light
8. long floating filaments whipping through the air
Plain flat light grey background, never black or checkered. No people, no gore. One image, maximum resolution, at least 2000 pixels wide.
```

| Ordem | Arquivo | Carta |
|---|---|---|
| 1 | `antler_charge.png` | Investida da Galhada |
| 2 | `lace_ribs.png` | Costelas Rendadas |
| 3 | `stag_gaze.png` | Olhar do Cervo |
| 4 | `burst_sacs.png` | Bolsas Estouradas |
| 5 | `rooted_steps.png` | Passos de Raiz |
| 6 | `moss_mantle.png` | Manto de Musgo |
| 7 | `lantern_core.png` | Coração-Lanterna |
| 8 | `drift_tendrils.png` | Filamentos à Deriva |

#### 3. L3: melhorias novas da Oficina (2, em uma folha)

Anexe `upgrades/up_jars.png` e `upgrades/up_obsidian.png`.

```
Dark fantasy hand-painted game icon sheet, same style as the attached images: matte painted surfaces, natural colors, thick dark outline, simple cel shading, gothic naturalist laboratory tools. Exactly 2 separate isolated objects in a single row with wide spacing, in this exact order, left to right.
1. a leather and brass filter mask with round glass eye pieces and a canister
2. a pair of long heavy iron tongs with a brass hinge, the tips glowing faintly orange
Plain flat light grey background, never black or checkered. No text, no numbers, no labels, no frames, no people, no gore. One image, maximum resolution, at least 1536 pixels wide.
```

| Ordem | Arquivo | Melhoria |
|---|---|---|
| 1 | `up_spore_filter.png` | Máscara Filtrante |
| 2 | `up_ember_tongs.png` | Pinças Refratárias |

#### 4. Líquido das mutações (4, editar a folha)

Anexe só `extra/fases34/folhas/MU2_folha_original.png`.

```
Edit the attached image, keeping everything exactly the same: same 4 containers, same contents, same style, same layout, same plain grey background. Change only the color of the fluid inside each container. Container 1 (left): clear pale teal fluid. Container 2: clear pale teal fluid. Container 3: amber yellow fluid. Container 4 (right): dark amber orange fluid. No red fluid. No text, no labels. One image, maximum resolution.
```

Os arquivos são os mesmos: `mut_sm_gills`, `mut_mm_core`, `mut_aw_gland` e `mut_er_heart`, nessa ordem.

#### 5. Ícones de elite e chefe no mapa (2, em uma folha)

Anexe `extra/fases34/folhas/Ícones de Navegação em Fantasia Sombria-1.png`.

```
Create 2 new icons in exactly the same style as the attached icon sheet: same thick black outline, same painted texture, same size and level of detail. Exactly 2 separate isolated icons in a single row with wide spacing, in this exact order, left to right.
1. a large cracked monster skull with big horns and red war paint, on crossed bones
2. a menacing bone crown with red gems, resting on a large monster skull
Plain flat white background. No text, no numbers, no labels, no frames, no people, no gore. One image, maximum resolution, at least 1536 pixels wide.
```

| Ordem | Arquivo | Onde aparece |
|---|---|---|
| 1 | `nav_elite.png` | Pontos de elite no mapa |
| 2 | `nav_boss.png` | Ponto do chefe no mapa, quando o chefe ainda é desconhecido |

#### 6. Stormtalon (1)

Anexe `monsters/ashwing.png` e `monsters/stormtalon.png`.

```
Redraw the creature from the second attached image, alone, in the same style and colors as the first attached image, but with a clearly different silhouette from the first image: a lean long body held low like a stalking raptor, wings folded back, a tall crest of flame-colored feathers, a fierce slit-pupil ember eye, and a very long feathered tail with a burning tip. Matte hand-painted dark fantasy game art, thick dark outline, cel shading. Full body, side view facing LEFT, centered with a small margin, nothing cropped. Transparent background. No ground, no shadow, no scenery, no text, no labels, no frame, no neon, no glowing aura. One single creature in one image, maximum resolution, at least 1536x1024.
```

O arquivo é o mesmo: `stormtalon.png`.

#### 7. Cartas com ação (C5, C6, C7)

Três folhas, uma por conversa. Anexe `cards/bloodthirst.png` e `cards/abyssal_gaze.png`. Cole o cabeçalho e, logo
depois, a lista da folha. Use `Exactly 12` e `4x3` nas folhas C5 e C6, e `Exactly 8` e `4x2` na C7. A ordem das
figuras é a mesma das tabelas em "Consulta" abaixo.

```
Dark fantasy hand-painted game icon sheet, same style as the attached images: matte painted surfaces, natural colors, thick dark outline, simple cel shading. Each figure is one simple object in action, readable at small size. Only the art: no card frame, no title, no text, no cost, no icons. Plain flat light grey background, never black or checkered. No people, no gore. One image, maximum resolution, at least 2000 pixels wide. Exactly 12 separate isolated figures in a 4x3 grid with wide spacing, in this exact order, left to right, top to bottom:
```

**C5, Sporemaw:**

```
1. an orange mushroom cap radiating teal light rays
2. a burst cloud of teal spores
3. mushroom gills exhaling a soft teal mist
4. a fungal jaw with fibrous teeth snapping shut
5. thick roots gripping the ground and spreading out, like an anchor
6. a web of white mycelium threads spreading outward
7. a shelf-fungus scythe blade mid-slash with a teal arc
8. a fibrous stalk springing upward
9. teal puffball eyes with a beam of light
10. a fungal core sending out rings of teal light
11. a pale lace veil fluttering like a curtain
12. a crown of mushroom caps lit from within
```

**C6, Ashwing:**

```
1. an ash-grey feather shedding small embers as it falls
2. dark smoke spreading sideways like a curtain, with a few embers
3. a torn leathery wing beating, with gust lines and ash
4. a serrated bone beak striking downward with a motion arc
5. ember-cracked talons diving down with speed lines
6. a hot coal in a cracked crust bursting into sparks
7. a crest of flame-colored feathers raised and bristling
8. a slit-pupil ember eye staring, with a thin beam of light
9. a burning feathered tail lashing like a whip
10. a molten heart pulsing with heat waves
11. a charred feathered wing spreading a wave of fire
12. a crown of charred bone spikes radiating heat waves
```

**C7, híbridas:**

```
1. one olive-grey bone with a few small teal mushrooms growing on it
2. a small violet spore cloud with two amber eyes inside it
3. one moss-green chitin plate with a patch of teal fungus
4. a pair of crimson fangs covered with pale fuzzy mold
5. one crimson fang with an ember-hot orange tip
6. one moss-green chitin plate with orange lava cracks
7. one ash-grey feather fading into violet smoke at the tip
8. one orange mushroom cap with embers on its edge
```

As tabelas de arquivos estão em "Consulta" abaixo. Na C5 e na C6 a ordem é a de cima para baixo em cada tabela.

#### 8. Ovos do Ninho e raio do Santuário (2, editar cada imagem)

**`ev_cliff_nest.png`:** anexe `events/ev_cliff_nest.png`.

```
Edit the attached image, keeping everything exactly the same: same composition, same style, same nest and background. Change only the three eggs: make them dark charcoal with glowing ember-orange cracks, and add a few old bones among the branches of the nest. No text, no frame. One square image, maximum resolution.
```

**`ev_storm_shrine.png`:** anexe `events/ev_storm_shrine.png`.

```
Edit the attached image, keeping everything exactly the same: same composition, same style, same shrine and background. Change only the lightning bolts in the sky: make them orange-white instead of violet. No text, no frame. One square image, maximum resolution.
```

### Consulta: partes e cartas prontas

Não precisa pedir.

**Sporemaw**

| Monstro | Parte (arquivo) | Parte | Carta (arquivo) | Carta |
|---|---|---|---|---|
| Sporeling | `sl_cap` | Chapéu Luminoso | `cap_glow` | Brilho do Chapéu |
| Sporeling | `sl_spores` | Saco de Esporos | `spore_cloud` | Nuvem de Esporos |
| Sporemaw | `sm_gills` | Lamelas | `filter_gills` | Lamelas Filtrantes |
| Sporemaw | `sm_maw` | Mandíbula Fúngica | `fungal_bite` | Bocada Fúngica |
| Sporemaw | `sm_roots` | Raízes-Pernas | `take_root` | Enraizar |
| Sporemaw | `sm_mycelium` | Rede de Micélio | `mycelial_web` | Rede Micélica |
| Mycostalker | `ms_scythe` | Foice de Orelha-de-pau | `shelf_scythe` | Ceifa Fúngica |
| Mycostalker | `ms_stalk` | Haste Fibrosa | `spring_stalk` | Haste Elástica |
| Mycostalker | `ms_eyes` | Olhos-Bufa | `glow_gaze` | Olhar Bioluminescente |
| Matriz Micélica | `mm_core` | Núcleo Pulsante | `matrix_pulse` | Pulso da Matriz |
| Matriz Micélica | `mm_veil` | Véu Luminoso | `luminous_veil` | Véu Luminoso |
| Matriz Micélica | `mm_crown` | Coroa de Chapéus | `cap_crown` | Coroa Micélica |

**Ashwing**

| Monstro | Parte (arquivo) | Parte | Carta (arquivo) | Carta |
|---|---|---|---|---|
| Ash Hatchling | `ah_down` | Pluma de Cinzas | `smoldering_down` | Penugem Fumegante |
| Ash Hatchling | `ah_smoke` | Véu de Fumaça | `smoke_screen` | Cortina de Fumaça |
| Ashwing | `aw_wing` | Membrana Alada | `wing_gust` | Rajada de Asas |
| Ashwing | `aw_beak` | Bico Serrilhado | `hooked_strike` | Golpe de Bico |
| Ashwing | `aw_talons` | Garra Incandescente | `dive_talons` | Mergulho |
| Ashwing | `aw_gland` | Núcleo de Brasa | `ember_burst` | Explosão de Brasa |
| Stormtalon | `st_crest` | Crista Flamejante | `bristling_crest` | Crista Eriçada |
| Stormtalon | `st_eye` | Olho de Cinza | `ash_gaze` | Olhar de Cinza |
| Stormtalon | `st_tail` | Cauda de Fogo | `fire_lash` | Chicote de Fogo |
| Roca de Brasa | `er_heart` | Coração de Brasa | `molten_heart` | Coração Fundido |
| Roca de Brasa | `er_wing` | Asa Carbonizada | `molten_wing` | Asa em Chamas |
| Roca de Brasa | `er_crown` | Coroa de Cinzas | `ash_crown` | Coroa de Cinzas |

**Monstros extras** (partes e cartas ainda pendentes: pedidos 1 e 2)

| Monstro | Papel |
|---|---|
| Fogo-Fátuo de Esporos (`spore_wisp`) | comum, vem em dupla |
| Carregador de Esporos (`spore_carrier`) | comum |
| Cervo de Esporos (`spore_stag`) | elite |

**Híbridas**

| Arquivo | Carta | Combinação |
|---|---|---|
| `hb_rot_bloom` | Flor da Podridão | Sporemaw + Rotwalker |
| `hb_void_spores` | Esporos do Vazio | Sporemaw + Voidspawn |
| `hb_moss_plate` | Placa Micélica | Sporemaw + Ironback |
| `hb_blood_mold` | Mofo Sanguíneo | Sporemaw + Bloodfang |
| `hb_ember_fang` | Presa de Brasa | Ashwing + Bloodfang |
| `hb_kiln_shell` | Casco de Forno | Ashwing + Ironback |
| `hb_void_feather` | Pena do Vazio | Ashwing + Voidspawn |
| `hb_burning_spores` | Esporos Ardentes | Ashwing + Sporemaw |

### O que veio a mais (não pedido)

Tudo em `assets/art/extra/fases34/`, fora do jogo por enquanto. Não precisa pedir de novo.

| Onde | O que é | Avaliação |
|---|---|---|
| `monstros_bonus/` | 4 variações do Sporemaw (os 3 monstros extras já foram para o jogo) | **Estilo certo.** Só para consulta |
| `neon/mutacoes_mu3/` | 8 ícones de mutação | **Fugiu muito**: neon sobre fundo preto |
| `neon/ui3/`, `neon/ui4/` | 12 ícones de interface + 12 de status | **Fugiu muito**: neon sobre fundo preto. Os ícones atuais do jogo continuam |
| `refazer/cartas_c7/`, `refazer/mutacoes_mu2/` | Primeiras versões neon de C7 e MU2 | **Fugiu do estilo**: já substituídas |
| `fundos/spore_battle_02.png` | Bosque roxo | Estilo aceitável, mas o roxo se confunde com o Voidspawn |
| `fundos/battle_*_v2.png` | Novas versões dos 4 fundos neutros | Mais vivos que os atuais; mantive os atuais, porque o combate pede fundo discreto |
| `folhas/` | As pranchas originais, usadas como anexo em alguns pedidos | Só para consulta |

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
