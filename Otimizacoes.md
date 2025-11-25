# Otimizações para Mundos Abertos Massivos em Godot 4

Para criar uma sensação de imensidão espacial sem sacrificar a performance, é necessário gerenciar cuidadosamente como o jogo processa o que o jogador vê e o que está "existindo" longe dele.

## 1. Floating Origin (Origem Flutuante)
O maior problema técnico em mapas gigantescos é a **precisão de ponto flutuante**. À medida que as coordenadas (X, Y) ficam muito grandes (ex: 1.000.000), a precisão diminui, causando "jitter" (tremor) nos sprites e física quebrada.

*   **Solução:** Periodicamente, quando a nave do jogador se afasta muito da origem (0,0), você deve mover todos os objetos do mundo de volta para perto da origem e resetar a posição do jogador.
*   **Implementação:** Crie um script global que monitora a posição. Se `player.global_position.length() > threshold`, subtraia esse offset de **todos** os nós raiz do jogo.

## 2. Sistema de Chunks (Pedaços) e Carregamento Dinâmico
Não tente carregar o universo inteiro. Divida o espaço em uma grade (grid).
*   **Lógica:** Apenas os chunks ao redor do jogador (ex: 3x3 grids) devem estar ativos na memória.
*   **Background Loading:** Use `ResourceLoader.load_threaded_request` para carregar cenas de planetas ou estações espaciais pesadas antes do jogador chegar lá, evitando travamentos (stuttering).

## 3. Renderização e Visibilidade
O Godot desenha tudo que está na árvore de cena, a menos que seja instruído o contrário.
*   **VisibleOnScreenEnabler2D / VisibleOnScreenNotifier2D:** Adicione este nó aos seus inimigos, asteroides e projéteis.
    *   Configure para `Process Mode = When Visible`. Isso faz com que a lógica (physics_process) e animações parem automaticamente quando o objeto sai da tela, economizando muita CPU.
*   **Shaders para Estrelas:** Em vez de criar 10.000 nós de Sprite para estrelas de fundo, use um único `ColorRect` cobrindo a tela com um **Shader** que gera estrelas baseadas em ruído (Noise). Isso custa quase zero de performance e permite zoom infinito sem perda de qualidade.

## 4. Física e Colisões
*   **Desativar Física Distante:** Inimigos muito longe não precisam rodar `move_and_slide()`. Se o jogador fugir e o inimigo ficar a 5000 pixels de distância, desative o processamento dele ou delete-o (pooling).
*   **Simplificação de Colisores:** Use `CircleShape2D` e `CapsuleShape2D` sempre que possível. `CollisionPolygon2D` complexos são muito mais caros para calcular.

## 5. Object Pooling (Reutilização de Objetos)
Em um jogo "Twin Stick Shooter", você terá milhares de tiros.
*   **Problema:** `instantiate()` e `queue_free()` geram lixo de memória e fragmentação.
*   **Solução:** Crie um "Pool" (piscina) de projéteis. Quando um tiro "morre", ele apenas fica invisível e inativo. Quando alguém atira, você pega um tiro inativo e o reativa. Isso mantém a memória estável.

## 6. Servidor de Física (PhysicsServer2D)
Para enxames de inimigos ou asteroides (ex: 500+ objetos), considere não usar nós (`Node2D`, `CharacterBody2D`).
*   Use o `PhysicsServer2D` e `RenderingServer` diretamente. É uma técnica avançada, mas permite desenhar e colidir milhares de objetos com performance extrema, pois ignora o overhead da árvore de nós do Godot.
