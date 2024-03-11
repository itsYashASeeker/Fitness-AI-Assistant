import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';


void main() async{
  await dotenv.load(fileName: ".env");
  runApp(const ChatApp());

}

String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}





class ChatApp extends StatelessWidget {
  const ChatApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Assistant',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyChatApp(title: 'Chat with Fitness AI Assistant | chat'),
    );
  }
}

class MyChatApp extends StatefulWidget {
  const MyChatApp({super.key,  required this.title});

  final String title;


  @override
  State<MyChatApp> createState() => _MyChatApp();
}

// final String title;

class _MyChatApp extends State<MyChatApp> {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: '1');

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(widget.title),
    ),
    body: Chat(
      messages: _messages,
      onSendPressed: _handleSendPressed,
      user: _user,
      theme: const DarkChatTheme(
        inputBackgroundColor: Colors.blueAccent,
      ),
    ),
  );

  Future<void> _getAI(String textm) async{
    print(textm);
    // print(message.stringify);
    await dotenv.load(fileName: ".env");
    final apiKey = dotenv.env["FLUTTER_GEMINI_API_KEY"];
    if (apiKey == null) {
      print('No \$API_KEY environment variable');
      exit(1);
    }

    // For text-only input, use the gemini-pro model
    // final model = GenerativeModel(
    //     model: 'gemini-pro',
    //     apiKey: apiKey,
    // // );
    //     generationConfig: GenerationConfig(maxOutputTokens: 100));
    final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
    // Initialize the chat
    // final chat = model.startChat(history: []);
    // var content = Content.text('Hi, I want to become fit.. want to loose out some weight. give me tips');
    // var response = await chat.sendMessage(content);
    // final content = [Content.text('Hi, I want to become fit.. want to loose out some weight. give me tips')];
    final content = [Content.text('You are a Fitness Assistant, stick to this.. dont answer questions that are not related to fitness. Answer in short and only one paragraph. Now answer this question: ${textm}')];
    final response = await model.generateContent(content);

    // final chat = model.startChat(history: [
      // Content.text('Hello, I have 2 dogs in my house.'),
      // Content.model([TextPart('Great to meet you. What would you like to know?')])
// /    ]);
    // var content = Content.text('Hi, I want to become fit.. want to loose out some weight. give me tips');
    // final response = await chat.sendMessage(content);
    // print(response.text);
    String tt=response.text ?? "default";
    final _user2 = const types.User(id: '2');
    final textMessage = types.TextMessage(
      author: _user2,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: tt,
    );

    // _addMessage(textMessage);
    setState(() {
      _messages.insert(0, textMessage);
    });
  }

  void _addMessage(types.Message message) async {
    setState(() {
      _messages.insert(0, message);
    });

    // print("hello");
  }

  void _handleSendPressed(types.PartialText message) async{
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: message.text,
    );

    _addMessage(textMessage);
    await _getAI(message.text);
  }
}