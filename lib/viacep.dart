// Classe que armazenará dados do cep (json -> objeto)

import 'dart:convert';
import 'package:http/http.dart' as http;

class ViaCep{
  final String cep;
  final String logradouro;
  final String bairro;
  final String localidade;
  final String uf;

  

  const ViaCep(this.cep, this.logradouro, this.bairro, this.localidade, this.uf);
  
  // factory garante a gestão da criação dos objetos(cada cep será singleton)
  //Só criaremos o objeto pelo método ViaCep.fromJson.
  factory ViaCep.fromJson(Map<String, dynamic> json){
    return ViaCep(json['cep'], json['logradouro'], json['bairro'], json['localidade'], json['uf']);
  }  
}



// Função que recebe String (cep) criando o objeto assim que receber (http/ws)/assíncrono.
Future<ViaCep> consultaCep(String cep) async{

  //endereço web que retorna json
  String viaCepWs = "http://viacep.com.br/ws/$cep/json/";

  // Consulta , via GET (ws), a uri do ViaCep.
  // await diz que a resposta será um Future<Response>.
  final resposta = await http.get(Uri.parse(viaCepWs)); //http = import 'package:http/http.dart'
   if(resposta.statusCode == 200){ // 200=OK
      return ViaCep.fromJson(jsonDecode(resposta.body)); // jsonDecode transforma a String(corpo da resposta) em json (HasMap<String, valor>)
   }
   else{
    throw Exception(('Deu pau, resposta não veio!'));
   }
}
