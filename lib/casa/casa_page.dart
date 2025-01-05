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

  List<File> _imageFiles = []; // Alterei de File? para List<File>
  bool _isLoading = false;
  int _currentPage = 0; // Variável para controle do indicador de página

  Future<void> _selectImages() async {
    if (_imageFiles.length > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Você pode adicionar no máximo 5 imagens!')),
      );
      return; // Impede a seleção de mais imagens
    }

    final ImagePicker _picker = ImagePicker();
    final List<XFile>? selectedImages = await _picker.pickMultiImage();

    if (selectedImages != null) {
      setState(() {
        // Adiciona as novas imagens à lista, mas garante que não ultrapasse 5
        if (_imageFiles.length + selectedImages.length <= 5) {
          _imageFiles
              .addAll(selectedImages.map((image) => File(image.path)).toList());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Você pode adicionar no máximo 5 imagens!')),
          );
        }
      });
      print("Imagens selecionadas: $_imageFiles"); // Debug
    }
  }

  // Função para excluir uma imagem
  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
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

        bool success = await widget.casaServices.cadastrarCasa(
            novaCasa, _imageFiles); // Passando a lista de imagens

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
            color: Color.fromARGB(255, 0, 0, 0),
            fontSize: 20,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
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
                onPressed: _selectImages,
                icon: Icon(Icons.image),
                label: Text('Selecionar Imagem'),
              ),
              if (_imageFiles.isNotEmpty)
                Container(
                  height: 200, // Definindo o tamanho do carrossel
                  child: PageView.builder(
                    itemCount: _imageFiles.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Image.file(
                            _imageFiles[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              // Indicadores de página
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _imageFiles.length,
                    (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _currentPage == index ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Botão de cadastrar
              ElevatedButton(
                onPressed: _isLoading ? null : _cadastrarCasa,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.blue[300])
                    : Text('Cadastrar Casa'),
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.blue[300]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
