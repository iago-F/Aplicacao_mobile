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

  // Método para cadastrar uma casa com múltiplas imagens (Opção B)
  Future<bool> cadastrarCasa(Casa casa, List<File> imageFiles) async {
    try {
      String? usuarioId = _usuarioServices.getUsuarioId();
      if (usuarioId == null) {
        debugPrint('Usuário não autenticado. Cadastro da casa falhou.');
        return false;
      }

      // Vamos usar o ID que já veio em casa.id_casa (via uuid.v4())
      casa.id_usuario = usuarioId;

      // Lista para armazenar as URLs das imagens
      List<String> imageUrls = [];

      // Faz o upload das imagens
      for (var imageFile in imageFiles) {
        String? imageUrl = await uploadImage(imageFile, casa.id_casa!);
        if (imageUrl != null) {
          imageUrls.add(imageUrl);
        } else {
          debugPrint('Erro ao obter a URL da imagem. Cadastro da casa falhou.');
          return false;
        }
      }

      // Adiciona as URLs das imagens à casa
      casa.Imagem = imageUrls;

      // Salva a casa no Firestore (usando o ID do uuid.v4())
      await _firestore.collection('casas').doc(casa.id_casa).set(casa.toJson());

      // Atualiza a lista local e notifica ouvintes
      _casas.add(casa);
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Erro ao cadastrar a casa: $e');
      return false;
    }
  }

  // Método para fazer upload da imagem para o Firebase Storage
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

  // Método para buscar todas as casas (carrega e converte types)
  Future<void> carregarCasas() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('casas').get();

      _casas = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Conversão int->double para área e preço
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

      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar as casas: $e');
    }
  }

  // Busca todas as casas, retornando uma lista
  Future<List<Casa>> buscarTodasCasas() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('casas').get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
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

  Future<bool> excluirCasa(String casaId) async {
    try {
      // 1. Obtém o documento da casa
      DocumentSnapshot docSnap =
          await _firestore.collection('casas').doc(casaId).get();

      if (!docSnap.exists) {
        debugPrint('Casa não encontrada no Firestore para o ID: $casaId');
        return false;
      }

      // 2. Pega a lista de URLs (campo "Imagem") no documento
      Map<String, dynamic> data = docSnap.data() as Map<String, dynamic>;
      List<String> imagens = List<String>.from(data['Imagem'] ?? []);

      // 3. Exclui cada imagem do Storage
      for (String url in imagens) {
        try {
          Reference ref = FirebaseStorage.instance.refFromURL(url);
          await ref.delete();
          debugPrint('Imagem removida do Firebase Storage: $url');
        } catch (e) {
          debugPrint('Erro ao remover imagem do Firebase Storage: $e');
        }
      }

      // 4. Exclui o documento no Firestore
      await _firestore.collection('casas').doc(casaId).delete();

      // 5. Remove da lista local
      _casas.removeWhere((casa) => casa.id_casa == casaId);
      notifyListeners();

      debugPrint('Casa com ID $casaId excluída com sucesso.');
      return true;
    } catch (e) {
      debugPrint('Erro ao excluir a casa: $e');
      return false;
    }
  }

  // Método para ouvir mudanças em tempo real
  Stream<List<Casa>> getCasas() {
    return _firestore.collection('casas').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) {
            return Casa.fromJson(doc.data() as Map<String, dynamic>);
          }).toList(),
        );
  }

  // Método para atualizar a casa (com diferença de imagens e tudo mais)
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
      String? usuarioId = _usuarioServices.getUsuarioId();
      if (usuarioId == null) {
        debugPrint('Usuário não autenticado. Atualização da casa falhou.');
        return false;
      }

      DocumentReference casaRef = _firestore.collection('casas').doc(casaId);
      DocumentSnapshot casaSnapshot = await casaRef.get();
      if (!casaSnapshot.exists) {
        debugPrint('Casa não encontrada no Firestore para o ID: $casaId');
        return false;
      }

      // Imagens atuais
      Map<String, dynamic> casaDataAtual =
          casaSnapshot.data() as Map<String, dynamic>;
      List<String> imagensAtuais =
          List<String>.from(casaDataAtual['Imagem'] ?? []);

      // Quais imagens remover
      List<String> imagensParaRemover = [];
      if (novasImagensPaths != null) {
        imagensParaRemover = imagensAtuais
            .where((imagem) => !novasImagensPaths.contains(imagem))
            .toList();
      }

      // Remove as imagens antigas do Storage
      for (String imagemUrl in imagensParaRemover) {
        try {
          Reference imagemRef = FirebaseStorage.instance.refFromURL(imagemUrl);
          await imagemRef.delete();
          debugPrint('Imagem removida do Firebase Storage: $imagemUrl');
        } catch (e) {
          debugPrint('Erro ao remover imagem do Firebase Storage: $e');
        }
      }

      // Novo set de dados
      Map<String, dynamic> casaDataAtualizada = {
        'imagens': novasImagensPaths ?? imagensAtuais,
        'rua': rua,
        'bairro': bairro,
        'cidade': cidade,
        'estado': estado,
        'descricao': descricao,
        'area': area ?? 0.0,
        'preco_total': precoTotal ?? 0.0,
        'num_quarto': numQuarto ?? 0,
        'num_banheiro': numBanheiro ?? 0,
        'id_usuario': usuarioId,
      };

      debugPrint('Atualizando dados no Firestore: $casaDataAtualizada');

      // Update no Firestore
      await casaRef.update(casaDataAtualizada);

      // Opcional: Recarregar ou atualizar a lista local
      await carregarCasas();

      debugPrint('Atualização realizada com sucesso no Firestore.');

      // Atualiza na lista local (caso já exista)
      int casaIndex = _casas.indexWhere((c) => c.id_casa == casaId);
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
      debugPrint('Erro ao atualizar a casa no Firestore: $e');
      return false;
    }
  }

  // Upload de imagem para quando você seleciona localmente (usado na edição)
  Future<String?> uploadImageToFirebase(
      String caminhoLocal, String casaId) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      String filePath = 'casas/$casaId/$fileName';

      File imagemFile = File(caminhoLocal);
      TaskSnapshot snapshot =
          await FirebaseStorage.instance.ref(filePath).putFile(imagemFile);

      String downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('Upload concluído! URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Erro ao fazer upload da imagem: $e');
      return null;
    }
  }

  // Excluir imagens do storage, se precisar
  Future<void> excluirImagensDoStorage(List<String> urlsParaRemover) async {
    for (String url in urlsParaRemover) {
      try {
        Reference ref = FirebaseStorage.instance.refFromURL(url);
        await ref.delete();
        debugPrint('Imagem removida do Firebase Storage: $url');
      } catch (e) {
        debugPrint('Erro ao remover imagem do Firebase Storage: $e');
      }
    }
  }
}
