import 'package:flutter/material.dart';
import 'package:mdi/mdi.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:math';
import 'main.dart';

class SquarePage extends StatefulWidget {
  @override
  _SquarePageState createState() => _SquarePageState();
}

class _SquarePageState extends State<SquarePage> {
  final Controller c = Get.put(Controller());

  var textController1 = new TextEditingController();
  var textController2 = new TextEditingController();
  var textController3 = new TextEditingController();
  var textController4 = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.yellow,
        child: widgetTextField(),
      ),
      appBar: AppBar(
        title: Text("Onda quadrada"),
        backgroundColor: Colors.black54,
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Positioned(
            bottom: 0,
            right: 135,
            child: FloatingActionButton(
              heroTag: 'SendMessage',
              onPressed: () {
                gerarPontosSquare(c.textFreqController, c.textAmpController,
                    c.textOffSetController, c.textDutyCicle);
                dispose();
              },
              child: Icon(Mdi.send),
              backgroundColor: Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Padding widgetTextField() {
    return Padding(
      padding: const EdgeInsets.all(17.0),
      child: Column(
        children: [
          // o primeiro campo texto tem o foco no inicio
          TextFormField(
            controller: textController1,
            onChanged: (text) {
              c.textFreqController = text.obs;
            },
            style: TextStyle(color: Colors.black, fontSize: 17),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: InputBorder.none,
              icon: Icon(Mdi.squareWave),
              hintText: 'Informe a frequência até 45 kHz',
              //labelText: "Frequência"
            ),
          ),
          SizedBox(height: 40),

          TextField(
            controller: textController2,
            onChanged: (text) {
              c.textAmpController = text.obs;
            },
            style: TextStyle(color: Colors.black, fontSize: 17),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                border: InputBorder.none,
                icon: Icon(Mdi.chartBellCurve),
                hintText: 'Informe a amplitude máxima'),
          ),
          SizedBox(height: 40),

          TextField(
            controller: textController3,
            onChanged: (text) {
              c.textOffSetController = text.obs;
            },
            style: TextStyle(color: Colors.black, fontSize: 17),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                border: InputBorder.none,
                icon: Icon(Mdi.currentDc),
                hintText: 'Informe o nível de Offset'),
          ),
          SizedBox(height: 40),

          TextField(
            controller: textController4,
            onChanged: (text) {
              c.textDutyCicle = text.obs;
            },
            style: TextStyle(color: Colors.black, fontSize: 17),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                border: InputBorder.none,
                icon: Icon(Mdi.codeTags),
                hintText: 'Informe o duty cicle'),
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}

void gerarPontosSquare(var freq, var amp, var offset, var dutycicle) async {
  final Controller c = Get.put(Controller());
  freq = num.parse(freq.toString());
  int duty = num.parse(dutycicle.toString());
  // int potencia = c.potencia.toInt();
  double periodo = (16384 * duty / 100) as double;
  int numDePontos = 0;

  while (numDePontos < 16384) {
    if (numDePontos <= periodo) {
      c.pontos[numDePontos] = 4095;
    } else if (numDePontos > periodo) {
      c.pontos[numDePontos] = 0;
    }
    print("Point:${c.pontos[numDePontos]}");
    numDePontos++;
  }
  c.connection.output.add(utf8.encode(c.pontos.toString() +
      '[, ' +
      freq.toString() +
      ', ' +
      amp.toString() +
      ', ' +
      offset.toString() +
      ', 1]'));
  await c.connection.output.allSent;
}
