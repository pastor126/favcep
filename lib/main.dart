import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Viacep.dart';

void main() {
  runApp(MyApp());
}
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ListaDeFavoritos listaDeFavoritos = ListaDeFavoritos();
  Color tema = Colors.blue;

  void alterarTema(Color novaCor) {
    setState(() {
      tema = novaCor;
    });
  }
   @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) => MainApp(listaDeFavoritos: listaDeFavoritos, 
        tema: tema, alterarTema: alterarTema),
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  final ListaDeFavoritos listaDeFavoritos;
   final Color tema;
  final Function(Color novaCor) alterarTema;
   MainApp({Key? key, required this.listaDeFavoritos, 
   required this.tema, required this.alterarTema}) : super(key: key);
  @override
  _MainAppState createState() => _MainAppState();
}
// Estado do Widget principal
class _MainAppState extends State<MainApp> {
  final controladorTexto = TextEditingController();
 
  
// Método para navegar para a tela de favoritos
  void _click(BuildContext context) {  
    Navigator.push(context, 
    MaterialPageRoute(builder: (context) => Favoritos(listaDeFavoritos: widget.listaDeFavoritos),),);
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(primary: widget.tema),
      ),
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('IFMS - Maps'),
          actions: [
            IconButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Favoritos(listaDeFavoritos: widget.listaDeFavoritos),),),
              icon: Icon(Icons.favorite, color: widget.tema == Colors.red ? Colors.orange : Colors.red),
            ),
          ],
        ),
        body: Tela1(alterarTema: widget.alterarTema, controladorTexto: controladorTexto, listaDeFavoritos: widget.listaDeFavoritos,),
      ),
    );
  }
}

class Tela1 extends StatelessWidget {
  const Tela1({Key? key, required this.controladorTexto, required this.alterarTema, required this.listaDeFavoritos}) : super(key: key);
  final TextEditingController controladorTexto;
  final Function(Color novaCor) alterarTema;
  final ListaDeFavoritos listaDeFavoritos;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Tema  '),
              GestureDetector(
                onTap: () {
                  alterarTema(Colors.blue);
                  print('azul');
                },
                child: const Icon(Icons.circle, color: Colors.blue),
              ),
              GestureDetector(
                onTap: () {
                  alterarTema(Colors.red);
                  print('vermelho');
                },
                child: const Icon(Icons.circle, color: Colors.red),
              ),
              GestureDetector(
                onTap: () {
                  alterarTema(Colors.black);
                  print('preto');
                },
                child: const Icon(Icons.circle, color: Colors.black),
              ),
            ],
          ),
          Column(
            children: [
              const Text('Pesquisar CEP'),
              CampoTexto(controladorTexto),
              BtConsulta(controladorTexto, listaDeFavoritos),
            ],
          ),
        ],
      ),
    );
  }
}

// Botão de consulta para pesquisar CEP
class BtConsulta extends StatelessWidget {
  const BtConsulta(this.controladorTexto, this.listaDeFavoritos, {Key? key}) : super(key: key);
  final TextEditingController controladorTexto;
  final ListaDeFavoritos listaDeFavoritos;

  void click(BuildContext context) async {
    print(controladorTexto.text);
    ViaCep enderecoFuturo = await consultaCep(controladorTexto.text);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Endereco(
          viacepdata: enderecoFuturo,
          listaDeFavoritos: listaDeFavoritos,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => click(context),
      child: Text('Consultar'),
    );
  }
}


class CampoTexto extends StatelessWidget {
  const CampoTexto(this.controladorTexto, {Key? key}) : super(key: key);
  final TextEditingController controladorTexto;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: controladorTexto,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r"[\d.]")),
          LengthLimitingTextInputFormatter(8),
        ],
        decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'CEP'),
      ),
    );
  }
}

class Favoritos extends StatefulWidget {
  final ListaDeFavoritos listaDeFavoritos;
  Favoritos({required this.listaDeFavoritos, });
  @override
  State<Favoritos> createState() => _FavoritosState();
}
class _FavoritosState extends State<Favoritos> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Endereços Favoritos')),
      body: widget.listaDeFavoritos.cepFavList.isEmpty
          ? Center(
              child: Text('Nenhum endereço favorito.'),
            )
          : ListView.builder(
              itemCount: widget.listaDeFavoritos.cepFavList.length,
              itemBuilder: (context, index) {
                ViaCep cep = widget.listaDeFavoritos.cepFavList[index];
                
                return 
                
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                 
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${cep.cep}  '),
                        Text('${cep.localidade}'),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Endereco(viacepdata: cep,
                          listaDeFavoritos: widget.listaDeFavoritos,)
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

// Tela de exibição de endereço
class Endereco extends StatefulWidget {
  const Endereco({Key? key, required this.viacepdata, required this.listaDeFavoritos}) : super(key: key);
  final ViaCep viacepdata;
  final ListaDeFavoritos listaDeFavoritos;
  @override
  State<Endereco> createState() => _EnderecoState(listaDeFavoritos);
}
// Estado da tela de endereço
class _EnderecoState extends State<Endereco> {
   ListaDeFavoritos listaDeFavoritos;
  _EnderecoState(this.listaDeFavoritos);
  Widget linha(String label, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label $valor'),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      appBar: AppBar( title: const Text('     IFMS Maps - Detalhes'),),
      body: Center(
      child: Column(
      mainAxisAlignment: MainAxisAlignment.center,  
      children: [
        linha('CEP: ', widget.viacepdata.cep),
        linha('', widget.viacepdata.logradouro),
        linha('', widget.viacepdata.bairro),
        linha('Cidade: ', widget.viacepdata.localidade),
        linha('UF: ', widget.viacepdata.uf),], 
      ),
      ),
     floatingActionButton: FloatingActionButton(
  onPressed: () async {
    String cepMsg = 'CEP ${widget.viacepdata.cep}';
    if (widget.listaDeFavoritos.favorito(widget.viacepdata)) {
      widget.listaDeFavoritos.removerFavorito(widget.viacepdata);
      _mostrarAlerta('Removido dos Favoritos', cepMsg);
    } else {
      widget.listaDeFavoritos.adicionarFavorito(widget.viacepdata);
      print(widget.listaDeFavoritos._cepFavList.length);
      _mostrarAlerta('Adicionado aos Favoritos', cepMsg);
    }
    setState(() {});
  },
        child: Icon(
          Icons.favorite,
          color: listaDeFavoritos.favorito(widget.viacepdata)
              ? Colors.yellow
              : Colors.white,
        ),
      ),
    );  
  }
  void _mostrarAlerta(String acao, String cepMsg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('$cepMsg $acao'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class ListaDeFavoritos {
  final List<ViaCep> _cepFavList = [];
  List<ViaCep> get cepFavList => _cepFavList;
  void adicionarFavorito(ViaCep cepFav) {
    _cepFavList.add(cepFav);
  }
  void removerFavorito(ViaCep cepFav) {
    _cepFavList.remove(cepFav);
  }
  bool favorito(ViaCep cepFav) {
    return _cepFavList.contains(cepFav);
  }
}