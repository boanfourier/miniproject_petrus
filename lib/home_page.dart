import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:miniproject_petrus/chatroom_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({Key? key, required this.username}) : super(key: key);

  get roomId => null;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<String> rooms = [];
  Map<String, List<Map<String, dynamic>>> roomMessages = {};

  List<dynamic> userName = [];
  void test(String username) async{
    userName = await getChatList(username);
  }
  @override
  void initState() {
    test(widget.username);
    super.initState();
    _getRooms();
  }

  _getRooms() async {
    final response = await http
        .get(Uri.parse('http://127.0.0.1:8080/api/user/${widget.username}'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['data'] != null) {
        setState(() {
          rooms = List<String>.from(data['data']['rooms']);
          _getRoomMessages();
        });
      } else {
        // handle the case when 'data' is null
        rooms = [];
      }
    } else {
      throw Exception('Failed to load rooms');
    }
  }
  _getRoomMessages() async {
    for (var roomId in rooms) {
      final response =
      await http.get(Uri.parse('http://127.0.0.1:8080/api/chat/$roomId'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['data'] != null) {
          setState(() {
            var messages =
            List<Map<String, dynamic>>.from(data['data']['messages']);
            messages.sort((a, b) => (b['timestamp'] is int
                ? b['timestamp']
                : int.parse(b['timestamp']))
                .compareTo(a['timestamp'] is int
                ? a['timestamp']
                : int.parse(a['timestamp'])));
            roomMessages[roomId] = messages;
          });
        }
      } else {
        throw Exception('Failed to load messages for room $roomId');
      }
    }
  }
  _createNewRoom(String from, String to) async {
    final response = await http.post(
      Uri.parse('http://localhost:8080/api/room'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'from': from,
        'to': to,
      }),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['data'] != null) {
      } else {
        print('Response data is null');
      }
    } else {
      throw Exception('Failed to create room');
    }
  }

  @override
  // In HomePageState
  Widget build(BuildContext context) {
    test(widget.username);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final TextEditingController _controller = TextEditingController();
          return showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Enter username'),
                content: TextField(
                  controller: _controller,
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Send'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _createNewRoom(
                        widget.username,
                        _controller.text,
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.message),
      ),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: Color(0xFF128C7E),
          elevation: 10,
          title: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage('https://static.vecteezy.com/system/resources/previews/005/544/718/non_2x/profile-icon-design-free-vector.jpg'), // Ganti dengan URL gambar profil pengguna
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${widget.username}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.camera_alt),
              color: Colors.white,
              onPressed: () {
              },
            ),
            IconButton(
              icon: Icon(Icons.call),
              color: Colors.white,
              onPressed: () {
              },
            ),
            IconButton(
              icon: Icon(Icons.more_vert),
              color: Colors.white,
              onPressed: () {
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: rooms.length,
        itemBuilder: (context, index) {
         // print(roomMessages['username']);
          String roomId = rooms[index];

          var lastMessage =
          roomMessages[roomId] != null && roomMessages[roomId]!.isNotEmpty
              ? roomMessages[roomId]![0]
              : null;
          return ListTile(
            leading: CircleAvatar(
              child: Text(lastMessage != null
                  ? lastMessage['username'][0].toUpperCase()
                  : ''),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    userName[index],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  lastMessage != null ? '${lastMessage['timestamp']}' : '',
                ),
              ],
            ),
            subtitle: Text(
              lastMessage != null ? '${lastMessage['text']}' : '',
            ),
            onTap: () {

              setState(() {
                userName.clear();
                test(widget.username);
              });
              // Navigate to the chatroom page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatRoomPage(
                    roomId: roomId,
                    username: widget.username,
                    selectedName: userName[index],

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

Future<List<dynamic>> getChatList(String username) async {
  List<dynamic> listUsername = [];
  var response = await http.get(Uri.parse('http://127.0.0.1:8080/api/room/${username}'));
  //var b = await _repository!.getChat(username);
  var data = jsonDecode(response!.body) as Map<String, dynamic>;
  var a = data['data'] as List<dynamic>;
  a.forEach((element) {
    listUsername.add(element['users']);
  });

  List<dynamic> filteredNames = listUsername
      .map((sublist) =>
      sublist.where((name) => name != '${username}').toList())
      .toList();
  List<dynamic> flatList =
  filteredNames.expand((sublist) => sublist).toList();

  List<dynamic> allMessages = [];
  for (var dataEntry in data['data']) {
    List<dynamic> messages = dataEntry['messages'];
    allMessages.addAll(messages);
  }
  print(allMessages);
  print(flatList);
  return flatList;
}

