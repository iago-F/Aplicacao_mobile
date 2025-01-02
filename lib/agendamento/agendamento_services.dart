import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aluguel/agendamento/agendamento_model.dart';

class VisitaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para salvar a visita
  Future<void> salvarVisita(VisitaModel visita) async {
    try {
      await _firestore
          .collection('visitas')
          .doc(visita.id)
          .set(visita.toJson());
    } catch (e) {
      throw Exception('Erro ao salvar visita: $e');
    }
  }

  // Método para listar visitas por casa
  Future<List<VisitaModel>> listarVisitasPorCasa(String casaId) async {
    try {
      final querySnapshot = await _firestore
          .collection('visitas')
          .where('casaId', isEqualTo: casaId)
          .get();

      return querySnapshot.docs
          .map((doc) => VisitaModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar visitas: $e');
    }
  }

  // Método para verificar conflito de agendamento
  Future<bool> verificarConflitoAgendamento(
      String casaId, DateTime dataHora) async {
    try {
      final visitas = await listarVisitasPorCasa(casaId);
      for (var visita in visitas) {
        if (visita.dataHora == dataHora) {
          return true; // Conflito encontrado
        }
      }
      return false; // Sem conflitos
    } catch (e) {
      throw Exception('Erro ao verificar conflito: $e');
    }
  }

  // Método para listar visitas por usuário
  Future<List<VisitaModel>> listarVisitasPorUsuario(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('visitas')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs
          .map((doc) => VisitaModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar visitas: $e');
    }
  }
}
