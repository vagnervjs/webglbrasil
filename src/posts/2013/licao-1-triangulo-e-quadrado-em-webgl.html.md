---
layout: post
title: "Lição 1 – Um Triângulo e um Quadrado"
date: 2013-06-02
category: licoes
description: 

referenceOthers: false
---

Bem vindo ao nosso primeiro tutorial de WebGL! A primeira lição é baseada na lição número 2 do tutorial NeHe OpenGL, que é uma forma muito popular de aprender gráficos 3D para desenvolvimento de jogos. Ele irá mostrar a você como desenhar um triângulo e um quadrado em uma página web. Talvez não seja tão excitante, mas é uma ótima forma de introdução aos fundamentos de WebGL; se você entender como isso funciona, o restante será bastante simples...
Aqui está o que está lição irá mostrar quando executado em um navegador com suporte ao WebGL:

<img src="http://learningwebgl.com/lessons/lesson01/static.png" alt="Triângulo e Quadrado em WebGL">

Mais informações sobre como tudo funciona a seguir...
Um aviso rápido: estas lições são recomendadas para pessoas com habilidades razoáveis de conhecimento em programação, mas não é exigido nenhuma experiência real com gráficos 3D; 
O objetivo é entregar para você e em funcionamento, com um bom entendimento do que está acontecendo no código, para que você possa começar produzir seus próprios experimentos de páginas Web em 3D o mais rápido possível. Estou escrevendo essas lições da forma como eu aprendi WebGL por conta própria, portanto, pode haver (e provavelmente haverá) erros; use por sua conta em risco =D (original). No entanto, estou consertando os bugs e corrigindo os equívocos de correção assim que forem encontrados, então se você encontrar qualquer coisa com problemas, fale sobre isso nos comentários.

Há duas formas que você pode obter o código para este exemplo, a primeira é vendo o código direto no seu navegador (ctrl+u ou inspecionar elemento por exemplo no Google Chrome) quando estiver visualizando a página do exemplo real, ou se você usar o GitHub, pode cloná-la (essa, e as lições futuras) do repositório lá. De qualquer maneira, assim que você tiver o código, abra em seu edito de texto preferido e dê uma olhada. 
É meio assustador a primeira vista, mesmo se você tiver um conhecimento com OpenGL. Logo no início, estamos definindo um par de shaders, e isso é geralmente considerado como algo relativamente avançado... mas não se desespere, é realmente muito mais simples do que parece.
Como muitos programas, esta página WebGL começa pela definição de um grupo de funçções de baixo nível, que são utilizadas pelo código de alto nível na parte inferior. Para explicar isso, vou começar de baixo para cima, e trabalhar da minha forma, por isso, se você está acompanhando pelo código, pule para a parte inferior.
Você verá o seguinte código HTML:

```html 
<body onload="webGLStart();"> 
	...
</body>
```

Este é o corpo completo da página – todo o resto é em JavaScript (se você estiver vendo o código através do navegador pode haver algum lixo extra, ignore isso por favor). Obviamente poderíamos colocar mais HTML dentro da tag <body> e construir nossa imagem WebGL em uma página web normal, mas para esta demonstração simples iremos utilizar apenas o necessário para visualizar o conteúdo em WebGL, e a tag ```<canvas>``` será a responsável por este feito, é nela onde os gráficos em 3D são carregados. Canvas é uma novidade do HTML5 – é ele que suporta novos gêneros do JavaScript  para desenhar elementos em páginas web, tanto em 2D quanto em 3D (através do WebGL). Nós não especicamos nada mais do que as propriedades de layout simples da tela em sua tag, e deixamos  todo o código de configuração do WebGL para uma função JavaScript chamada webGLStart, que você pode ver é chamada uma vez que quando a página é carregada.
Vamos até essa função agora para dar uma olhada:

```javascript
function webGLStart()
```

Ela chama outras funções para inicializar o WebGL e os shaders que mencionei anteriormente, passando como parâmetro o elemento canvas sobre o qual queremos desenhar nosso conteúdo em 3D, e então ele inicializa alguns buffers usando a função initBuffers, buffers são coisas que guardam os detalhes do triangulo e do quadrado que vamos desenhar – falaremos mais sobre eles em um outro momento. Em seguida, é feito algumas configurações básicas do WebGL, dizendo que quando limpamos a tela deverá ficar preto, e que devemos fazer o teste de profundidade (para que as coisas desenhadas por trás de outras coisas deve ser escondidas pelas coisas na que estão na frente, entenderão certo?). Essas etapas são implementadas por chamadas a métodos em um objeto gl – vamos ver como que é inicializado mais tarde. Finalmente, chama-se a função drawScene; esta (como já é de se esperar pelo nome) desenha o triangulo e o quadrado, usando os buffers.

Vamos voltar para as funções initGL e initShaders mais tarde, pois elas são importante na compreensão de como a página funciona, mas, primeiro, vamos dar uma olhada nas funções initBuffers e drawScene.

initBuffers primeiro, fazendo passo a passo:

```javascript
var triangleVertexPositionBuffer;
var squareVertexPositionBuffer;
```

Declaramos duas variáveis globais para armazenar os buffers. (Em qualquer página de WebGL do mundo real você não teria uma variável global separada para cada objeto na cena, mas estamos usando aqui para manter as coisas simples, pois estamos apenas começando.)
Seguindo:

```javascript
function initBuffers() {
    triangleVertexPositionBuffer = gl.createBuffer();
}
```

Criamos um buffer para as posições dos vértices do triangulo. Vértices são os pontos no espaço 3D que definem as formas que estamos desenhando. Para o nosso triangulo, teremos três deles (que vamos definir em um minuto). Este buffer é na realidade um pouco de memória na placa de vídeo; colocando as posições dos vértices na placa em nosso código de inicialização e então, quando chegarmos a desenhar a cena, essencialmente, apenas dizendo ao WebGL para “desenhar aquelas coisas que eu lhe disse mais cedo”, podemos fazer o código muito eficiente, especialmente quando começar a animar a cena e desenhar objetos dezenas de vezes por segundo para fazer o movimento. É claro que, quando é apenas três posições dos vértices como neste caso, não há um custo muito alto para envia-los para a placa de vídeo – mas quando você estiver lidando com modelos grandes, com dezenas de milhares de vértices, pode ser um vantagem real fazer as coisas dessa forma. Continuando: 

```javascript
gl.bindBuffer(gl.ARRAY_BUFFER, triangleVertexPositionBuffer);
```