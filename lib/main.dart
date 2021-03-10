import 'dart:ffi';

import 'package:flutter/material.dart';

/* para que possamos fazer requisições temos que importar a biblioteca http dessa maneira */
import 'package:http/http.dart' as http;

/** para que nossa aplicação não trave com o tempo que a requisição vai levar para
 * ser concluida temos que importar outra biblioteca chamada async, essa biblioteca
 * vai fazer com que a requisição possa ser executada tipo em segundo plano permitindo
 * que a aplicação não pare.
 */
import 'package:async/async.dart';

/// Para transformar os valores da requisição em formato json temos que importar
/// outra biblioteca chamada convert
import 'dart:convert';

/// Para crarmos uma função do tipo Future que vai ser usada para retornar os dados
/// da requisição de uma forma melhor temos que importar o dart:async
import 'dart:async';

/**
 * Para usarmos uma api o primeiro passo é criar uma variável request do tipo
 * const com o entedereço de requisição da api. Essa variável do tipo const nunca
 * vai poder ser alterada no sistema. 
 */
const request = "https://api.hgbrasil.com/finance?format=json&key=27ad742f";

void main() async {
  runApp(
    MaterialApp(
      title: "Conversor de Moedas",
      home: Home(),
      theme: ThemeData(
          hintColor: Colors.amber,
          primaryColor: Colors.white,
          inputDecorationTheme: InputDecorationTheme(
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber)),
              hintStyle: TextStyle(color: Colors.amber))),
      debugShowCheckedModeBanner: false,
    ),
  );
}

/// Aqui estamos criando uma função chamada getData do tipo Future<Map>. Será nessa
/// função que colocaremos a requisição dos dados da api. Como ela é do tipo future
/// temos que passar um async antes da abertura do escopo da função dizendo assim
/// que ela vai ser executada em segundo plano.
Future<Map> getData() async {
  /** 
   * para fazermos a requisição criamos uma variável do tipo http.Response.
   * Essa variável recebe um contrutor http.get no qual tem um parâmetro para
   * passarmos a nossa variavel request que contem a url da api.
   * 
   * Para que essa requisição do tipo get funcione tempos que fazer com que ela
   * aconteça assincronamente. Para isso, adicionamos "await" antes de http.get 
   * e também adicionamos async antes da abertura do escopo da função getData.
  */
  http.Response response = await http.get(request);

  ///aqui estamos usando o dart:convert  para transformar o corpo da requisição
  ///no formato do tipo json. E então damos um print no resultado da conversão.
  return json.decode(response.body)["results"]["currencies"];
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar; // variavel para receber o valor do dolar atual
  double euro; //variavel para receber o valor do euro atual

  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('\$ Conversor de moedas \$'),
          centerTitle: true,
          backgroundColor: Colors.amber,
        ),

        ///Quando estamos querendo retornar dados futuros e apresentar nas telas temos que usar um widget
        ///específico para isso, esse widget é o FutureBuilder, no nosso caso especificamos que esse widget é
        ///do tipo map, isso porque a nossa requisição da api esta dentro de uma função do tipo Future<map>.
        ///
        ///O FutureBuilder recebe dois parâmetros obrigatórios. O primeiro é o future que vai receber as informações
        ///da requisição que fizemos dentro da função getData. Como a nossa função retorna as informações da requisição,
        ///basta que coloquemos o nome da função getData() no parâmetro future do FutureBuilder.
        ///
        ///O segundo parametro é o builder que recebe uma função anonima com dois parâmetros o "context" que é como se fosse
        ///um avaliação do contexto da requisição e o "snapshot"(instantâneo) que contem todas as informações sobre a requisição,
        ///como por exemplo o estado da conexão onde estão as informações sobre o que está acontendo na requisição, se ela esta
        ///demorando demais, se não retornou nada ou se houve algum erro.
        body: FutureBuilder<Map>(
            future:
                getData(), // aqui passamos o nome da nossa função Future que faz a requisição
            builder: (context, AsyncSnapshot snapshot) {
              ///Aqui fazemos um swith case tendo como parâmetro o estado da conexão da requisição
              ///que esta dentro de snapshot
              switch (snapshot.connectionState) {

                ///aqui fazemos uma verificação de caso. Se o ConnectionState for none ou o ConnectionState for waiting,
                ///ou seja, se o estado da conexão ainda não tiver recebido nenhuma informação ou o estado da conexão estiver
                ///aguardando os dados, nós vamos retornar uma mensagem de "Carregando dados..."
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                    child: Text(
                      'Carregando dados...',
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ),
                  );

                /// se chegar no default significa que já recebemos um response da nossa requisição.
                default:

                  ///o passo agora é fazer uma verificação no snapshot para ver se houve algum erro na response recebida.
                  /// Se houver ele retorna uma mensagem de erro.
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Erro ao carregar dados...',
                        style: TextStyle(color: Colors.amber, fontSize: 25.0),
                        textAlign: TextAlign.center,
                      ),
                    );

                    ///Se não houver nenhum erro na response recebida ai sim ele começa a criar os widgets do nosso app.
                  } else {
                    dolar = snapshot.data["USD"][
                        "buy"]; //joga o valor do dolar recebido da requisicao dentro da variavel
                    euro = snapshot.data["EUR"][
                        "buy"]; //joda o valor do euro recebido da requisicao dentro da variavel
                    return SingleChildScrollView(
                      //SingleChildScrowView usado em telas que geralmente têm inputs para que o layout  nao quebre
                      padding: EdgeInsets.all(
                          10.0), //todo SingleChildScrowView tem um padding
                      child: Column(
                        // coluna para alinhar os itens na vertical (um em cima do outro)
                        crossAxisAlignment: CrossAxisAlignment
                            .stretch, //alinhamento da coluna no eixo cruzado(horizontal)
                        children: <Widget>[
                          Icon(Icons.monetization_on,
                              size: 150.0, color: Colors.amber),
                          textField(
                              "Reais", "R\$", realController, _realChanged),
                          Divider(), //Divider é um widget que da um espaçamento de quebra de linha, bem parecido com a tag <br> do html
                          textField("Dólares", "US\$", dolarController,
                              _dolarChanged),
                          Divider(), //Divider é um widget que da um espaçamento de quebra de linha, bem parecido com a tag <br> do html
                          textField("Euro", "€", euroController, _euroChanged),
                        ],
                      ),
                    );
                  }
              }
            }));
  }
}

/// Você pode ter observado que repetimos muitas vezes o widget TextField com
/// todos os parâmetros iguais basicamente, mudando pouca coisa. Para que
/// isso não aconteça e o nosso código não fique tão poluido podemos criar uma
/// função do tipo widget que vai retornar exatamente o nosso widget TextField.
/// Nessa função podemos especificar os parâmetros que usaremos aonde for diferente
/// no TextField

///Os controllers nos TextFields servem especificamente para monitorar e editar
///os valores do textField. Para que isso aconteça temos que criar primeiramente
///o controller no inicio da classe state, esse controller vai ser do tipo TextEditingController.
///Agora no widget TextField passamos como parametro o controller que vai controlar
///aquele textfield especifico.
///
///As funções dos TextFields são bem parecidas com os controllers, mas a funções
///tem toda a regra do negocio. É como se a função controlasse o Controller daquele
///TextField. Para criar uma função declaramos ela no inicio do nosso state do colocando
///void e depois o _nomedafuncao. Para relacionarmos o TextField á essa função, basta que
///utilizemos o parâmetro onChanged do TextField e passamos o nome da função.
Widget textField(
    String label, String simbolo, TextEditingController c, Function f) {
  return TextField(
    controller: c,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: simbolo),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    keyboardType: TextInputType.number,
    onChanged: f,
  );
}
