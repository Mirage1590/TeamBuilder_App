import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// [MCP LLM] สมมติว่านี่คือ library หลักของคุณ
import 'package:mcp_llm/mcp_llm.dart'; 
// [GEMINI PROVIDER] Import provider ที่เราสร้างขึ้น
// **สำคัญ:** คุณต้องสร้างไฟล์นี้ในโปรเจกต์ของคุณด้วย
import 'gemini_provider.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // โหลดค่าจากไฟล์ .env
  await dotenv.load(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gemini AI Chat App', // เปลี่ยนชื่อ Title
      theme: ThemeData(
        primarySwatch: Colors.deepPurple, // ลองเปลี่ยนสี Theme
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  late McpLlm _mcpLlm;
  LlmClient? _client;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _initializeLlm();
  }

  Future<void> _initializeLlm() async {
    _mcpLlm = McpLlm();
    // 1. [CHANGE] ลงทะเบียน Gemini provider แทน Claude
    _mcpLlm.registerProvider('gemini', GeminiProviderFactory());

    // 2. [CHANGE] อ่าน API Key ของ Gemini จากไฟล์ .env
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      _showError('GEMINI_API_KEY not found. Please check your .env file.');
      return;
    }

    try {
      _client = await _mcpLlm.createClient(
        // 3. [CHANGE] ระบุว่าจะใช้ provider ที่ชื่อ 'gemini'
        providerName: 'gemini',
        config: LlmConfiguration(
          apiKey: apiKey,
          // 4. [CHANGE] ระบุชื่อ model ของ Gemini
          model: 'gemini-1.5-flash-latest', 
          options: {
            'temperature': 0.7,
            'max_tokens': 1500,
          },
        ),
        systemPrompt: 'You are a helpful assistant powered by Google Gemini. Be concise and friendly.',
      );
    } catch (e) {
      _showError('Failed to initialize Gemini AI: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    _textController.clear();

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
      ));
      _isTyping = true;
    });

    if (_client == null) {
      _showError('AI client not initialized');
      setState(() {
        _isTyping = false;
      });
      return;
    }

    try {
      final response = await _client!.chat(text);

      setState(() {
        _messages.add(ChatMessage(
          text: response.text,
          isUser: false,
        ));
        _isTyping = false;
      });
    } catch (e) {
      _showError('Error getting Gemini AI response: $e');
      setState(() {
        _isTyping = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Gemini'),
      ),
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (_, index) => _messages[_messages.length - 1 - index],
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 8),
                  Text('Gemini is thinking...'),
                ],
              ),
            ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.primary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Send a message to Gemini',
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mcpLlm.shutdown();
    _textController.dispose();
    super.dispose();
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              child: Text(isUser ? 'You' : 'G'), // G for Gemini
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUser ? 'You' : 'Gemini',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: Text(text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}