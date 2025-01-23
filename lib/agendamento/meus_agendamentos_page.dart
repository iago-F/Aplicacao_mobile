import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aluguel/agendamento/agendamento_model.dart';
import 'package:aluguel/casa/casa_model.dart';

class MinhasVisitasPage extends StatelessWidget {
  final String userId;

  const MinhasVisitasPage({Key? key, required this.userId}) : super(key: key);

  Future<Map<String, Casa>> _buscarCasasRelacionadas(
      List<VisitaModel> visitas) async {
    final Map<String, Casa> casasMap = {};

    for (var visita in visitas) {
      if (!casasMap.containsKey(visita.casaId)) {
        final casaDoc = await FirebaseFirestore.instance
            .collection('casas')
            .doc(visita.casaId)
            .get();

        if (casaDoc.exists) {
          final casaData = casaDoc.data();
          if (casaData != null) {
            casasMap[visita.casaId] = Casa.fromJson(casaData)
              ..id_casa = casaDoc.id;
          }
        }
      }
    }

    return casasMap;
  }

  Future<List<VisitaModel>> _listarVisitasDoUsuario() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('visitas')
        .where('userId', isEqualTo: userId)
        .get();

    return querySnapshot.docs
        .map((doc) => VisitaModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitas Agendadas'),
        backgroundColor: Colors.blue[300],
      ),
      body: FutureBuilder<List<VisitaModel>>(
        future: _listarVisitasDoUsuario(),
        builder: (context, visitasSnapshot) {
          if (visitasSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!visitasSnapshot.hasData || visitasSnapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma visita agendada.'));
          }

          final visitas = visitasSnapshot.data!;
          return FutureBuilder<Map<String, Casa>>(
            future: _buscarCasasRelacionadas(visitas),
            builder: (context, casasSnapshot) {
              if (casasSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!casasSnapshot.hasData || casasSnapshot.data!.isEmpty) {
                return const Center(child: Text('Erro ao carregar casas.'));
              }

              final casas = casasSnapshot.data!;
              return ListView.builder(
                itemCount: visitas.length,
                itemBuilder: (context, index) {
                  final visita = visitas[index];
                  final casa = casas[visita.casaId];

                  return Card(
                    margin: const EdgeInsets.all(8),
                    elevation: 4,
                    child: ListTile(
                      title: Text(
                        visita.nomeCompleto ?? 'Nome não disponível',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cidade: ${casa?.cidade ?? 'Não disponível'}'),
                          Text('Bairro: ${casa?.bairro ?? 'Não disponível'}'),
                          Text(
                            'Data da visita: ${visita.dataHora?.toString() ?? 'Não disponível'}',
                          ),
                        ],
                      ),
                      leading: casa != null &&
                              casa.Imagem != null &&
                              casa.Imagem!.isNotEmpty
                          ? Image.network(
                              casa.Imagem![0],
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                            )
                          : const Icon(
                              Icons.home,
                              size: 90,
                              color: Colors.grey,
                            ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
