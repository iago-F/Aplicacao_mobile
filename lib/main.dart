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
          // Usando colorScheme corretamente
          colorScheme: ColorScheme.light(
            primaryContainer: Color.fromARGB(
                255, 242, 242, 242), // Nova forma de definir a cor principal
            onPrimaryContainer:
                Colors.white, // Cor do texto sobre 'primaryContainer'
            secondary:
                const Color.fromARGB(255, 252, 252, 252), // Cor secundária
            onSecondary: Colors.white, // Cor do texto sobre 'secondary'
            background: Colors.white, // Cor de fundo
            onBackground: const Color.fromARGB(
                255, 39, 38, 38), // Cor do texto sobre o fundo
            surface: Colors.white, // Cor para superfícies como cards
            onSurface: const Color.fromARGB(
                255, 67, 65, 65), // Cor do texto ou ícones sobre 'surface'
          ),

          // Configuração do cursor e seleção
          textSelectionTheme: TextSelectionThemeData(
            cursorColor:
                Color.fromARGB(255, 99, 154, 255), // Cor do ponteiro (cursor)
            selectionColor:
                Colors.grey.withOpacity(0.3), // Cor da seleção de texto
            selectionHandleColor: Colors.black, // Cor dos "handles" de seleção
          ),

          // Configuração do AppBar
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blue, // Cor do AppBar
            foregroundColor: Colors.white, // Cor do texto ou ícones no AppBar
          ),

          // Configuração dos Botões
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, // Cor de fundo do botão
              foregroundColor: Color.fromARGB(
                  255, 255, 255, 255), // Cor do texto ou ícones no botão
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          // Configuração dos Inputs
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Color.fromARGB(221, 74, 72, 72), // Cor padrão da borda
                width: 1.8,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Color.fromARGB(
                    221, 74, 72, 72), // Cor da borda quando habilitado
                width: 1.8,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color:
                    Color.fromARGB(255, 99, 154, 255), // Cor da borda ao focar
                width: 1.8,
              ),
            ),
            focusColor: Colors.transparent, // Remove cor de foco interna
            labelStyle: TextStyle(
              color: const Color.fromARGB(
                  255, 0, 0, 0), // Cor da label quando não está focada
            ),
            floatingLabelStyle: TextStyle(
              color: Color.fromARGB(
                  255, 99, 154, 255), // Cor da label quando está focada
            ),
          ),
          // Configuração para links interativos e botões de texto
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.amber[600], // Cor do texto do botão/link
            ),
          ),
        ),

        home: LoginPage(), // Aqui você pode definir a página inicial
      ),
    );
  }
}
