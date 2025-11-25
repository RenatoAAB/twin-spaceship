# Sistema de Feedback

Este sistema permite configurar áudio, partículas e feedback visual para as entidades do jogo.

## Estrutura

- **autoloads/AudioManager.gd**: Gerenciador global de áudio. Registrado como Autoload.
- **components/SoundComponent.gd**: Componente para configurar sons de movimento, tiro, hit, destruição e habilidades.
- **components/ParticleSpawnerComponent.gd**: Componente para configurar cenas de partículas para hit e destruição.
- **components/FeedbackComponent.gd**: Componente para feedback visual (flash de cor, shake de tela).
- **ui/HealthBar.tscn**: Barra de vida reutilizável.
- **shaders/Distortion.gdshader**: Shader de distorção para ondas de choque.
- **particles/DistortionRing.tscn**: Cena pronta para instanciar ondas de choque.

## Como Configurar

### 1. Áudio

1.  Selecione a cena da nave ou inimigo (ex: `FighterShip.tscn`).
2.  Encontre o nó `SoundComponent`.
3.  No Inspector, arraste os arquivos de áudio (`.wav`, `.ogg`) para os campos correspondentes (`Move Sound`, `Shoot Sound`, etc.).
4.  Ajuste `Pitch Randomness` para variar o tom dos sons.

### 2. Partículas

1.  Crie cenas de partículas (GPUParticles2D ou CPUParticles2D) e salve na pasta `particles/`.
    *   Certifique-se de que as partículas tenham `One Shot` ativado se forem explosões.
    *   Se a partícula não se destruir sozinha, adicione um script para `queue_free()` após o término.
2.  Selecione a cena da nave ou inimigo.
3.  Encontre o nó `ParticleSpawnerComponent`.
4.  Arraste as cenas de partículas (`.tscn`) para os campos `Hit Particles` ou `Destroy Particles`.

### 3. Feedback Visual (Flash/Shake)

1.  O `FeedbackComponent` já está configurado para piscar o sprite e tremer a câmera ao receber dano.
2.  Você pode ajustar a cor do flash (`Flash Color`) e a intensidade do shake (`Shake Intensity`) no Inspector.

### 4. Barra de Vida

1.  A `HealthBar` já foi adicionada às naves.
2.  Ela se conecta automaticamente ao `HealthComponent`.

### 5. Distorção (Onda de Choque)

1.  Para criar uma onda de choque, instancie a cena `res://particles/DistortionRing.tscn`.
2.  Exemplo de uso em código:
    ```gdscript
    var distortion = preload("res://particles/DistortionRing.tscn").instantiate()
    distortion.global_position = global_position
    get_tree().current_scene.add_child(distortion)
    ```

### 6. Sistema de Música Trance

Para criar um efeito de "Trance" onde os sons se tornam música:

1.  **MusicController**: Um novo autoload que gerencia o BPM global.
    *   Acesse `autoloads/MusicController.gd` para ajustar o BPM (padrão 120).
2.  **Quantização**:
    *   No `SoundComponent`, ative a opção `Quantize`.
    *   Isso fará com que os sons de habilidades ou tiros esperem a próxima batida para tocar, garantindo que fiquem no ritmo.
    *   *Nota*: Isso introduz um pequeno atraso entre o input e o som, o que é normal para aplicações musicais, mas use com cuidado em mecânicas de twitch reaction.
3.  **Sons Musicais**:
    *   Use samples de sintetizadores, baixos ou percussão para os sons de `Ability 1` e `Ability 2`.
    *   Quando você usar as habilidades repetidamente, elas criarão uma melodia ou ritmo sincronizado.
