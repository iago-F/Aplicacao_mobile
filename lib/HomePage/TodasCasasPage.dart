import 'package:flutter/material.dart';
import 'package:aluguel/casa/casa_model.dart';
import 'package:aluguel/casa/casa_service.dart';
import 'package:aluguel/HomePage/casa_detalhes_page.dart'; // Página de detalhes

class TodasCasasPage extends StatefulWidget {
  final CasaServices casaServices;

  TodasCasasPage({required this.casaServices});

  @override
  _TodasCasasPageState createState() => _TodasCasasPageState();
}

class _TodasCasasPageState extends State<TodasCasasPage> {
  late Future<List<Casa>> _casasFuture;

  @override
  void initState() {
    super.initState();
    _casasFuture = widget.casaServices.buscarTodasCasas();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Casa>>(
      future: _casasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar as casas.'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Nenhuma casa encontrada.'));
        } else {
          List<Casa> casas = snapshot.data!;
          return GridView.builder(
            padding: EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 0.8,
            ),
            itemCount: casas.length,
            itemBuilder: (context, index) {
              Casa casa = casas[index];
              return GestureDetector(
                onTap: () {
                  // Navega para a página de detalhes
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CasaDetalhesPage(casa: casa),
                    ),
                  );
                },
                child: Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: casa.imagem != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12.0),
                                ),
                                child: Image.network(
                                  casa.imagem!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              )
                            : Icon(Icons.home, size: 100, color: Colors.grey),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
              );
            },
          );
        }
      },
    );
  }
}
