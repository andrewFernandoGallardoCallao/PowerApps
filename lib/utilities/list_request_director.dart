import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:power_apps_flutter/utilities/components/firebase_instance.dart';
import 'package:power_apps_flutter/utilities/components/snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'components/main_color.dart';

class PermisosScreen extends StatefulWidget {
  const PermisosScreen({
    super.key,
  });

  @override
  State<PermisosScreen> createState() => _PermisosScreenState();
}

class _PermisosScreenState extends State<PermisosScreen> {
  final permisosRef = instance.collection('request');
  bool isLoading = false;
  String _searchQuery = '';
  String _sortCriteria = 'Nombre'; // Criterio de ordenamiento inicial
  bool _isAscending = true; // Dirección de ordenamiento


  @override
  Widget build(BuildContext context) {
    final Size sizeScreen = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase(); 
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                 const SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.filter_list),
                  onPressed: _mostrarOpcionesFiltro,
                ),
              ],
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
            _getPermmisos(),
          ],
        ),
      ),
    );
  }

  Expanded _getPermmisos() {
  return Expanded(
    child: StreamBuilder<QuerySnapshot>(
      // Aquí agregamos el filtro y el ordenamiento
      stream: permisosRef
          .orderBy(
            // Esto depende de si el criterio de orden es 'Nombre' o 'Fecha'
            _sortCriteria == 'Nombre' ? 'reason' : 'fecha',
            descending: !_isAscending, // Si no es ascendente, es descendente
          )
          .where(
            // Filtro de búsqueda solo si hay texto en _searchQuery
            'reason', isGreaterThanOrEqualTo: _searchQuery.isNotEmpty ? _searchQuery : null)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar permisos'));
        }

        final permisos = snapshot.data?.docs ?? [];

        return ListView.builder(
          itemCount: permisos.length,
          itemBuilder: (context, index) {
            final permiso = permisos[index];
            final permisoId = permiso.id;
            final razonPermiso = permiso['reason'] ?? 'Sin razón';
            final estadoPermiso = permiso['estado'] ?? 'Sin estado';
            final fechaPermiso = permiso['fecha'];

            final List<dynamic> evidenciaUrls = permiso['evidence_urls'];
            final List<dynamic> nombreArchivos = permiso['evidence_names'];
            final DocumentReference reference = permiso['userReference'];

            return FutureBuilder<DocumentSnapshot>(
  future: reference.get(),
  builder: (context, userSnapshot) {
    if (userSnapshot.connectionState == ConnectionState.waiting) {
      return const SizedBox.shrink();
    }

    if (userSnapshot.hasError || !userSnapshot.hasData || !userSnapshot.data!.exists) {
      return const SizedBox.shrink();
    }

    final userData = userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
    final userName = userData['name'] ?? 'Sin nombre';

    if (_searchQuery.isNotEmpty &&
        !userName.toLowerCase().contains(_searchQuery)) {
      return const SizedBox.shrink();
    }

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  razonPermiso,
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ],
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
        ],
      ),
    );
  },
);

          },
        );
      },
    ),
  );
}

// FILTRADO DE PERMISOS
  void _mostrarOpcionesFiltro() {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text('Nombre (A-Z)'),
            onTap: () {
              setState(() {
                _sortCriteria = 'Nombre';
                _isAscending = false;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Nombre (Z-A)'),
            onTap: () {
              setState(() {
                _sortCriteria = 'Nombre';
                _isAscending = true;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Fecha (Reciente)'),
            onTap: () {
              setState(() {
                _sortCriteria = 'Fecha';
                _isAscending = false;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Fecha (Antigua)'),
            onTap: () {
              setState(() {
                _sortCriteria = 'Fecha';
                _isAscending = true;
              });
              Navigator.pop(context);
            },
          )
        ],
      );
    },
  );
}

  void _mostrarDialogoConfirmacion(BuildContext context, String permisoId, String nuevoEstado, String accion) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Confirmar acción',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: '¿Estás seguro de que deseas ',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: accion,
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              color: nuevoEstado == 'Aprobado' ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(
                            text: ' esta solicitud?',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      color: Colors.red,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      setState(() {
                        isLoading = true;
                      });

                      await _actualizarEstado(
                        context,
                        permisoId,
                        nuevoEstado,
                        accion,
                      );

                      Future.delayed(
                        const Duration(milliseconds: 300),
                        () {
                          if (mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                      );
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al $accion la solicitud: $e'),
                          ),
                        );
                      }
                    } finally {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  child: const Text(
                    'Confirmar',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
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

  Future<void> _actualizarEstado(BuildContext context, String permisoId,
      String nuevoEstado, String accion) async {
    try {
      await permisosRef.doc(permisoId).update({'estado': nuevoEstado});

      if (mounted) {
        showAnimatedSnackBar(
          context,
          'Solicitud ${accion}da con éxito',
          Colors.green,
          Icons.check,
        );
      }
    } catch (e) {
      if (mounted) {
        showAnimatedSnackBar(
          context,
          'Error al procesar la solicitud',
          Colors.red,
          Icons.error,
        );
      }
    }
  }

  Color getColor(String estadoPermiso) {
    switch (estadoPermiso) {
      case 'Aprobado':
        return Colors.green;
      case 'Cancelado':
        return Colors.red;
      case 'Pendiente':
        return Colors.yellow[800]!;
      default:
        return Colors.black;
    }
  }
}