import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';

class CastDeviceSelector extends StatefulWidget {
  const CastDeviceSelector({super.key});

  @override
  State<CastDeviceSelector> createState() => _CastDeviceSelectorState();
}

class _CastDeviceSelectorState extends State<CastDeviceSelector> {
  bool _scanning = true;

  @override
  void initState() {
    super.initState();
    // Simular búsqueda de dispositivos
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _scanning = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MusicProvider>(context);

    return Container(
      padding: const EdgeInsets.all(16),
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Conectar a un dispositivo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          if (_scanning)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text('Buscando dispositivos Wi-Fi...'),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView(
                children: [
                  _buildDeviceTile(
                    context,
                    provider,
                    'Chromecast Sala',
                    Icons.tv,
                  ),
                  _buildDeviceTile(
                    context,
                    provider,
                    'Google Home Cocina',
                    Icons.speaker,
                  ),
                  _buildDeviceTile(
                    context,
                    provider,
                    'TV Dormitorio',
                    Icons.tv,
                  ),
                  if (provider.isCasting)
                    ListTile(
                      leading: const Icon(Icons.close, color: Colors.red),
                      title: const Text(
                        'Desconectar',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () {
                        provider.disconnectCast();
                        Navigator.pop(context);
                      },
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeviceTile(
    BuildContext context,
    MusicProvider provider,
    String name,
    IconData icon,
  ) {
    final isConnected = provider.connectedDeviceName == name;
    return ListTile(
      leading: Icon(
        icon,
        color: isConnected ? Colors.blueAccent : Colors.white,
      ),
      title: Text(
        name,
        style: TextStyle(
          color: isConnected ? Colors.blueAccent : Colors.white,
          fontWeight: isConnected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: isConnected
          ? const Text('Conectado', style: TextStyle(color: Colors.blueAccent))
          : null,
      trailing: isConnected
          ? const Icon(Icons.check, color: Colors.blueAccent)
          : null,
      onTap: () {
        provider.connectToDevice(name);
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Conectando a $name...')));
      },
    );
  }
}
