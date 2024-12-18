import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aluguel/casa/casa_model.dart';
import 'package:aluguel/casa/casa_service.dart';
import 'package:uuid/uuid.dart';
import 'package:aluguel/HomePage/homepage.dart';

class CadastrarCasaPage extends StatefulWidget {
  final CasaServices casaServices;

  CadastrarCasaPage({required this.casaServices});

  @override
  _CadastrarCasaPageState createState() => _CadastrarCasaPageState();
}

class _CadastrarCasaPageState extends State<CadastrarCasaPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para os campos do formulário
  TextEditingController _areaController = TextEditingController();
  TextEditingController _banheirosController = TextEditingController();
  TextEditingController _precoController = TextEditingController();
  TextEditingController _ruaController = TextEditingController();
  TextEditingController _bairroController = TextEditingController();
  TextEditingController _cidadeController = TextEditingController();
  TextEditingController _estadoController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();

  File? _imageFile;

  // Método para selecionar imagem da galeria
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Método para cadastrar a casa
  Future<void> _cadastrarCasa() async {
    if (_formKey.currentState!.validate()) {
      // Gerar um ID único para a casa
      var uuid = Uuid();
      String casaId = uuid.v4(); // Gerar um novo ID

      Casa novaCasa = Casa(
        id_casa: casaId, // Atribuindo o ID gerado
        area: double.parse(_areaController.text),
        num_banheiro: int.parse(_banheirosController.text),
        preco_total: double.parse(_precoController.text),
        rua: _ruaController.text,
        bairro: _bairroController.text,
        cidade: _cidadeController.text,
        estado: _estadoController.text,
        descricao: _descricaoController.text,
      );

      // Chama o método para cadastrar a casa
      bool success =
          await widget.casaServices.cadastrarCasa(novaCasa, _imageFile!);
      if (success) {
        // Exibe a mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Casa cadastrada com sucesso!')),
        );

        // Redireciona para a HomePage
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar a casa.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastrar Casa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Campo para área
              _buildTextFormField(
                controller: _areaController,
                label: 'Área (m²)',
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Informe a área' : null,
              ),

              // Campo para número de banheiros
              _buildTextFormField(
                controller: _banheirosController,
                label: 'Número de Banheiros',
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Informe o número de banheiros' : null,
              ),

              // Campo para preço total
              _buildTextFormField(
                controller: _precoController,
                label: 'Preço Total',
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Informe o preço total' : null,
              ),

              // Campo para rua
              _buildTextFormField(
                controller: _ruaController,
                label: 'Rua',
                validator: (value) => value!.isEmpty ? 'Informe a rua' : null,
              ),

              // Campo para bairro
              _buildTextFormField(
                controller: _bairroController,
                label: 'Bairro',
                validator: (value) =>
                    value!.isEmpty ? 'Informe o bairro' : null,
              ),

              // Campo para cidade
              _buildTextFormField(
                controller: _cidadeController,
                label: 'Cidade',
                validator: (value) =>
                    value!.isEmpty ? 'Informe a cidade' : null,
              ),

              // Campo para estado
              _buildTextFormField(
                controller: _estadoController,
                label: 'Estado',
                validator: (value) =>
                    value!.isEmpty ? 'Informe o estado' : null,
              ),

              // Campo para descrição
              _buildTextFormField(
                controller: _descricaoController,
                label: 'Descrição',
                validator: (value) =>
                    value!.isEmpty ? 'Informe a descrição' : null,
              ),

              SizedBox(height: 20),

              // Botão para escolher imagem
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Escolher Imagem'),
              ),

              // Exibe a imagem escolhida, se houver
              _imageFile != null
                  ? Image.file(
                      _imageFile!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Text('Nenhuma imagem selecionada'),

              SizedBox(height: 20),

              // Botão para cadastrar a casa
              ElevatedButton(
                onPressed: _cadastrarCasa,
                child: Text('Cadastrar Casa'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método reutilizável para campos de texto
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0), // Borda arredondada
          ),
        ),
        validator: validator,
      ),
    );
  }
}
