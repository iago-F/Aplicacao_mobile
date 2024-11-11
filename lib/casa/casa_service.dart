import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:aluguel/casa/casa_model.dart';
import 'package:aluguel/usuario/usuario_services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class CasaServices extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UsuarioServices _usuarioServices;

  List<Casa> _casas = [];

  CasaServices(this._usuarioServices);

  // Getter para acessar a lista de casas
  List<Casa> get casas => _casas;

  // Método para cadastrar uma casa
  Future<bool> cadastrarCasa(Casa casa, File imageFile) async {
    try {
      // Obtém o ID do usuário logado
      String? usuarioId = _usuarioServices.getUsuarioId();
      if (usuarioId == null) {
        debugPrint('Usuário não autenticado. Cadastro da casa falhou.');
        return false;
      }

      // Adiciona o ID do usuário à casa
      casa.id_usuario = usuarioId;

      // Verifica se casa.id_casa é nulo
      if (casa.id_casa == null) {
        debugPrint('ID da casa não pode ser nulo.');
        return false;
      }

      // Salva a imagem no Firebase Storage e obtém a URL
      String? imageUrl = await uploadImage(imageFile, casa.id_casa!);
      if (imageUrl != null) {
        casa.imagem = imageUrl; // Armazena a URL da imagem
      } else {
        debugPrint('Erro ao obter a URL da imagem. Cadastro da casa falhou.');
        return false;
      }

      // Adiciona a casa ao Firestore
      await _firestore.collection('casas').add(casa.toJson());

      // Atualiza a lista local de casas e notifica os ouvintes
      _casas.add(casa);
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Erro ao cadastrar a casa: $e');
      return false;
    }
  }

  // Método para fazer upload da imagem
  Future<String?> uploadImage(File image, String casaId) async {
    try {
      // Cria uma referência para o arquivo de imagem no Storage
      String filePath =
          'casas/$casaId/imagem.jpg'; // ou qualquer nome que você deseje
      TaskSnapshot snapshot =
          await FirebaseStorage.instance.ref(filePath).putFile(image);

      // Obtém a URL de download da imagem
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Erro ao fazer upload da imagem: $e');
      return null;
    }
  }

  // Método para buscar todas as casas
  Future<void> carregarCasas() async {
    try {
      // Carrega as casas do Firestore
      QuerySnapshot snapshot = await _firestore.collection('casas').get();

      // Converte os documentos para uma lista de objetos Casa
      _casas = snapshot.docs
          .map((doc) => Casa.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Notifica os ouvintes que os dados foram carregados
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar as casas: $e');
    }
  }

  // Método para excluir uma casa
  Future<bool> excluirCasa(String casaId) async {
    try {
      // Deleta a imagem da casa no Firebase Storage
      String filePath = 'casas/$casaId/imagem.jpg';
      await FirebaseStorage.instance.ref(filePath).delete();

      // Deleta o documento da casa no Firestore
      await _firestore.collection('casas').doc(casaId).delete();

      // Atualiza a lista de casas local e notifica os ouvintes
      _casas.removeWhere((casa) => casa.id_casa == casaId);
      notifyListeners();

      debugPrint('Casa com ID $casaId excluída com sucesso.');
      return true;
    } catch (e) {
      debugPrint('Erro ao excluir a casa: $e');
      return false;
    }
  }

  // Método para ouvir mudanças em tempo real (como no StreamBuilder)
  Stream<List<Casa>> getCasas() {
    return _firestore.collection('casas').snapshots().map((snapshot) => snapshot
        .docs
        .map((doc) => Casa.fromJson(doc.data() as Map<String, dynamic>))
        .toList());
  }
}
