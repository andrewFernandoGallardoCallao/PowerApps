import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:power_apps_flutter/utilities/components/firebase_instance.dart';
import 'package:power_apps_flutter/utilities/components/main_color.dart';
import 'package:power_apps_flutter/utilities/components/snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class GetPermisosScreen extends StatefulWidget {
  final String permisoEstado;
  final int accion;
  const GetPermisosScreen(
      {super.key, required this.permisoEstado, required this.accion});

  @override
  State<GetPermisosScreen> createState() => _GetPermisosScreenState();
}

class _GetPermisosScreenState extends State<GetPermisosScreen> {
  final permisosRef = instance.collection('request');
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
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
          final List<QueryDocumentSnapshot<Object?>> permisosPendientes;
          if (widget.accion == 0) {
            permisosPendientes = snapshot.data?.docs
                    .where(
                        (permiso) => permiso['estado'] == widget.permisoEstado)
                    .toList() ??
                [];
          } else {
            permisosPendientes = snapshot.data?.docs
                    .where(
                        (permiso) => permiso['estado'] != widget.permisoEstado)
                    .toList() ??
                [];
          }

          if (permisosPendientes.isEmpty) {
            return const Center(child: Text('No hay permisos pendientes'));
          }

          return ListView.builder(
            itemCount: permisosPendientes.length,
            itemBuilder: (context, index) {
              final permiso = permisosPendientes[index];
              final permisoId = permiso.id;
              final razonPermiso = permiso['reason'] ?? 'Sin razón';
              final estadoPermiso = permiso['estado'] ?? 'Sin estado';
              final fechaPermiso = permiso['fecha'];

              final List<dynamic> evidenciaUrls = permiso['evidence_urls'];
              final List<dynamic> nombreArchivos = permiso['evidence_names'];
              final DocumentReference reference = permiso['userReference'];

              return Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: ExpansionTile(
                    title: FutureBuilder<DocumentSnapshot>(
                      future: reference.get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          // Mostrar un indicador de carga mientras se obtienen los datos
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    razonPermiso,
                                    style: const TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const CircularProgressIndicator(), // Indicador de carga
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
                          );
                        }

                        if (snapshot.hasError) {
                          // Manejo de errores
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    razonPermiso,
                                    style: const TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const Text(
                                    'Error al cargar usuario',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 14,
                                      color: Colors.red,
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
                          );
                        }

                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          // Manejo de caso donde no se encuentra el usuario
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    razonPermiso,
                                    style: const TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const Text(
                                    'Usuario no encontrado',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 14,
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
                          );
                        }

                        final userName = snapshot.data!['name'] ?? 'Sin nombre';

                        return Row(
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
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  _formatDate(fechaPermiso),
                                  style: const TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
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
                        );
                      },
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
                                // Mostrar el modal de confirmación
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
                                              ? const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ) // Mostrar el ProgressIndicator si está cargando
                                              : RichText(
                                                  text: const TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text:
                                                            '¿Estás seguro de que deseas ',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Urbanist',
                                                          color: Colors
                                                              .black, // Estilo por defecto
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: 'aprobar',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Urbanist',
                                                          color: Colors
                                                              .green, // Color para resaltar la palabra "reprobar"
                                                          fontWeight: FontWeight
                                                              .bold, // Opcional, para hacerla más prominente
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            ' esta solicitud?',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Urbanist',
                                                          color: Colors
                                                              .black, // Estilo por defecto
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                          actions: [
                                            // Botón Cancelar
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Cerrar el modal
                                              },
                                              child: const Text(
                                                'Cancelar',
                                                style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                            // Botón Confirmar
                                            TextButton(
                                              onPressed: () async {
                                                try {
                                                  // Cambiar el estado a cargando
                                                  setState(() {
                                                    isLoading = true;
                                                  });

                                                  // Primero, realiza la actualización en Firestore
                                                  await _actualizarEstado(
                                                    context,
                                                    permisoId,
                                                    'Aprobado',
                                                    "Aprobada",
                                                  );

                                                  // Usar Future.delayed para cerrar el diálogo después de un pequeño retraso
                                                  Future.delayed(
                                                    const Duration(
                                                      milliseconds: 300,
                                                    ),
                                                    () {
                                                      if (mounted) {
                                                        Navigator.of(context)
                                                            .pop(); // Ahora cierra el diálogo
                                                      }
                                                    },
                                                  );

                                                  // Mostrar mensaje de éxito
                                                } catch (e) {
                                                  // Mostrar mensaje de error si ocurre algún fallo
                                                  if (mounted) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                            'Error al aprobar la solicitud: $e'),
                                                      ),
                                                    );
                                                  }
                                                } finally {
                                                  // Asegurarse de que el estado de loading se cambie al final del proceso
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
                                'Aprobar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Urbanist',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
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
                                              ? const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ) // Mostrar el ProgressIndicator si está cargando
                                              : RichText(
                                                  text: const TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text:
                                                            '¿Estás seguro de que deseas ',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Urbanist',
                                                          color: Colors
                                                              .black, // Estilo por defecto
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: 'reprobar',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Urbanist',
                                                          color: Colors
                                                              .red, // Color para resaltar la palabra "reprobar"
                                                          fontWeight: FontWeight
                                                              .bold, // Opcional, para hacerla más prominente
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            ' esta solicitud?',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Urbanist',
                                                          color: Colors
                                                              .black, // Estilo por defecto
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                          actions: [
                                            // Botón Cancelar
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Cerrar el modal
                                              },
                                              child: const Text(
                                                'Cancelar',
                                                style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                            // Botón Confirmar
                                            TextButton(
                                              onPressed: () async {
                                                try {
                                                  // Cambiar el estado a cargando
                                                  setState(() {
                                                    isLoading = true;
                                                  });

                                                  // Primero, realiza la actualización en Firestore
                                                  await _actualizarEstado(
                                                    context,
                                                    permisoId,
                                                    'Reprobado',
                                                    "Reprobada",
                                                  );

                                                  // Usar Future.delayed para cerrar el diálogo después de un pequeño retraso
                                                  Future.delayed(
                                                    const Duration(
                                                      milliseconds: 300,
                                                    ),
                                                    () {
                                                      if (mounted) {
                                                        Navigator.of(context)
                                                            .pop(); // Ahora cierra el diálogo
                                                      }
                                                    },
                                                  );

                                                  // Mostrar mensaje de éxito
                                                } catch (e) {
                                                  // Mostrar mensaje de error si ocurre algún fallo
                                                  if (mounted) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                            'Error al aprobar la solicitud: $e'),
                                                      ),
                                                    );
                                                  }
                                                } finally {
                                                  // Asegurarse de que el estado de loading se cambie al final del proceso
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
                                'Reprobar',
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
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _actualizarEstado(BuildContext context, String permisoId,
      String nuevoEstado, String accion) async {
    try {
      await permisosRef.doc(permisoId).update({'estado': nuevoEstado});

      if (mounted) {
        showAnimatedSnackBar(
          context,
          'Solicitud $accion con exito',
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

  String _formatDate(String isoDate) {
    try {
      DateTime parsedDate = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy').format(parsedDate); // Formatea la fecha
    } catch (e) {
      return 'Fecha inválida'; // Manejo de errores
    }
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
