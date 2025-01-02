import 'package:flutter/material.dart';
import 'package:aluguel/casa/casa_model.dart';
import 'package:aluguel/casa/casa_service.dart';
import 'package:provider/provider.dart'; // Importação do Provider
import 'minhas_casas_page.dart'; // Importe a página MinhasCasasPage
import 'editar_casa_page.dart'; // Importe a página EditarCasaPage (certifique-se de ter essa página)

class CasaDetalhesPage extends StatelessWidget {
  final Casa casa;

  CasaDetalhesPage({required this.casa});

  void _confirmarExclusao(BuildContext context, String casaId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Exclusão'),
          content: Text('Você tem certeza que deseja excluir esta casa?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                bool sucesso =
                    await Provider.of<CasaServices>(context, listen: false)
                        .excluirCasa(casaId);

                if (sucesso) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Casa excluída com sucesso.')),
                  );

                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MinhasCasasPage()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao excluir a casa.')),
                  );
                }

                Navigator.of(context).pop();
              },
              child: Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final casaServices =
        Provider.of<CasaServices>(context); // Obtém o serviço de casas

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes da Casa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (casa.imagem != null)
              Center(
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(0), // Removido o arredondamento
                  child: Image.network(
                    casa.imagem!,
                    width:
                        double.infinity, // Faz a imagem ocupar toda a largura
                    height: 250, // Altura da imagem
                    fit: BoxFit
                        .cover, // Faz a imagem cobrir toda a área disponível
                  ),
                ),
              )
            else
              Center(
                child: CircleAvatar(
                  radius: 60,
                  child: Icon(Icons.home, size: 40),
                ),
              ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoRow(
                    'Quartos', casa.num_quarto?.toString() ?? 'Não disponível'),
                _buildInfoRow('Banheiros',
                    casa.num_banheiro?.toString() ?? 'Não disponível'),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoRow('Rua', casa.rua),
                _buildInfoRow('Bairro', casa.bairro),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoRow('Cidade', casa.cidade),
                _buildInfoRow('UF', casa.estado),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoRow(
                    'Área', '${casa.area?.toString() ?? 'Não disponível'} m²'),
                _buildInfoRow('Valor',
                    'R\$ ${casa.preco_total?.toString() ?? 'Não disponível'}'),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Descrição:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              casa.descricao ?? 'Sem descrição',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.edit,
                      color: Colors.blue), // Ícone de edição em azul
                  label:
                      Text('Editar Casa', style: TextStyle(color: Colors.blue)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditarCasaPage(
                          casa: casa
                              .toJson(), // Passando a casa como Map<String, dynamic>
                          casaId: casa.id_casa!, // Passando o id da casa
                          casaServices:
                              casaServices, // Passando o serviço de casas
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Fundo branco
                    foregroundColor: Colors.blue, // Texto e ícone azuis
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: Colors.blue), // Borda azul
                    ),
                  ),
                ),

                ElevatedButton.icon(
                  icon: Icon(Icons.delete,
                      color: Colors.red), // Ícone da lixeira em vermelho
                  label: Text('Excluir Casa',
                      style: TextStyle(color: Colors.red)), // Texto em vermelho
                  onPressed: () => _confirmarExclusao(context, casa.id_casa!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Fundo branco
                    foregroundColor: Colors.red, // Texto e ícone vermelhos
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: Colors.red), // Borda vermelha
                    ),
                  ),
                ),
                SizedBox(width: 16), // Espaçamento entre os botões
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String? value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            value ?? 'Não disponível',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
