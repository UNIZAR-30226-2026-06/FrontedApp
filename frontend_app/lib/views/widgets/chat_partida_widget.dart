import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  final List<_ChatMessage> _mensajes = [];
  SocketService? _socketService;
  final FocusNode _focusNode = FocusNode();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final socketService = context.read<SocketService>();
    if (_socketService == socketService) return;

    _socketService = socketService;
    _registrarListeners();
  }

  @override
  void didUpdateWidget(covariant ChatPartidaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.partidaId != widget.partidaId) {
      _mensajes.clear();
      _registrarListeners();
    }
  }

  @override
  void dispose() {
    _limpiarListeners();
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _registrarListeners() {
    final socket = _socketService?.socket;
    if (socket == null) return;

    _limpiarListeners();
    // Nos aseguramos de estar en la sala correcta para recibir mensajes
    _socketService?.emitir('unirse_room_partida', widget.partidaId);

    // Escuchamos los mensajes entrantes (los nuestros y los del resto)
    socket.on('mensajeMostrar', _recibirMensaje);
    socket.on('nuevoMensajeChat', _recibirMensaje);
    socket.on('chat_error', _recibirError);
  }

  void _limpiarListeners() {
    final socket = _socketService?.socket;
    socket?.off('mensajeMostrar');
    socket?.off('nuevoMensajeChat');
    socket?.off('chat_error');
  }

  void _recibirMensaje(dynamic data) {
    if (!mounted || data is! Map) return;

    final msg = _ChatMessage.fromSocket(data);

    // Verificamos que el mensaje sea para esta partida
    if (msg.partidaId != null && msg.partidaId != widget.partidaId) return;

    setState(() {
      _mensajes.add(msg);
      // Mantenemos un máximo de 80 mensajes en RAM para no saturar
      if (_mensajes.length > 80) _mensajes.removeAt(0);
    });
    _scrollToBottom();
  }

  void _recibirError(dynamic data) {
    if (!mounted) return;
    final message = data is Map ? data['message']?.toString() : 'Error al enviar mensaje';
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message ?? 'Error en el chat'),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 2),
        )
    );
  }

  void _enviar() {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;

    // Emitimos el evento 'newMessage' al backend
    _socketService?.emitir('newMessage', {
      'partidaID': widget.partidaId,
      'mensaje': texto,
    });

    _controller.clear();
    // Devolvemos el foco al TextField por si quiere seguir escribiendo
    _focusNode.requestFocus();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Al ser el contenido de un Dialog, usamos Expanded donde se pueda
    // y decoramos el contenedor principal.
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1535).withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _mensajes.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _mensajes.length,
              itemBuilder: (context, index) {
                final msg = _mensajes[index];
                final isMine = msg.remitente == widget.miUsuario;
                return Align(
                  alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: _MessageBubble(message: msg, isMine: isMine),
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          const Icon(Icons.forum, color: Color(0xFF00E5FF), size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Chat de Partida',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline, color: Colors.white.withOpacity(0.2), size: 48),
          const SizedBox(height: 12),
          Text(
            'Aún no hay mensajes.\n¡Sé el primero en saludar!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLength: 150,
              maxLines: 3,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                counterText: '', // Ocultar el contador de caracteres
                hintText: 'Escribe un mensaje...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _enviar(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF00E5FF),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
              onPressed: _enviar,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  final bool isMine;

  const _MessageBubble({required this.message, required this.isMine});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7, // No ocupar todo el ancho
      ),
      decoration: BoxDecoration(
        color: isMine ? const Color(0xFF00E5FF).withOpacity(0.2) : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
          bottomLeft: isMine ? const Radius.circular(12) : const Radius.circular(4),
          bottomRight: isMine ? const Radius.circular(4) : const Radius.circular(12),
        ),
        border: Border.all(
          color: isMine ? const Color(0xFF00E5FF).withOpacity(0.5) : Colors.white24,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mostrar el nombre del remitente si no soy yo
          if (!isMine) ...[
            Text(
              message.remitente,
              style: const TextStyle(
                color: Color(0xFFFFD54F), // Amarillo para destacar a los demás
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            message.texto,
            style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.3),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String remitente;
  final String texto;
  final String? partidaId;

  _ChatMessage({required this.remitente, required this.texto, this.partidaId});

  factory _ChatMessage.fromSocket(Map data) {
    return _ChatMessage(
      remitente: data['remitente']?.toString() ?? 'Jugador',
      texto: data['texto']?.toString() ?? '',
      partidaId: (data['partidaId'] ?? data['partidaID'])?.toString(),
    );
  }
}