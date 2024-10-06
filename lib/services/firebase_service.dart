import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Instancia de Firestore

  // Método para registrar un usuario con correo y contraseña
  Future<User?> registerWithEmail(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print(userCredential);
      User? user = userCredential.user;

      // Si el usuario se crea correctamente, guarda los datos en Firestore
      if (user != null) {
        await _firestore.collection('usuarios').doc(user.uid).set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } catch (e) {
      print("Error en el registro: $e");
      return null;
    }
  }

  // Método para iniciar sesión con correo y contraseña
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Error en el inicio de sesión: $e");
      return null;
    }
  }

  // Método para cerrar sesión
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Error al cerrar sesión: $e");
    }
  }

  // Obtener usuario actual
  User? get currentUser {
    return _auth.currentUser;
  }
}
