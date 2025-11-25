# Considerações de Design: A Imensidão do Espaço

Criar um jogo onde o jogador se sente "pequeno" e "sozinho" exige trabalhar a atmosfera e o ritmo (pacing). O tédio da viagem deve ser transformado em tensão ou preparação.

## 1. A Dinâmica Cargueiro (Tank) vs Escolta (Fighter)
Essa assimetria é o coração do seu jogo.
*   **O Cargueiro (A Base Móvel):**
    *   Não deve ser apenas uma "vaca gorda" lenta. Dê ao jogador coisas para fazer durante a viagem.
    *   **Gerenciamento:** Redirecionar energia (Escudos vs Motores), reparar danos internos, fabricar munição para a escolta.
    *   **Radar:** O Cargueiro deve ter o radar de longo alcance. Ele "vê" o perigo antes da Escolta. O jogador do Cargueiro é o "Navegador".
*   **A Escolta (O Batedor):**
    *   Deve ter liberdade para voar longe, mas um motivo para voltar.
    *   **Mecânica de Tether (Corda):** Se a escolta se afastar demais, o radar pifa, ou o escudo regenera mais devagar. Isso força a cooperação.
    *   **Dogfight:** Enquanto o cargueiro lida com a rota e a sobrevivência, a escolta lida com a ameaça imediata.

## 2. Navegação e "Fog of War" (Névoa de Guerra)
*   Não mostre o mapa todo. A imensidão vem do desconhecido.
*   **Sensores:** Use um sistema de "ping" (sonar). O jogador envia um pulso e recebe ecos vagos (ex: "Massa grande detectada a Leste"). Pode ser um asteroide rico em minérios ou uma nave pirata emboscada. A incerteza gera tensão.

## 3. O Ritmo da Viagem (Travel Gameplay)
Se os pontos de interesse estão longe, o que acontece no meio do caminho?
*   **Micro-eventos Ambientais:**
    *   *Campos de Destroços:* Requer navegação cuidadosa (o Cargueiro é lento e bate fácil).
    *   *Nebulosas:* Interferência no HUD, perda de radar, inimigos aparecem "do nada".
    *   *Sinais de Rádio:* Captar transmissões fragmentadas que contam a história do mundo (Lore) sem interromper o gameplay.
*   **Manutenção:** A viagem é o momento de curar a nave. O combate desgasta a blindagem, a viagem permite o reparo.

## 4. Escala Visual e Sonora
*   **Câmera Dinâmica:**
    *   *Combate:* Zoom in, focado na ação, câmera tremendo, claustrofóbico.
    *   *Viagem:* Zoom out massivo. A nave fica minúscula na tela, o fundo se move devagar (efeito parallax). Isso visualmente vende a ideia de "estamos viajando grandes distâncias".
*   **Áudio:**
    *   O som é crucial. No combate: música intensa, explosões.
    *   Na viagem: Apenas o zumbido grave dos motores e o som do casco estalando. O silêncio enfatiza a solidão.

## 5. Pontos de Interesse (POIs) Significativos
Como os eventos são raros, eles devem ser impactantes.
*   **Não use "Trash Mobs" aleatórios:** Se aparecer um inimigo no meio do nada, deve haver um motivo. É um batedor? Um pirata perdido?
*   **Derelicts (Naves Abandonadas):** Encontrar uma nave gigante flutuando sem energia. O jogador deve decidir: parar o cargueiro (vulnerável) para a escolta investigar e saquear, ou seguir em frente seguro? Risco vs Recompensa.

## 6. UI Diegética
Tente colocar as informações no mundo do jogo, não apenas coladas na tela.
*   Hologramas na nave, luzes de alerta no painel. Isso aumenta a imersão de estar "dentro" de uma máquina complexa viajando pelo vazio.
