# Sobre o projeto

# AWG - Gerador de ondas arbitrárias
O awg é uma importante ferramenta de testes em circuitos pois é capaz de gerar sinais de tensão totalmente configurados pelo usuário. Assim, o objetivo deste trabalho foi
o desenvolvimento de um gerador de ondas arbitrárias de código aberto e controlado digitalmente por um aplicativo móvel, oferecendo uma alternativa aos geradores comerciais,
proporcionando maior mobilidade e possibilidade de replicação.
Para tal, foi desenvolvido um aplicativo para smartphone que permite a configuração dos sinais. Posteriormente o aplicativo realiza o envio dos dados via Bluetooth para um microcontrolador da família MSP430 onde a técnica de síntese digital direta (DDS, do inglês Direct Digital Synthesis) foi aplicada para a sintetização dos sinais. Além disso, foi implementado um estágio de saída com conversores digital para analógico, possibilitando o controle totalmente digital do AWG.
Entre o aplicativo e o microcontrolador empregou-se um Raspberry Pi Zero W para realizar a comunicação Bluetooth, acrescentando também um processamento dos dados e possibilitando grande diversidade de aplicações futuras utilizando o mesmo aplicativo.

Este repositório contém o projeto do aplicativo, código implementado em C no microcontrolador, código em Python desenvolvido para o Raspberry e ainda aquivos gerber e esquemético da PCB desenvolvida para o gerador.

## Controle Digital

O controle digital do sistema foi realizado por meio do microcontrolador MSP430F5529, programado em linguagem C através da IDE Code Composer Studio, fornecida em versão gratuita pela Texas Instruments.

O código CodigoMSP430.c implementa a técnica de Síntese Digital Direta (DDS) para a geração de sinais.
Utilizando o Banco D da memória flash do microcontrolador é implementada uma LUT de 14 bits, armazenando 16384 amostras do sinal que será gerado. Para o acumulador de fase (AF) é utilizada uma variável de 32 bits, onde apenas 19 bits são utilizados sendo que o 5 bits menos significativos são truncados. A ftw é descrita como uma variável de 16 bits.
As amostas do sinal são recebidas através do protocolo SPI por uma rotina de interrupção, da mesma forma que o valor de FTW. Tais amostras são então alocadas na LUT implementada.
Um ciclo de geração foi desenvolvido, permitindo que as amostas sejam enviadas para o DAC conectado em saidas do PORT A do microcontrolador.

## Raspberry Pi Zero W

O sistema operacional utilizado no raspberry foi o Raspbian e o codigo CodigoRASPBERRY.py foi desenvolvido na liguagem python, nativa do sistema Raspbian.
O Raspberry foi empregado como uma interface de comunicação entre o aplicativo e restante do hardware do gerador. Por conter um módulo Bluetooth e interfaces de comunicação serial integrados, o Raspberry é responsável por receber a lista de dados enviadas pelo aplicativo, em seguida transmitir as amostras para o microcontrolador através do protocolo SPI e enviar os valores de amplitude e offset para dois DACs no estágio de saída através do protocolo I2C. 

## Aplicativo 

O aplicativo foi desenvolvido no editor de código Visual Studio Code, pelas facilidades oferecidas no uso de bibliotecas e extensões. Por ser uma tendência no ramo de desenvolvimento mobile, buscando APPs mais rápidos e esteticamente melhorados, foi empregado o framework Flutter que utiliza a linguagem de programação Dart orientada a objetos e semelhante a linguagem C++.

No APP foram desenvolvidso telas que permitem ao usuário a configuração de sinais. Após isso, são geradas 16384 amostras que são enviadas por Bluetooth para o Raspberry Pi Zero W. Assim, o aplicativo é respponsável pelos processos de emparelhamento e conexão Bluetooth.
