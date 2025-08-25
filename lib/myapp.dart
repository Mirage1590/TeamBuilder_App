import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'controllers/team_controller.dart';
import 'ui/team_page.dart';
import 'ui/poke_theme.dart'; // ⭐

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Pokémon Team Builder',
      debugShowCheckedModeBanner: false,
      theme: buildPokeTheme(), // ⭐ ใช้ธีมใหม่
      initialBinding: BindingsBuilder(() {
        Get.put(TeamController(maxTeam: 3), permanent: true);
      }),
      home: const TeamPage(),
      builder: (context, child) {
        // ⭐ พื้นหลังทั้งแอป: gradient + วงกลม Poké faint
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF1F1), Color(0xFFECE8FF)],
            ),
          ),
          child: Stack(
            children: [
              // watermark pokéball
              Positioned(
                right: -40,
                top: -30,
                child: Opacity(
                  opacity: .07,
                  child: Icon(Icons.catching_pokemon, size: 240),
                ),
              ),
              child!,
            ],
          ),
        );
      },
    );
  }
}
