import 'package:flutter/material.dart';
import 'package:aluguel/casa/casa_page.dart';
import 'package:aluguel/casa/casa_service.dart';
import 'package:aluguel/usuario/usuario_services.dart';
import 'package:aluguel/casa/minhas_casas_page.dart';
import 'package:aluguel/HomePage/TodasCasasPage.dart';
import 'package:aluguel/casa/casa_model.dart';

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
    UsuarioServices _usuarioServices = UsuarioServices();
    usuarioId = _usuarioServices.getUsuarioId() ?? 'default_id';

    // Inicializa o CasaServices
    _casaServices = CasaServices(_usuarioServices);

    // Inicializa as páginas
    _pages = [
      // Passa o Future diretamente para o FutureBuilder
      TodasCasasPage(casaServices: _casaServices), // Exibe todas as casas
      CadastrarCasaPage(casaServices: _casaServices), // Cadastrar Casa
      MinhasCasasPage(), // Exibe Minhas Casas
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
        title: Text('Home Page'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: _pages[_selectedIndex], // Exibe a página selecionada
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
