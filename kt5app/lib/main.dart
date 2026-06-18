import 'package:flutter/material.dart';
import 'storage_service.dart';

void main() {
  runApp(const MyApp());
}

class User {
  String name;
  String email;
  int age;

  User({required this.name, required this.email, required this.age});

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'age': age,
      };

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String,
      email: json['email'] as String,
      age: json['age'] as int,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'КТ5',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthChecker(),
    );
  }
}

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  final StorageService _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 300));

    bool loggedIn = await _storage.isLoggedIn();
    User? user = await _storage.loadUser();

    if (mounted) {
      if (loggedIn && user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage(user: user)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final StorageService _storage = StorageService();

  void _saveAndLogin() async {
    if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _ageCtrl.text.isEmpty) {
      if (!mounted) return; 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля!')),
      );
      return;
    }

    try {
      User user = User(
        name: _nameCtrl.text,
        email: _emailCtrl.text,
        age: int.parse(_ageCtrl.text),
      );

      await _storage.saveUser(user);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage(user: user)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка: возраст должен быть числом')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Вход')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Имя', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _ageCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Возраст', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _saveAndLogin, child: const Text('Войти')),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final User user;
  const HomePage({super.key, required this.user});

  void _logout(BuildContext context) async {
    final storage = StorageService();
    await storage.logout();
    if (context.mounted) { 
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Имя: ${user.name}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Email: ${user.email}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Возраст: ${user.age} лет', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Выйти из аккаунта'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            ),
          ],
        ),
      ),
    );
  }
}