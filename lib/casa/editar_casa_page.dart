import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'casa_model.dart';
import 'casa_service.dart';
import 'package:aluguel/usuario/usuario_services.dart';

class EditarCasaPage extends StatefulWidget {
  final Casa casa;
  final CasaServices casaservices;

  EditarCasaPage({required this.casa, required this.casaservices});

  @override
  _EditarCasaPageState createState() => _EditarCasaPageState();
}

class _EditarCasaPageState extends State<EditarCasaPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  late TextEditingController _quartosController;
  late TextEditingController _banheirosController;
  late TextEditingController _ruaController;
  late TextEditingController _bairroController;
  late TextEditingController _cidadeController;
  late TextEditingController _estadoController;
  late TextEditingController _areaController;
  late TextEditingController _valorController;
  late TextEditingController _descricaoController;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _quartosController =
        TextEditingController(text: widget.casa.num_quarto?.toString() ?? '');
    _banheirosController =
        TextEditingController(text: widget.casa.num_banheiro?.toString() ?? '');
    _ruaController = TextEditingController(text: widget.casa.rua ?? '');
    _bairroController = TextEditingController(text: widget.casa.bairro ?? '');
    _cidadeController = TextEditingController(text: widget.casa.cidade ?? '');
    _estadoController = TextEditingController(text: widget.casa.estado ?? '');
    _areaController =
        TextEditingController(text: widget.casa.area?.toString() ?? '');
    _valorController =
        TextEditingController(text: widget.casa.preco_total?.toString() ?? '');
    _descricaoController =
        TextEditingController(text: widget.casa.descricao ?? '');
  }

  @override
  void dispose() {
    _quartosController.dispose();
    _banheirosController.dispose();
    _ruaController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _areaController.dispose();
    _valorController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void _salvarAlteracoes() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
      });

      try {
        // Coleta os valores atualizados do formulário
        String rua = _ruaController.text;
        String bairro = _bairroController.text;
        String cidade = _cidadeController.text;
        String estado = _estadoController.text;
        String descricao = _descricaoController.text;
        double? area = double.tryParse(_areaController.text);
        double? precoTotal = double.tryParse(_valorController.text);
        int? numQuarto = int.tryParse(_quartosController.text);
        int? numBanheiro = int.tryParse(_banheirosController.text);

        // Checa se há nova imagem e faz o upload
        String? imagemUrl;
        if (widget.casa.Imagem != null && widget.casa.Imagem!.isNotEmpty) {
          imagemUrl = await widget.casaservices.uploadImageToFirebase(
              widget.casa.Imagem![0], widget.casa.id_casa!);
        }

        // Cria uma nova instância de Casa com os valores atualizados
        Casa casaAtualizada = Casa(
          id_casa: widget.casa.id_casa,
          rua: rua,
          bairro: bairro,
          cidade: cidade,
          estado: estado,
          descricao: descricao,
          area: area,
          preco_total: precoTotal,
          num_quarto: numQuarto,
          num_banheiro: numBanheiro,
          Imagem: imagemUrl != null
              ? [imagemUrl]
              : widget.casa.Imagem, // Atualiza a imagem
        );

        // Chama o método atualizarCasa do serviço
        await widget.casaservices.atualizarCasa(
          widget.casa.id_casa!,
          novasImagensPaths: casaAtualizada.Imagem,
          rua: rua,
          bairro: bairro,
          cidade: cidade,
          estado: estado,
          descricao: descricao,
          area: area,
          precoTotal: precoTotal,
          numQuarto: numQuarto,
          numBanheiro: numBanheiro,
        );

        // Exibe uma mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Casa atualizada com sucesso!')),
        );

        // Volta para a página anterior ou atualiza a interface
        Navigator.pop(context, casaAtualizada);
      } catch (e) {
        // Exibe uma mensagem de erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar casa: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage(int index) async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          widget.casa.Imagem ??= [];
          if (index >= 0 && index < widget.casa.Imagem!.length) {
            widget.casa.Imagem![index] = pickedFile.path; // Caminho local
          } else {
            widget.casa.Imagem!.add(pickedFile.path); // Adiciona novo
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao selecionar imagem: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Casa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carousel de imagens
            if (widget.casa.Imagem != null && widget.casa.Imagem!.isNotEmpty)
              CarouselSlider(
                items: widget.casa.Imagem!.map((imagemUrl) {
                  int index = widget.casa.Imagem!.indexOf(imagemUrl);
                  return GestureDetector(
                    onTap: () => _pickImage(index),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: imagemUrl.startsWith('http')
                              ? CachedNetworkImage(
                                  imageUrl: imagemUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 200.0,
                                  placeholder: (context, url) => Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) => Center(
                                    child: Icon(Icons.broken_image,
                                        size: 50, color: Colors.grey),
                                  ),
                                )
                              : Image.file(
                                  File(imagemUrl),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 200.0,
                                ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Icon(
                            Icons.image,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                options: CarouselOptions(
                  height: 200.0,
                  autoPlay: false,
                  enlargeCenterPage: true,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.8,
                ),
              ),

            SizedBox(height: 16),
            // Formulário de edição
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _quartosController,
                    decoration: InputDecoration(labelText: 'Número de Quartos'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _banheirosController,
                    decoration:
                        InputDecoration(labelText: 'Número de Banheiros'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _ruaController,
                    decoration: InputDecoration(labelText: 'Rua'),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _bairroController,
                    decoration: InputDecoration(labelText: 'Bairro'),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _cidadeController,
                    decoration: InputDecoration(labelText: 'Cidade'),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _estadoController,
                    decoration: InputDecoration(labelText: 'Estado'),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _areaController,
                    decoration: InputDecoration(labelText: 'Área (m²)'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _valorController,
                    decoration: InputDecoration(labelText: 'Valor Total (R\$)'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _descricaoController,
                    decoration: InputDecoration(labelText: 'Descrição'),
                    maxLines: 4,
                  ),
                  SizedBox(height: 16),
                  // Botão para salvar
                  Center(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.blue, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: isLoading
                          ? null
                          : _salvarAlteracoes, // Chama o método
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.blue)
                          : Text(
                              'Salvar Alterações',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
