import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aluguel/usuario/usuario_services.dart';
import 'package:aluguel/usuario/cadastro_usuario_page.dart';
import 'package:aluguel/HomePage/homepage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final UsuarioServices _usuarioServices = UsuarioServices();
  bool isLoading = false;

  // Controladores dos campos
  TextEditingController emailController = TextEditingController();
  TextEditingController senhaController = TextEditingController();

  void _login(context) async {
    setState(() {
      isLoading = true; // Ativar carregamento
    });

    if (_formKey.currentState!.validate()) {
      bool loginRealizado = await _usuarioServices.Login(
        email: emailController.text,
        password: senhaController.text,
      );

      if (loginRealizado) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login realizado com sucesso!')),
        );
        // Redirecionar para a próxima tela, se necessário
        // Redireciona o usuário para a HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao realizar login.')),
        );
      }
    }

    setState(() {
      isLoading = false; // Ativar carregamento
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 250, 250, 250),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          'assets/images/LOGO_CASA_PRINCIPAL.PNG'), // Atualize para o caminho da sua logo
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(75),
                  ),
                ),
                SizedBox(height: 5),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@')) {
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
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'A senha precisa ter no mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32),
                SizedBox(
                  width: double.infinity, // Ocupa toda a largura disponível
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () => _login(context),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Color.fromARGB(255, 99, 154, 255),
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(
                          fontSize: 19,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight, // Alinha à direita
                  child: TextButton(
                    onPressed: () {
                      // Redireciona para a página de cadastro
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CadastroPage()),
                      );
                    },
                    child: Text(
                      'Não tem uma conta? Cadastre-se aqui.',
                      style: TextStyle(
                        fontSize: 12, // Altere para o tamanho desejado
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
