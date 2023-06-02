import 'dart:convert';

import 'package:http/http.dart' as http;

String apiKey = "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";

Future sendTextCompletionRequest(String message) async {
  String baseUrl = "https://api.openai.com/v1/completions";
  Map<String, String> headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer $apiKey"
  };
  var res = await http.post(Uri.parse(baseUrl),
      headers: headers,
      body: json.encode({
        "model": "text-davinci-003",
        "prompt": message,
        "max_tokens": 300,
        "temperature": 0,
        "top_p": 1,
        "n": 1,
        "stream": false,
        "logprobs": null,
      }));
  if (res.statusCode == 200) {
    String body = utf8.decode(res.bodyBytes);
    var jsonResponse = jsonDecode(body);
    return jsonResponse;
  } else {
    print('Request failed with status: ${res.statusCode}.');
    print('Response body: ${res.body}');
  }
}