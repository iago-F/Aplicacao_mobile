import 'package:flutter/material.dart';
import 'package:aluguel/casa/casa_page.dart';
import 'package:aluguel/casa/casa_service.dart';
import 'package:aluguel/usuario/usuario_services.dart';
import 'package:aluguel/casa/minhas_casas_page.dart';
import 'package:aluguel/HomePage/TodasCasasPage.dart';
import 'package:aluguel/casa/casa_model.dart';

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
          return ListView.builder(
            itemCount: casas.length,
            itemBuilder: (context, index) {
              Casa casa = casas[index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  leading: casa.imagem != null
                      ? Image.network(casa.imagem!, width: 60, height: 60)
                      : Icon(Icons.home),
                  title: Text(casa.cidade ?? 'Casa'),
                  subtitle: Text(casa.descricao ?? 'Sem descrição'),
                  trailing: Text(
                    casa.preco_total != null
                        ? 'R\$ ${casa.preco_total!.toStringAsFixed(2)}' // Verifica se preco_total não é null
                        : 'Preço não disponível', // Valor alternativo caso seja null
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
