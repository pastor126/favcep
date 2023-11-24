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
              const Text('Tema  ', style: TextStyle(fontSize: 22),),
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
          Padding(
            padding: const EdgeInsets.only(top: 30), // Ajuste conforme necessário
            child: Column(
              children: [
                const Text('Pesquisar CEP', style: TextStyle(fontSize: 22),),
                CampoTexto(controladorTexto),
                BtConsulta(
                  controladorTexto: controladorTexto,
                  listaDeFavoritos: listaDeFavoritos,
                  tema: tema,
    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Botão de consulta para pesquisar CEP
class BtConsulta extends StatefulWidget {
  const BtConsulta(
      {Key? key,
      required this.controladorTexto,
      required this.listaDeFavoritos,
      required this.tema})
      : super(key: key);

  final TextEditingController controladorTexto;
  final ListaDeFavoritos listaDeFavoritos;
  final Color tema;

  @override
  State<BtConsulta> createState() => _BtConsultaState();
}

class _BtConsultaState extends State<BtConsulta> {
  bool carregando = false;
  void click(BuildContext context) async {
    print(widget.controladorTexto.text);
    setState(() {
      carregando = true;
    });
    await Future.delayed(Duration(seconds: 2));
       consultaCep(widget.controladorTexto.text).then((enderecoFuturo) {

      setState(() {
        carregando = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Endereco(
            viacepdata: enderecoFuturo,
            listaDeFavoritos: widget.listaDeFavoritos,
            tema: widget.tema,
          ),
        ),
      );
       }).catchError((err){

      setState(() {
        carregando = false;
      });
      showDialog(
          context: context,
          builder: (context) =>
              const AlertDialog(content: Text('Consulta não retornou resultado.')));
      print('Erro ao consultar o CEP!');
       });
    
  }

  @override
  Widget build(BuildContext context) {
    return carregando ? const CircularProgressIndicator() : ElevatedButton(
      onPressed: () => click(context),
      child: const Text('Pesquisar'),
    );
  }
}

class Favoritos extends StatefulWidget {
  final ListaDeFavoritos listaDeFavoritos;
  final Color tema;
  const Favoritos({required this.listaDeFavoritos, required this.tema, Key? key})
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
            return const Center(
              child: Text('Nenhum endereço favorito.', style: TextStyle(fontSize: 22),),
            );
          } else {
            Color corFav;
            if (widget.tema == Colors.black) {
              corFav = Colors.white;
            } else {
              corFav = Colors.black;
            }
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Text(
                        'Endereços Favoritos',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 35,
                        ),
                      ),
                    ),
                    Column(
                    
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                             
                              padding: const EdgeInsets.only(left: 38, right: 20, top: 6, bottom: 6,),
                               decoration: BoxDecoration(
                    border: Border.all(color: Colors.black), color: widget.tema,
                    ),
                              child: Text(
                                'CEP ',
                                style: TextStyle(
                                  fontSize: 25,
                                  color: corFav, 
                                
                                ), 
                              ),
                            ),Container(
                               padding: const EdgeInsets.only(left: 25, right: 25, top: 6, bottom: 6),
                               decoration: BoxDecoration(
                    border: Border.all(color: Colors.black), color: widget.tema,
                    ),
                              child: Text(
                                ' CIDADE',
                                style: TextStyle(
                                  fontSize: 25,
                                  color: corFav, 
                                
                                ), 
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                   
                    SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SizedBox(
                        height: 450,
                        width: 290,
                      
                        child: ListView.builder(
                          itemCount: widget.listaDeFavoritos.cepFavList.length,
                          itemBuilder: (context, index) {
                            ViaCep cep = widget.listaDeFavoritos.cepFavList[index];
                            return ListTile(
                              title: Row(
                                
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(left: 5, bottom: 10, top: 10),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                    ),
                                    child: Text(
                                      '${cep.cep}  ',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        
                                      ),
                                    ),
                                  ),
                               Expanded(
                          child: Container(
                padding: const EdgeInsets.only(left: 3, bottom: 10, top: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: Text(
                  cep.localidade,
                  style: const TextStyle(
                    fontSize: 20, overflow: TextOverflow.ellipsis, //reticencias se passar
                  ),
                ),
                          ),
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
                    ),
                  ],
                ),
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
  // ignore: no_logic_in_create_state
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
        Text('$label $valor', style: const TextStyle(fontSize: 18,),),
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
            _mostrarAlerta(' removido dos Favoritos', cepMsg);
          } else {
            widget.listaDeFavoritos.adicionarFavorito(widget.viacepdata);
            print(widget.listaDeFavoritos._cepFavList.length);
            _mostrarAlerta(' adicionado aos Favoritos', cepMsg);
          }
          setState(() {});
        },
        backgroundColor: widget.tema,
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
              child: const Text('OK'),
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
