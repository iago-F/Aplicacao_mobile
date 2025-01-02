import 'package:flutter/material.dart';
import 'package:aluguel/casa/casa_page.dart';
import 'package:aluguel/casa/casa_service.dart';
import 'package:aluguel/usuario/usuario_services.dart';
import 'package:aluguel/casa/minhas_casas_page.dart';
import 'package:aluguel/HomePage/TodasCasasPage.dart';
import 'package:aluguel/casa/casa_model.dart';
import 'package:aluguel/usuario/meu_perfil_page.dart';
import 'package:aluguel/maps/mapa_page_geo.dart'; // Importando a página de mapa

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late CasaServices _casaServices;
  late String usuarioId;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    UsuarioServices _usuarioServices = UsuarioServices();
    usuarioId = _usuarioServices.getUsuarioId() ?? 'default_id';

    _casaServices = CasaServices(_usuarioServices);

    _pages = [
      TodasCasasPage(casaServices: _casaServices), // Página inicial
      CadastrarCasaPage(
          casaServices: _casaServices), // Página de cadastro de casas
      MinhasCasasPage(), // Página de "Minhas Casas"
      MapPage(),
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
        // Imagem à esquerda
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: GestureDetector(
            onTap: () {
              print('Imagem clicada!');
            },
            child: CircleAvatar(
              backgroundImage:
                  AssetImage('assets/images/LOGO_CASA_PRINCIPAL.PNG'),
              radius: 19, // Aumenta o tamanho da imagem
            ),
          ),
        ),
        // Ícones à direita
        actions: [
          // Ícone de perfil
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PerfilPage(), // Página de destino
                ),
              );
            },
            child: Icon(
              Icons.person,
              size: 30, // Aumenta o tamanho do ícone
            ),
          ),
          SizedBox(width: 16), // Espaçamento entre os ícones
        ],
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
          BottomNavigationBarItem(
            icon: Icon(Icons.share_location_outlined), // Ícone do mapa
            label: 'Mapa',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[300], // Cor dos itens selecionados
        unselectedItemColor: Colors.black54, // Cor dos itens não selecionados
        backgroundColor: const Color.fromARGB(
            255, 239, 240, 241), // Cor de fundo do BottomNavigationBar
        onTap: _onItemTapped, // Navega para a página clicada
      ),
    );
  }
}
