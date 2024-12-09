import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aluguel/usuario/usuario_services.dart';

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (usuario.image != null)
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(usuario.image!),
                ),
              ),
            SizedBox(height: 16),
            Text(
              'Nome: ${usuario.nome ?? 'Não informado'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'E-mail: ${usuario.email ?? 'Não informado'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'CPF: ${usuario.cpf ?? 'Não informado'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Data de Nascimento: ${usuario.data_nascimento != null ? '${usuario.data_nascimento!.day}/${usuario.data_nascimento!.month}/${usuario.data_nascimento!.year}' : 'Não informado'}',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
