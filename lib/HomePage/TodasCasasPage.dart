import 'package:flutter/material.dart';
import 'package:aluguel/casa/casa_model.dart';
import 'package:aluguel/casa/casa_service.dart';
import 'package:aluguel/HomePage/casa_detalhes_page.dart';

class TodasCasasPage extends StatefulWidget {
  final CasaServices casaServices;

  TodasCasasPage({required this.casaServices});

  @override
  _TodasCasasPageState createState() => _TodasCasasPageState();
}

class _TodasCasasPageState extends State<TodasCasasPage> {
  late Future<List<Casa>> _casasFuture;
  List<Casa> _casas = [];
  List<Casa> _casasFiltradas = [];
  TextEditingController _pesquisaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _casasFuture = widget.casaServices.buscarTodasCasas();
    _carregarCasas();
  }

  void _carregarCasas() async {
    try {
      List<Casa> casas = await widget.casaServices.buscarTodasCasas();
      setState(() {
        _casas = casas;
        _casasFiltradas = casas;
      });
    } catch (e) {
      print("Erro ao carregar casas: $e");
    }
  }

  void _filtrarCasas(String query) {
    setState(() {
      if (query.isEmpty) {
        _casasFiltradas = _casas;
      } else {
        _casasFiltradas = _casas.where((casa) {
          final cidade = casa.cidade?.toLowerCase() ?? '';
          final preco = casa.preco_total?.toString() ?? '';
          final descricao = casa.descricao?.toLowerCase() ?? '';
          final num_quarto = casa.num_quarto?.toString() ?? '';
          return cidade.contains(query.toLowerCase()) ||
              preco.contains(query) ||
              descricao.contains(query.toLowerCase()) ||
              num_quarto.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _pesquisaController,
              decoration: InputDecoration(
                hintText: 'Pesquisar por cidade, preço ou descrição',
                hintStyle: TextStyle(color: Colors.blue[300]),
                prefixIcon: Icon(Icons.search, color: Colors.blue[300]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.orange),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
              ),
              style: TextStyle(color: Colors.blue),
              onChanged: _filtrarCasas,
            ),
          ),
          Expanded(
            child: _casas.isEmpty
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(8.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            2, // Ou 1 se quiser um layout de coluna única
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio:
                            0.68, // Aumente esse valor para aumentar a altura do card
                      ),
                      itemCount: _casasFiltradas.length,
                      itemBuilder: (context, index) {
                        Casa casa = _casasFiltradas[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CasaDetalhesPage(casa: casa),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Card(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  casa.Imagem != null && casa.Imagem!.isNotEmpty
                                      ? _ImageCarousel(imagens: casa.Imagem!)
                                      : Icon(Icons.home,
                                          size: 100, color: Colors.grey),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          casa.cidade ?? 'Casa',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                        SizedBox(height: 4.0),
                                        Text(
                                          casa.descricao ?? 'Sem descrição',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        SizedBox(height: 8.0),
                                        Text(
                                          casa.preco_total != null
                                              ? 'R\$ ${casa.preco_total!.toStringAsFixed(2)}'
                                              : 'Preço não disponível',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ImageCarousel extends StatefulWidget {
  final List<String> imagens;

  _ImageCarousel({required this.imagens});

  @override
  __ImageCarouselState createState() => __ImageCarouselState();
}

class __ImageCarouselState extends State<_ImageCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 160, // Altura ajustada
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.imagens.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  widget.imagens[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 160,
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.imagens.length,
            (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index ? Colors.blue : Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
