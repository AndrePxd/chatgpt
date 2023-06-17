// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_apigpt/pages/map.dart';
import 'package:get/get.dart';

import '../controlador.dart';

class HomePage extends StatelessWidget {
  final ChatController _chatController = Get.put(ChatController());

  @override
  String direccion = "";
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF343540),
      appBar: AppBar(
        backgroundColor: Color(0xFF212023),
        centerTitle: true,
        title: Text(
          "Chat with GPT",
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        //icono de mapa que lleve a la pantalla MapScreen
        actions: [
          IconButton(
            icon: Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MapWidget(
                          direccion: direccion,
                        )),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                final isGeneratingResponse =
                    _chatController.isGeneratingResponse.value;

                return ListView.builder(
                  itemCount: _chatController.messages.length,
                  itemBuilder: (context, index) {
                    bool isUser = _chatController.messages[index]['isUser'];
                    bool isImage = _chatController.messages[index]['isImage'];
                    String text = _chatController.messages[index]['text'];

                    if (isGeneratingResponse &&
                        index == _chatController.messages.length - 1) {
                      // Show loading indicator as a separate message
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                          ],
                        ),
                      );
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: isUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // Alineación horizontal
                        children: [
                          if (!isUser)
                            Padding(
                              padding: const EdgeInsets.only(right: 7.0),
                              child: Icon(
                                Icons.person,
                                color: Colors.grey,
                              ),
                            ),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                                color: isUser
                                    ? Color(0xFF0099FF)
                                    : Color(0xFF00CC99),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (!isImage && isUser)
                                    Text(
                                      text,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  if (!isImage && !isUser)
                                    Text(
                                      text,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.black,
                                      ),
                                    ),
                                  if (isImage)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12.0),
                                      child: Image.network(
                                        text,
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (isUser)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Icon(
                                Icons.person,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _chatController.controller,
                      cursorColor: Colors.white,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(5.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        filled: true,
                        fillColor: Color.fromARGB(106, 158, 158, 158),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 200, 111, 255),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    onPressed: () {
                      if (_chatController.controller.text.startsWith('img: ')) {
                        _chatController.generateAIImage();
                      } else {
                        _chatController.sendMessage();
                      }
                      //si empieza por dir: abre el mapa y mostrar la direccion que le pasas
                      if (_chatController.controller.text.startsWith('dir: ')) {
                        direccion =
                            _chatController.controller.text.substring(4);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MapWidget(
                                    direccion: direccion,
                                  )),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Enviar",
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
