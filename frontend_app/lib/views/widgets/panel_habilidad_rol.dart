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

  final List<String> _colores = ['red', 'blue', 'green', 'yellow'];
  final List<int> _numeros = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
  final Set<String> _cartasEspeciales = {'+2', 'reverse', '+2R', 'skip', 'extraTurn', 'playOdd', 'playEven', 'wild', '+4', 'draw1All', 'cancelColor'};

  String _getRoleKey(String roleName) {
    final n = roleName.toLowerCase().replaceAll('í', 'i').replaceAll('ó', 'o').trim();
    if (n.contains("espia")) return "espia";
    if (n.contains("ladron")) return "ladron";
    if (n.contains("anular cartas")) return "anular_cartas";
    if (n.contains("transformar carta")) return "transformar_carta";
    if (n.contains("mirar la siguiente")) return "mirar_siguiente_carta";
    if (n.contains("bloquear habilidades")) return "bloquear_habilidades";
    return "";
  }

  Future<void> _ejecutarRol(PartidaActualViewModel vm) async {
    if (vm.miRol == null || !vm.canUseRoleNow) return;

    final roleKey = _getRoleKey(vm.miRol!['name'] ?? '');
    final bool needsPanel = ["espia", "ladron", "anular_cartas", "transformar_carta"].contains(roleKey);

    if (!needsPanel) {
      setState(() => _isLoading = true);
      final res = await vm.activarHabilidadRol();
      setState(() => _isLoading = false);

      if (res != null && res['result'] != null) {
        if (roleKey == "mirar_siguiente_carta") {
          _mostrarResultado(context, "Siguiente Carta", res['result']['nextCard']);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Habilidad ejecutada"), backgroundColor: Colors.green),
          );
        }
      }
      return;
    }

    _mostrarMenuSeleccion(context, vm, roleKey);
  }

  void _mostrarMenuSeleccion(BuildContext context, PartidaActualViewModel vm, String roleKey) {
    String? selectedTarget;
    String? selectedCard;
    String? selectedColor;
    int? selectedNumber;

    final miId = vm.partidaActual?.jugadorLocal ?? '';
    final rivales = vm.partidaActual?.jugadores.where((j) => j.id != miId).toList() ?? [];

    // 🔥 Adaptación React: Filtramos si es "transformar" para que solo salgan números
    final manoCompleta = vm.partidaActual?.jugadores.firstWhere((j) => j.id == miId).hand ?? [];
    final miMano = roleKey == "transformar_carta"
        ? manoCompleta.where((c) {
      final valor = Carta.fromJson(c).valor;
      return !_cartasEspeciales.contains(valor);
    }).toList()
        : manoCompleta;

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xFF0D1433),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) {
          return StatefulBuilder(
            builder: (BuildContext ctx, StateSetter setModalState) {
              return Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                    left: 20, right: 20, top: 20
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Usar: ${vm.miRol!['name']}", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),

                    // 1. SELECTOR DE RIVAL
                    if (roleKey == "espia" || roleKey == "ladron") ...[
                      const Text("¿A quién aplicas la habilidad?", style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        children: rivales.map((r) => ChoiceChip(
                          label: Text(r.id, style: TextStyle(color: selectedTarget == r.id ? Colors.white : Colors.black)),
                          selected: selectedTarget == r.id,
                          selectedColor: const Color(0xFF00E5FF),
                          onSelected: (val) => setModalState(() => selectedTarget = val ? r.id : null),
                        )).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // 2. SELECTOR DE CARTA
                    if (roleKey == "ladron" || roleKey == "anular_cartas" || roleKey == "transformar_carta") ...[
                      Text(roleKey == "transformar_carta" ? "¿Qué carta transformas?" : "¿Qué carta tuya usas?", style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 10),
                      if (miMano.isEmpty)
                        const Text("No tienes cartas válidas", style: TextStyle(color: Colors.redAccent))
                      else
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: miMano.length,
                            itemBuilder: (ctx, i) {
                              final c = Carta.fromJson(miMano[i]);
                              final isSelected = selectedCard == c.id;
                              return GestureDetector(
                                onTap: () => setModalState(() => selectedCard = c.id),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                      border: isSelected ? Border.all(color: const Color(0xFF00E5FF), width: 3) : null,
                                      borderRadius: BorderRadius.circular(8)
                                  ),
                                  child: CartaWidget(carta: c, width: 60),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],

                    // 3. SELECTORES EXTRAS PARA TRANSFORMAR
                    if (roleKey == "transformar_carta") ...[
                      const Text("Nuevo Color (Opcional)", style: TextStyle(color: Colors.white70)),
                      Wrap(
                        spacing: 10,
                        children: _colores.map((color) => ChoiceChip(
                          label: Text(color.toUpperCase(), style: const TextStyle(fontSize: 10)),
                          selected: selectedColor == color,
                          selectedColor: _getColor(color),
                          onSelected: (val) => setModalState(() => selectedColor = val ? color : null),
                        )).toList(),
                      ),
                      const SizedBox(height: 10),
                      const Text("Nuevo Número (Opcional)", style: TextStyle(color: Colors.white70)),
                      Wrap(
                        spacing: 5,
                        children: _numeros.map((num) => ChoiceChip(
                          label: Text('$num'),
                          selected: selectedNumber == num,
                          selectedColor: const Color(0xFF00E5FF),
                          onSelected: (val) => setModalState(() => selectedNumber = val ? num : null),
                        )).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF62B155),
                          minimumSize: const Size(double.infinity, 45)
                      ),
                      onPressed: () async {
                        // Validaciones copiadas de React
                        if ((roleKey == "espia" || roleKey == "ladron") && selectedTarget == null) return;
                        if ((roleKey == "ladron" || roleKey == "anular_cartas" || roleKey == "transformar_carta") && selectedCard == null) return;
                        if (roleKey == "transformar_carta" && selectedColor == null && selectedNumber == null) return;

                        Navigator.pop(ctx);

                        setState(() => _isLoading = true);
                        final res = await vm.activarHabilidadRol(
                          targetPlayerId: selectedTarget,
                          ownCardId: selectedCard,
                          cardId: selectedCard,
                          newColor: selectedColor,
                          newNumber: selectedNumber,
                        );
                        setState(() => _isLoading = false);

                        if (res != null && res['result'] != null && roleKey == "espia") {
                          _mostrarResultado(context, "Mano de $selectedTarget", res['result']['targetHand']);
                        } else if (res != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("✅ Habilidad usada con éxito"), backgroundColor: Colors.green),
                          );
                        }
                      },
                      child: const Text("Confirmar Acción", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              );
            },
          );
        }
    );
  }

  Color _getColor(String colorName) {
    switch (colorName) {
      case 'red': return Colors.red;
      case 'blue': return Colors.blue;
      case 'green': return Colors.green;
      case 'yellow': return Colors.orangeAccent;
      default: return Colors.grey;
    }
  }

  void _mostrarResultado(BuildContext context, String titulo, dynamic data) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0D1433),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF00E5FF))),
        title: Text(titulo, style: const TextStyle(color: Colors.white)),
        content: data is List && data.isNotEmpty
            ? Wrap(
          spacing: 10, runSpacing: 10,
          children: data.map((c) => CartaWidget(carta: Carta.fromJson(c), width: 50)).toList(),
        )
            : Text(data != null ? data.toString() : "Mazo vacío", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar", style: TextStyle(color: Color(0xFF00E5FF)))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PartidaActualViewModel>();
    if (vm.miRol == null || vm.partidaActual?.rolesMode != true) return const SizedBox.shrink();

    final maxUsos = vm.maxUsosRol;
    final usosRestantes = maxUsos > 0 ? (maxUsos - vm.usosRol).clamp(0, 99) : 0;
    final canUse = vm.canUseRoleNow && vm.partidaActual!.esMiTurno(vm.partidaActual?.jugadorLocal ?? '') && usosRestantes > 0;

    return Positioned(
      left: 16,
      bottom: 160,
      child: GestureDetector(
        onTap: () {
          if (canUse && !_isLoading) _ejecutarRol(vm);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: canUse ? const Color(0xFF00E5FF).withOpacity(0.2) : Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: canUse ? const Color(0xFF00E5FF) : Colors.white24, width: 2),
            boxShadow: canUse ? [const BoxShadow(color: Color(0xFF00E5FF), blurRadius: 10, spreadRadius: 1)] : [],
          ),
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.theater_comedy, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                  canUse ? "USAR ROL ($usosRestantes/$maxUsos)" : "ROL EN ESPERA",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)
              ),
            ],
          ),
        ),
      ),
    );
  }
}