import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aluguel/usuario/usuario_services.dart';
import 'package:aluguel/usuario/editar_perfil_page.dart';
import 'package:aluguel/HomePage/homepage.dart';

class PerfilPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final usuarioServices = Provider.of<UsuarioServices>(context);
    final usuario = usuarioServices.usuario;

    if (usuario == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Perfil do Usuário'),
        ),
        body: Center(
          child: Text('Nenhum usuário autenticado.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil do Usuário'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Foto de Perfil
            if (usuario.image != null)
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(usuario.image!),
                ),
              )
            else
              Center(
                child: CircleAvatar(
                  radius: 60,
                  child: Icon(Icons.person, size: 40),
                ),
              ),
            SizedBox(height: 16),

            // Dados do usuário lado a lado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Nome
                _buildProfileInfo('Nome', usuario.nome),
                // E-mail
                _buildProfileInfo('E-mail', usuario.email),
              ],
            ),
            SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // CPF
                _buildProfileInfo('CPF', usuario.cpf),
                // Data de Nascimento
                _buildProfileInfo(
                    'Data de Nascimento',
                    usuario.data_nascimento != null
                        ? '${usuario.data_nascimento!.day}/${usuario.data_nascimento!.month}/${usuario.data_nascimento!.year}'
                        : 'Não informado'),
              ],
            ),
            SizedBox(height: 32),

            // Linha com os botões de editar perfil e excluir conta
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botão de editar perfil
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.edit),
                      label: Text('Editar Perfil',
                          style: TextStyle(color: Colors.blue)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditarPerfilPage(usuario: usuario),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        backgroundColor:
                            Colors.white, // Altere para backgroundColor
                        side: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                ),
                // Botão de excluir conta
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.delete, color: Colors.red),
                      label: Text('Excluir Conta',
                          style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        _showDeleteConfirmationDialog(context, usuarioServices);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        backgroundColor:
                            Colors.white, // Altere para backgroundColor
                        side: BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Método para criar os campos de dados de usuário
  Widget _buildProfileInfo(String label, String? value) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(left: 8, right: 8),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey),
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
              value ?? 'Não informado',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // Método para exibir a caixa de confirmação de exclusão
  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, UsuarioServices usuarioServices) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Excluir Conta'),
          content: Text('Você tem certeza que deseja excluir sua conta?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await usuarioServices
                    .excluirConta(); // Adapte o método para excluir
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Conta excluída com sucesso!')),
                );
                // Redireciona para a tela inicial ou outra página
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              child: Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
