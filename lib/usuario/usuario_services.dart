import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:aluguel/usuario/usuario_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class UsuarioServices extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Usuario? usuario;
  String? usuarioId; // Armazena o ID do usuário logado

  // Referências do Firestore
  DocumentReference get _docRef => _firestore.doc('usuarios/${usuario!.id}');
  CollectionReference get _colletionRef => _firestore.collection('usuarios');

  UsuarioServices() {
    UsuarioAtenticado(); // Chama o método para obter o usuário autenticado ao inicializar
  }

  // Método para obter o usuário autenticado
  Future<void> UsuarioAtenticado({User? user}) async {
    try {
      User? userAtual = user ?? _auth.currentUser;
      if (userAtual != null) {
        DocumentSnapshot docUser =
            await _firestore.collection('usuarios').doc(userAtual.uid).get();

        if (docUser.exists) {
          // Extrai os dados do documento
          Map<String, dynamic>? userData =
              docUser.data() as Map<String, dynamic>?;

          if (userData != null) {
            // Atualiza o usuário e notifica ouvintes
            usuario = Usuario.fromJson(userData);
            usuarioId = userAtual.uid; // Armazena o ID do usuário
            notifyListeners(); // Notifica os ouvintes sobre a mudança
          } else {
            debugPrint('Dados do usuário estão nulos.');
          }
        } else {
          debugPrint('Usuário não encontrado no Firestore.');
        }
      } else {
        debugPrint('Usuário não autenticado.');
      }
    } catch (e) {
      debugPrint('Erro ao buscar dados do usuário: $e');
    }
  }

  // Método para obter o ID do usuário logado
  String? getUsuarioId() {
    return usuarioId; // Retorna o ID do usuário
  }

  // Método para realizar o cadastro do usuário
  Future<bool> cadastrar(Usuario usuario, File imageFile) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: usuario.email!,
        password: usuario.senha!,
      );

      User? user = userCredential.user;

      if (user != null) {
        usuario.id = user.uid;

        // Salva a imagem no Firebase Storage e obtém a URL
        String? imageUrl = await uploadImage(imageFile);
        if (imageUrl != null) {
          this.usuario = Usuario(
            id: usuario.id,
            nome: usuario.nome,
            email: usuario.email,
            senha: usuario.senha,
            image: imageUrl, // Armazena a URL da imagem
            cpf: usuario.cpf,
            data_nascimento: usuario.data_nascimento,
          );

          debugPrint(usuario.id!);
          salvarDetalhesUsuario();
          notifyListeners(); // Notifica ouvintes sobre a mudança
          return true;
        } else {
          debugPrint('Erro ao salvar a imagem.');
          return false;
        }
      } else {
        return false;
      }
    } on FirebaseAuthException catch (error) {
      // Tratamento de erro de autenticação
      return false;
    }
  }

  // Método para fazer upload da imagem de perfil
  Future<String?> uploadImage(File image) async {
    try {
      // Cria uma referência para o arquivo de imagem no Storage
      String filePath =
          'usuarios/${usuario!.id}/profile.jpg'; // ou qualquer nome que você deseje
      TaskSnapshot snapshot = await _storage.ref(filePath).putFile(image);

      // Obtém a URL de download da imagem
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Erro ao fazer upload da imagem: $e');
      return null;
    }
  }

  // Método para realizar o login
  Future<bool> Login({
    String? email,
    String? password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email!,
        password: password!,
      );

      // Extrair o objeto User do UserCredential
      User? user = userCredential.user;

      // Atualiza os dados do usuário e notifica ouvintes
      await UsuarioAtenticado(user: user); // Atualiza o estado do usuário
      return true;
    } on FirebaseAuthException catch (e) {
      String code;
      if (e.code == 'invalid-email') {
        // Ajustado para 'invalid-email'
        code = 'E-mail incorreto';
      } else if (e.code == 'wrong-password') {
        code = 'Senha incorreta';
      } else if (e.code == 'user-disabled') {
        // Ajustado o código
        code = 'Usuário desativado';
      } else if (e.code == 'user-not-found') {
        code = 'Usuário não encontrado';
      } else {
        code = 'Erro interno do Firebase';
      }

      debugPrint('Erro de login: $code');
      return false;
    }
  }

  // Método para salvar os detalhes do usuário no Firestore
  void salvarDetalhesUsuario() {
    if (usuario != null) {
      _docRef.set(usuario!.toJson());
    } else {
      debugPrint('Erro: Usuário não pode ser nulo');
    }
  }

  // Método para atualizar os dados do usuário
  updateUser(Usuario usuario) {
    _docRef.update(usuario.toJson());
    this.usuario = usuario; // Atualiza os dados locais também
    notifyListeners(); // Notifica ouvintes sobre a mudança
  }

  // Método para obter a lista de usuários
  Stream<QuerySnapshot> getUsuarios() {
    return _colletionRef.snapshots();
  }
}
