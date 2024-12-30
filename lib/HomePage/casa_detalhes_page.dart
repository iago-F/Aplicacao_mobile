import 'package:flutter/material.dart';
import 'package:aluguel/casa/casa_model.dart';
import 'package:aluguel/agendamento/agendamento_page.dart';

class CasaDetalhesPage extends StatelessWidget {
  final Casa casa;

  CasaDetalhesPage({required this.casa});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(casa.cidade ?? 'Detalhes da Casa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Imagem principal
            casa.imagem != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.network(
                      casa.imagem!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                    ),
                  )
                : Icon(Icons.home, size: 100, color: Colors.grey),
            SizedBox(height: 16.0),

            // Grid de informações da casa
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCasaInfoCard(
                    'Quartos', casa.num_quarto?.toString() ?? 'N/A'),
                _buildCasaInfoCard(
                    'Banheiros', casa.num_banheiro?.toString() ?? 'N/A'),
              ],
            ),
            SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCasaInfoCard('Rua', casa.rua ?? 'N/A'),
                _buildCasaInfoCard('Bairro', casa.bairro ?? 'N/A'),
              ],
            ),
            SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCasaInfoCard('Cidade', casa.cidade ?? 'N/A'),
                _buildCasaInfoCard('UF', casa.estado ?? 'N/A'),
              ],
            ),
            SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCasaInfoCard(
                    'Área', '${casa.area?.toString() ?? 'N/A'} m²'),
                _buildCasaInfoCard(
                    'Valor',
                    casa.preco_total != null
                        ? 'R\$ ${casa.preco_total!.toStringAsFixed(2)}'
                        : 'N/A'),
              ],
            ),
            SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildCasaInfoCard(
                      'Descrição', casa.descricao?.toString() ?? 'N/A'),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Botão de Agendar Visita com borda laranja
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AgendarVisitaPage(
                          casaId: casa.id_casa.toString(),
                          userId: casa.id_usuario.toString()),
                    ),
                  );
                },
                icon: Icon(Icons.calendar_today, size: 20),
                label: Text('Agendar Visita'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Colors.white, // Cor de fundo branca
                  foregroundColor: Colors.orange[300], // Cor do texto
                  side: BorderSide(
                    color: Colors.orange, // Cor da borda laranja
                    width: 1.8, // Espessura da borda
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para criar o card de informação da casa
  Widget _buildCasaInfoCard(String label, String value) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(left: 8, right: 8),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.black, // Cor laranja
            width: 1.8, // Espessura da borda
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
