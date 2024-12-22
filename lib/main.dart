import 'package:flutter/material.dart';
import 'package:aluguel/usuario/cadastro_usuario_page.dart'; // Importe sua página de cadastro aqui
import 'package:firebase_core/firebase_core.dart';
import 'package:aluguel/usuario/Login_usuario_page.dart';
import 'package:provider/provider.dart'; // Importe o provider
import 'package:aluguel/casa/casa_service.dart'; // Importe seu serviço de casa
import 'package:aluguel/usuario/usuario_services.dart'; // Importe seu serviço de usuário

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const firebaseConfig = FirebaseOptions(
      apiKey: "AIzaSyCYJ6P3XTfRv9MoaeDeIqnVTJig1L19pLM",
      authDomain: "aluguel-mobile.firebaseapp.com",
      projectId: "aluguel-mobile",
      storageBucket: "aluguel-mobile.appspot.com",
      messagingSenderId: "1009693461933",
      appId: "1:1009693461933:web:4daa47404b3950bd932524");

  await Firebase.initializeApp(options: firebaseConfig);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Fornecendo o UsuarioServices
        ChangeNotifierProvider<UsuarioServices>(
          create: (_) => UsuarioServices(),
        ),

        // Fornecendo o CasaServices
        ChangeNotifierProvider<CasaServices>(
          create: (context) => CasaServices(
              Provider.of<UsuarioServices>(context, listen: false)),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: LoginPage(), // Aqui você pode definir a página inicial
      ),
    );
  }
}
