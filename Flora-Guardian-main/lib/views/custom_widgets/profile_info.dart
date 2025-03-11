import 'package:flutter/material.dart';
import 'package:flora_guardian/models/user_model.dart';

class ProfileInfo extends StatelessWidget {
  final UserModel? user;

  const ProfileInfo({super.key, this.user});

 @override
Widget build(BuildContext context) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 20),
    child: Row(
      children: [
        Container(
          height: 140,
          width: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black,
          ),
          child: Icon(Icons.face, color: Colors.white, size: 100),
        ),
        SizedBox(width: 20),
        // ✅ Wrap Column inside Expanded
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.userName ?? "Loading...",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                overflow: TextOverflow.ellipsis, 
              ),
              Text(
                user?.email ?? "Loading...",
                style: TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis, 
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}

