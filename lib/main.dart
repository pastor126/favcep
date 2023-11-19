import 'package:flutter/material.dart';
import 'Viacep.dart';
import 'CampoTexto.dart';
import 'package:provider/provider.dart';

class ThemeModel extends ChangeNotifier {
  Color _currentTheme = Colors.blue;

  get currentTheme => _currentTheme;

  void updateTheme(Color newTheme) {
    _currentTheme = newTheme;
    notifyListeners();
  }
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeModel()),
        ChangeNotifierProvider(create: (context) => ListaDeFavoritos()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) {
          var themeModel = Provider.of<ThemeModel>(context);
          var favoritosModel = Provider.of<ListaDeFavoritos>(context);
          return MainApp(
            listaDeFavoritos: favoritosModel,
            tema: themeModel.currentTheme,
            alterarTema: themeModel.updateTheme,
          );
        },
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  final ListaDeFavoritos listaDeFavoritos;
  final Color tema;
  final Function(Color novaCor) alterarTema;
  MainApp(
      {Key? key,
      required this.listaDeFavoritos,
      required this.tema,
      required this.alterarTema})
      : super(key: key);
  @override
  _MainAppState createState() => _MainAppState();
}

// Estado do Widget principal
class _MainAppState extends State<MainApp> {
  final controladorTexto = TextEditingController();

// Método para navegar para a tela de favoritos
  void _click(BuildContext context) {
    var favoritosScreen = Favoritos(
      listaDeFavoritos: widget.listaDeFavoritos,
      tema: widget.tema,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => favoritosScreen,
      ),
    );
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
            BtnFav(
                alterarTema: widget.alterarTema,
                controladorTexto: controladorTexto,
                listaDeFavoritos: widget.listaDeFavoritos,
                tema: widget.tema),
          ],
        ),
        body: Tela1(
            alterarTema: widget.alterarTema,
            controladorTexto: controladorTexto,
            listaDeFavoritos: widget.listaDeFavoritos,
            tema: widget.tema),
      ),
    );
  }
}

class BtnFav extends StatelessWidget {
  const BtnFav({
    Key? key,
    required this.controladorTexto,
    required this.alterarTema,
    required this.listaDeFavoritos,
    required this.tema,
  }) : super(key: key);
  final TextEditingController controladorTexto;
  final Function(Color novaCor) alterarTema;
  final ListaDeFavoritos listaDeFavoritos;
  final Color tema;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Favoritos(
            listaDeFavoritos: listaDeFavoritos,
            tema: tema,
          ),
        ),
      ),
      icon: Icon(Icons.favorite,
          color: tema == Colors.red ? Colors.orange : Colors.red),
    );
  }
}

class Tela1 extends StatelessWidget {
  const Tela1({
    Key? key,
    required this.controladorTexto,
    required this.alterarTema,
    required this.listaDeFavoritos,
    required this.tema,
  }) : super(key: key);
  final TextEditingController controladorTexto;
  final Function(Color novaCor) alterarTema;
  final ListaDeFavoritos listaDeFavoritos;
  final Color tema;

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
              BtConsulta(
                  controladorTexto: controladorTexto,
                  listaDeFavoritos: listaDeFavoritos,
                  tema: tema),
            ],
          ),
        ],
      ),
    );
  }
}

// Botão de consulta para pesquisar CEP
class BtConsulta extends StatelessWidget {
  const BtConsulta(
      {Key? key,
      required this.controladorTexto,
      required this.listaDeFavoritos,
      required this.tema})
      : super(key: key);

  final TextEditingController controladorTexto;
  final ListaDeFavoritos listaDeFavoritos;
  final Color tema;

  void click(BuildContext context) async {
    print(controladorTexto.text);
    try {
      ViaCep enderecoFuturo = await consultaCep(controladorTexto.text);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Endereco(
            viacepdata: enderecoFuturo,
            listaDeFavoritos: listaDeFavoritos,
            tema: tema,
          ),
        ),
      );
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(content: Text('Consulta não retornou resultado.')));
      print('Erro ao consultar o CEP!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => click(context),
      child: Text('Consultar'),
    );
  }
}

class Favoritos extends StatefulWidget {
  final ListaDeFavoritos listaDeFavoritos;
  final Color tema;
  Favoritos({required this.listaDeFavoritos, required this.tema, Key? key})
      : super(key: key);

  @override
  State<Favoritos> createState() => _FavoritosState();
}

class _FavoritosState extends State<Favoritos> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IFMS Maps - Favoritos')),
      body: Consumer<ThemeModel>(
        builder: (context, themeModel, child) {
          if (widget.listaDeFavoritos.cepFavList.isEmpty) {
            return Center(
              child: Text('Nenhum endereço favorito.'),
            );
          } else {
            return Center(
             child: Column(
                
                children: [
                  Text(
                    'Endereços Favoritos',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 35,
                    ),
                  ),
                  SizedBox.fromSize(
                    size: Size(260, 300),
                    child: ListView.builder(
                      itemCount: widget.listaDeFavoritos.cepFavList.length,
                      itemBuilder: (context, index) {
                        ViaCep cep = widget.listaDeFavoritos.cepFavList[index];
                        return ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                ),
                                child: Text('${cep.cep}  '),
                              ),
                              Container(
                                margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.01),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                ),
                                child: Text('${cep.localidade}'),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Endereco(
                                  viacepdata: cep,
                                  listaDeFavoritos: widget.listaDeFavoritos,
                                  tema: widget.tema,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

// Tela de exibição de endereço
class Endereco extends StatefulWidget {
  const Endereco(
      {Key? key,
      required this.viacepdata,
      required this.listaDeFavoritos,
      required this.tema})
      : super(key: key);
  final ViaCep viacepdata;
  final ListaDeFavoritos listaDeFavoritos;
  final Color tema;
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
      appBar: AppBar(
        title: const Text('     IFMS Maps - Detalhes'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            linha('CEP: ', widget.viacepdata.cep),
            linha('', widget.viacepdata.logradouro),
            linha('', widget.viacepdata.bairro),
            linha('Cidade: ', widget.viacepdata.localidade),
            linha('UF: ', widget.viacepdata.uf),
          ],
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
        backgroundColor: widget.tema,
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

class ListaDeFavoritos extends ChangeNotifier {
  final List<ViaCep> _cepFavList = [];
  List<ViaCep> get cepFavList => _cepFavList;

  void adicionarFavorito(ViaCep cepFav) {
    _cepFavList.add(cepFav);
    notifyListeners(); // Notifica os ouvintes sobre a mudança
  }

  void removerFavorito(ViaCep cepFav) {
    _cepFavList.remove(cepFav);
    notifyListeners(); // Notifica os ouvintes sobre a mudança
  }

  bool favorito(ViaCep cepFav) {
    return _cepFavList.contains(cepFav);
  }
}
