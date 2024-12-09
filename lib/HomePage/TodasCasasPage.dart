import 'package:flutter/material.dart';
import 'package:aluguel/casa/casa_model.dart';
import 'package:aluguel/casa/casa_service.dart';

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
              crossAxisCount: 2, // Número de colunas
              crossAxisSpacing: 8.0, // Espaçamento entre colunas
              mainAxisSpacing: 8.0, // Espaçamento entre linhas
              childAspectRatio: 0.8, // Proporção largura/altura do card
            ),
            itemCount: casas.length,
            itemBuilder: (context, index) {
              Casa casa = casas[index];
              return Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagem em destaque
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
                    // Título e descrição
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
              );
            },
          );
        }
      },
    );
  }
}
