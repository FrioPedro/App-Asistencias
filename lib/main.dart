import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/events_provider.dart'; 
import 'ui/screens/events_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EventsProvider()), 
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EventsScreen(),
    );
  }
}