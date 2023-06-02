import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_apigpt/services/openai_services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ChatController extends GetxController {
  RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  TextEditingController controller = TextEditingController();
  String apiKey = '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';
  String url = 'https://api.openai.com/v1/images/generations';

  RxBool isGeneratingResponse = false.obs;

  Future<void> sendMessage() async {
    var text = controller.text;

    messages.add({'text': text, 'isUser': true, 'isImage': false});
    isGeneratingResponse.value = true;

    var res = await sendTextCompletionRequest(text);
    if (res != null && res.containsKey("choices")) {
      messages.add({
        'text': res["choices"][0]["text"],
        'isUser': false,
        'isImage': false
      });
    } else {
      messages.add({
        'text': 'No response from server.',
        'isUser': false,
        'isImage': false
      });
    }

    isGeneratingResponse.value = false;
    controller.clear();
  }

  Future<void> generateAIImage() async {
    if (controller.text.isNotEmpty) {
      var data = {
        "prompt": controller.text,
        "n": 1,
        "size": "256x256",
      };

      messages.add({'text': controller.text, 'isUser': true, 'isImage': false});
      isGeneratingResponse.value = true;

      var res = await http.post(Uri.parse(url),
          headers: {
            "Authorization": "Bearer ${apiKey}",
            "Content-Type": "application/json"
          },
          body: jsonEncode(data));
      if (res.statusCode == 200) {
        var jsonResponse = jsonDecode(res.body);
        var imageUrl = jsonResponse['data'][0]['url'];
        messages.add({'text': imageUrl, 'isUser': false, 'isImage': true});
      } else {
        messages.add({'text': 'No response from server.', 'isUser': false});
      }

      isGeneratingResponse.value = false;
      controller.clear();
    } else {
      print("Error");
    }
  }
}
