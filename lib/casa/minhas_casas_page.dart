import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aluguel/casa/casa_model.dart';
import 'package:aluguel/casa/minhas_casas_detalhe_page.dart';
import 'package:aluguel/agendamento/meus_agendamentos_page.dart';

class MinhasCasasPage extends StatelessWidget {
  final String usuarioId;

  MinhasCasasPage({Key? key})
      : usuarioId = FirebaseAuth.instance.currentUser?.uid ?? 'default_id',
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Número de abas
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight), // Tamanho da AppBar
          child: AppBar(
            backgroundColor:
                const Color.fromARGB(255, 255, 255, 255), // Cor de fundo
            bottom: const TabBar(
              labelColor: Colors.black,
              indicatorColor:
                  Colors.orange, // Cor do indicador da aba selecionada
              tabs: [
                Tab(text: 'Minhas Casas'),
                Tab(text: 'Meus Agendamentos'),
              ],
            ),
          ),
        ),
        body: SafeArea(
          // Adicionado para evitar espaço indesejado
          child: TabBarView(
            children: [
              _buildMinhasCasas(context),
              MinhasVisitasPage(userId: usuarioId), // Página dos agendamentos
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMinhasCasas(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('casas')
          .where('id_usuario', isEqualTo: usuarioId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Nenhuma casa cadastrada.'));
        }
        return ListView(
          padding: const EdgeInsets.all(8),
          children: snapshot.data!.docs.map((doc) {
            Casa casa = Casa.fromJson(doc.data() as Map<String, dynamic>)
              ..id_casa = doc.id;

            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CasaDetalhesPage(casa: casa),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: casa.Imagem != null
                            ? Image.network(
                                casa.Imagem!.toString(),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              )
                            : Icon(
                                Icons.home,
                                size: 80,
                                color: Colors.grey.shade400,
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              casa.cidade ?? 'Casa sem endereço',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Bairro: ${casa.bairro ?? 'Não disponível'}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Valor Total: R\$${casa.preco_total?.toString() ?? 'Não disponível'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
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
          }).toList(),
        );
      },
    );
  }
}
