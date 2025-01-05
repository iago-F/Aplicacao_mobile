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
  // Método para cadastrar uma casa com múltiplas imagens
  Future<bool> cadastrarCasa(Casa casa, List<File> imageFiles) async {
    try {
      String? usuarioId = _usuarioServices.getUsuarioId();
      if (usuarioId == null) {
        debugPrint('Usuário não autenticado. Cadastro da casa falhou.');
        return false;
      }

      casa.id_usuario = usuarioId;
      String casaId = _firestore.collection('casas').doc().id;
      casa.id_casa = casaId;

      // Lista para armazenar as URLs das imagens
      List<String> imageUrls = [];

      // Fazendo o upload das imagens
      for (var imageFile in imageFiles) {
        String? imageUrl = await uploadImage(imageFile, casaId);
        if (imageUrl != null) {
          imageUrls.add(imageUrl);
        } else {
          debugPrint('Erro ao obter a URL da imagem. Cadastro da casa falhou.');
          return false;
        }
      }

      // Adiciona as URLs das imagens à casa
      casa.Imagem = imageUrls;

      // Salva a casa no Firestore
      await _firestore.collection('casas').doc(casaId).set(casa.toJson());

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
      String filePath =
          'casas/$casaId/imagem_${DateTime.now().millisecondsSinceEpoch}.jpg';
      TaskSnapshot snapshot =
          await FirebaseStorage.instance.ref(filePath).putFile(image);

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

  // metodo para trazer todas as casas do bacno
  Future<List<Casa>> buscarTodasCasas() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('casas').get();

      // Mapeia os documentos para objetos do tipo Casa
      return snapshot.docs
          .map((doc) => Casa.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar todas as casas: $e');
      return [];
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

  Future<void> atualizarCasa({
    required String casaId,
    String? novaImagemPath,
    String? rua,
    String? bairro,
    String? cep,
    String? cidade,
    String? estado,
    String? descricao,
    double? area,
    double? precoTotal,
    int? numBanheiro,
    int? numQuarto,
  }) async {
    try {
      // Referência para a casa no Firestore
      DocumentReference casaRef = _firestore.collection('casas').doc(casaId);

      // Montar os dados a serem atualizados
      Map<String, dynamic> dadosAtualizados = {
        if (rua != null) 'rua': rua,
        if (bairro != null) 'bairro': bairro,
        if (cep != null) 'cep': cep,
        if (cidade != null) 'cidade': cidade,
        if (estado != null) 'estado': estado,
        if (descricao != null) 'descricao': descricao,
        if (area != null) 'area': area,
        if (precoTotal != null) 'preco_total': precoTotal,
        if (numBanheiro != null) 'num_banheiro': numBanheiro,
        if (numQuarto != null) 'num_quarto': numQuarto,
      };

      // Atualizar os dados no Firestore
      await casaRef.update(dadosAtualizados);

      // Se houver uma nova imagem, faz o upload
      if (novaImagemPath != null) {
        File novaImagem = File(novaImagemPath);

        // Upload da imagem para o Firebase Storage
        String? imagemUrl = await uploadImage(novaImagem, casaId);

        // Atualizar a URL da imagem, se o upload for bem-sucedido
        if (imagemUrl != null) {
          await casaRef.update({'imagem': imagemUrl});
        } else {
          debugPrint('Falha ao carregar a nova imagem.');
        }
      }

      debugPrint('Casa atualizada com sucesso!');
    } catch (e) {
      debugPrint('Erro ao atualizar casa: $e');
      throw Exception('Erro ao atualizar casa');
    }
  }
}
