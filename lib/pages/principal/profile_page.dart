import 'package:billmind/models/client.dart';
import 'package:billmind/pages/session/login_page.dart';
import 'package:billmind/services/client_service.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final int clientId;

  const ProfilePage({super.key, required this.clientId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Client> _client;

  @override
  void initState() {
    super.initState();
    _client = fetchClient();
  }

  Future<Client> fetchClient() async {
    final service = ClientService();
    final client = await service.getClientById(widget.clientId, clientId: 1);
    return client;
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _editClient(Client client) {
    final nameController = TextEditingController(text: client.name);
    final lastNameController = TextEditingController(text: client.lastName);
    final mailController = TextEditingController(text: client.mail);
    final phoneController = TextEditingController(text: client.phone);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar perfil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Apellido'),
              ),
              TextField(
                controller: mailController,
                decoration: const InputDecoration(labelText: 'Correo'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final updatedClient = Client(
                  id: client.id,
                  name: nameController.text,
                  lastName: lastNameController.text,
                  mail: mailController.text,
                  phone: phoneController.text,
                  password: client.password,
                );
                final service = ClientService();
                await service.updateClient(client.id, updatedClient);

                setState(() {
                  _client = fetchClient();
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Perfil actualizado'),
                  ),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<Client>(
        future: _client,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            final client = snapshot.data!;
            return ListView(
              children: [
                Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Nombre'),
                    subtitle: Text(client.name),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Apellido'),
                    subtitle: Text(client.lastName),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Correo'),
                    subtitle: Text(client.mail),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: const Icon(Icons.phone_android),
                    title: const Text('Teléfono'),
                    subtitle: Text(client.phone),
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FutureBuilder<Client>(
        future: _client,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return FloatingActionButton(
              onPressed: () => _editClient(snapshot.data!),
              child: const Icon(Icons.edit),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
