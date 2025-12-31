class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? id;

  Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.id,
  });

  factory Message.user(String text) {
    return Message(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  factory Message.bot(String text) {
    return Message(
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      id: 'bot_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}