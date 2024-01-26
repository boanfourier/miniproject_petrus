import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatRoomPage extends StatefulWidget {
  final String roomId;
  final String username;
  final String selectedName;

  const ChatRoomPage({Key? key, required this.roomId, required this.username, required this.selectedName})
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
        title: Text('${widget.selectedName}'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var message = messages[index];

                return ListTile(
                  title: Align(
                    alignment: message['username'] == widget.username
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: message['username'] == widget.username
                            ? Colors.blue.withOpacity(0.8)
                            : Colors.grey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${message['text']}',
                            style: TextStyle(
                              color: message['username'] == widget.username
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          Text(
                            '${message['timestamp']}',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 12,
                              color: message['username'] == widget.username
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  subtitle: Align(
                    alignment: message['username'] == widget.username
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Text(
                      '${message['username']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Message',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}





