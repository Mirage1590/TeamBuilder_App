import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../data/poke_api_service.dart';
import '../models/pokemon.dart';

class TeamController extends GetxController {
  TeamController({this.maxTeam = 3});
  final int maxTeam;

  final _box = GetStorage();
  final _service = PokeApiService();

  // Reactive states
  final RxList<Pokemon> allPokemon = <Pokemon>[].obs;
  final RxList<Pokemon> selected = <Pokemon>[].obs;
  final RxString teamName = ''.obs;
  final RxString query = ''.obs;

  // Derived
  List<Pokemon> get filtered {
    final q = query.value.trim().toLowerCase();
    if (q.isEmpty) return allPokemon;
    return allPokemon.where((p) => p.name.contains(q)).toList();
  }

  bool isSelected(Pokemon p) => selected.any((e) => e.id == p.id);

  @override
  void onInit() {
    super.onInit();
    _loadPersisted();
    _fetchInitial();

    // Persist automatically
    ever<List<Pokemon>>(selected, (_) => _saveTeamMembers());
    debounce<String>(teamName, (_) => _saveTeamName(),
        time: const Duration(milliseconds: 400));
  }

  Future<void> _fetchInitial() async {
    try {
      if (allPokemon.isNotEmpty) return;
      final list = await _service.fetchPokemonList(limit: 151);

      allPokemon.assignAll(list);
      // กรณีเคยเลือกไว้ ให้ sync กับชุดใหม่ (กันรูป/ข้อมูลเปลี่ยน)
      if (selected.isNotEmpty) {
        final ids = selected.map((e) => e.id).toSet();
        final restored = allPokemon.where((p) => ids.contains(p.id)).toList();
        selected.assignAll(restored);
      }
    } catch (e) {
      Get.snackbar('Error', 'โหลดรายชื่อโปเกมอนไม่สำเร็จ: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void toggle(Pokemon p) {
    if (isSelected(p)) {
      selected.removeWhere((e) => e.id == p.id);
    } else {
      if (selected.length >= maxTeam) {
        Get.snackbar('Team full', 'เลือกได้สูงสุด $maxTeam ตัว',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2));
        return;
      }
      selected.add(p);
    }
  }

  void resetTeam() {
    selected.clear();
    teamName.value = '';
    _box.remove('team_members');
    _box.remove('team_name');
  }

  // Persistence
  void _loadPersisted() {
    final tn = _box.read('team_name');
    if (tn is String) teamName.value = tn;

    final list = _box.read('team_members');
    if (list is List) {
      final restored = list
          .map((e) => Pokemon.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      selected.assignAll(restored);
    }
  }

  void _saveTeamMembers() =>
      _box.write('team_members', selected.map((e) => e.toJson()).toList());

  void _saveTeamName() => _box.write('team_name', teamName.value);

  @override
  void onClose() {
    _service.dispose();
    super.onClose();
  }

  GetStorage get box => _box; // เพิ่ม getter นี้
}
