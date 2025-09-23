import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mcp_llm/mcp_llm.dart';

/// Provider ที่สร้างขึ้นเพื่อเชื่อมต่อกับ Google Gemini API
/// แก้ไขให้สอดคล้องกับ mcp_llm library v1.0.2
class GeminiProvider extends CustomLlmProvider {
  final String apiKey;
  final String model; // [ADD] เพิ่ม property สำหรับเก็บชื่อโมเดล

  GeminiProvider({
    required this.apiKey,
    required this.model, // [ADD] รับชื่อโมเดลเข้ามาใน constructor
    ProviderOptions? options,
  }) : super(name: 'Google Gemini', options: options ?? ProviderOptions());

  @override
  String getCompletionEndpoint() {
    // [FIX] สร้าง URL แบบ dynamic โดยใช้ชื่อโมเดลที่รับเข้ามา
    return 'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey';
  }

  @override
  Map<String, String> getHeaders() {
    return {'Content-Type': 'application/json'};
  }

  @override
  Future<Map<String, dynamic>> transformRequest(LlmRequest request) async {
    // [FIX] เปลี่ยนจาก request.options เป็น request.parameters
    return {
      'contents': [
        {
          'parts': [
            {'text': request.prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': request.parameters['temperature'] ?? 0.7,
        'maxOutputTokens': request.parameters['max_tokens'] ?? 1500,
      }
    };
  }

  @override
  Future<LlmResponse> transformResponse(
      Map<String, dynamic> rawResponse) async {
    final text = rawResponse['candidates']?[0]?['content']?['parts']?[0]
            ?['text'] ??
        'Error: Could not parse Gemini response';
    return LlmResponse(
      text: text,
      metadata: {'raw_response': rawResponse},
    );
  }

  @override
  Future<Map<String, dynamic>> executeRequest(
    Map<String, dynamic> requestData,
    String endpoint,
    Map<String, String> headers,
  ) async {
    final uri = Uri.parse(endpoint);
    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorBody = jsonDecode(response.body);
      final errorMessage = errorBody?['error']?['message'] ?? response.body;
      throw Exception(
          'Failed to call Gemini API: ${response.statusCode} - $errorMessage');
    }
  }

  @override
  Stream<dynamic> executeStreamingRequest(
    Map<String, dynamic> requestData,
    String endpoint,
    Map<String, String> headers,
  ) {
    throw UnimplementedError('Streaming is not implemented for Gemini yet.');
  }

  // --- [ADD] เพิ่มเมธอดที่ขาดไปตามที่ library ต้องการ ---
  @override
  Future<void> close() async {
    // ไม่จำเป็นต้องทำอะไรเป็นพิเศษสำหรับ http client
  }

  @override
  LlmToolCall? extractToolCallFromMetadata(Map<String, dynamic> metadata) {
    throw UnimplementedError();
  }

  @override
  Future<List<double>> getEmbeddings(String text) {
    throw UnimplementedError();
  }

  @override
  bool hasToolCallMetadata(Map<String, dynamic> metadata) {
    return false;
  }

  @override
  Future<void> initialize(LlmConfiguration config) async {
    // ไม่จำเป็นต้องทำอะไรเป็นพิเศษ
  }

  @override
  Map<String, dynamic> standardizeMetadata(Map<String, dynamic> metadata) {
    return metadata;
  }
}

/// Factory สำหรับสร้าง GeminiProvider
class GeminiProviderFactory implements LlmProviderFactory {
  @override
  String get name => 'gemini';

  @override
  Set<LlmCapability> get capabilities => {LlmCapability.completion};

  @override
  LlmInterface createProvider(LlmConfiguration config) {
    final apiKey = config.apiKey;
    if (apiKey == null) {
      throw Exception('Google Gemini API key is required.');
    }
    final model = config.model;
    if (model == null) {
      throw Exception('Gemini model name is required.');
    }

    // [FIX] ส่ง apiKey และ model ไปให้ GeminiProvider
    return GeminiProvider(apiKey: apiKey, model: model);
  }
}