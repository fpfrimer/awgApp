"""
Gerador de ondas abitrarias controlado por aplicativo movel
Codigo para Raspberry PI Zero W
Ano: 2021
Autores: Daiany Besen e Giovani Blanco Bartnik

Descricao: 
Codigo escrito em Python para Raspberry PI Zero W.
Faz conexao com um aplicativo mobile atraves do padrao de 
comunicacao Bluetooth. Apos a conexao realizada com exito 
o Raspberry recebe 16384 amostras do sinal, alem de valores 
de amplitude, offset e FTW. Com os pontos recebidos e tratados 
em uma lista, o codigo envia as amostras e o valor de FTW para 
o microcontrolador MSP430F5529 atraves do protocolode comunicacao
SPI e, atraves do protolo I2C, envia os valores de amplitude e offset para 
dois modulos DAC MCP4725.

"""

# bibliotecas utilizadas
import bluetooth
import spidev
import time
import smbus

# configuracoes do bluetooth
# endereco bluetooth do dispositivo (rasp)
hostMACAddress = 'B8:27:EB:38:9D:99'
port = 0
backlog = 1
size = 1024

# configuracoes do SPI
spi = spidev.SpiDev()
spi.open(0, 0)
spi.max_speed_hz = 3000000


# configuracoes do I2C
bus = smbus.SMBus(1)

# loop infinito que permite que o codigo nao feche ao
# desconectar um dispositivo
while 1:

    s = bluetooth.BluetoothSocket(bluetooth.RFCOMM)
    s.bind((hostMACAddress, bluetooth.PORT_ANY))
    print('Aguardado conexao...')
    s.listen(backlog)

    try:

        client, clientInfo = s.accept()
        print('Dispositivo conctado: ', clientInfo)
        i = 0
        amostrasSTR = ''
        compara = 0
        pontos0 = []
        pontos1 = []

        while 1:

            # recebe um parcela dos pontos no formato sring
            str = client.recv(size)
            # a cada iteracao concatena os pendacos da string
            amostrasSTR = amostrasSTR + str
            tamanhoSTR = len(amostrasSTR)
            i = 0

            # se o ultimo caractere foi ] chegou ao fim dos pontos
            if (amostrasSTR[tamanhoSTR-1] == ']'):

                # tira espacos e colchetes da string
                recebidoNOVO1 = amostrasSTR.replace(" ", "")
                recebidoNOVO2 = recebidoNOVO1.replace("[", "")
                recebidoNOVO3 = recebidoNOVO2.replace("]", "")
                # separa a sring nas virgulas. Retorna tipo lista
                pontos = recebidoNOVO3.split(',')

                amostrasSTR = ''

                # esta estrutura compara se recebeu amostras novas ou so alterou ftw
                if (int(compara) == 0):
                    pontos0 = pontos[0:16384]
                    compara = 1
                else:
                    pontos1 = pontos[0:16384]
                    compara = 0

                if (pontos0 == pontos1):
                    opt = 0
                else:
                    opt = 1

                # print(pontos)

                print("------------------------")
                x = pontos[len(pontos)-1]
                Voff = pontos[len(pontos)-2]
                Vamp = pontos[len(pontos)-3]
                frequencia = pontos[len(pontos)-4]

                print("Opt", opt)
                print("Offset", Voff)
                print("Amplitude", Vamp)
                print("frequencia", frequencia)
                print("------------------------")

                # 0.70 e a resolucao = 25M/68ciclos/2^19
                ftw = (int(float(frequencia)/0.701231115))*2

                # valor acima de 65535 fica nessa variavel
                ftwaux = ((int(ftw) >> 16) & 0x1)
                print("ftw", ftw)
                print("ftwaux", ftwaux)
                print("------------------------")

                if ((float(Vamp) == 3.3)):
                    div1 = 4095
                else:
                    div1 = 4096

                if ((float(Voff) == 3.3)):
                    div2 = 4095
                else:
                    div2 = 4096

                amplitude = (int((float(Vamp)*div1)/10.89)*2)
                offset = int(
                    (((float(float(Voff)-float(Vamp))+3.3)*int(div2))/6.6))

                # ENVIO I2C
                amp1 = ((int(amplitude) >> 8) & 0x0F)
                amp2 = (int(amplitude) & 0x00FF)

                off1 = ((int(offset) >> 8) & 0x0F)
                off2 = (int(offset) & 0x00FF)

                bus.write_block_data(0x60, 0, [amp1, amp2])
                bus.write_block_data(0x61, 0, [off1, off2])

                # ENVIO SPI
                # mensagem de inicio
                spi.xfer([int(opt)])
                time.sleep(0.5)

                if (int(opt) == 1):
                    i = 0
                    # envia primeiro as duas parte de FTW
                    spi.xfer([int(ftwaux)])
                    time.sleep(0.0001)
                    msb = (int(ftw) >> 8 & 0xFF)
                    lsb = int(ftw) & 0xFF
                    spi.xfer([int(msb)])
                    time.sleep(0.0001)
                    spi.xfer([int(lsb)])
                    time.sleep(0.0001)

                    # envio da amostras
                    while (i <= 16383):
                        msb = int(pontos[i]) >> 8
                        lsb = int(pontos[i]) & 0xFF
                        spi.xfer([int(msb)])
                        # time.sleep(0.0001)
                        spi.xfer([int(lsb)])
                        i = i+1

                # envia somente o valor de ftw
                else:
                    spi.xfer([int(ftwaux)])
                    time.sleep(0.0001)
                    msb = int(ftw) >> 8
                    lsb = int(ftw) & 0xFF
                    spi.xfer([int(msb)])
                    time.sleep(0.0001)
                    spi.xfer([int(lsb)])

                print("TERMINOU")

    except:
        print("Closing socket")
        client.close()
        s.close()
