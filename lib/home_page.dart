import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:miniproject_petrus/chatroom_page.dart';

import 'login_page.dart';

class HomePage extends StatefulWidget {
  final String username;
  const HomePage({Key? key, required this.username}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<String> rooms = [];
  Map<String, List<Map<String, dynamic>>> roomMessages = {};

  @override
  void initState() {
    super.initState();
    _getRooms();
  }

  Future<void> _getRooms() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8080/api/user/${widget.username}'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['data'] != null) {
          setState(() {
            rooms = List<String>.from(data['data']['rooms']) ?? [];
            _getRoomMessages();
          });
        } else {
          rooms = [];
        }
      } else {
        throw Exception('Failed to load rooms');
      }
    } catch (e) {
      print('Error fetching rooms: $e');
    }
  }

  Future<void>   _getRoomMessages() async {
    for (var roomId in rooms) {
      final response =
      await http.get(Uri.parse('http://127.0.0.1:8080/api/chat/$roomId'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['data'] != null) {
          setState(() {
            var messages =
            List<Map<String, dynamic>>.from(data['data']['messages']);
            messages.sort((a, b) => b['timestamp']
                .compareTo(a['timestamp'])); // Sort messages by timestamp
            roomMessages[roomId] = messages;
          });
        }
      } else {
        throw Exception('Failed to load messages for room $roomId');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home - ${widget.username}'),
      ),
      body: ListView.builder(
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          String roomId = rooms[index];
          var lastMessage = roomMessages[roomId]?.isNotEmpty == true ? roomMessages[roomId]!.last : null;
          return ListTile(
            leading: CircleAvatar(
              child: Text(lastMessage != null ? lastMessage['username'][0].toUpperCase() : ''),
            ),
            title: Text(lastMessage != null ? '${lastMessage['username']} : ${lastMessage['text']}' : 'No messages'),
            subtitle: Text(lastMessage != null ? 'Timestamp: ${lastMessage['timestamp']}' : ''),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatRoomPage(
                    roomId: roomId,
                    username: widget.username,
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: _logout,
          child: Text('Logout'),
        ),
      ),
    );
  }
  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
          (route) => false,
    );}
}
