import 'package:flutter/material.dart';
import 'package:aluguel/casa/casa_model.dart';
import 'package:aluguel/casa/casa_service.dart';
import 'package:aluguel/HomePage/casa_detalhes_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
          final num_banheiro = casa.num_banheiro?.toString() ?? '';
          final num_quarto = casa.num_quarto?.toString() ?? '';
          final bairro = casa.bairro?.toString() ?? '';
          return cidade.contains(query.toLowerCase()) ||
              preco.contains(query) ||
              num_banheiro.contains(query) ||
              num_quarto.contains(query) ||
              bairro.contains(query);
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
                hintText: 'Pesquise por cidade, bairro, preço, quartos...',
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
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 0.60,
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
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          child: CachedNetworkImage(
                                            imageUrl: casa.Imagem![0],
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: 160,
                                            placeholder: (context, url) =>
                                                Center(
                                              child: CircularProgressIndicator(
                                                color: Colors
                                                    .orange, // Cor do carregamento
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) => Icon(
                                              Icons.error,
                                              color: const Color.fromARGB(
                                                  255, 194, 193, 193),
                                            ),
                                          ),
                                        )
                                      : Icon(Icons.home,
                                          size: 100, color: Colors.grey),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          casa.cidade ?? 'N/A',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                        SizedBox(height: 4.0),
                                        Text(
                                          casa.bairro ?? 'N/A',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        SizedBox(height: 4.0),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons
                                                  .hotel, // ou outro ícone relacionado a quartos
                                              color: Colors.blue[300],
                                              size: 20,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              (casa.num_quarto?.toString() ??
                                                      '0') +
                                                  ' quartos',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons
                                                  .bathroom, // ou outro ícone relacionado a quartos
                                              color: Colors.blue[300],
                                              size: 20,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              (casa.num_banheiro?.toString() ??
                                                      '0') +
                                                  ' banheiro',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                          ],
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
