import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatRoomPage extends StatefulWidget {
  final String roomId;
  final String username;

  const ChatRoomPage({Key? key, required this.roomId, required this.username})
      : super(key: key);

  @override
  ChatRoomPageState createState() => ChatRoomPageState();
}

class ChatRoomPageState extends State<ChatRoomPage> {
  List<Map<String, dynamic>> messages = [];
  final messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getMessages();
  }

  Future<void> _getMessages() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8080/api/chat/${widget.roomId}'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          messages = (data['data']['messages'] as List<dynamic>)
              .cast<Map<String, dynamic>>() // Casting ke List<Map<String, dynamic>>
              .toList();
        });
      } else {
        throw Exception('Failed to load messages for room ${widget.roomId}');
      }
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }
  Future<void> _sendMessage() async {
    try {
      if (messageController.text.isNotEmpty) {
        final response = await http.post(
          Uri.parse('http://127.0.0.1:8080/api/chat'),
          body: {
            'id': widget.roomId,
            'from': widget.username,
            'text': messageController.text,
          },
        );
        if (response.statusCode == 200) {
          _getMessages();
          messageController.clear();
        } else {
          print('Failed to send message. Error: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room ${widget.roomId}'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var message = messages[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(message['username'][0].toUpperCase()),
                  ),
                  title: Text('${message['username']} : ${message['text']}'),
                  subtitle: Text('Timestamp: ${message['timestamp']}'),
                );
              },
            ),
          ),
          TextField(
            controller: messageController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Message',
            ),
          ),
          ElevatedButton(
            child: const Text('Send'),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
