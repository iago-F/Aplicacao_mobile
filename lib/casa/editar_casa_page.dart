import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:aluguel/casa/casa_service.dart';

class EditarCasaPage extends StatefulWidget {
  final Map<String, dynamic> casa; // Dados da casa para edição
  final String casaId;
  final CasaServices casaServices;

  const EditarCasaPage(
      {required this.casa,
      required this.casaId,
      required this.casaServices,
      Key? key})
      : super(key: key);

  @override
  _EditarCasaPageState createState() => _EditarCasaPageState();
}

class _EditarCasaPageState extends State<EditarCasaPage> {
  final _formKey = GlobalKey<FormState>();

  File? _novaImagem;
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _ruaController;
  late TextEditingController _bairroController;
  late TextEditingController _cepController;
  late TextEditingController _cidadeController;
  late TextEditingController _estadoController;
  late TextEditingController _descricaoController;
  late TextEditingController _areaController;
  late TextEditingController _precoTotalController;
  late TextEditingController _numBanheiroController;
  late TextEditingController _numQuartoController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    // Inicializar os controladores com os dados da casa
    _ruaController = TextEditingController(text: widget.casa['rua']);
    _bairroController = TextEditingController(text: widget.casa['bairro']);
    _cepController = TextEditingController(text: widget.casa['cep']);
    _cidadeController = TextEditingController(text: widget.casa['cidade']);
    _estadoController = TextEditingController(text: widget.casa['estado']);
    _descricaoController =
        TextEditingController(text: widget.casa['descricao']);
    _areaController =
        TextEditingController(text: widget.casa['area']?.toString());
    _precoTotalController =
        TextEditingController(text: widget.casa['preco_total']?.toString());
    _numBanheiroController =
        TextEditingController(text: widget.casa['num_banheiro']?.toString());
    _numQuartoController =
        TextEditingController(text: widget.casa['num_quarto']?.toString());
  }

  Future<void> _selecionarImagem() async {
    final XFile? imagemSelecionada =
        await _picker.pickImage(source: ImageSource.gallery);
    if (imagemSelecionada != null) {
      setState(() {
        _novaImagem = File(imagemSelecionada.path);
      });
    }
  }

  Future<void> _salvar(context) async {
    setState(() {
      isLoading = true; // Ativar carregamento
    });

    if (_formKey.currentState!.validate()) {
      try {
        await widget.casaServices.atualizarCasa(
          casaId: widget.casaId,
          novaImagemPath: _novaImagem?.path,
          rua: _ruaController.text,
          bairro: _bairroController.text,
          cep: _cepController.text,
          cidade: _cidadeController.text,
          estado: _estadoController.text,
          descricao: _descricaoController.text,
          area: double.tryParse(_areaController.text),
          precoTotal: double.tryParse(_precoTotalController.text),
          numBanheiro: int.tryParse(_numBanheiroController.text),
          numQuarto: int.tryParse(_numQuartoController.text),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Casa atualizada com sucesso!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Casa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _selecionarImagem,
                child: Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.width *
                            0.5, // Proporção da altura
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(16), // Arredondar as bordas
                          image: DecorationImage(
                            image: _novaImagem != null
                                ? FileImage(File(_novaImagem!.path))
                                : (widget.casa['imagem'] != null
                                    ? NetworkImage(widget.casa['imagem'])
                                        as ImageProvider
                                    : AssetImage(
                                            'assets/images/default_avatar.png')
                                        as ImageProvider),
                            fit: BoxFit
                                .cover, // Ajustar a imagem para cobrir o espaço
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.blue,
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(_ruaController, 'Rua'),
              _buildTextField(_bairroController, 'Bairro'),
              _buildTextField(_cepController, 'CEP'),
              _buildTextField(_cidadeController, 'Cidade'),
              _buildTextField(_estadoController, 'Estado'),
              _buildTextField(_descricaoController, 'Descrição'),
              _buildTextField(_areaController, 'Área (m²)',
                  keyboardType: TextInputType.number),
              _buildTextField(_precoTotalController, 'Preço Total',
                  keyboardType: TextInputType.number),
              _buildTextField(_numBanheiroController, 'Número de Banheiros',
                  keyboardType: TextInputType.number),
              _buildTextField(_numQuartoController, 'Número de Quartos',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : () => _salvar(context),
                child: const Text('Salvar Alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        keyboardType: keyboardType,
        validator: (value) =>
            value == null || value.isEmpty ? 'Campo obrigatório' : null,
      ),
    );
  }
}
