import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AJUSTES')),
      body: ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.palette),
            title: Text('APARIENCIA'),
            subtitle: Text('Tema oscuro activo'),
          ),
          const ListTile(
            leading: Icon(Icons.language),
            title: Text('IDIOMA'),
            subtitle: Text('Español (Predeterminado)'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('ACERCA DE'),
            subtitle: const Text('TagFootStats v1.0.0'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
