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

  Future<bool> cadastrar(Usuario usuario, File? imageFile) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: usuario.email!,
        password: usuario.senha!,
      );

      User? user = userCredential.user;

      if (user != null) {
        usuario.id = user.uid;

        String? imageUrl;
        // Salva a imagem apenas se imageFile for fornecido
        if (imageFile != null) {
          imageUrl = await uploadImage(imageFile);
        }

        // Cria o objeto do usuário com ou sem a URL da imagem
        this.usuario = Usuario(
          id: usuario.id,
          nome: usuario.nome,
          email: usuario.email,
          senha: usuario.senha,
          image: imageUrl, // Pode ser null se não houver imagem
          cpf: usuario.cpf,
          data_nascimento: usuario.data_nascimento,
        );

        debugPrint(usuario.id!);
        salvarDetalhesUsuario();
        notifyListeners(); // Notifica ouvintes sobre a mudança
        return true;
      } else {
        return false;
      }
    } on FirebaseAuthException catch (error) {
      // Tratamento de erro de autenticação
      debugPrint('Erro no cadastro: $error');
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

  // Método para atualizar os dados do usuário
  Future<void> atualizarPerfil({
    required String nome,
    required String email,
    DateTime? dataNascimento,
    File? novaImagem,
  }) async {
    try {
      // Atualizar dados de perfil no Firestore
      DocumentReference usuarioRef = _firestore
          .collection('usuarios')
          .doc(usuarioId!); // Use usuarioId para pegar o ID correto

      // Atualizando dados no Firestore
      await usuarioRef.update({
        'nome': nome,
        'email': email,
        'data_nascimento': dataNascimento,
      });

      // Se houver uma nova imagem, faz o upload
      if (novaImagem != null) {
        // Upload da imagem para o Firebase Storage
        String? imagemUrl = await uploadImage(novaImagem);

        // Se a URL da imagem não for nula, atualize a imagem
        if (imagemUrl != null) {
          await usuarioRef.update({'image': imagemUrl});
        } else {
          debugPrint('Falha ao carregar a imagem, URL nula.');
        }
      }

      // Recarrega os dados do usuário
      await UsuarioAtenticado();

      // Notifica ouvintes sobre a atualização
      notifyListeners();

      debugPrint('Perfil atualizado com sucesso!');
    } catch (e) {
      debugPrint('Erro ao atualizar perfil: $e');
      throw Exception('Erro ao atualizar perfil');
    }
  }

  // Método para excluir a conta do usuário
  Future<bool> excluirConta() async {
    try {
      // Primeiro, excluímos as casas vinculadas ao usuário
      if (usuario != null) {
        // Obtém uma lista de todas as casas associadas ao usuário
        var casasQuerySnapshot = await _firestore
            .collection(
                'casas') // Supondo que a coleção das casas seja chamada 'casas'
            .where('userId',
                isEqualTo: usuario!.id) // Filtra as casas pelo 'userId'
            .get();

        // Exclui todas as casas associadas ao usuário
        for (var casaDoc in casasQuerySnapshot.docs) {
          await casaDoc.reference.delete(); // Exclui cada casa
        }
      }

      // Excluímos a imagem de perfil, se existir
      if (usuario!.image != null) {
        await _storage.refFromURL(usuario!.image!).delete(); // Exclui a imagem
      }

      // Exclui o documento do usuário no Firestore
      await _docRef.delete();

      // Exclui o usuário do Firebase Authentication
      User? user = _auth.currentUser;
      await user?.delete();

      // Após excluir o usuário, você pode limpar as informações do usuário localmente
      usuario = null;
      usuarioId = null;

      // Notificar os ouvintes para que a UI seja atualizada
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Erro ao excluir conta: $e');
      return false;
    }
  }
}
