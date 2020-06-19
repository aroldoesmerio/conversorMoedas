import 'dart:convert';

import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

const request = "https://api.hgbrasil.com/finance";

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHome(),
      theme: ThemeData(
          hintColor: Colors.amber,
          primaryColor: Colors.white,
          inputDecorationTheme: InputDecorationTheme(
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[900])),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber)))),
    );
  }
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  double dolar;
  double euro;
  double real;

void _clearAll(){
  realController.text = "";
  dolarController.text = "";
  euroController.text = ""; 
}


  void _realChanged(String text) {
    if(text.isEmpty){
      _clearAll();
      return;  
    }
    double real = double.parse(text);
    dolarController.text = (real*dolar).toStringAsFixed(2); 
    euroController.text = (real*euro).toStringAsFixed(2); 
  }

  void _dolarChanged(String text) {
     if(text.isEmpty){
      _clearAll();
      return;  
    }
    double dolar = double.parse(text); 
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
     if(text.isEmpty){
      _clearAll();
      return;  
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.dolar).toStringAsPrecision(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(" \$ Conversor de valores \$"),
        centerTitle: true,
        backgroundColor: Colors.amber[400],
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                    "Carregando dados ...",
                    style: TextStyle(color: Colors.red[900], fontSize: 20),
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erro ao carregar os dados...",
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  );
                } else {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(Icons.monetization_on,
                            size: 150.0, color: Colors.amber),
                        buildTextField("Reais", "R\$ ", realController, _realChanged),
                        Divider(),
                        buildTextField("Dolares", "US\$ ", dolarController,_dolarChanged),
                        Divider(),
                        buildTextField("Euros", "EU\$ ", euroController, _euroChanged)
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

buildTextField(String label, String prefix, controller,Function function ) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix,
      
    ),
    keyboardType: TextInputType.number,
    onChanged: function,
  );
}
