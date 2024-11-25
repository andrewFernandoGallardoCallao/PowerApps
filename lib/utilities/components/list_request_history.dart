import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:power_apps_flutter/utilities/components/firebase_instance.dart';
import 'package:power_apps_flutter/utilities/components/main_color.dart';
import 'package:url_launcher/url_launcher.dart';

class PermisosScreenHistory extends StatefulWidget {
  const PermisosScreenHistory({
    super.key,
  });

  @override
  State<PermisosScreenHistory> createState() => _PermisosScreenHistoryState();
}

class _PermisosScreenHistoryState extends State<PermisosScreenHistory> {
  final permisosRef = instance.collection('request');

  @override
  Widget build(BuildContext context) {
    final Size sizeScreen = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nombre',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Estado',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(thickness: 2),
            const SizedBox(height: 40),
            _getPermmisos("Pendiente"),
          ],
        ),
      ),
    );
  }

  Expanded _getPermmisos(String permisoEstado) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: permisosRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar permisos'));
          }

          // Filtrar permisos por estado 'Pendiente'
          final permisosPendientes = snapshot.data?.docs
                  .where((permiso) => permiso['estado'] != permisoEstado)
                  .toList() ??
              [];

          if (permisosPendientes.isEmpty) {
            return const Center(child: Text('No hay permisos pendientes'));
          }

          return ListView.builder(
            itemCount: permisosPendientes.length,
            itemBuilder: (context, index) {
              final permiso = permisosPendientes[index];
              final razonPermiso = permiso['reason'] ?? 'Sin razón';
              final estadoPermiso = permiso['estado'] ?? 'Sin estado';
              final permisoId = permiso.id;
              final List<dynamic> evidenciaUrls = permiso['evidence_urls'];
              final List<dynamic> nombreArchivos = permiso['evidence_names'];

              return Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ExpansionTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        razonPermiso,
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        estadoPermiso,
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 16,
                          color: getColor(estadoPermiso),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: evidenciaUrls.length,
                      itemBuilder: (context, fileIndex) {
                        final url = evidenciaUrls[fileIndex];
                        final nombreArchivo = nombreArchivos[fileIndex];

                        return ListTile(
                          leading: _getIconForFile(nombreArchivo),
                          title: Text(
                            nombreArchivo,
                            style: const TextStyle(
                              fontFamily: 'Urbanist',
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          onTap: () {
                            _mostrarBottomSheetArchivo(
                              context,
                              nombreArchivo,
                              url,
                            );
                          },
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _actualizarEstado(context, permisoId, 'Aprobado');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            child: const Text(
                              'Aceptar',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Urbanist',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              _actualizarEstado(
                                  context, permisoId, 'Cancelado');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Urbanist',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _getIconForFile(String nombreArchivo) {
    if (nombreArchivo.endsWith('.pdf')) {
      return const Icon(Icons.picture_as_pdf, color: Colors.red);
    } else if (nombreArchivo.endsWith('.docx')) {
      return const Icon(Icons.description, color: Colors.blue);
    } else if (_esImagen(nombreArchivo)) {
      return const Icon(Icons.image, color: Colors.green);
    } else {
      return const Icon(Icons.insert_drive_file, color: Colors.grey);
    }
  }

  bool _esImagen(String nombreArchivo) {
    return nombreArchivo.endsWith('.jpg') ||
        nombreArchivo.endsWith('.jpeg') ||
        nombreArchivo.endsWith('.png');
  }

  void _mostrarBottomSheetArchivo(
      BuildContext context, String nombreArchivo, String url) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _getIconForFile(nombreArchivo),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      nombreArchivo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_esImagen(nombreArchivo))
                Center(
                  child: Image.network(
                    url,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Text(
                          'No se pudo cargar la imagen',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    },
                  ),
                )
              else
                const Center(
                  child: Text('No se puede mostrar este archivo aquí.'),
                ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _abrirArchivo(url),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Abrir en aplicación externa'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cerrar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _abrirArchivo(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'No se pudo abrir el archivo: $url';
    }
  }

  Future<void> _actualizarEstado(
      BuildContext context, String permisoId, String nuevoEstado) async {
    try {
      await permisosRef.doc(permisoId).update({'estado': nuevoEstado});
      _mostrarMensaje(context, 'Estado actualizado a $nuevoEstado');
    } catch (e) {
      _mostrarMensaje(context, 'Error al actualizar estado');
    }
  }

  void _mostrarMensaje(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.black87,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Color getColor(String estadoPermiso) {
    switch (estadoPermiso) {
      case 'Aprobado':
        return Colors.green;
      case 'Reprobado':
        return Colors.red;
      case 'Pendiente':
        return Colors.yellow[800]!;
      default:
        return Colors.black;
    }
  }
}
