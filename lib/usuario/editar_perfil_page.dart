import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aluguel/usuario/usuario_model.dart';
import 'package:provider/provider.dart';
import 'package:aluguel/usuario/usuario_services.dart';

class EditarPerfilPage extends StatefulWidget {
  final Usuario usuario;

  EditarPerfilPage({required this.usuario});

  @override
  _EditarPerfilPageState createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  late TextEditingController nomeController;
  late TextEditingController emailController;
  late TextEditingController dataNascimentoController;
  String? novaImagemPath;
  bool isLoading = false; // Variável para controlar o estado de carregamento

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController(text: widget.usuario.nome);
    emailController = TextEditingController(text: widget.usuario.email);
    dataNascimentoController = TextEditingController(
      text: widget.usuario.data_nascimento != null
          ? '${widget.usuario.data_nascimento!.day}/${widget.usuario.data_nascimento!.month}/${widget.usuario.data_nascimento!.year}'
          : '',
    );
  }

  Future<void> selecionarImagem() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? imagemSelecionada =
        await _picker.pickImage(source: ImageSource.gallery);

    if (imagemSelecionada != null) {
      setState(() {
        novaImagemPath = imagemSelecionada.path;
      });
    }
  }

  Future<void> _salvarAlteracoes(BuildContext context) async {
    setState(() {
      isLoading = true; // Ativar carregamento
    });

    try {
      // Chame o método atualizarPerfil passando o context
      await Provider.of<UsuarioServices>(context, listen: false)
          .atualizarPerfil(
        nome: nomeController.text,
        email: emailController.text,
        dataNascimento: dataNascimentoController.text.isNotEmpty
            ? DateTime.parse(
                "${dataNascimentoController.text.split('/').reversed.join('-')}")
            : null,
        novaImagem: novaImagemPath != null ? File(novaImagemPath!) : null,
      );
      Navigator.pop(context); // Volta para a página anterior após salvar
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar alterações: $e')),
      );
    } finally {
      setState(() {
        isLoading = false; // Desativar carregamento
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil'),
        actions: [
          isLoading
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(), // Carregamento discreto
                )
              : IconButton(
                  icon: Icon(Icons.save),
                  onPressed: () {
                    // Passar o context para o método de salvar alterações
                    _salvarAlteracoes(context);
                  },
                ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Foto de Perfil
            GestureDetector(
              onTap: selecionarImagem,
              child: Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: novaImagemPath != null
                          ? FileImage(File(novaImagemPath!))
                          : (widget.usuario.image != null
                              ? NetworkImage(widget.usuario.image!)
                                  as ImageProvider
                              : AssetImage('assets/images/default_avatar.png')),
                    ),
                    Positioned(
                      bottom: -10,
                      right: -10,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.camera_alt, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Campos de texto com bordas arredondadas
            _buildTextFormField(nomeController, 'Nome'),
            SizedBox(height: 16),
            _buildTextFormField(emailController, 'E-mail'),
            SizedBox(height: 16),
            _buildDatePickerField(context),

            SizedBox(height: 24),

            // Botão de salvar alterações
            ElevatedButton(
              onPressed: isLoading ? null : () => _salvarAlteracoes(context),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: Colors.blue, // Corrigido para backgroundColor
              ),
              child: Text(
                'Salvar Alterações',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para construir os campos de texto
  Widget _buildTextFormField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    );
  }

  // Método para campo de data de nascimento com seletor de data
  Widget _buildDatePickerField(BuildContext context) {
    return TextFormField(
      controller: dataNascimentoController,
      decoration: InputDecoration(
        labelText: 'Data de Nascimento',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
      readOnly: true, // Impede edição direta
      onTap: () async {
        DateTime? date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          dataNascimentoController.text =
              '${date.day}/${date.month}/${date.year}';
        }
      },
    );
  }
}
