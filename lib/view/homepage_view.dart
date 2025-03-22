import 'package:flutter/material.dart';

class HomepageView extends StatefulWidget {
  const HomepageView({super.key});

  @override
  State<HomepageView> createState() => _HomepageViewState();
}

class _HomepageViewState extends State<HomepageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Validator'),
      ),
      body: const Center(
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(hintText: "mail@mail.com"),
            ),
            Card(
              child: Column(
                children: [
                  Text("Your Information"),
                  Text("Email"),
                  Text("Domain status"),
                  Text("Mx information"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
