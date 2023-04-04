/*
  Autores: Felipe Walter Dafico Pfrimer, Alberto Yoshihiro Nakano, Daiany Besen, Giovani Blanco Bartnik
  Título do TCC: Gerador de ondas arbitrárias controlado por aplicativo móvel
  Local/data: Toledo, dezembro de 2023

  Descrição: Este código é parte do projeto de um aplicativo móvel desenvolvido em Flutter para controlar um gerador
  de ondas arbitrárias. O aplicativo permite aos usuários ajustar e controlar diferentes tipos de ondas,
  como senoidal, triangular e quadrada, além de gerenciar conexões Bluetooth com um Raspberry Pi Zero W,
  que recebe amostras de sinal e outros parâmetros através da conexão. A interface do usuário é composta
  por várias telas, incluindo uma tela para cada tipo de onda, uma tela para gerenciar conexões Bluetooth
  e uma tela para ajustar pontos específicos de uma onda.
*/

// Bibliotecas necessárias

import 'dart:math'; // Pacote para realizar operações matemáticas avançadas
import 'package:flutter/material.dart'; // Pacote para a construção da interface do usuário
import 'package:get/get.dart'; // Pacote GetX para gerenciamento de estado e navegação
import 'package:mdi/mdi.dart'; // Pacote de ícones Material Design Icons
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart'; // Pacote para utilizar e gerenciar conexões Bluetooth
import 'package:flutter/services.dart'; // Pacote para lidar com serviços da plataforma, como sensores e permissões

// Importações das páginas individuais do aplicativo
import 'sin_page.dart'; // Página para configuração de onda senoidal
import 'square_page.dart'; // Página para configuração de onda quadrada
import 'triangule_page.dart'; // Página para configuração de onda triangular
import 'bluetooth_page.dart'; // Página para gerenciamento de conexões Bluetooth
import 'point_page.dart'; // Página para ajuste de pontos específicos da onda

// Função principal que inicia a execução do aplicativo e configura o widget Home como a página inicial do GetMaterialApp
void main() => runApp(GetMaterialApp(home: Home()));

class Controller extends GetxController {
  //variaveis utilizadas no código
  var textFreqController = '1000'.obs;
  var textAmpController = '5'.obs;
  var textOffSetController = '0'.obs;
  var textDutyCicle = '50'.obs;
  var numDePontos = 0.obs;
  var potencia = 14.obs;
  int indice = 0;
  final pontos = List<int>.generate(pow(2, 14), (i) => 99);
  final pontosX = List<double>.generate(pow(2, 8), (i) => 99);
  final pontosY = List<double>.generate(pow(2, 8), (i) => 99);

  // Inicializando o estado da conexão Bluetooth a ser desconhecido
  BluetoothState bluetoothState = BluetoothState.UNKNOWN;

  // Inicializando uma chave global, pois isso nos ajudaria a mostrar um SnackBar mais tarde
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  // Obtenha a instância do Bluetooth
  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;

  // Rastreie a conexão Bluetooth com o dispositivo remoto
  BluetoothConnection connection;

  int deviceState;

  bool isDisconnecting = false;

  // Para rastrear se o dispositivo ainda está conectado ao Bluetooth
  bool get isConnected => connection != null && connection.isConnected;

  // Defina algumas variáveis, que serão necessárias mais tarde
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice device;
  bool connected = false;
  bool isButtonUnavailable = false;

  @override
  void dispose() {
    // Evite vazamento de memória e desconecte
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  // Solicite permissão de Bluetooth do usuário
  Future<void> enableBluetooth() async {
    // Recuperando o estado atual do Bluetooth
    bluetoothState = await FlutterBluetoothSerial.instance.state;

    // Se o bluetooth estiver desligado, ligue-o primeiro
    // e então recupere os dispositivos que estão emparelhados.

    if (bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return true;
    } else {
      await getPairedDevices();
    }
    return false;
  }

  // Para recuperar e armazenar os dispositivos emparelhados
  // em uma lista.
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // Para obter a lista de dispositivos emparelhados
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    // Armazene a lista de [devices] em [_devicesList] para acessar
    // a lista fora desta classe

    devicesList = devices;
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Controller c = Get.put(Controller());

  final _sinPage = SinPage();
  final _triangulePage = TriangulePage();
  final _squarePage = SquarePage();
  final _bluetoothPage = BluetoothApp();
  final _pointsPage = PointsPage();

  void selecaoPagina(int page) {
    switch (page) {
      case 0:
        Get.to(() => TelaInicial());
        break;
      case 1:
        Get.to(() => _bluetoothPage);
        break;
      case 2:
        Get.to(() => _sinPage);
        break;
      case 3:
        Get.to(() => _triangulePage);
        break;
      case 4:
        Get.to(() => _squarePage);
        break;
      case 5:
        Get.to(() => _pointsPage);
        break;
      default:
        Get.to(TelaInicial());
        break;
    }
  }

//Tela inicial do app
  @override
  Widget build(context) {
    return Scaffold(
        floatingActionButton: Stack(
          children: <Widget>[
            Positioned(
              bottom: 480,
              right: 0,
              child: FloatingActionButton(
                heroTag: 'BluetoothPage',
                onPressed: () {
                  selecaoPagina(1);
                },
                child: Icon(Mdi.bluetooth),
                backgroundColor: Colors.black38,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
            Positioned(
              bottom: 400.0,
              right: 0,
              child: FloatingActionButton(
                heroTag: 'SinPage',
                onPressed: () {
                  selecaoPagina(2);
                },
                child: Icon(Mdi.sineWave),
                backgroundColor: Colors.black38,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
            Positioned(
              bottom: 320.0,
              right: 0,
              child: FloatingActionButton(
                heroTag: 'TriangulePage',
                onPressed: () {
                  selecaoPagina(3);
                },
                child: Icon(Mdi.triangleWave),
                backgroundColor: Colors.black38,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
            Positioned(
              bottom: 240.0,
              right: 0,
              child: FloatingActionButton(
                heroTag: 'SquarePage',
                onPressed: () {
                  selecaoPagina(4);
                },
                child: Icon(Mdi.squareWave),
                backgroundColor: Colors.black38,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
            Positioned(
              bottom: 160,
              right: 0,
              child: FloatingActionButton(
                heroTag: 'PointsPage',
                onPressed: () {
                  selecaoPagina(5);
                },
                child: Icon(Mdi.numeric8BoxMultiple),
                backgroundColor: Colors.black38,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
          ],
        ),
        body: new Stack(
          children: <Widget>[
            new Container(
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: new AssetImage('imagens/AppAWG.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ));
  }
}

class TelaInicial extends StatelessWidget {
  // Você pode pedir o Get para encontrar o controller que foi usado em outra página e redirecionar você pra ele.
  final Controller c = Get.find();

  @override
  Widget build(context) => Scaffold(
      appBar: AppBar(
        title: Text("UTFPR TCC"),
        backgroundColor: Colors.black54,
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            label: Text(
              "Refresh",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            splashColor: Colors.yellow,
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        color: Colors.yellow,
        child: Center(
          child: Text("UTFPR - TCC"),
        ),
      ));
}
