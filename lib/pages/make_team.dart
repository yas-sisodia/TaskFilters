import 'package:flutter/material.dart';

class Final_Team extends StatefulWidget {
  final List<Map<String, dynamic>> selectedUsers;
  const Final_Team({super.key, 
    required this.selectedUsers,
  });

  @override
  State<Final_Team> createState() => _Final_TeamState();
}

class _Final_TeamState extends State<Final_Team> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Final Team'),
      ),
      body: ListView.builder(
        itemCount: widget.selectedUsers.length,
        itemBuilder: (context, index) {
          final user = widget.selectedUsers[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user["avatar"]),
                    radius: 40,
                  ),
                  title: Text("${user["first_name"]} ${user["last_name"]}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Gender: ${user["gender"]}"),
                      Text("Email: ${user["email"]}"),
                      Text("Domain: ${user["domain"]}"),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
