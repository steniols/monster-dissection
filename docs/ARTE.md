# MONSTER DISSECTION: arte

## Status: tudo pronto

| Grupo | Qtde | Situação |
|---|---|---|
| Monstros | 10 | **Pronto** (Carniçal refeito, rastejante) |
| Partes anatômicas | 30 | **Pronto** |
| Cartas | 43 | **Pronto** |
| Mutações | 7 | **Pronto** |
| Eventos | 6 | **Pronto** |
| Fundos (paisagens) | 6 | **Pronto** |

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

## Próximas artes possíveis

Precisam de um ajuste pequeno no código antes; me avise que eu preparo e escrevo os pedidos.

| Item | Onde aparece |
|---|---|
| O Pesquisador (personagem do jogador) | Combate, ao lado da vida; hoje é um vulto desenhado em código |
| Ícones das 6 estações do laboratório | Laboratório |

## Ferramentas (para mim)

- `tools/remove_bg.gd`: tira o fundo liso ou borrado de uma folha.
- `tools/slice_sheet.gd`: recorta uma folha pela ordem das figuras.
- `tools/crop_items.gd`: recorta por caixas marcadas à mão, para figuras encostadas.
