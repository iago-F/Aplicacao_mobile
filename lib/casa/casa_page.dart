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
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _banheirosController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();
  final TextEditingController _ruaController = TextEditingController();
  final TextEditingController _bairroController = TextEditingController();
  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _estadoController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _quartosController = TextEditingController();

  File? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _cadastrarCasa() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        var uuid = Uuid();
        String casaId = uuid.v4();

        Casa novaCasa = Casa(
          id_casa: casaId,
          area: double.parse(_areaController.text),
          num_banheiro: int.parse(_banheirosController.text),
          preco_total: double.parse(_precoController.text),
          rua: _ruaController.text,
          bairro: _bairroController.text,
          cep: _cepController.text,
          cidade: _cidadeController.text,
          estado: _estadoController.text,
          descricao: _descricaoController.text,
          num_quarto: int.parse(_quartosController.text),
        );

        bool success =
            await widget.casaServices.cadastrarCasa(novaCasa, _imageFile!);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Casa cadastrada com sucesso!')),
          );

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao cadastrar a casa.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ocorreu um erro: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      labelText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.blue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cadastrar Casa',
          style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0), // Cor do título
            fontSize: 20, // Tamanho da fonte
          ),
        ),
        backgroundColor:
            Color.fromARGB(255, 255, 255, 255), // Cor de fundo da AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _areaController,
                keyboardType: TextInputType.number,
                decoration: _buildInputDecoration('Área (m²)'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _banheirosController,
                keyboardType: TextInputType.number,
                decoration: _buildInputDecoration('Número de Banheiros'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _quartosController,
                keyboardType: TextInputType.number,
                decoration: _buildInputDecoration('Número de Quartos'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _precoController,
                keyboardType: TextInputType.number,
                decoration: _buildInputDecoration('Preço (R\$)'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _ruaController,
                decoration: _buildInputDecoration('Rua'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _bairroController,
                decoration: _buildInputDecoration('Bairro'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _cepController,
                decoration: _buildInputDecoration('CEP'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _cidadeController,
                decoration: _buildInputDecoration('Cidade'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _estadoController,
                decoration: _buildInputDecoration('Estado'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _descricaoController,
                maxLines: 3,
                decoration: _buildInputDecoration('Descrição'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 20),
              // Botão para selecionar imagem
              TextButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image),
                label: Text('Selecionar Imagem'),
              ),
              if (_imageFile != null)
                Image.file(
                  _imageFile!,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              SizedBox(height: 20),
              // Botão de cadastrar
              ElevatedButton(
                onPressed: _isLoading ? null : _cadastrarCasa,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Cadastrar Casa'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
