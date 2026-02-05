import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';

void main() {
  runApp(const StekomYessApp());
}

class StekomYessApp extends StatelessWidget {
  const StekomYessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'STEKOM YESS AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const ChatScreen(),
      },
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  // Convert object to JSON for storage
  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
      };

  // Create object from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  // Fungsi untuk memuat pesan yang tersimpan (Save Data)
  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedMessages = prefs.getString('chat_history');

    if (storedMessages != null) {
      final List<dynamic> decoded = jsonDecode(storedMessages);
      setState(() {
        _messages = decoded.map((e) => ChatMessage.fromJson(e)).toList();
      });
      // Scroll ke bawah setelah load
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } else {
      // Pesan sambutan default jika belum ada data
      _addBotMessage("Halo! Saya STEKOM YESS. Ada yang bisa saya bantu hari ini?");
    }
  }

  // Fungsi untuk menyimpan pesan (Save Data)
  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_messages.map((m) => m.toJson()).toList());
    await prefs.setString('chat_history', encoded);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    _controller.clear();
    
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });
    
    _saveMessages(); // Simpan data user
    _scrollToBottom();

    // Simulasi AI berpikir agar terlihat "Lebih Hidup"
    Timer(const Duration(seconds: 1, milliseconds: 500), () {
      _generateAIResponse(text);
    });
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _isTyping = false;
    });
    _saveMessages(); // Simpan data bot
    _scrollToBottom();
  }

  // Logika AI "Penuh Kebenaran"
  void _generateAIResponse(String input) {
    String response = "";
    String lowerInput = input.toLowerCase();

    if (lowerInput.contains("siapa kamu") || lowerInput.contains("nama")) {
      response = "Saya adalah STEKOM YESS, asisten cerdas yang dirancang untuk memberikan informasi yang benar dan akurat.";
    } else if (lowerInput.contains("johanes")) {
      response = "Nama Johanes telah diperbarui menjadi STEKOM YESS sesuai instruksi sistem terbaru.";
    } else if (lowerInput.contains("kebenaran") || lowerInput.contains("fakta")) {
      response = "Kebenaran adalah fondasi dari segala pengetahuan. Saya diprogram untuk menyampaikan data yang valid dan objektif.";
    } else if (lowerInput.contains("halo") || lowerInput.contains("hai")) {
      response = "Salam! Semoga hari Anda penuh dengan hal-hal positif. Apa yang ingin Anda diskusikan?";
    } else if (lowerInput.contains("terima kasih") || lowerInput.contains("makasih")) {
      response = "Sama-sama! Senang bisa membantu Anda menemukan jawaban yang tepat.";
    } else if (lowerInput.contains("jam") || lowerInput.contains("waktu")) {
      response = "Saat ini adalah waktu yang tepat untuk belajar hal baru. Waktu terus berjalan, mari manfaatkan sebaik mungkin.";
    } else {
      // Jawaban generik yang bijak
      List<String> wiseAnswers = [
        "Pertanyaan yang menarik. Berdasarkan data yang ada, hal tersebut memerlukan analisis mendalam.",
        "Saya mengerti maksud Anda. Mari kita fokus pada solusi yang paling logis dan benar.",
        "Data tersimpan dengan aman. Silakan lanjutkan, saya mendengarkan dengan seksama.",
        "STEKOM YESS selalu siap memproses informasi Anda. Itu adalah poin yang valid.",
        "Kebenaran sejati seringkali sederhana namun mendalam. Saya mencatat input Anda."
      ];
      response = wiseAnswers[DateTime.now().second % wiseAnswers.length];
    }

    _addBotMessage(response);
  }

  // Fungsi untuk menghapus chat (Reset Data)
  void _clearChat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_history');
    setState(() {
      _messages.clear();
      _addBotMessage("Data telah direset. Halo, saya STEKOM YESS yang baru!");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.smart_toy, color: Colors.blueAccent),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("STEKOM YESS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("Online & Menyimpan Data", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w300)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Hapus Data',
            onPressed: _clearChat,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text("Mulai percakapan dengan STEKOM YESS..."))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return const Padding(
                          padding: EdgeInsets.only(left: 16, bottom: 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "STEKOM YESS sedang mengetik...",
                              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, fontSize: 12),
                            ),
                          ),
                        );
                      }
                      final msg = _messages[index];
                      return _buildMessageBubble(msg);
                    },
                  ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: msg.isUser ? Colors.blueAccent : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: msg.isUser ? const Radius.circular(12) : const Radius.circular(0),
            bottomRight: msg.isUser ? const Radius.circular(0) : const Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                color: msg.isUser ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(msg.timestamp),
              style: TextStyle(
                color: msg.isUser ? Colors.white70 : Colors.black45,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: "Tanya STEKOM YESS...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: _handleSubmitted,
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () => _handleSubmitted(_controller.text),
            ),
          ),
        ],
      ),
    );
  }
}
