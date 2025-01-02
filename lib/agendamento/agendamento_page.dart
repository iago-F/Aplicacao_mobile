import 'package:flutter/material.dart';
import 'package:aluguel/agendamento/agendamento_model.dart';
import 'package:aluguel/agendamento/agendamento_services.dart';

class AgendarVisitaPage extends StatefulWidget {
  final String casaId;
  final String userId;

  const AgendarVisitaPage({
    required this.casaId,
    required this.userId,
    Key? key,
  }) : super(key: key);

  @override
  State<AgendarVisitaPage> createState() => _AgendarVisitaPageState();
}

class _AgendarVisitaPageState extends State<AgendarVisitaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCompletoController = TextEditingController();
  final _telefoneController = TextEditingController();
  DateTime? _dataHoraSelecionada;
  TimeOfDay? _horaSelecionada;

  final VisitaService _visitaService = VisitaService();

  // Método para agendar visita
  Future<void> _agendarVisita() async {
    if (_formKey.currentState!.validate() &&
        _dataHoraSelecionada != null &&
        _horaSelecionada != null) {
      bool conflito = await _visitaService.verificarConflitoAgendamento(
        widget.casaId,
        _dataHoraSelecionada!,
      );

      if (conflito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Já existe uma visita agendada para esse horário!'),
          ),
        );
        return;
      }

      final visita = VisitaModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        casaId: widget.casaId,
        userId: widget.userId,
        nomeCompleto: _nomeCompletoController.text,
        telefone: _telefoneController.text,
        dataHora: DateTime(
          _dataHoraSelecionada!.year,
          _dataHoraSelecionada!.month,
          _dataHoraSelecionada!.day,
          _horaSelecionada!.hour,
          _horaSelecionada!.minute,
        ),
      );

      try {
        await _visitaService.salvarVisita(visita);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Visita agendada com sucesso!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao agendar visita: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agendar Visita')),
      body: SingleChildScrollView(
        // Adiciona a rolagem na tela
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nomeCompletoController,
                  decoration: InputDecoration(
                    labelText: 'Nome Completo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.orange,
                        width: 1.8, // Espessura da borda
                      ),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Campo obrigatório'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _telefoneController,
                  decoration: InputDecoration(
                    labelText: 'Telefone',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.orange,
                        width: 1.8, // Espessura da borda
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Campo obrigatório'
                      : null,
                ),
                const SizedBox(height: 16),

                // Container com borda arredondada para o calendário
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.black, // Cor da borda
                      width: 1.8, // Espessura da borda
                    ),
                  ),
                  child: CalendarDatePicker(
                    initialDate: _dataHoraSelecionada ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    onDateChanged: (selectedDate) {
                      setState(() {
                        _dataHoraSelecionada = selectedDate;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Se uma data foi selecionada, exibe o seletor de hora
                if (_dataHoraSelecionada != null)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // Fundo branco
                      foregroundColor: Colors.orange, // Texto laranja
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                      side: BorderSide(
                          color: Colors.orange, width: 1.8), // Borda laranja
                    ),
                    onPressed: () async {
                      final TimeOfDay? hora = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (hora != null) {
                        setState(() {
                          _horaSelecionada = hora;
                        });
                      }
                    },
                    child: Text(
                      _horaSelecionada == null
                          ? 'Selecionar Hora'
                          : 'Hora: ${_horaSelecionada!.format(context)}',
                      style: const TextStyle(
                          color: Colors.orange), // Texto laranja
                    ),
                  ),
                const SizedBox(height: 32),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Fundo branco
                    foregroundColor: Colors.orange, // Texto laranja
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                    side: BorderSide(
                        color: Colors.orange, width: 1.8), // Borda laranja
                  ),
                  onPressed: _agendarVisita,
                  child: const Text(
                    'Agendar Visita',
                    style: TextStyle(color: Colors.orange), // Texto laranja
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
