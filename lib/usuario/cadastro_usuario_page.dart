import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatação de data
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aluguel/usuario/usuario_services.dart';
import 'package:aluguel/usuario/usuario_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CadastroPage extends StatefulWidget {
  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();
  final UsuarioServices _usuarioServices = UsuarioServices();

  // Controladores dos campos
  TextEditingController nomeController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController senhaController = TextEditingController();
  TextEditingController cpfController = TextEditingController();
  TextEditingController dataNascimentoController = TextEditingController();

  DateTime? _dataSelecionada;
  File? _image; // Variável para armazenar a imagem

  void _cadastrar() async {
    try {
      if (_formKey.currentState!.validate()) {
        Usuario usuario = Usuario(
          nome: nomeController.text,
          email: emailController.text,
          senha: senhaController.text,
          cpf: cpfController.text,
          data_nascimento: _dataSelecionada,
        );

        bool cadastroRealizado =
            await _usuarioServices.cadastrar(usuario, _image!);

        if (cadastroRealizado) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Usuário cadastrado com sucesso!')),
          );
          // Limpa os campos após o cadastro
          nomeController.clear();
          emailController.clear();
          senhaController.clear();
          cpfController.clear();
          dataNascimentoController.clear();
          setState(() {
            _image = null; // Reseta a imagem
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao cadastrar usuário.')),
          );
        }
      }
    } catch (e) {
      print('Erro: $e');
      String mensagemErro;

      if (e is FirebaseException) {
        mensagemErro = 'Erro Firebase: ${e.message}';
      } else {
        mensagemErro = 'Erro desconhecido: $e';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagemErro)),
      );
    }
  }

  // Abrir um seletor de data
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _dataSelecionada) {
      setState(() {
        _dataSelecionada = pickedDate;
        dataNascimentoController.text =
            DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      // Mudei de getImage para pickImage
      source: ImageSource.gallery, // ou ImageSource.camera
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      // Mudei de getImage para pickImage
      source: ImageSource.camera,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 252, 250, 243),
      appBar: AppBar(
        title: Text(
          'Cadastro de Usuário',
          style: TextStyle(
              fontSize: 19, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 99, 154, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu nome';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Por favor, insira um e-mail válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: senhaController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'A senha precisa ter no mínimo 6 caracteres';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: cpfController,
                decoration: InputDecoration(
                  labelText: 'CPF',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) {
                  if (value == null || value.length != 11) {
                    return 'Por favor, insira um CPF válido (11 dígitos)';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: dataNascimentoController,
                decoration: InputDecoration(
                  labelText: 'Data de Nascimento',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione sua data de nascimento';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // Botão para selecionar a imagem
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor:
                            const Color.fromARGB(255, 199, 214, 241),
                      ),
                      child: Text(
                        'Selecionar Imagem',
                        style: TextStyle(fontSize: 18, color: Colors.black87),
                      ),
                    ),
                  ),
                  SizedBox(width: 10), // Espaço entre os botões
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _takePhoto,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor:
                            const Color.fromARGB(255, 199, 214, 241),
                      ),
                      child: Text(
                        'Tirar Foto',
                        style: TextStyle(fontSize: 18, color: Colors.black87),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Exibir imagem selecionada
              if (_image != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Image.file(
                    _image!,
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _cadastrar,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Color.fromARGB(255, 99, 154, 255),
                ),
                child: Text(
                  'Cadastrar',
                  style: TextStyle(
                      fontSize: 19,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
