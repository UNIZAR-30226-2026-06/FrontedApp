import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/chat_message_model.dart';
import '../../services/socket_service.dart';

class ChatPartidaWidget extends StatefulWidget {
  final String partidaId;
  final String miUsuario;

  const ChatPartidaWidget({
    super.key,
    required this.partidaId,
    required this.miUsuario,
  });

  @override
  State<ChatPartidaWidget> createState() => _ChatPartidaWidgetState();
}

class _ChatPartidaWidgetState extends State<ChatPartidaWidget> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _mensajes = [];
  bool _abierto = false;
  int _noLeidos = 0;
  SocketService? _socketService;
  bool _listenersRegistrados = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Usamos watch (no read) para que didChangeDependencies se vuelva a
    // llamar cuando el SocketService notifique (típicamente al conectar
    // por primera vez tras login). Sin esto, si el chat widget se monta
    // ANTES de que el socket esté listo, _registrarListeners() salía
    // early con socket==null y nunca se reintentaba → el cliente recibía
    // los eventos pero el chat no los procesaba.
    final socketService = context.watch<SocketService>();

    final cambioInstancia = _socketService != socketService;
    if (cambioInstancia) _socketService = socketService;

    // Re-registramos si:
    //  - cambia la instancia del service (poco habitual)
    //  - aún no había listeners pero ahora el socket sí existe
    final socketYaListo = socketService.socket != null;
    if ((cambioInstancia || !_listenersRegistrados) && socketYaListo) {
      _registrarListeners();
    }
  }

  @override
  void didUpdateWidget(covariant ChatPartidaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.partidaId != widget.partidaId) {
      _mensajes.clear();
      _noLeidos = 0;
      _listenersRegistrados = false;
      _registrarListeners();
    }
  }

  @override
  void dispose() {
    _limpiarListeners();
    _controller.dispose();
    _scrollController.dispose();
    _mensajes.clear();
    super.dispose();
  }

  void _registrarListeners() {
    final socket = _socketService?.socket;
    if (socket == null) {
      debugPrint('[Chat] _registrarListeners abortado: socket null (se reintentará cuando conecte)');
      return;
    }

    _limpiarListeners();
    _socketService?.emitir('unirse_room_partida', widget.partidaId);
    socket.on('mensajeMostrar', _recibirMensaje);
    socket.on('nuevoMensajeChat', _recibirMensaje);
    socket.on('chat_error', _recibirError);
    _listenersRegistrados = true;
    debugPrint('[Chat] listeners registrados para ${widget.partidaId}');
  }

  void _limpiarListeners() {
    final socket = _socketService?.socket;
    socket?.off('mensajeMostrar');
    socket?.off('nuevoMensajeChat');
    socket?.off('chat_error');
    _listenersRegistrados = false;
  }

  void _recibirMensaje(dynamic data) {
    if (!mounted || data is! Map) return;
    final msg = ChatMessage.fromSocket(data);
    if (msg.partidaId != null && msg.partidaId != widget.partidaId) return;

    setState(() {
      _mensajes.add(msg);
      if (_mensajes.length > 80) _mensajes.removeAt(0);
      // Sólo cuenta no-leídos si el panel está cerrado y el mensaje NO es mío.
      if (!_abierto && msg.remitente != widget.miUsuario) {
        _noLeidos++;
      }
    });
    _scrollToBottom();
  }

  void _recibirError(dynamic data) {
    if (!mounted) return;
    final message = data is Map
        ? data['message']?.toString()
        : 'Error en el chat';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message ?? 'Error en el chat')));
  }

  void _enviar() {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;

    _socketService?.emitir('newMessage', {
      'partidaID': widget.partidaId,
      'mensaje': texto,
    });
    _controller.clear();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }

  void _abrirPanel() {
    setState(() {
      _abierto = true;
      _noLeidos = 0;
    });
    // Al abrir, scrolea al final para ver el último mensaje.
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final openWidth = screen.width < 700 ? 285.0 : 310.0;
    final openHeight = screen.height < 520 ? 230.0 : 350.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: _abierto ? openWidth : 54,
      height: _abierto ? openHeight : 54,
      child: _abierto ? _buildPanel() : _buildClosedButton(),
    );
  }

  Widget _buildClosedButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(27),
        onTap: _abrirPanel,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.72),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF00E5FF), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withOpacity(0.35),
                blurRadius: 18,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.chat_bubble_outline, color: Color(0xFF00E5FF)),
              if (_noLeidos > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: Colors.white, width: 1.2),
                    ),
                    child: Center(
                      child: Text(
                        _noLeidos > 9 ? '9+' : '$_noLeidos',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPanel() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF080C22).withOpacity(0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF00E5FF), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withOpacity(0.22),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _mensajes.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Sin mensajes todavía.\n¡Empieza tú la conversación!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    itemCount: _mensajes.length,
                    itemBuilder: (context, index) {
                      final msg = _mensajes[index];
                      final mine = msg.remitente == widget.miUsuario;
                      return Align(
                        alignment: mine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: _MessageBubble(message: msg, mine: mine),
                      );
                    },
                  ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.forum_outlined, color: Color(0xFF00E5FF), size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Chat de partida',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close, color: Colors.white70, size: 18),
            onPressed: () => setState(() => _abierto = false),
          ),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              maxLength: 150,
              minLines: 1,
              maxLines: 2,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                counterText: '',
                hintText: 'Mensaje...',
                hintStyle: const TextStyle(color: Colors.white38),
                isDense: true,
                filled: true,
                fillColor: Colors.white.withOpacity(0.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _enviar(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF00E5FF),
              foregroundColor: Colors.black,
            ),
            onPressed: _enviar,
            icon: const Icon(Icons.send_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool mine;

  const _MessageBubble({required this.message, required this.mine});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 230),
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: mine
            ? const Color(0xFF00E5FF).withOpacity(0.18)
            : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: mine ? const Color(0xFF00E5FF) : Colors.white12,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message.remitente,
            style: TextStyle(
              color: mine ? const Color(0xFF00E5FF) : const Color(0xFFFFD54F),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            message.texto,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 3),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              message.horaCorta,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
