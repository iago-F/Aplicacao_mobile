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
      _casas = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Corrige os tipos para valores de área e preço
        return Casa.fromJson({
          ...data,
          'area': (data['area'] is int)
              ? (data['area'] as int).toDouble()
              : data['area'],
          'preco_total': (data['preco_total'] is int)
              ? (data['preco_total'] as int).toDouble()
              : data['preco_total'],
        });
      }).toList();

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
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Corrige os tipos para valores de área e preço
        return Casa.fromJson({
          ...data,
          'area': (data['area'] is int)
              ? (data['area'] as int).toDouble()
              : data['area'],
          'preco_total': (data['preco_total'] is int)
              ? (data['preco_total'] as int).toDouble()
              : data['preco_total'],
        });
      }).toList();
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

  Future<bool> atualizarCasa(
    String casaId, {
    required List<String>? novasImagensPaths,
    required String rua,
    required String bairro,
    required String cidade,
    required String estado,
    required String descricao,
    required double? area,
    required double? precoTotal,
    required int? numQuarto,
    required int? numBanheiro,
  }) async {
    try {
      // Obtém o ID do usuário autenticado
      String? usuarioId = _usuarioServices.getUsuarioId();
      if (usuarioId == null) {
        debugPrint('Usuário não autenticado. Atualização da casa falhou.');
        return false;
      }

      // Referência ao documento no Firestore
      DocumentReference casaRef = _firestore.collection('casas').doc(casaId);

      // Verifica se o documento existe no Firestore
      DocumentSnapshot casaSnapshot = await casaRef.get();
      if (!casaSnapshot.exists) {
        debugPrint('Casa não encontrada no Firestore para o ID: $casaId');
        return false;
      }

      // Recupera a lista de imagens existentes no Firestore
      Map<String, dynamic> casaDataAtual =
          casaSnapshot.data() as Map<String, dynamic>;
      List<String> imagensAtuais =
          List<String>.from(casaDataAtual['Imagem'] ?? []);

      // Identifica as imagens a serem removidas
      List<String> imagensParaRemover = [];
      if (novasImagensPaths != null) {
        imagensParaRemover = imagensAtuais
            .where((imagem) => !novasImagensPaths.contains(imagem))
            .toList();
      }

      // Remove as imagens antigas do Firebase Storage
      for (String imagemUrl in imagensParaRemover) {
        try {
          Reference imagemRef = FirebaseStorage.instance.refFromURL(imagemUrl);
          await imagemRef.delete();
          debugPrint('Imagem removida do Firebase Storage: $imagemUrl');
        } catch (e) {
          debugPrint('Erro ao remover imagem do Firebase Storage: $e');
        }
      }

      // Dados para atualização
      Map<String, dynamic> casaDataAtualizada = {
        'Imagem':
            novasImagensPaths ?? imagensAtuais, // Atualiza a lista de imagens
        'rua': rua,
        'bairro': bairro,
        'cidade': cidade,
        'estado': estado,
        'descricao': descricao,
        'area': area ?? 0.0,
        'preco_total': precoTotal ?? 0.0,
        'num_quarto': numQuarto ?? 0,
        'num_banheiro': numBanheiro ?? 0,
        'id_usuario': usuarioId, // Certifique-se de enviar o usuário associado
      };

      // Debug dos dados a serem enviados
      debugPrint('Atualizando dados no Firestore: $casaDataAtualizada');

      // Atualizando o documento no Firestore
      await casaRef.update(casaDataAtualizada);

      // Debug após sucesso na atualização
      debugPrint('Atualização realizada com sucesso no Firestore.');

      // Atualiza a lista local de casas
      int casaIndex = _casas.indexWhere((casa) => casa.id_casa == casaId);
      if (casaIndex != -1) {
        _casas[casaIndex] = Casa.fromJson({
          ...casaDataAtualizada,
          'id_casa': casaId,
        });
        notifyListeners();
        debugPrint('Casa atualizada localmente na lista de casas.');
      } else {
        debugPrint('Casa não encontrada na lista local para o ID: $casaId');
      }

      return true;
    } catch (e) {
      // Captura e exibe o erro, caso ocorra
      debugPrint('Erro ao atualizar a casa no Firestore: $e');
      return false;
    }
  }

  Future<String?> uploadImageToFirebase(String imagePath, String casaId) async {
    try {
      // Cria um caminho único para a imagem no Firebase Storage
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      String filePath = 'casas/$casaId/$fileName';

      // Faz o upload da imagem
      File imageFile = File(imagePath);
      TaskSnapshot snapshot =
          await FirebaseStorage.instance.ref(filePath).putFile(imageFile);

      // Obtém a URL pública da imagem armazenada
      String downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('Imagem enviada com sucesso! URL: $downloadUrl');

      return downloadUrl;
    } catch (e) {
      debugPrint('Erro ao fazer upload da imagem: $e');
      return null;
    }
  }
}
