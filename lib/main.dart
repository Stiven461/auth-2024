import 'package:auth_2024/firebase_options.dart';
import 'package:auth_2024/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase dependiendo de si es web o no
  // if (GetPlatform.isWeb) {
  //   await Firebase.initializeApp(
  //     options: const FirebaseOptions(
  //    apiKey: "AIzaSyBiqNeq50WO67uq3J_uCFrsy12Hu8HIaGo",
  //    authDomain: "practicamovil-5711e.firebaseapp.com",
  //    projectId: "practicamovil-5711e",
  //    storageBucket: "practicamovil-5711e.appspot.com",
  //    messagingSenderId: "726321217295",
  //    appId: "1:726321217295:web:9373eb04dc2df3465ac87a"),
  //   );
  // } else {
  //   await Firebase.initializeApp();
  // }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Authenticaion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: LoginPage(),
    );
  }
}
