// Para realizar algumas operações de forma assíncrona
import 'dart:async';
import 'dart:convert';

// Para usar PlatformException
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';

import 'main.dart';

class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  final Controller c = Get.put(Controller());

  @override
  void initState() {
    // Obtenha o estado atual
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        c.bluetoothState = state;
      });
      super.initState();
    });

    //c.deviceState = 0; // neutral

    // Se o bluetooth do dispositivo não estiver habilitado,
    // então solicite permissão para ligar o bluetooth
    // quando o aplicativo é inicializado
    c.enableBluetooth();

    // Ouça mais mudanças de estado
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        c.bluetoothState = state;
        if (c.bluetoothState == BluetoothState.STATE_OFF) {
          c.isButtonUnavailable = true;
        } else if (c.bluetoothState == BluetoothState.STATE_ON) {
          c.isButtonUnavailable = false;
        } else {
          c.getPairedDevices();
        }
      });
    });
  }

  // Agora, é hora de construir a IU
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: c.scaffoldKey,
        appBar: AppBar(
          title: Text("Bluetooth"),
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
              onPressed: () async {
                // Então, quando novos dispositivos são pareados
                // enquanto o aplicativo está em execução, o usuário pode atualizar
                // a lista de dispositivos emparelhados.
                await c.getPairedDevices().then((_) {
                  show('Device list refreshed');
                });
              },
            ),
          ],
        ),
        body: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Visibility(
                visible: c.isButtonUnavailable &&
                    c.bluetoothState == BluetoothState.STATE_ON,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.yellow,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black26),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Habilitar Bluetooth',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Switch(
                      value: c.bluetoothState.isEnabled,
                      onChanged: (bool value) {
                        future() async {
                          if (value) {
                            await FlutterBluetoothSerial.instance
                                .requestEnable();
                          } else {
                            await FlutterBluetoothSerial.instance
                                .requestDisable();
                          }

                          await c.getPairedDevices();
                          setState(() {
                            c.isButtonUnavailable = false;
                          });

                          if (c.connected) {
                            setState(() {
                              _disconnect();
                            });
                          }
                        }

                        future().then((_) {
                          setState(() {});
                        });
                      },
                    )
                  ],
                ),
              ),
              Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          "Dispositivos pareados",
                          style: TextStyle(fontSize: 24, color: Colors.blue),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Dispositivo:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            DropdownButton(
                              items: _getDeviceItems(),
                              onChanged: (value) => setState(
                                () => c.device = value,
                              ),
                              value: c.devicesList.isNotEmpty ? c.device : null,
                            ),
                            RaisedButton(
                              onPressed: c.isButtonUnavailable
                                  ? null
                                  : c.connected
                                      ? _disconnect
                                      : _connect,
                              child:
                                  Text(c.connected ? 'Disconnect' : 'Connect'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    color: Colors.blue,
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "NOTA: Se você não conseguir encontrar o dispositivo na lista, emparelhe o dispositivo acessando as configurações de bluetooth",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 15),
                        RaisedButton(
                          elevation: 2,
                          child: Text("Configurações Bluetooth"),
                          onPressed: () {
                            setState(() {
                              FlutterBluetoothSerial.instance.openSettings();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        backgroundColor: Colors.yellow,
      ),
    );
  }

  // Crie a lista de dispositivos a serem mostrados no menu suspenso
  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (c.devicesList.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('Nenhum'),
      ));
    } else {
      c.devicesList.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
      });
    }
    return items;
  }

  // Método para conectar ao bluetooth
  void _connect() async {
    setState(() {
      c.isButtonUnavailable = true;
    });
    if (c.device == null) {
      show('Nenhum dispositivo selecionado');
    } else {
      if (!c.isConnected) {
        await BluetoothConnection.toAddress(c.device.address)
            .then((_connection) {
          print('Dispositivo conectado');
          c.connection = _connection;
          setState(() {
            c.connected = true;
          });

          c.connection.input.listen(null).onDone(() {
            if (c.isDisconnecting) {
              print('Desconectado localmente!');
            } else {
              print('Desconectado remotamente!');
            }
            if (this.mounted) {
              setState(() {});
            }
          });
        }).catchError((error) {
          print('Não pode conectar, ocorreu uma exceção');
          print(error);
        });
        //show('Device connected');

        setState(() => c.isButtonUnavailable = false);
      }
    }
  }

  // Método para desconectar bluetooth
  void _disconnect() async {
    setState(() {
      c.connection.finish();

      c.isButtonUnavailable = true;
      c.deviceState = 0;
      c.isDisconnecting = true;
      c.connection = null;
      c.connected = false;
      FlutterBluetoothSerial.instance.requestDisable();
    });

    await c.connection.close();
    initState();
  }

  // Método para mostrar um Snackbar,
  // tomando a mensagem como o texto
  Future show(
    String message, {
    Duration duration: const Duration(seconds: 1),
  }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    c.scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text(
          message,
        ),
        duration: duration,
      ),
    );
  }
}
