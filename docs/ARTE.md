# MONSTER DISSECTION: pedido de arte

O jogo já usa as imagens sozinho: basta salvar cada arquivo com o **nome exato** indicado, na pasta indicada,
e abrir o projeto no editor do Godot uma vez (ele importa as imagens). Arquivo que faltar continua com o
desenho provisório, então dá para entregar aos poucos.

```
assets/art/monsters/<id>.png   retratos de monstros      (10, obrigatório)
assets/art/cards/<id>.png      ilustrações das cartas    (43, obrigatório)
assets/art/parts/<id>.png      ícones das partes         (30, obrigatório)
assets/art/events/<id>.png     ilustrações de eventos    (6, opcional)
assets/art/mutations/<id>.png  ícones de mutações        (7, opcional)
```

São aceitos `.png`, `.jpg` e `.webp`. As versões aprimoradas ("+") das cartas usam a mesma imagem.

---

## 1. Estilo comum (cole antes de todo prompt)

> **STYLE:** dark fantasy naturalist illustration, a 19th-century anatomical plate merged with a grim monster-hunter's
> field journal. Painterly ink and watercolor wash on aged paper texture, visible brush and pen strokes, heavy
> shadows, grounded and believable anatomy, unsettling but not gory-splatter. Muted palette: charcoal #24272A,
> aged paper #CDC3AB, bone #AE8B52, with the accent color given per item. No text, no letters, no numbers,
> no watermark, no signature, no frame, no border, no UI elements.

**Cores de destaque por família** (use no lugar de `<ACCENT>`):

| Família | Destaque | Sensação |
|---|---|---|
| Bloodfang (predadores) | blood red #8F3439 / #C2474D | carne, sangue, ferocidade |
| Ironback (insetos blindados) | moss green #677D5B + dark iron | quitina, ácido, peso |
| Voidspawn (aberrações) | violet #704E84 / #A27BBB | olhos, tentáculos, frio, irreal |
| Rotwalker (mortos-vivos) | sickly green #8C9A5B + yellowed flesh | podridão, suturas, regeneração |
| Neutra (ferramentas do caçador) | bone #AE8B52 + steel | bisturis, anotações, técnica |

**Regras:**

- Não imitar nenhum jogo, artista ou franquia existente.
- Mantenha o mesmo estilo em todas as imagens: gere uma, aprove e use-a como referência para as outras.

---

## 2. Especificações técnicas

| Tipo | Proporção | Tamanho sugerido | Fundo | Como aparece no jogo |
|---|---|---|---|---|
| Monstros | **4:3 horizontal** | 1600×1200 | **transparente** | Grande, no combate (300×220 a 400×300 em 720p), no arquivo e na dissecação |
| Cartas | **16:9 horizontal** | 1344×768 (mín. 960×540) | opaco, imagem até a borda | **Pequeno**: cerca de 135×75 na carta |
| Partes | **1:1** | 1024×1024 (mín. 512) | **transparente** | De 26×26 (prateleira) até 120×110 |
| Eventos | 1:1 | 1024×1024 | opaco | 380×380 |
| Mutações | 1:1 | 1024×1024 | transparente | 90×90 |

### Monstros

- O corpo inteiro aparece, com margem de uns 5% em volta.
- **O monstro olha para a ESQUERDA**, porque o jogador fica à esquerda da tela. A vista é de perfil ou 3/4.
- As patas ficam perto da base da imagem, a uns 90% da altura.
- Sem chão, sem cenário e sem sombra projetada.

### Cartas

A imagem fica **muito pequena** na carta. Por isso:

- um único assunto, centralizado;
- silhueta forte e alto contraste;
- nada de detalhes miúdos.

### Partes

- Um espécime isolado, como numa prancha anatômica: centralizado, sem fundo.
- Ocupa uns 80% do quadro.

### Fundo transparente

Se a IA não gerar transparência, peça um **fundo cinza liso** e remova depois com um removedor de fundo
(remove.bg, Photoshop etc.).

### Pontos de dissecação

Na dissecação, o jogo marca 4 regiões em cima do retrato: **Cabeça, Tórax, Membros e Fluidos**. Siga a
composição descrita em cada monstro. Depois que as imagens chegarem, eu calibro os pontos exatos no campo
`region_anchors` de cada monstro.

---

## 3. Monstros (10): `assets/art/monsters/`

Cada prompt: **STYLE** + **"Full-body creature portrait, facing left, isolated on transparent background."** + a descrição abaixo.

| Arquivo | Nome no jogo | Descrição para o prompt | Composição (cabeça · tórax · membros · fluidos) |
|---|---|---|---|
| `bloodfang.png` | Bloodfang | Lean quadruped predator, wolf-hyena-like but wrong: tall hunched shoulders, disproportionately large jaw with serrated fangs, short scarred hide, blood-red accents (#8F3439), silent stalking pose. | cabeça à esquerda (≈20%, 45%) · tronco ao centro-direita · patas embaixo · coração/sangue no peito |
| `bloodfang_pup.png` | Filhote de Bloodfang | Young Bloodfang: smaller, gangly, oversized paws and jaw, fewer scars, playful but hungry pose. Blood-red accents. | igual ao Bloodfang |
| `bloodfang_alpha.png` | Bloodfang Alfa *(elite)* | Massive pack-leader Bloodfang covered in dozens of old scars, mane of bristling bone spines along the neck and back, heavier jaw, mid-lunge stance. Deep blood-red accents. | igual ao Bloodfang |
| `ironback.png` | Ironback | Boar-sized armored insect/beetle: overlapping iron-hard chitin plates, spikes on the carapace, heavy mandibles, six thick legs, a translucent green acid sac at the rear. Moss green and dark iron (#677D5B). | cabeça/mandíbula à esquerda (≈15%, 55%) · carapaça no centro · patas embaixo · glândula ácida na traseira, à direita (≈80%, 55%) |
| `iron_colossus.png` | Colosso Ironback *(chefe)* | Ancient colossal Ironback, many times larger: carapace caked with centuries of dried mud and rust (warm brown-orange tones), one enormous battering-ram horn, a cracked iron core glowing faintly between plates. | igual ao Ironback |
| `voidspawn.png` | Voidspawn | Asymmetric aberration: a lumpy body with many mismatched eyes staring in different directions, writhing tentacles instead of legs, cold violet glow (#704E84), skin like wet slate. | olhos/cabeça no alto-centro (≈45%, 40%) · corpo no centro · tentáculos embaixo · icor violeta à direita-baixo |
| `void_matriarch.png` | Matriarca do Vazio *(chefe)* | Towering mother-aberration, roughly symmetrical and frontal: a crown of eye-stalks on top, a translucent belly with a pulsing violet core visible inside, thick mother-tentacles spreading at the base, smaller spawn clinging to her. | coroa de olhos no topo (≈50%, 17%) · núcleo no centro · tentáculos embaixo · fluido à direita |
| `rotwalker.png` | Rotwalker | Upright walking corpse, gaunt humanoid, grey-green rotting skin, wounds visibly knitting closed with fresh pink flesh, dragging one arm, yellowed eyes. Sickly green accents (#8C9A5B). | cabeça no alto-esquerda (≈37%, 33%) · tronco no centro · pernas embaixo · bile/barriga no centro |
| `stitched_abomination.png` | Abominação Costurada *(elite)* | Hulking mass of several corpses crudely stitched together with thick black sutures and iron staples, extra arms, mismatched skin tones, three hearts bulging under a stitched chest. Sickly green and flesh tones. | igual ao Rotwalker, maior |
| `ghoul.png` | Carniçal | Low crawling ghoul on all fours, emaciated, long fingers, rotten teeth, head low and forward, catacomb-dweller pallor. Sickly green accents. | cabeça baixa à esquerda (≈27%, 62%) · corpo ao centro · membros embaixo · fluidos à direita |

---

## 4. Cartas (43): `assets/art/cards/`

Cada prompt: **STYLE** + **"Small card illustration, single centered subject, bold silhouette, high contrast, 16:9."** + accent + descrição.

Tipos: Ataque, Defesa, Habilidade e Mutação. Nas **híbridas**, misture as duas cores de destaque.

### Neutras (ferramentas do caçador): destaque bone #AE8B52

| Arquivo | Carta | Tipo | Descrição |
|---|---|---|---|
| `scalpel_cut.png` | Corte de Bisturi | Ataque | A surgical scalpel slicing through the air, a thin arc of blood following the blade. |
| `double_scalpel.png` | Bisturi Duplo | Ataque | Two crossed scalpels mid-strike, twin slash marks. |
| `incision.png` | Incisão Precisa | Ataque | Gloved hand making a precise incision along a dotted line on hide, pinned specimen style. |
| `guard.png` | Postura de Guarda | Defesa | Hunter's leather-wrapped forearm raised with a bone bracer, defensive stance. |
| `field_notes.png` | Anotações de Campo | Habilidade | Open blood-stained field journal with anatomical sketches, quill and pinned specimen. |

### Bloodfang: destaque blood red

| Arquivo | Carta | Tipo | Descrição |
|---|---|---|---|
| `deep_bite.png` | Mordida Profunda | Ataque | Serrated fangs sinking deep, blood welling from channels in the teeth. |
| `rend.png` | Rasgar | Ataque | Three curved claws tearing downward, ragged red slash marks. |
| `pack_lunge.png` | Investida da Matilha | Ataque | Several predator silhouettes lunging together from the dark. |
| `predatory_pulse.png` | Pulso Predatório | Ataque | A four-chambered heart beating violently, red pulse waves. |
| `hematic_fury.png` | Fúria Hemática | Habilidade | Boiling blood rising like steam from a clenched clawed hand. |
| `hunters_sight.png` | Visão do Caçador | Habilidade | Vertical-pupil predator eye reflecting a red target. |
| `reflex.png` | Reflexo Muscular | Habilidade | Taut tendons and muscle fibers snapping like bowstrings. |
| `tough_hide.png` | Couro Resistente | Defesa | Scarred stretched hide deflecting a blade. |
| `bloodthirst.png` | Sede de Sangue | Mutação | A human arm with predator veins and claws erupting, dripping blood. |

### Ironback: destaque moss green + iron

| Arquivo | Carta | Tipo | Descrição |
|---|---|---|---|
| `acid_gland.png` | Glândula Ácida | Ataque | Green acid sac bursting, droplets corroding metal. |
| `chitin_charge.png` | Investida Quitinosa | Ataque | Armored dorsal plates ramming forward like a battering ram. |
| `colossal_horn.png` | Chifrada Colossal | Ataque | Enormous horn smashing through a stone wall. |
| `carapace_plate.png` | Placa de Carapaça | Defesa | A single overlapping chitin plate used as a shield. |
| `iron_bastion.png` | Bastião de Ferro | Defesa | Wall of interlocking carapace plates, impenetrable. |
| `reactive_mandible.png` | Mandíbula Reativa | Habilidade | Insect mandibles snapping shut on a blade. |
| `endoskeleton.png` | Endoesqueleto | Mutação | Human ribcage reinforced with insect chitin growing over the bones. |

### Voidspawn: destaque violet

| Arquivo | Carta | Tipo | Descrição |
|---|---|---|---|
| `tentacle_grip.png` | Aperto Tentacular | Ataque | Suckered tentacle coiling and squeezing. |
| `tide_of_void.png` | Maré do Vazio | Ataque | A wave of violet tentacles surging out of darkness. |
| `corrupting_touch.png` | Toque Corruptor | Ataque | Violet ichor spreading through veins from a single touch. |
| `void_eyes.png` | Olhos do Vazio | Habilidade | Cluster of mismatched eyes, each looking a different way. |
| `unstable_core.png` | Núcleo Instável | Habilidade | Pulsing violet organ crackling with unstable light. |
| `abyssal_gaze.png` | Contemplar o Abismo | Mutação | A human face with a crown of eye-stalks sprouting from the skull, staring into darkness. |

### Rotwalker: destaque sickly green

| Arquivo | Carta | Tipo | Descrição |
|---|---|---|---|
| `infected_bite.png` | Mordida Infecta | Ataque | Rotten teeth biting, feverish green miasma. |
| `necrotic_bile.png` | Bile Necrótica | Ataque | Yellow-green bile splashing and blistering flesh. |
| `dry_sinew.png` | Tendões Secos | Defesa | Dried unbreakable sinew wrapped around a forearm like armor. |
| `field_suture.png` | Sutura de Campo | Habilidade | Crude black stitches closing a wound, curved needle. |
| `regenerative_flesh.png` | Carne Regenerativa | Habilidade | Pink flesh visibly knitting over a cut. |
| `marrow_spark.png` | Medula Energética | Habilidade | Split bone revealing warm glowing dark marrow. |
| `muscle_memory.png` | Memória Muscular | Habilidade | Shrunken brain with twitching nerve threads still firing. |
| `rot_pulse.png` | Pulso Pútrido | Mutação | A rotting heart grafted into a human chest, still beating, green glow. |

### Híbridas: duas cores de destaque

| Arquivo | Carta | Tipo | Famílias | Descrição |
|---|---|---|---|---|
| `hb_armored_heart.png` | Coração Blindado | Defesa | Bloodfang + Ironback | A red beating heart encased in chitin plates. |
| `hb_chitin_maw.png` | Bocarra Quitinosa | Ataque | Ironback + Bloodfang | Insect mandibles lined with serrated predator fangs. |
| `hb_corrosive_fang.png` | Presa Corrosiva | Ataque | Bloodfang + Ironback | A fang dripping green acid instead of blood. |
| `hb_hematic_tide.png` | Maré Hemática | Ataque | Bloodfang + Voidspawn | Tentacles made of blood, red-violet tide. |
| `hb_void_claws.png` | Garras do Vazio | Ataque | Bloodfang + Voidspawn | Predator claws trailing violet void energy. |
| `hb_living_shell.png` | Casca Viva | Defesa | Ironback + Rotwalker | Carapace plates growing out of regenerating rotten flesh. |
| `hb_necro_oracle.png` | Oráculo Necrótico | Habilidade | Voidspawn + Rotwalker | Shrunken brain sprouting violet eyes. |
| `hb_void_marrow.png` | Medula do Vazio | Habilidade | Voidspawn + Rotwalker | Split bone with violet glowing marrow. |

---

## 5. Partes anatômicas (30): `assets/art/parts/`

Cada prompt: **STYLE** + **"Single anatomical specimen, scientific plate illustration, centered, isolated on transparent background, 1:1."** + accent + descrição.

| Arquivo | Parte | Família | Descrição |
|---|---|---|---|
| `bf_fangs.png` | Presas | Bloodfang | Pair of serrated fangs with blood channels. |
| `bf_claws.png` | Garras | Bloodfang | Three curved claws, severed at the base. |
| `bf_eyes.png` | Olhos | Bloodfang | Pair of eyes with vertical pupils, red sclera. |
| `bf_heart.png` | Coração | Bloodfang | Four-chambered predator heart. |
| `bf_hide.png` | Pele | Bloodfang | Folded square of short scarred hide. |
| `bfa_blood.png` | Sangue Fervente | Bloodfang | Glass vial of steaming dark blood. |
| `bfa_claws.png` | Garras do Alfa | Bloodfang | Huge worn claws, chipped and scarred. |
| `bfa_heart.png` | Coração do Alfa | Bloodfang | Oversized heart, larger than a fist, scarred. |
| `bfa_tendons.png` | Tendões | Bloodfang | Coiled taut tendons like bowstrings. |
| `ib_carapace.png` | Carapaça | Ironback | Overlapping chitin plate section. |
| `ib_endo.png` | Endoesqueleto | Ironback | Insect-like internal ribcage frame. |
| `ib_gland.png` | Glândula Ácida | Ironback | Translucent sac of green acid. |
| `ib_mandible.png` | Mandíbula | Ironback | Pair of heavy insect mandibles. |
| `ib_plates.png` | Placas Dorsais | Ironback | Heavy stacked dorsal plates. |
| `co_core.png` | Núcleo de Ferro | Ironback | Massive iron-dark core with rust and mud. |
| `co_horn.png` | Chifre Colossal | Ironback | Giant cracked battering-ram horn. |
| `vs_eyes.png` | Olhos Múltiplos | Voidspawn | Cluster of mismatched eyes on a membrane. |
| `vs_ichor.png` | Icor Violeta | Voidspawn | Vial of cold glowing violet fluid. |
| `vs_tentacles.png` | Tentáculos | Voidspawn | Coiled suckered tentacle in a jar. |
| `vm_core.png` | Núcleo do Vazio | Voidspawn | Strange glowing violet organ, faint whisper aura. |
| `vm_crown.png` | Coroa de Olhos | Voidspawn | Ring of eye-stalks arranged like a crown. |
| `vm_tentacles.png` | Tentáculos-Mãe | Voidspawn | Thick trunk-like wet tentacle. |
| `rw_flesh.png` | Carne | Rotwalker | Chunk of grey-green flesh with a wound closing. |
| `rw_bile.png` | Bile | Rotwalker | Vial of yellowish bile. |
| `rw_brain.png` | Cérebro | Rotwalker | Shrunken shriveled brain. |
| `rw_marrow.png` | Medula | Rotwalker | Split bone with dark marrow. |
| `gh_teeth.png` | Dentes Podres | Rotwalker | Handful of rotten pointed teeth. |
| `gh_sinew.png` | Tendões Secos | Rotwalker | Dried leathery sinew bundle. |
| `ab_heart.png` | Coração Costurado | Rotwalker | Three hearts stitched into one with black sutures. |
| `ab_stitches.png` | Suturas | Rotwalker | Strip of skin with crude black stitches and staples. |

---

## 6. Opcional: eventos (6): `assets/art/events/`

Cada prompt: **STYLE** + **"Square scene illustration, dark moody environment, 1:1."** + descrição.

| Arquivo | Evento | Descrição |
|---|---|---|
| `ev_bone_altar.png` | Altar de Ossos | An altar of stacked ribs in a misty bog, rotting old offerings at its base. Sickly green. |
| `ev_hermit.png` | Eremita Alquimista | An old hermit mixing boiling flasks over a blue campfire in the dark. Petrol blue. |
| `ev_ironback_nest.png` | Ninho de Ironback | Metallic-shelled eggs, still warm, nested among gnawed bones. Moss green. |
| `ev_old_carcass.png` | Carcaça Antiga | A days-dead predator half-buried in peat, hide still intact. Blood red. |
| `ev_violet_pool.png` | Poça Violeta | Cold luminous violet liquid seeping from a rock crack, flowing upward against gravity. |
| `ev_wounded_researcher.png` | Pesquisador Ferido | A wounded researcher slumped against a dead tree, clutching a blood-stained notebook. Bone tones. |

## 7. Opcional: mutações (7): `assets/art/mutations/`

Cada prompt: **STYLE** + **"Icon of a creature organ grafted into human anatomy, isolated on transparent background, 1:1."** + descrição.

| Arquivo | Mutação | Descrição |
|---|---|---|
| `mut_bf_heart.png` | Coração de Bloodfang | Predator heart grafted into a human chest. Blood red. |
| `mut_bfa_blood.png` | Sangue do Alfa | Human veins glowing with boiling red blood. |
| `mut_ib_shell.png` | Couraça de Ironback | Chitin plates growing over human shoulders. Moss green. |
| `mut_co_plates.png` | Placas de Colosso | Heavy rusted colossus plates fused onto a human torso. |
| `mut_vs_eyes.png` | Olhos de Voidspawn | Extra violet eyes opening along a human arm. |
| `mut_vm_core.png` | Núcleo Transplantado | Glowing violet core embedded in a human sternum. |
| `mut_rw_blood.png` | Sangue de Rotwalker | Human hand with green veins, a wound stitching itself closed. |

---

## Checklist de entrega

- [ ] Nomes de arquivo exatamente como nas tabelas (minúsculas, com `_`).
- [ ] Monstros e partes com fundo transparente.
- [ ] Monstros olhando para a esquerda, corpo inteiro, em 4:3.
- [ ] Cartas em 16:9, assunto único e legível em tamanho pequeno.
- [ ] Mesmo estilo em todas as imagens.
- [ ] Depois de colocar os arquivos, abrir o projeto no editor do Godot (importação) e pedir a calibração dos
      pontos de dissecação dos monstros.
