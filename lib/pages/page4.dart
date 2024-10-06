import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Page4 extends StatefulWidget {
  @override
  _Page4State createState() => _Page4State();
}

class _Page4State extends State<Page4> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  DateTime? _selectedBirthDate;
  XFile? _profileImage;
  String? _profileImageUrl; // Variable para almacenar la URL de la imagen de perfil

  // Método para cargar los datos del usuario desde Firestore
  Future<void> _loadUserData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    _nameController.text = userDoc['name'] ?? '';
    _emailController.text = userDoc['email'] ?? '';
    _whatsappController.text = userDoc['whatsapp'] ?? '';
    _phoneController.text = userDoc['phone'] ?? '';
    _selectedBirthDate = (userDoc['birthDate'] as Timestamp?)?.toDate();
    _profileImageUrl = userDoc['profileImage'] ?? '';
  }

  // Método para seleccionar la imagen desde la galería
  Future<void> _selectProfileImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = pickedFile;
      });
    }
  }

  // Método para subir la imagen a Firebase Storage
  Future<String?> _uploadProfileImage(String uid) async {
    if (_profileImage != null) {
      try {
        Reference ref = FirebaseStorage.instance.ref().child('perfil_user/$uid.jpg');

        if (kIsWeb) {
          UploadTask uploadTask = ref.putData(await _profileImage!.readAsBytes());
          TaskSnapshot snapshot = await uploadTask;
          String downloadUrl = await snapshot.ref.getDownloadURL();
          return downloadUrl;
        } else {
          UploadTask uploadTask = ref.putFile(File(_profileImage!.path));
          TaskSnapshot snapshot = await uploadTask;
          String downloadUrl = await snapshot.ref.getDownloadURL();
          return downloadUrl;
        }
      } catch (e) {
        print('Error al subir la imagen: $e');
        return null;
      }
    }
    return null;
  }

  // Método para guardar los datos en Firestore
  Future<void> _saveProfile() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    // Sube la imagen a Firebase Storage
    String? imageUrl = await _uploadProfileImage(uid);

    // Actualiza el perfil del usuario en Firestore
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': _nameController.text,
      'email': _emailController.text,
      'whatsapp': _whatsappController.text,
      'phone': _phoneController.text,
      'birthDate': _selectedBirthDate,
      'profileImage': imageUrl ?? _profileImageUrl,
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Perfil guardado exitosamente')));
  }

  // Método para seleccionar la fecha de nacimiento
  Future<void> _selectBirthDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedBirthDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
      ),
      body: FutureBuilder(
        future: _loadUserData(), // Aquí cargamos los datos al construir el widget
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Indicador de carga mientras se esperan los datos
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los datos.'));
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Imagen circular con icono de cámara
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _profileImage != null
                              ? kIsWeb
                                  ? NetworkImage(_profileImage!.path)
                                  : FileImage(File(_profileImage!.path)) as ImageProvider
                              : _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                                  ? NetworkImage(_profileImageUrl!)
                                  : AssetImage('assets/profile_placeholder.png') as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            icon: Icon(Icons.camera_alt, color: Colors.white, size: 30),
                            onPressed: _selectProfileImage,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Campo de texto para el nombre
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Campo de texto para el correo electrónico
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 10),

                    // Campo de texto para WhatsApp
                    TextField(
                      controller: _whatsappController,
                      decoration: InputDecoration(
                        labelText: 'WhatsApp',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 10),

                    // Campo de texto para celular
                    TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Celular',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 10),

                    // Campo de selección de fecha de nacimiento
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedBirthDate != null
                                ? 'Fecha de nacimiento: ${_selectedBirthDate!.toLocal().toString().split(' ')[0]}'
                                : 'Seleccione su fecha de nacimiento',
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () => _selectBirthDate(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Botón para guardar cambios
                    ElevatedButton(
                      onPressed: _saveProfile,
                      child: Text('Guardar cambios'),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}