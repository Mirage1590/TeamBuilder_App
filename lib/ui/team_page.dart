import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/team_controller.dart';
import '../models/pokemon.dart';
import 'widgets/pokemon_tile.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});
  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  late final TeamController c;
  final _nameCtl = TextEditingController();
  final _searchCtl = TextEditingController();
  PokemonType? selectedType;

  final RxList<Map<String, dynamic>> savedTeams = <Map<String, dynamic>>[].obs;
  int? editingIndex;

  @override
  void initState() {
    super.initState();
    c = Get.find<TeamController>();
    _nameCtl.text = c.teamName.value;
    _searchCtl.text = c.query.value;

    ever<String>(c.teamName, (val) {
      if (_nameCtl.text != val) _nameCtl.text = val;
    });
    ever<String>(c.query, (val) {
      if (_searchCtl.text != val) _searchCtl.text = val;
    });

    _loadSavedTeams(); // ⭐ โหลดทีมที่บันทึกไว้ทุกครั้งที่เปิดหน้า
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ***ลบ _loadSavedTeams(); ออก***
  }

  void _loadSavedTeams() {
    final box = c.box;
    final teams = box.read('saved_teams');
    if (teams is List) {
      savedTeams.assignAll(List<Map<String, dynamic>>.from(teams));
    }
  }

  void _saveCurrentTeam() {
    final team = {
      'name': c.teamName.value,
      'members': c.selected.map((e) => e.toJson()).toList(),
    };
    if (editingIndex != null) {
      savedTeams[editingIndex!] = team;
      editingIndex = null;
    } else {
      savedTeams.add(team);
    }
    c.box.write('saved_teams', savedTeams);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Team saved!'), duration: Duration(seconds: 1)),
    );
  }

  void _loadTeam(Map<String, dynamic> team) {
    c.teamName.value = team['name'] as String? ?? '';
    final members = (team['members'] as List<dynamic>? ?? [])
        .map((e) => Pokemon.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    c.selected.assignAll(members);
    editingIndex = savedTeams.indexOf(team);
  }

  void _deleteTeam(int idx) {
    savedTeams.removeAt(idx);
    c.box.write('saved_teams', savedTeams);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        titleSpacing: 12,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFF64B5F6), Color(0xFFFFDE00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            Image.network(
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/master-ball.png',
              height: 34,
            ),
            const SizedBox(width: 10),
            Text(
              'Pokémon GO Team',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
                letterSpacing: 1.2,
                shadows: [
                  const Shadow(
                    color: Colors.blueAccent,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Reset Team',
            icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
            onPressed: () => _confirmReset(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Pokéball watermark
          Positioned(
            right: -40,
            bottom: -40,
            child: Opacity(
              opacity: 0.08,
              child: Image.network(
                'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/poke-ball.png',
                width: 220,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF90CAF9), Color(0xFFFFF1B6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 88),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: TextField(
                        controller: _nameCtl,
                        onChanged: (v) => c.teamName.value = v,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        decoration: InputDecoration(
                          labelText: 'Team name',
                          labelStyle: TextStyle(color: Color(0xFF1976D2)),
                          prefixIcon: const Icon(Icons.edit, color: Color(0xFF1976D2)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: Color(0xFF1976D2), width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(.92),
                          suffixIcon: Obx(() => AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: c.teamName.value.isEmpty
                                    ? const SizedBox(key: ValueKey('empty'))
                                    : const Icon(Icons.check, key: ValueKey('nonempty'), color: Colors.amber),
                              )),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: TextField(
                        controller: _searchCtl,
                        onChanged: (v) => c.query.value = v,
                        decoration: InputDecoration(
                          labelText: 'Search Pokémon',
                          labelStyle: TextStyle(color: Color(0xFF1976D2)),
                          prefixIcon: Icon(Icons.search, color: Color(0xFF1976D2)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: Color(0xFF1976D2), width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(.92),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: DropdownButtonFormField<PokemonType>(
                        value: selectedType,
                        decoration: InputDecoration(
                          labelText: 'Filter by Type',
                          labelStyle: TextStyle(color: Color(0xFF1976D2)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: Color(0xFF1976D2), width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(.92),
                        ),
                        items: [
                          const DropdownMenuItem<PokemonType>(
                            value: null,
                            child: Text('All Types'),
                          ),
                          ...PokemonType.values.map((type) => DropdownMenuItem<PokemonType>(
                            value: type,
                            child: Row(
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: _typeColor(type),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Text(_typeName(type)),
                              ],
                            ),
                          )),
                        ],
                        onChanged: (type) {
                          setState(() {
                            selectedType = type;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Obx(() => SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: c.selected
                                    .map((p) => _SelectedChip(
                                          key: ValueKey('sel-${p.id}'),
                                          pokemon: p,
                                          onRemove: () => c.toggle(p),
                                        ))
                                    .toList(),
                              ),
                            )),
                          ),
                          const SizedBox(width: 8),
                          Obx(() => AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: PokeCounterBadge(
                              key: ValueKey('count-${c.selected.length}'),
                              count: c.selected.length,
                              max: c.maxTeam,
                            ),
                          )),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save, size: 22),
                        label: const Text('Save Team', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        onPressed: _saveCurrentTeam,
                      ),
                    ),
                    // เปลี่ยนจาก if (savedTeams.isNotEmpty) เป็น Obx
                    Obx(() => savedTeams.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          child: SizedBox(
                            height: 130,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: savedTeams.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 16),
                              itemBuilder: (_, i) {
                                final t = savedTeams[i];
                                final members = (t['members'] as List<dynamic>? ?? [])
                                    .map((e) => Pokemon.fromJson(Map<String, dynamic>.from(e)))
                                    .toList();
                                return Card(
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  color: Colors.white,
                                  child: Container(
                                    width: 220,
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.catching_pokemon, size: 20, color: Color(0xFF1976D2)),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                t['name'] ?? 'Unnamed',
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                              tooltip: 'Delete team',
                                              onPressed: () => _deleteTeam(i),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.edit, color: Color(0xFF1976D2), size: 20),
                                              tooltip: 'Load/Edit team',
                                              onPressed: () => _loadTeam(t),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: members.map((p) => Padding(
                                            padding: const EdgeInsets.only(right: 6),
                                            child: CircleAvatar(
                                              radius: 18,
                                              backgroundImage: NetworkImage(p.imageUrl),
                                              backgroundColor: Colors.white,
                                            ),
                                          )).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      : SizedBox.shrink()
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.52,
                        child: Obx(() {
                          final list = c.filtered.where((p) {
                            if (selectedType == null) return true;
                            return p.types.contains(selectedType);
                          }).toList();

                          if (list.isEmpty) {
                            return const Center(child: Text('No Pokémon found'));
                          }

                          return GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 1.5,
                              crossAxisSpacing: 50,
                              mainAxisSpacing: 50,
                            ),
                            itemCount: list.length,
                            itemBuilder: (_, i) {
                              final p = list[i];
                              return Obx(() {
                                final selected = c.isSelected(p);

                                return AnimatedScale(
                                  key: ValueKey('tile-${p.id}'),
                                  scale: selected ? 1.08 : 1.0,
                                  duration: const Duration(milliseconds: 150),
                                  curve: Curves.easeOut,
                                  child: InkWell(
                                    onTap: () => c.toggle(p),
                                    borderRadius: BorderRadius.circular(18),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: selected
                                              ? [Color(0xFFFFF176), Color(0xFF64B5F6)]
                                              : [Colors.white, Color(0xFFFAF6FF)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: selected ? Color(0xFF1976D2) : Colors.grey.shade300,
                                          width: selected ? 2 : 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.18),
                                            blurRadius: selected ? 14 : 6,
                                            spreadRadius: 1,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: selected ? Color(0xFFFFCB05) : Color(0xFF3B4CCA),
                                                width: 3,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.yellowAccent.withOpacity(0.2),
                                                  blurRadius: 8,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: CircleAvatar(
                                              radius: 38,
                                              backgroundColor: Colors.white,
                                              backgroundImage: NetworkImage(p.imageUrl),
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            _cap(p.name),
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF3B4CCA),
                                              shadows: [
                                                Shadow(
                                                  color: Colors.yellow.shade200,
                                                  blurRadius: 2,
                                                ),
                                              ],
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 6),
                                          Wrap(
                                            spacing: 4,
                                            children: p.types.map((type) => Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: _typeColor(type).withOpacity(0.85),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                _typeName(type),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  shadows: [
                                                    Shadow(
                                                      color: Colors.black26,
                                                      blurRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )).toList(),
                                          ),
                                          SizedBox(height: 8),
                                          AnimatedSwitcher(
                                            duration: Duration(milliseconds: 200),
                                            child: selected
                                                ? Icon(Icons.check_circle, color: Colors.green, size: 22, key: ValueKey('selected'))
                                                : Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 22, key: ValueKey('unselected')),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              });
                            },
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset team?'),
        content: const Text('ล้างชื่อทีมและสมาชิกทั้งหมด'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (ok == true) c.resetTeam();
  }
}

class PokeCounterBadge extends StatelessWidget {
  final int count, max;
  const PokeCounterBadge({super.key, required this.count, required this.max});

  @override
  Widget build(BuildContext context) {
    final ok = count < max;
    final border = ok ? Colors.indigo : Colors.red;
    final fill = ok ? Colors.indigo.withOpacity(.12) : Colors.red.withOpacity(.12);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: ShapeDecoration(
        color: fill,
        shape: StadiumBorder(side: BorderSide(color: border, width: 2)),
        shadows: [
          BoxShadow(
            blurRadius: 12,
            color: border.withOpacity(.2),
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.catching_pokemon, size: 18),
          const SizedBox(width: 6),
          Text(
            '$count / $max',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: border,
              letterSpacing: .5,
            ),
          ),
        ],
      ),
    );
  }
}

// ปรับขนาด Selected Chip ให้เล็กลงและรองรับ overflow
class _SelectedChip extends StatelessWidget {
  final Pokemon pokemon;
  final VoidCallback onRemove;
  const _SelectedChip({super.key, required this.pokemon, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: .95, end: 1.0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.only(left: 4, right: 2),
        constraints: const BoxConstraints(maxWidth: 120), // จำกัดความกว้าง
        decoration: ShapeDecoration(
          color: Colors.white.withOpacity(.85),
          shape: const StadiumBorder(side: BorderSide(color: Color(0xFF3B4CCA), width: 1.2)),
          shadows: const [BoxShadow(blurRadius: 6, color: Color(0x22000000), offset: Offset(0, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 12,
              backgroundImage: NetworkImage(pokemon.imageUrl),
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                _cap(pokemon.name),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              splashRadius: 16,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              onPressed: onRemove,
              icon: const Icon(Icons.close, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}

String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

// เพิ่มฟังก์ชันสำหรับชื่อและสีธาตุ
String _typeName(PokemonType type) {
  switch (type) {
    case PokemonType.grass: return 'Grass';
    case PokemonType.fire: return 'Fire';
    case PokemonType.water: return 'Water';
    case PokemonType.electric: return 'Electric';
    case PokemonType.normal: return 'Normal';
    case PokemonType.psychic: return 'Psychic';
    case PokemonType.fairy: return 'Fairy';
    case PokemonType.fighting: return 'Fighting';
    case PokemonType.flying: return 'Flying';
    case PokemonType.poison: return 'Poison';
    case PokemonType.ground: return 'Ground';
    case PokemonType.rock: return 'Rock';
    case PokemonType.bug: return 'Bug';
    case PokemonType.ghost: return 'Ghost';
    case PokemonType.steel: return 'Steel';
    case PokemonType.ice: return 'Ice';
    case PokemonType.dragon: return 'Dragon';
    case PokemonType.dark: return 'Dark';
  }
}

Color _typeColor(PokemonType type) {
  switch (type) {
    case PokemonType.grass: return Color(0xFF78C850);
    case PokemonType.fire: return Color(0xFFF08030);
    case PokemonType.water: return Color(0xFF6890F0);
    case PokemonType.electric: return Color(0xFFF8D030);
    case PokemonType.normal: return Color(0xFFA8A878);
    case PokemonType.psychic: return Color(0xFFF85888);
    case PokemonType.fairy: return Color(0xFFEE99AC);
    case PokemonType.fighting: return Color(0xFFC03028);
    case PokemonType.flying: return Color(0xFFA890F0);
    case PokemonType.poison: return Color(0xFFA040A0);
    case PokemonType.ground: return Color(0xFFE0C068);
    case PokemonType.rock: return Color(0xFFB8A038);
    case PokemonType.bug: return Color(0xFFA8B820);
    case PokemonType.ghost: return Color(0xFF705898);
    case PokemonType.steel: return Color(0xFFB8B8D0);
    case PokemonType.ice: return Color(0xFF98D8D8);
    case PokemonType.dragon: return Color(0xFF7038F8);
    case PokemonType.dark: return Color(0xFF705848);
  }
}