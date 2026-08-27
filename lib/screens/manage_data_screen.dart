import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_colors.dart';
import '../services/supabase_auth_service.dart';

class ManageDataScreen extends StatefulWidget {
  const ManageDataScreen({super.key});

  @override
  State<ManageDataScreen> createState() => _ManageDataScreenState();
}

class _ManageDataScreenState extends State<ManageDataScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SupabaseClient _client = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _logOut() async {
    await SupabaseAuthService.instance.logOut();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Data'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Internships'),
            Tab(text: 'Scholarships'),
            Tab(text: 'Roadmaps'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: _logOut,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _InternshipsTab(client: _client),
          _ScholarshipsTab(client: _client),
          _RoadmapsTab(client: _client),
        ],
      ),
    );
  }
}

// ============================================================
// INTERNSHIPS TAB
// ============================================================

class _InternshipsTab extends StatefulWidget {
  final SupabaseClient client;
  const _InternshipsTab({required this.client});

  @override
  State<_InternshipsTab> createState() => _InternshipsTabState();
}

class _InternshipsTabState extends State<_InternshipsTab> {
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await widget.client
        .from('internships')
        .select()
        .order('created_at');
    setState(() {
      _rows = List<Map<String, dynamic>>.from(data);
      _loading = false;
    });
  }

  Future<void> _delete(String id) async {
    await widget.client.from('internships').delete().eq('id', id);
    _load();
  }

  Future<void> _openForm({Map<String, dynamic>? existing}) async {
    final titleCtrl = TextEditingController(text: existing?['title'] ?? '');
    final subtitleCtrl =
        TextEditingController(text: existing?['subtitle'] ?? '');
    final descCtrl =
        TextEditingController(text: existing?['description'] ?? '');
    final locationCtrl =
        TextEditingController(text: existing?['location'] ?? '');
    final deadlineCtrl =
        TextEditingController(text: existing?['deadline'] ?? '');
    final requirementsCtrl = TextEditingController(
      text: existing?['requirements'] != null
          ? (existing!['requirements'] as List).join(', ')
          : '',
    );
    final skillsCtrl = TextEditingController(
      text: existing?['skills'] != null
          ? (existing!['skills'] as List).join(', ')
          : '',
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add Internship' : 'Edit Internship'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: subtitleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Subtitle (e.g. Company - Jun to Aug)',
                ),
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextField(
                controller: locationCtrl,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: deadlineCtrl,
                decoration: const InputDecoration(
                  labelText: 'Deadline (e.g. 15 Sep 2026)',
                ),
              ),
              TextField(
                controller: requirementsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Requirements (comma-separated)',
                ),
                maxLines: 2,
              ),
              TextField(
                controller: skillsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Skills (comma-separated)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved != true) return;

    final payload = {
      'type': 'internship',
      'title': titleCtrl.text.trim(),
      'subtitle': subtitleCtrl.text.trim(),
      'description': descCtrl.text.trim(),
      'location': locationCtrl.text.trim(),
      'deadline': deadlineCtrl.text.trim(),
      'requirements': requirementsCtrl.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      'skills': skillsCtrl.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
    };

    if (existing == null) {
      await widget.client.from('internships').insert(payload);
    } else {
      await widget.client
          .from('internships')
          .update(payload)
          .eq('id', existing['id']);
    }
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        child: _rows.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 80),
                  Center(child: Text('No internships yet.')),
                ],
              )
            : ListView.builder(
                itemCount: _rows.length,
                itemBuilder: (context, index) {
                  final row = _rows[index];
                  return ListTile(
                    title: Text(row['title'] ?? ''),
                    subtitle: Text(row['subtitle'] ?? ''),
                    onTap: () => _openForm(existing: row),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _delete(row['id']),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryPurple,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ============================================================
// SCHOLARSHIPS TAB
// ============================================================

class _ScholarshipsTab extends StatefulWidget {
  final SupabaseClient client;
  const _ScholarshipsTab({required this.client});

  @override
  State<_ScholarshipsTab> createState() => _ScholarshipsTabState();
}

class _ScholarshipsTabState extends State<_ScholarshipsTab> {
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await widget.client
        .from('scholarships')
        .select()
        .order('created_at');
    setState(() {
      _rows = List<Map<String, dynamic>>.from(data);
      _loading = false;
    });
  }

  Future<void> _delete(String id) async {
    await widget.client.from('scholarships').delete().eq('id', id);
    _load();
  }

  Future<void> _openForm({Map<String, dynamic>? existing}) async {
    final titleCtrl = TextEditingController(text: existing?['title'] ?? '');
    final providerCtrl =
        TextEditingController(text: existing?['provider'] ?? '');
    final amountCtrl = TextEditingController(text: existing?['amount'] ?? '');
    final deadlineCtrl =
        TextEditingController(text: existing?['deadline'] ?? '');
    final shortDescCtrl =
        TextEditingController(text: existing?['short_description'] ?? '');
    final fullDescCtrl =
        TextEditingController(text: existing?['full_description'] ?? '');
    final eligibilityCtrl =
        TextEditingController(text: existing?['eligibility'] ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add Scholarship' : 'Edit Scholarship'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: providerCtrl,
                decoration: const InputDecoration(labelText: 'Provider'),
              ),
              TextField(
                controller: amountCtrl,
                decoration: const InputDecoration(
                  labelText: 'Amount (e.g. \$5,000)',
                ),
              ),
              TextField(
                controller: deadlineCtrl,
                decoration: const InputDecoration(labelText: 'Deadline'),
              ),
              TextField(
                controller: shortDescCtrl,
                decoration: const InputDecoration(
                  labelText: 'Short Description',
                ),
                maxLines: 2,
              ),
              TextField(
                controller: fullDescCtrl,
                decoration: const InputDecoration(
                  labelText: 'Full Description',
                ),
                maxLines: 3,
              ),
              TextField(
                controller: eligibilityCtrl,
                decoration: const InputDecoration(labelText: 'Eligibility'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved != true) return;

    final payload = {
      'title': titleCtrl.text.trim(),
      'provider': providerCtrl.text.trim(),
      'amount': amountCtrl.text.trim(),
      'deadline': deadlineCtrl.text.trim(),
      'short_description': shortDescCtrl.text.trim(),
      'full_description': fullDescCtrl.text.trim(),
      'eligibility': eligibilityCtrl.text.trim(),
      'icon': existing?['icon'] ?? 'school',
    };

    if (existing == null) {
      final newId = 'sch_${DateTime.now().millisecondsSinceEpoch}';
      await widget.client
          .from('scholarships')
          .insert({...payload, 'id': newId});
    } else {
      await widget.client
          .from('scholarships')
          .update(payload)
          .eq('id', existing['id']);
    }
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        child: _rows.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 80),
                  Center(child: Text('No scholarships yet.')),
                ],
              )
            : ListView.builder(
                itemCount: _rows.length,
                itemBuilder: (context, index) {
                  final row = _rows[index];
                  return ListTile(
                    title: Text(row['title'] ?? ''),
                    subtitle: Text(
                      '${row['provider'] ?? ''} • ${row['amount'] ?? ''}',
                    ),
                    onTap: () => _openForm(existing: row),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _delete(row['id']),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryPurple,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ============================================================
// SKILL ROADMAPS TAB
// (steps are shown read-only for now — editing role/description/aliases
// covers the common case; step-by-step editing can be added later)
// ============================================================

class _RoadmapsTab extends StatefulWidget {
  final SupabaseClient client;
  const _RoadmapsTab({required this.client});

  @override
  State<_RoadmapsTab> createState() => _RoadmapsTabState();
}

class _RoadmapsTabState extends State<_RoadmapsTab> {
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await widget.client
        .from('skill_roadmaps')
        .select()
        .order('created_at');
    setState(() {
      _rows = List<Map<String, dynamic>>.from(data);
      _loading = false;
    });
  }

  Future<void> _delete(String id) async {
    await widget.client.from('skill_roadmaps').delete().eq('id', id);
    _load();
  }

  Future<void> _openForm({Map<String, dynamic>? existing}) async {
    final roleCtrl = TextEditingController(text: existing?['role'] ?? '');
    final descCtrl =
        TextEditingController(text: existing?['description'] ?? '');
    final aliasesCtrl = TextEditingController(
      text: existing?['aliases'] != null
          ? (existing!['aliases'] as List).join(', ')
          : '',
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add Roadmap' : 'Edit Roadmap'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: roleCtrl,
                decoration: const InputDecoration(labelText: 'Role'),
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              TextField(
                controller: aliasesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Aliases (comma-separated)',
                ),
              ),
              if (existing != null) ...[
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Steps aren\'t editable here yet — ask Allan to '
                    'update those directly for now.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved != true) return;

    final payload = {
      'role': roleCtrl.text.trim(),
      'description': descCtrl.text.trim(),
      'aliases': aliasesCtrl.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
    };

    if (existing == null) {
      final newId = roleCtrl.text.trim().toLowerCase().replaceAll(' ', '_');
      await widget.client
          .from('skill_roadmaps')
          .insert({...payload, 'id': newId, 'steps': []});
    } else {
      await widget.client
          .from('skill_roadmaps')
          .update(payload)
          .eq('id', existing['id']);
    }
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        child: _rows.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 80),
                  Center(child: Text('No roadmaps yet.')),
                ],
              )
            : ListView.builder(
                itemCount: _rows.length,
                itemBuilder: (context, index) {
                  final row = _rows[index];
                  final stepCount = (row['steps'] as List?)?.length ?? 0;
                  return ListTile(
                    title: Text(row['role'] ?? ''),
                    subtitle: Text('$stepCount steps'),
                    onTap: () => _openForm(existing: row),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _delete(row['id']),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryPurple,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}