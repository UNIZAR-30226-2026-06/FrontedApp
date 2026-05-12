import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/partida_actual_viewmodel.dart';
import '../../models/carta_model.dart';
import 'carta_widget.dart';

class PanelHabilidadRol extends StatefulWidget {
  const PanelHabilidadRol({super.key});

  @override
  State<PanelHabilidadRol> createState() => _PanelHabilidadRolState();
}

class _PanelHabilidadRolState extends State<PanelHabilidadRol> {
  bool _isLoading = false;

  String? selectedTarget;
  String? selectedCard;
  String? selectedColor;
  int? selectedNumber;

  final List<String> _colores = ['red', 'blue', 'green', 'yellow'];
  final List<int> _numeros = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
  final Set<String> _cartasEspeciales = {
    '+2', 'reverse', '+2R', 'skip', 'extraTurn', 'playOdd',
    'playEven', 'wild', '+4', 'draw1All', 'cancelColor'
  };

  String _getRoleKey(String roleName) {
    final n = roleName.toLowerCase().replaceAll('í', 'i').replaceAll('ó', 'o').trim();
    // Búsqueda por raíz de palabra para evitar que cambios en la DB rompan el front
    if (n.contains("espia") || n.contains("ver mano")) return "espia";
    if (n.contains("ladron") || n.contains("robar")) return "ladron";
    if (n.contains("anular") || n.contains("cancelar")) return "anular_cartas";
    if (n.contains("transformar") || n.contains("mutar")) return "transformar_carta";
    if (n.contains("mirar") || n.contains("siguiente")) return "mirar_siguiente_carta";
    if (n.contains("bloquear") || n.contains("silenciar")) return "bloquear_habilidades";
    return "";
  }

  Color _getColor(String colorName) {
    switch (colorName) {
      case 'red': return const Color(0xFFD32F2F);
      case 'blue': return const Color(0xFF1976D2);
      case 'green': return const Color(0xFF388E3C);
      case 'yellow': return const Color(0xFFFBC02D);
      default: return Colors.grey;
    }
  }

  String _traductorColor(String c) {
    switch (c) {
      case 'red': return "Rojo";
      case 'blue': return "Azul";
      case 'green': return "Verde";
      case 'yellow': return "Amarillo";
      default: return c;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PartidaActualViewModel>();
    final roleName = vm.miRol?['nombre'] ?? '';
    final roleKey = _getRoleKey(roleName);

    final miId = vm.partidaActual?.jugadorLocal ?? '';
    final rivales = vm.partidaActual?.jugadores.where((j) => j.id != miId).toList() ?? [];

    final manoCompleta = vm.partidaActual?.jugadores.firstWhere((j) => j.id == miId).hand ?? [];

    // Si la habilidad es transformar, filtramos las cartas especiales (no se pueden transformar)
    final miMano = roleKey == "transformar_carta"
        ? manoCompleta.where((c) {
      final valor = Carta.fromJson(c).valor;
      return !_cartasEspeciales.contains(valor);
    }).toList()
        : manoCompleta;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1535).withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.5), width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 15)],
      ),
      child: Column(
        children: [
          // CABECERA
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    roleName.toUpperCase(),
                    style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.w900, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
          ),

          // CONTENIDO SCROLLABLE
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // 1. SELECTOR DE RIVAL (Espía, Ladrón, Anular Cartas)
                  if (roleKey == "espia" || roleKey == "ladron" || roleKey == "anular_cartas") ...[
                    const Text("🎯 Elige tu objetivo", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: rivales.map((r) => ChoiceChip(
                        label: Text(r.id, style: TextStyle(color: selectedTarget == r.id ? Colors.black : Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        selected: selectedTarget == r.id,
                        selectedColor: const Color(0xFF00E5FF),
                        backgroundColor: Colors.white10,
                        onSelected: (val) => setState(() => selectedTarget = val ? r.id : null),
                      )).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 2. SELECTOR DE CARTA (Transformar, Anular)
                  if (roleKey == "anular_cartas" || roleKey == "transformar_carta") ...[
                    Text(
                        roleKey == "transformar_carta" ? "✨ ¿Qué carta transformas?\n(solo numéricas)" : "🃏 Selecciona una carta",
                        style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 12),
                    if (miMano.isEmpty)
                      const Text("No tienes cartas válidas", style: TextStyle(color: Colors.redAccent, fontSize: 12))
                    else
                      Wrap(
                        spacing: 12, runSpacing: 12,
                        children: miMano.map((cRaw) {
                          final c = Carta.fromJson(cRaw);
                          final isSelected = selectedCard == c.id;
                          return GestureDetector(
                            onTap: () {
                              setState(() => selectedCard = isSelected ? null : c.id);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isSelected ? const Color(0xFF00E5FF) : Colors.transparent, width: 3),
                                boxShadow: isSelected ? [const BoxShadow(color: Color(0xFF00E5FF), blurRadius: 8)] : [],
                              ),
                              child: IgnorePointer(
                                child: CartaWidget(carta: c, width: 55),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 24),
                  ],

                  // 3. SELECTORES EXTRAS (Color y Número para Transformar)
                  if (roleKey == "transformar_carta") ...[
                    const Text("🎨 Nuevo color (opcional)", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _colores.map((color) => ChoiceChip(
                        label: Text(_traductorColor(color), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        selected: selectedColor == color,
                        selectedColor: _getColor(color).withOpacity(0.8),
                        backgroundColor: _getColor(color).withOpacity(0.2),
                        side: BorderSide(color: selectedColor == color ? Colors.white : _getColor(color), width: 1.5),
                        onSelected: (val) => setState(() => selectedColor = val ? color : null),
                      )).toList(),
                    ),
                    const SizedBox(height: 24),

                    const Text("🔢 Nuevo número (opcional)", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _numeros.map((num) => ChoiceChip(
                        label: Text('$num', style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w900)),
                        selected: selectedNumber == num,
                        selectedColor: const Color(0xFF00E5FF),
                        backgroundColor: Colors.white,
                        onSelected: (val) => setState(() => selectedNumber = val ? num : null),
                      )).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Habilidades automáticas
                  if (roleKey == "mirar_siguiente_carta" || roleKey == "bloquear_habilidades")
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                          "Esta habilidad se aplicará de forma automática y no requiere seleccionar opciones.",
                          style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, fontSize: 12)
                      ),
                    ),
                ],
              ),
            ),
          ),

          // BOTÓN DE CONFIRMAR CON VALIDACIONES Y BLOQUEO INTELIGENTE
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 5,
                ),
                onPressed: (_isLoading || ((roleKey == "transformar_carta" || roleKey == "anular_cartas") && miMano.isEmpty))
                    ? null
                    : () async {

                  // 1. VALIDACIONES ESTRICTAS SEGÚN EL ROL
                  if ((roleKey == "espia" || roleKey == "ladron" || roleKey == "anular_cartas") && selectedTarget == null) {
                    _mostrarError("Debes seleccionar un jugador objetivo.");
                    return;
                  }

                  if ((roleKey == "transformar_carta" || roleKey == "anular_cartas") && selectedCard == null) {
                    _mostrarError("Debes seleccionar una carta de tu mano.");
                    return;
                  }

                  if (roleKey == "transformar_carta" && selectedColor == null && selectedNumber == null) {
                    _mostrarError("Debes elegir un nuevo color o un nuevo número.");
                    return;
                  }

                  // 2. PAYLOAD INTELIGENTE (Asignamos el target correcto sin romper el backend)
                  String? finalTarget;
                  if (roleKey == "transformar_carta") {
                    finalTarget = miId; // Mutamos nuestra propia carta
                  } else if (roleKey == "espia" || roleKey == "ladron" || roleKey == "anular_cartas") {
                    finalTarget = selectedTarget; // Acciones contra un rival
                  } else {
                    finalTarget = null; // Acciones globales (mirar mazo, bloquear)
                  }

                  setState(() => _isLoading = true);

                  // 3. LLAMADA AL BACKEND
                  final res = await vm.activarHabilidadRol(
                    targetPlayerId: finalTarget,
                    ownCardId: selectedCard,
                    cardId: selectedCard,
                    newColor: selectedColor,
                    newNumber: selectedNumber,
                  );

                  setState(() => _isLoading = false);

                  if (!context.mounted) return;

                  if (res != null) {
                    if (roleKey == "espia" && res['result'] != null) {
                      final targetHand = res['result']['targetHand'];
                      final manoLimpia = (targetHand is List) ? targetHand : [];
                      await _mostrarPopup(context, "Mano de $selectedTarget", manoLimpia);
                      if (context.mounted) Navigator.of(context).pop();
                    } else if (roleKey == "mirar_siguiente_carta" && res['result'] != null) {
                      final nextCard = res['result']['nextCard'];
                      final listaSegura = nextCard != null ? [nextCard] : [];
                      await _mostrarPopup(context, "Próxima Carta", listaSegura);
                      if (context.mounted) Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("✅ Habilidad ejecutada con éxito", style: TextStyle(fontWeight: FontWeight.bold)),
                            backgroundColor: Color(0xFF388E3C)
                        ),
                      );
                    }
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : const Text("Confirmar Acción", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 2),
        )
    );
  }

  Future<void> _mostrarPopup(BuildContext outerContext, String titulo, dynamic data) async {
    return showDialog(
      context: outerContext,
      builder: (dialogCtx) => AlertDialog(

        backgroundColor: const Color(0xFF0F1535),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF00E5FF), width: 2)),
        title: Text(titulo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: data is List && data.isNotEmpty
            ? Wrap(
          spacing: 10, runSpacing: 10, alignment: WrapAlignment.center,
          children: data.map((c) => CartaWidget(carta: Carta.fromJson(c), width: 60)).toList(),
        )
            : const Text("No hay cartas para mostrar.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text("Cerrar", style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }
}