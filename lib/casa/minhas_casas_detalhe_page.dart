import 'package:flutter/material.dart';
import 'package:aluguel/casa/casa_model.dart';
import 'package:aluguel/casa/casa_service.dart';
import 'package:provider/provider.dart'; // Importação do Provider
import 'minhas_casas_page.dart'; // Importe a página MinhasCasasPage

class CasaDetalhesPage extends StatelessWidget {
  final Casa casa;

  CasaDetalhesPage({required this.casa});

  // Função para mostrar o diálogo de confirmação de exclusão
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
                // Fecha o diálogo sem fazer nada
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                // Chama a função para excluir a casa
                bool sucesso =
                    await Provider.of<CasaServices>(context, listen: false)
                        .excluirCasa(casaId);

                if (sucesso) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Casa excluída com sucesso.')),
                  );

                  // Redireciona para a página MinhasCasasPage após a exclusão
                  Navigator.of(context).pop(); // Fecha o diálogo
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MinhasCasasPage()), // Redireciona
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao excluir a casa.')),
                  );
                }

                // Fecha o diálogo após a ação
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes da Casa'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (casa.imagem != null)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    casa.imagem!,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            SizedBox(height: 24),

            // Primeira linha com "Rua" e "Bairro"
            Row(
              children: [
                Expanded(child: _buildInfoRow('Rua:', casa.rua)),
                SizedBox(width: 16),
                Expanded(child: _buildInfoRow('Bairro:', casa.bairro)),
              ],
            ),
            SizedBox(height: 15),

            Row(
              children: [
                Expanded(child: _buildInfoRow('Cidade:', casa.cidade)),
                SizedBox(width: 16),
                Expanded(child: _buildInfoRow('UF:', casa.estado)),
              ],
            ),
            SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                    child: _buildInfoRow('Área:',
                        '${casa.area?.toString() ?? 'Não disponível'} m²')),
              ],
            ),

            SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                    child: _buildInfoRow('Valor total:',
                        'R\$ ${casa.preco_total?.toString() ?? 'Não disponível'}')),
              ],
            ),

            SizedBox(height: 15),

            // Descrição
            Text(
              'Descrição:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            Text(
              casa.descricao ?? 'Sem descrição',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),

            SizedBox(height: 15),

            // Botão para excluir a casa
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.delete),
                  color: Colors.red,
                  iconSize:
                      39.0, // Define o tamanho do ícone, ajuste conforme necessário
                  onPressed: () => _confirmarExclusao(context, casa.id_casa!),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value ?? 'Não disponível',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }
}
