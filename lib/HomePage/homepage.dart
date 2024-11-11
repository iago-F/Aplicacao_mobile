import 'package:flutter/material.dart';
import 'package:aluguel/casa/casa_page.dart';
import 'package:aluguel/casa/casa_service.dart';
import 'package:aluguel/usuario/usuario_services.dart'; // Importe o UsuarioServices
import 'package:aluguel/casa/minhas_casas_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Índice para controle da navegação
  late CasaServices _casaServices;
  late String usuarioId; // Declarado como late para inicializar depois
  late List<Widget> _pages; // Lista de páginas será inicializada no initState

  @override
  void initState() {
    super.initState();

    // Inicializa o UsuarioServices
    UsuarioServices _usuarioServices =
        UsuarioServices(); // Se precisar de parâmetros, adicione aqui
    usuarioId = _usuarioServices.getUsuarioId() ?? 'default_id';

    // Inicializa o CasaServices passando o UsuarioServices como argumento
    _casaServices = CasaServices(_usuarioServices);

    // Inicializa as páginas agora que o _casaServices já foi criado
    _pages = <Widget>[
      Center(child: Text('Página Inicial', style: TextStyle(fontSize: 24))),
      CadastrarCasaPage(
          casaServices:
              _casaServices), // Passando o casaServices como parâmetro
      MinhasCasasPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: _pages.elementAt(_selectedIndex), // Exibe a página selecionada
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_home_work_outlined),
            label: 'Cadastrar Casa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.my_library_books),
            label: 'Minhas Casas',
          ),
        ],
        currentIndex: _selectedIndex, // Define qual item está selecionado
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped, // Função chamada ao clicar no item
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:aluguel/casa/casa_page.dart';
// import 'package:aluguel/casa/casa_service.dart';
// import 'package:aluguel/casa/minhas_casas_page.dart'; // Importe a nova página
// import 'package:aluguel/usuario/usuario_services.dart'; // Importe o UsuarioServices

// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   int _selectedIndex = 0; // Índice para controle da navegação
//   late CasaServices _casaServices; // Declarado como late para inicializar depois
//   late List<Widget> _pages; // Lista de páginas será inicializada no initState
//   late MinhasCasasPage  _minhasCasasPage;

//   @override
//   void initState() {
//     super.initState();

//     // Inicializa o UsuarioServices
//     UsuarioServices _usuarioServices =
//         UsuarioServices(); // Se precisar de parâmetros, adicione aqui

//     // Inicializa o CasaServices passando o UsuarioServices como argumento
//     _casaServices = CasaServices(_usuarioServices);

//     _minhasCasasPage = MinhasCasasPage(usuarioId: usuarioId)

//     // Inicializa as páginas agora que o _casaServices já foi criado
//     _pages = <Widget>[
//       Center(child: Text('Página Inicial', style: TextStyle(fontSize: 24))),

//       CadastrarCasaPage(casaServices: _casaServices),
//       // Passando o casaServices como parâmetro

//       MinhasCasasPage(
//           usuarioId: usuarioId), // Adiciona a página MinhasCasasPage
//     ];
//   }

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('HomePage'),
//         centerTitle: true,
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: Center(
//         child: _pages.elementAt(_selectedIndex), // Exibe a página selecionada
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Início',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.add_home_work_outlined),
//             label: 'Cadastrar Casa',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.my_library_books),
//             label: 'Minhas Casas',
//           ),
//         ],
//         currentIndex: _selectedIndex, // Define qual item está selecionado
//         selectedItemColor: Colors.blueAccent,
//         onTap: _onItemTapped, // Função chamada ao clicar no item
//       ),
//     );
//   }
// }
