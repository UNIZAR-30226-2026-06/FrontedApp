import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/jugador_partida_model.dart';
import '../../models/rol_model.dart';
import '../../viewmodels/partida_actual_viewmodel.dart';
import '../../viewmodels/rol_viewmodel.dart';

// Cartas "especiales" cuyo `value` no es 0-9. Se usan para filtrar las cartas
// del rol "transformar_carta" (que solo opera sobre numéricas).
const _kSpecialValues = <String>{
  '+2', 'reverse', '+2R', 'skip', 'extraTurn',
  'playOdd', 'playEven', 'wild', '+4', 'draw1All', 'swapHands', 'changeColor',
  'addRole', 'restartGame',
};

const _kColors = [
  ('red', 'Rojo', Color(0xFFD72600)),
  ('blue', 'Azul', Color(0xFF0956BF)),
  ('green', 'Verde', Color(0xFF379711)),
  ('yellow', 'Amarillo', Color(0xFFECD407)),
];

class RolOverlay extends StatefulWidget {
  final VoidCallback onClose;
  const RolOverlay({super.key, required this.onClose});

  @override
  State<RolOverlay> createState() => _RolOverlayState();
}

class _RolOverlayState extends State<RolOverlay> {
  String? _targetId;
  String? _ownCardId;
  String? _newColor;
  int? _newNumber;

  @override
  Widget build(BuildContext context) {
    final rolVm = context.watch<RolViewModel>();
    final partidaVm = context.watch<PartidaActualViewModel>();
    final miRol = rolVm.miRol;

    // Si hay un resultado pendiente de mostrar (espía o peek), lo enseñamos
    // sobre el panel — el usuario lo cierra y el panel queda visible.
    final pending = rolVm.ultimoResultado;

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.78),
        child: Stack(
          children: [
            Center(child: _panel(rolVm, partidaVm, miRol)),
            if (pending != null) _resultOverlay(pending, rolVm),
          ],
        ),
      ),
    );
  }

  Widget _panel(
    RolViewModel rolVm,
    PartidaActualViewModel partidaVm,
    MiRolResponse? miRol,
  ) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380, maxHeight: 540),
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1535),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.55)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withOpacity(0.18),
              blurRadius: 28,
              spreadRadius: 4,
            ),
          ],
        ),
        child: rolVm.cargando && miRol == null
            ? const _Loading()
            : (miRol == null || miRol.rol == null)
                ? _sinRol(rolVm)
                : _conRol(rolVm, partidaVm, miRol),
      ),
    );
  }

  Widget _sinRol(RolViewModel rolVm) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _header('Sin rol asignado'),
        const SizedBox(height: 12),
        const Text(
          'Esta partida no parece tener roles activos, o aún no se han asignado.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        if (rolVm.error != null) ...[
          const SizedBox(height: 8),
          Text(
            rolVm.error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent, fontSize: 11),
          ),
        ],
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: rolVm.refrescar,
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Reintentar'),
        ),
      ],
    );
  }

  Widget _conRol(
    RolViewModel rolVm,
    PartidaActualViewModel partidaVm,
    MiRolResponse miRol,
  ) {
    final rol = miRol.rol!;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header('🎭  ${rol.nombre}'),
          if (rol.descripcion != null && rol.descripcion!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              rol.descripcion!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _stat(
                  'Usos restantes',
                  '${miRol.remainingUses}/${miRol.maxUses ?? rol.maxUsos ?? 0}'),
              _stat(
                'Estado',
                miRol.canUseNow ? 'Listo' : 'Espera',
                color: miRol.canUseNow
                    ? const Color(0xFF53D86A)
                    : Colors.white54,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _panelAccion(rolVm, partidaVm, miRol),
          const SizedBox(height: 14),
          _botonera(rolVm, miRol),
        ],
      ),
    );
  }

  Widget _panelAccion(
    RolViewModel rolVm,
    PartidaActualViewModel partidaVm,
    MiRolResponse miRol,
  ) {
    final partida = partidaVm.partidaActual;
    final miId = partida?.jugadorLocal ?? '';
    final rivales = (partida?.jugadores ?? <JugadorPartidaModel>[])
        .where((j) => j.id != miId && !j.isBot)
        .toList();
    final miJugador = partida?.jugadores.firstWhere(
      (j) => j.id == miId,
      orElse: () => JugadorPartidaModel(id: miId),
    );
    final misCartas = (miJugador?.hand ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();

    switch (miRol.rol!.key) {
      case 'espia':
        return _selectorJugadores(rivales, '🕵️  ¿A quién quieres espiar?');
      case 'ladron':
        return Column(children: [
          _selectorJugadores(rivales, '🦹  ¿A quién quieres robar?'),
          const SizedBox(height: 10),
          _selectorCartas(misCartas, '🃏  ¿Qué carta das a cambio?'),
        ]);
      case 'anular_cartas':
        return _selectorCartas(misCartas, '🗑  ¿Qué carta descartas?');
      case 'transformar_carta':
        final numericas = misCartas.where((c) {
          final v = c['value']?.toString() ?? '';
          return !_kSpecialValues.contains(v);
        }).toList();
        return Column(children: [
          _selectorCartas(numericas, '✨  Transformar (solo numéricas)'),
          const SizedBox(height: 10),
          _selectorColor(),
          const SizedBox(height: 10),
          _selectorNumero(),
        ]);
      case 'mirar_siguiente_carta':
        return const _InfoBox(
          texto: '🔮  Verás la siguiente carta del mazo. Pulsa "Usar rol".',
        );
      case 'bloquear_habilidades':
        return const _InfoBox(
          texto: '🚫  Bloquea las habilidades del resto por la próxima ronda.',
        );
      default:
        return _InfoBox(texto: 'Rol no reconocido: ${miRol.rol!.nombre}');
    }
  }

  Widget _selectorJugadores(List<JugadorPartidaModel> rivales, String label) {
    if (rivales.isEmpty) {
      return _InfoBox(texto: 'No hay rivales humanos disponibles');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 12)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: rivales.map((r) {
            final sel = _targetId == r.id;
            return ChoiceChip(
              label: Text(r.id),
              selected: sel,
              selectedColor: const Color(0xFF00E5FF),
              backgroundColor: const Color(0xFF1E244D),
              labelStyle: TextStyle(
                color: sel ? Colors.black : Colors.white,
                fontWeight: FontWeight.w700,
              ),
              onSelected: (_) => setState(() => _targetId = sel ? null : r.id),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _selectorCartas(List<Map<String, dynamic>> cartas, String label) {
    if (cartas.isEmpty) {
      return _InfoBox(texto: 'No tienes cartas válidas para esta acción');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 12)),
        const SizedBox(height: 6),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cartas.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final c = cartas[i];
              final id = c['id']?.toString() ?? '';
              final color = c['color']?.toString() ?? 'blue';
              final value = c['value']?.toString() ?? '?';
              final sel = _ownCardId == id;
              return GestureDetector(
                onTap: () => setState(() => _ownCardId = sel ? null : id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: 48,
                  decoration: BoxDecoration(
                    color: _hexColor(color),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: sel ? const Color(0xFFFFD54F) : Colors.white24,
                      width: sel ? 3 : 1,
                    ),
                    boxShadow: sel
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFFD54F).withOpacity(0.6),
                              blurRadius: 10,
                            ),
                          ]
                        : [],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _selectorColor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🎨  Nuevo color (opcional)',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 12)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          children: _kColors.map((c) {
            final sel = _newColor == c.$1;
            return ChoiceChip(
              label: Text(c.$2),
              selected: sel,
              selectedColor: c.$3,
              backgroundColor: const Color(0xFF1E244D),
              labelStyle: TextStyle(
                color: sel ? Colors.white : Colors.white70,
                fontWeight: FontWeight.w700,
              ),
              onSelected: (_) =>
                  setState(() => _newColor = sel ? null : c.$1),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _selectorNumero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🔢  Nuevo número (opcional)',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 12)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 4,
          children: List.generate(10, (i) {
            final sel = _newNumber == i;
            return ChoiceChip(
              label: Text('$i'),
              selected: sel,
              selectedColor: const Color(0xFF00E5FF),
              backgroundColor: const Color(0xFF1E244D),
              labelStyle: TextStyle(
                color: sel ? Colors.black : Colors.white,
                fontWeight: FontWeight.w700,
              ),
              onSelected: (_) => setState(() => _newNumber = sel ? null : i),
            );
          }),
        ),
      ],
    );
  }

  Widget _botonera(RolViewModel rolVm, MiRolResponse miRol) {
    final puedeUsar = miRol.canUseNow && !rolVm.cargando;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: widget.onClose,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Cerrar'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: puedeUsar ? () => _confirmar(rolVm, miRol) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E5FF),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12),
              disabledBackgroundColor: Colors.white24,
              disabledForegroundColor: Colors.white38,
            ),
            icon: rolVm.cargando
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : const Icon(Icons.flash_on, size: 18),
            label: Text(
              rolVm.cargando ? 'Usando…' : 'Usar rol',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmar(RolViewModel rolVm, MiRolResponse miRol) async {
    final key = miRol.rol!.key;
    final err = _validar(key);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final payload = UsarRolPayload(
      targetPlayerId: _targetId,
      ownCardId: _ownCardId,
      newColor: _newColor,
      newNumber: _newNumber,
    );
    final res = await rolVm.usarRol(payload);
    if (!mounted) return;

    // Reseteamos selectores tras un uso exitoso.
    if (res != null && res.success) {
      setState(() {
        _targetId = null;
        _ownCardId = null;
        _newColor = null;
        _newNumber = null;
      });
    } else if (rolVm.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(rolVm.error!), backgroundColor: Colors.redAccent),
      );
    }
  }

  String? _validar(String key) {
    switch (key) {
      case 'espia':
        if (_targetId == null) return 'Selecciona un jugador para espiar';
        return null;
      case 'ladron':
        if (_targetId == null) return 'Selecciona un jugador objetivo';
        if (_ownCardId == null) return 'Selecciona una carta tuya';
        return null;
      case 'anular_cartas':
        if (_ownCardId == null) return 'Selecciona una carta para descartar';
        return null;
      case 'transformar_carta':
        if (_ownCardId == null) return 'Selecciona una carta para transformar';
        if (_newColor == null && _newNumber == null) {
          return 'Elige un nuevo color o número';
        }
        return null;
      default:
        return null;
    }
  }

  Widget _resultOverlay(UsarRolResponse res, RolViewModel rolVm) {
    final key = res.rol?.key ?? '';
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(28),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            constraints: const BoxConstraints(maxWidth: 340),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1535),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFFD54F).withOpacity(0.6)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  key == 'espia'
                      ? '🕵️  Mano del rival'
                      : key == 'mirar_siguiente_carta'
                          ? '🔮  Siguiente carta del mazo'
                          : '✅  Rol usado',
                  style: const TextStyle(
                      color: Color(0xFFFFD54F),
                      fontWeight: FontWeight.w900,
                      fontSize: 16),
                ),
                const SizedBox(height: 12),
                if (key == 'espia') _spyResult(res.targetHand),
                if (key == 'mirar_siguiente_carta') _peekResult(res.nextCard),
                if (key != 'espia' && key != 'mirar_siguiente_carta')
                  const Text(
                    '¡Acción completada!',
                    style: TextStyle(color: Colors.white70),
                  ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: rolVm.clearUltimoResultado,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _spyResult(List<dynamic> hand) {
    if (hand.isEmpty) {
      return const Text('El rival no tiene cartas',
          style: TextStyle(color: Colors.white60));
    }
    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: hand.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final c = hand[i] is Map<String, dynamic>
              ? hand[i] as Map<String, dynamic>
              : <String, dynamic>{};
          return _miniCard(c);
        },
      ),
    );
  }

  Widget _peekResult(dynamic carta) {
    if (carta == null) {
      return const Text('El mazo está vacío',
          style: TextStyle(color: Colors.white60));
    }
    final c = carta is Map<String, dynamic> ? carta : <String, dynamic>{};
    return _miniCard(c, big: true);
  }

  Widget _miniCard(Map<String, dynamic> c, {bool big = false}) {
    final color = c['color']?.toString() ?? 'blue';
    final value = c['value']?.toString() ?? '?';
    final side = big ? 80.0 : 48.0;
    return Container(
      width: side,
      height: side * 1.35,
      decoration: BoxDecoration(
        color: _hexColor(color),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white30, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        value,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: big ? 26 : 16,
        ),
      ),
    );
  }

  // Helpers visuales
  Widget _header(String txt) => Text(
        txt,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 18,
        ),
      );

  Widget _stat(String label, String valor, {Color? color}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8)),
        const SizedBox(height: 2),
        Text(valor,
            style: TextStyle(
              color: color ?? const Color(0xFFFFD54F),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            )),
      ],
    );
  }

  Color _hexColor(String name) {
    switch (name) {
      case 'red':
        return const Color(0xFFD72600);
      case 'blue':
        return const Color(0xFF0956BF);
      case 'green':
        return const Color(0xFF379711);
      case 'yellow':
        return const Color(0xFFECD407);
      case 'black':
      case 'wild':
        return const Color(0xFF1E244D);
      default:
        return const Color(0xFF1E244D);
    }
  }
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String texto;
  const _InfoBox({required this.texto});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
    );
  }
}
