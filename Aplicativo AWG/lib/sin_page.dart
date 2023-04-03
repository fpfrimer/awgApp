import 'package:flutter/material.dart';
import 'package:mdi/mdi.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'dart:convert';
import 'main.dart';

class SinPage extends StatefulWidget {
  @override
  _SinPageState createState() => _SinPageState();
}

class _SinPageState extends State<SinPage> {
  final Controller c = Get.put(Controller());

  var textController1 = new TextEditingController();
  var textController2 = new TextEditingController();
  var textController3 = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.yellow,
        child: widgetTextField(),
      ),
      appBar: AppBar(
        title: Text("Onda senoidal"),
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
                gerarPontosSeno(c.textFreqController, c.textAmpController,
                    c.textOffSetController);
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
              icon: Icon(Mdi.sineWave),
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
        ],
      ),
    );
  }
}

void gerarPontosSeno(var freq, var amp, var offset) async {
  final Controller c = Get.put(Controller());
  freq = num.parse(freq.toString());
  int potencia = c.potencia.toInt();
  num deltaRad = (2 * pi) / pow(2, potencia);
  double tempo = 0;
  int numDePontos = 0;
  num seno;
  num senoNormalizado;
  int saida = 0;

  while (numDePontos < (pow(2, potencia))) {
    tempo = deltaRad * numDePontos;
    seno = sin(tempo);
    senoNormalizado = 4095 * (seno + 1) / 2;
    saida = senoNormalizado.toInt();
    c.pontos[numDePontos] = saida;

    if (numDePontos == (pow(2, potencia) - 1)) {
      print(c.pontos[numDePontos]);
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
    numDePontos++;
  }
}
