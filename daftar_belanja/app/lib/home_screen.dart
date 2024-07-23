import 'package:flutter/material.dart';
import 'local_notification_service.dart';
import 'push_notification_service.dart';

class HomeScreen extends StatelessWidget {
  final LocalNotificationService localNotificationService;
  final PushNotificationService pushNotificationService;

  HomeScreen({required this.localNotificationService, required this.pushNotificationService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping List'),
      ),
      body: Center(
        child: Text('Welcome to Shopping List App'),
      ),
    );
  }
}
