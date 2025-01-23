import 'package:flutter/material.dart';
import 'package:aluguel/casa/casa_model.dart';
import 'package:aluguel/agendamento/agendamento_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CasaDetalhesPage extends StatefulWidget {
  final Casa casa;

  CasaDetalhesPage({required this.casa});

  @override
  _CasaDetalhesPageState createState() => _CasaDetalhesPageState();
}

class _CasaDetalhesPageState extends State<CasaDetalhesPage> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.casa.cidade ?? 'Detalhes da Casa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Carousel de Imagens com Indicadores
            widget.casa.Imagem != null && widget.casa.Imagem!.isNotEmpty
                ? Column(
                    children: [
                      Container(
                        height: 200, // Altura fixa para o carousel
                        width: double.infinity,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: widget.casa.Imagem!.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: CachedNetworkImage(
                                imageUrl: widget
                                    .casa.Imagem![index], // Alterado para index
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 160,
                                placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(
                                    color: Colors
                                        .amber[300], // Cor do carregamento
                                  ),
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.error,
                                  color:
                                      const Color.fromARGB(255, 194, 193, 193),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 8.0),
                      // Indicadores de bolinhas
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.casa.Imagem!.length,
                          (index) => Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: CircleAvatar(
                              radius: 5,
                              backgroundColor: _currentPage == index
                                  ? Colors.orange
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Icon(Icons.home, size: 100, color: Colors.grey),
            SizedBox(height: 16.0),

            // Grid de informações da casa
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCasaInfoCard(
                    'Quartos', widget.casa.num_quarto?.toString() ?? 'N/A'),
                _buildCasaInfoCard(
                    'Banheiros', widget.casa.num_banheiro?.toString() ?? 'N/A'),
              ],
            ),
            SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCasaInfoCard('Rua', widget.casa.rua ?? 'N/A'),
                _buildCasaInfoCard('Bairro', widget.casa.bairro ?? 'N/A'),
              ],
            ),
            SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCasaInfoCard('Cidade', widget.casa.cidade ?? 'N/A'),
                _buildCasaInfoCard('UF', widget.casa.estado ?? 'N/A'),
              ],
            ),
            SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCasaInfoCard(
                    'Área', '${widget.casa.area?.toString() ?? 'N/A'} m²'),
                _buildCasaInfoCard(
                    'Valor',
                    widget.casa.preco_total != null
                        ? 'R\$ ${widget.casa.preco_total!.toStringAsFixed(2)}'
                        : 'N/A'),
              ],
            ),
            SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildCasaInfoCard(
                      'Descrição', widget.casa.descricao?.toString() ?? 'N/A'),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Botão de Agendar Visita com borda laranja
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AgendarVisitaPage(
                          casaId: widget.casa.id_casa.toString(),
                          userId: widget.casa.id_usuario.toString()),
                    ),
                  );
                },
                icon: Icon(Icons.calendar_today, size: 20),
                label: Text('Agendar Visita'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Colors.white, // Cor de fundo branca
                  foregroundColor: Colors.orange[300], // Cor do texto
                  side: BorderSide(
                    color: Colors.orange, // Cor da borda laranja
                    width: 1.8, // Espessura da borda
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para criar o card de informação da casa
  Widget _buildCasaInfoCard(String label, String value) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(left: 8, right: 8),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.black, // Cor laranja
            width: 1.8, // Espessura da borda
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
