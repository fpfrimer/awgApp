import 'dart:convert';

import 'dart:io';
import 'dart:async';
import 'dart:ui';
//import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mdi/mdi.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'main.dart';
//import 'package:path_provider/path_provider.dart';

//import 'package:csv/csv.dart';

class PointsPage extends StatefulWidget {
  @override
  _PointsPageState createState() => _PointsPageState();
}

class _PointsPageState extends State<PointsPage> {
  final Controller c = Get.put(Controller());
  var pontox = new TextEditingController();
  var pontoy = new TextEditingController();
  var textController1 = new TextEditingController();
  var textController2 = new TextEditingController();
  var textController3 = new TextEditingController();
  int indice = 0, maiorIndice = 0, aux;

  double vX = 0, vY = 0, amp = 0, freq = 0, off = 0;

  void erroIntervaloX(double vX) {
    if (vX > 1) {
      vX = 1;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("Erro:"),
            content: new Text("o valor digitado deve estar entre 0 e 1."),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Fechar"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else if (vX < 0) {
      vX = 0;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("Erro:"),
            content: new Text("o valor digitado deve estar entre 0 e 1."),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Fechar"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void erroIntervaloY(double vY) {
    if (vY > 1) {
      vY = 1;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("Erro:"),
            content: new Text("o valor digitado deve estar entre -1 e 1."),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Fechar"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else if (vY < -1) {
      vY = -1;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("Erro:"),
            content: new Text("o valor digitado deve estar entre -1 e 1."),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Fechar"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void intervaloAmplitude(double vY) {
    if (vY > 24) {
      vY = 24;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("Erro:"),
            content: new Text(
                "o valor digitado para a excurção do sinal deve ser inferior a 24."),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Fechar"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void intervaloFrequencia(double vY) {
    if (vY > 50000) {
      vY = 50000;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("Erro:"),
            content: new Text(
                "o valor digitado para a frequência deve ser inferior a 45000."),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Fechar"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      vY = vY * (-1);
    }
  }

  void intervaloOffset(double vY) {
    if (vY > 5) {
      vY = 5;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("Erro:"),
            content: new Text(
                "o valor digitado para o Offset deve ser inferior a 5."),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Fechar"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else if (vY < -5) {
      vY = -5;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("Erro:"),
            content: new Text(
                "o valor digitado para o Offset deve ser superior a -5."),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Fechar"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  var _valores = ['Linear', 'Polinomial'];
  String selecionado = 'Linear';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, //não redimensionar a tela quando o teclado for aberto
      appBar: AppBar(
        title: Text('Entrada manual de pontos'),
        backgroundColor: Colors.black54,
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            Column(children: [
              TextFormField(
                controller: pontox,
                onChanged: (text) {
                  vX = double.parse(text.toString());
                  setState(() {
                    erroIntervaloX(vX);
                  });
                },
                style: TextStyle(color: Colors.black, fontSize: 17),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(Mdi.alphaXBox),
                    hintText: 'Informe o ponto X'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: pontoy,
                onChanged: (text) {
                  vY = double.parse(text.toString());
                  setState(() {
                    erroIntervaloY(vY);
                  });
                },
                style: TextStyle(color: Colors.black, fontSize: 17),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(Mdi.alphaYBox),
                    hintText: 'Informe o ponto Y'),
              ),
              SizedBox(height: 10),
              FloatingActionButton.extended(
                onPressed: () {
                  if (vX != null) {
                    if (vY != null) {
                      setState(() {
                        erroIntervaloX(vX);
                        erroIntervaloY(vY);

                        c.pontosX[indice] = vX;
                        c.pontosY[indice] = vY;
                        indice++;
                      });
                      print("x: ${vX}" + "y: ${vY}");
                    }
                  }
                },
                label: Text("Ponto $indice"),
                icon: Icon(Mdi.plus),
                backgroundColor: Colors.black38,
              ),
              TextField(
                controller: textController1,
                onChanged: (text) {
                  freq = double.parse(text.toString());
                  setState(() {
                    intervaloFrequencia(freq);
                    c.textFreqController = text.obs; //freq.toString().obs;
                    print(c.textFreqController);
                  });
                },
                style: TextStyle(color: Colors.black, fontSize: 17),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(Mdi.sineWave),
                    hintText: 'Informe a frequência máxima'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: textController2,
                onChanged: (text) {
                  amp = double.parse(text.toString());
                  setState(() {
                    intervaloAmplitude(amp);
                    c.textAmpController = text.obs; //amp.toString().obs;
                    print(c.textAmpController);
                  });
                },
                style: TextStyle(color: Colors.black, fontSize: 17),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(Mdi.chartBellCurve),
                    hintText: 'Informe a amplitude máxima'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: textController3,
                onChanged: (text) {
                  off = double.parse(text.toString());
                  setState(() {
                    intervaloOffset(off);
                    c.textOffSetController = text.obs; //off.toString().obs;
                    print(c.textOffSetController);
                  });
                },
                style: TextStyle(color: Colors.black, fontSize: 17),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(Mdi.currentDc),
                    hintText: 'Informe o nível de Offset'),
              ),
              SizedBox(height: 10),
              Text("Selecione o tipo de interpolação"),
              DropdownButton<String>(
                  items: _valores.map((String dropDownStringItem) {
                    return DropdownMenuItem<String>(
                      value: dropDownStringItem,
                      child: Text(dropDownStringItem),
                    );
                  }).toList(),
                  onChanged: (String novoItemSelecionado) {
                    setState(() {
                      selecionado = novoItemSelecionado;
                    });
                  },
                  value: selecionado),
            ]),
            Container(
              margin: EdgeInsetsDirectional.fromSTEB(0, 400, 0, 0),
              height: 200,
              child: ListView.builder(
                //itemCount: c.pontosDigitados.length,
                itemBuilder: (ctx, i) => ListTile(
                  leading: Icon(Mdi.handPointingRight),
                  title: Text("Ponto $i"),
                  subtitle: Text(
                    "x: ${c.pontosX[i]}, y: ${c.pontosY[i]}",
                  ),
                  trailing: Container(
                    width: 100,
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            setState(() {
                              indice = i;
                            });
                          },
                          color: Colors.green,
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              c.pontosX[i] = 99;
                              c.pontosY[i] = 99;
                              indice = i;
                            });
                          },
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 135,
              child: FloatingActionButton(
                heroTag: 'SendMessage',
                onPressed: () {
                  gerarPontosManual(c.textFreqController, c.textAmpController,
                      c.textOffSetController, selecionado);
                },
                child: Icon(Mdi.send),
                backgroundColor: Colors.black38,
              ),
            ),
          ],
        ),
        height: MediaQuery.of(context).size.height,
      ),
      backgroundColor: Colors.yellow,
    );
  }
}

//Função que irá calcular os pontos e preencher o vetor de acordo com o tipo de interpolação selecionado
void gerarPontosManual(
    var freq, var amp, var offset, var tipoInterpolacao) async {
  final Controller c = Get.put(Controller());
  int quantidadePontos = 0, contador = 0, indiceAux = 0;

  double intervalo = 0;

//Função que organiza os pontos digitados pelo usuário
//desconsiderando os pontos repetidos
  void organizar() {
    int i = 0, d = 255;
    i = 0;

    while (d > 0) {
      while (i <= 255) {
        if (c.pontosX[d] == c.pontosX[i]) {
          if (d == i) {
          } else if (c.pontosX[i] == 99) {
          } else {
            c.pontosX[d] = 99;
            c.pontosY[d] = 99;
          }
        }
        i++;
      }
      i = 0;
      d--;
    }
    i = 0;
    d = 255;
    while (d > 0) {
      while (i < 255) {
        if (c.pontosX[i] > c.pontosX[i + 1]) {
          var temp = c.pontosX[i];
          c.pontosX[i] = c.pontosX[i + 1];
          c.pontosX[i + 1] = temp;

          temp = c.pontosY[i];
          c.pontosY[i] = c.pontosY[i + 1];
          c.pontosY[i + 1] = temp;
        }
        i++;
      }
      d--;
      i = 0;
    }
    i = 0;

    while (i != 256) {
      if (c.pontosX[i] != 99) {
        quantidadePontos++;
      }
      i++;
    }
    i = 0;
  }

  organizar();

  if (tipoInterpolacao == "Linear") {
    // print("$quantidadePontos + $intervalo");
    int contadorAux = 0;

    while (contador < (quantidadePontos - 1)) {
      double incremento,
          inclinacao,
          x0,
          aux,
          distanciaPontos = c.pontosX[contador + 1] -
              c.pontosX[contador]; //distancia entre pontos X
      intervalo = distanciaPontos * 16384;
      incremento = (distanciaPontos /
          intervalo); //valor incremento durante a equação da reta

      x0 = c.pontosX[contador]; //valor inicial de X
      inclinacao = ((c.pontosY[contador + 1] - c.pontosY[contador]) /
          (c.pontosX[contador + 1] - c.pontosX[contador])); //inclinacao da reta

      while (contadorAux <= (intervalo)) {
        aux = inclinacao * ((x0 + contadorAux * incremento) - x0) +
            c.pontosY[contador];
        if (indiceAux < 16384) {
          c.pontos[indiceAux] = (aux * 2047 + 2047).toInt();
          // print("c.pontos[$indiceAux] = ${c.pontos[indiceAux]}");
        }
        contadorAux++;
        indiceAux++;
      }

      contadorAux = 0;
      contador++;
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
  } else if (tipoInterpolacao == "Polinomial") {
    indiceAux = 0;
    intervalo = pow(2, c.potencia.toInt()) / (quantidadePontos - 1);

    double incremento = (c.pontosX[quantidadePontos - 1] - c.pontosX[0]) /
        (pow(2, c.potencia.toInt()));
    double fx = 0, pdtfinal = 1, valorParcial, x = 0;
    int contadorAux = 0;

    while (contadorAux < (pow(2, c.potencia.toInt()))) {
      x = c.pontosX[0] + incremento * contadorAux;

      fx = 0;

      for (int i = 0; i < quantidadePontos; i++) {
        pdtfinal = 1;
        for (int j = 0; j < quantidadePontos; j++) {
          if (j == i) {
            j++;
          }
          valorParcial = 0;

          valorParcial = (x - c.pontosX[j]) / (c.pontosX[i] - c.pontosX[j]);

          if (j != quantidadePontos) {
            pdtfinal *= valorParcial;
          }
        }

        fx = fx + c.pontosY[i] * pdtfinal;

        pdtfinal = 0;
      }
      int aux = (fx * 2047 + 2047).toInt();
      if (aux > 4095) {
        aux = 4095;
      }
      if (aux < 0) {
        aux = 0;
      }
      c.pontos[contadorAux] = aux;

      contadorAux++;
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
}
