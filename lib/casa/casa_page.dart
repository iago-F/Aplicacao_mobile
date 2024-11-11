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
              TextFormField(
                controller: _areaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Área (m²)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a área';
                  }
                  return null;
                },
              ),

              // Campo para número de banheiros
              TextFormField(
                controller: _banheirosController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Número de Banheiros'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o número de banheiros';
                  }
                  return null;
                },
              ),

              // Campo para preço total
              TextFormField(
                controller: _precoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Preço Total'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o preço total';
                  }
                  return null;
                },
              ),

              // Campo para rua
              TextFormField(
                controller: _ruaController,
                decoration: InputDecoration(labelText: 'Rua'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a rua';
                  }
                  return null;
                },
              ),

              // Campo para bairro
              TextFormField(
                controller: _bairroController,
                decoration: InputDecoration(labelText: 'Bairro'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o bairro';
                  }
                  return null;
                },
              ),

              // Campo para cidade
              TextFormField(
                controller: _cidadeController,
                decoration: InputDecoration(labelText: 'Cidade'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a cidade';
                  }
                  return null;
                },
              ),

              // Campo para estado
              TextFormField(
                controller: _estadoController,
                decoration: InputDecoration(labelText: 'Estado'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o estado';
                  }
                  return null;
                },
              ),

              // Campo para descrição
              TextFormField(
                controller: _descricaoController,
                decoration: InputDecoration(labelText: 'Descrição'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a descrição';
                  }
                  return null;
                },
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
}
