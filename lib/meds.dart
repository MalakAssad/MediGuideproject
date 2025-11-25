import 'package:flutter/material.dart';

class Med {
  final String name;
  final String dose;
  final TimeOfDay time;
  bool taken;

  Med({required this.name, required this.dose, required this.time, this.taken = false});

  Med copyWith({String? name, String? dose, TimeOfDay? time, bool? taken}) {
    return Med(
      name: name ?? this.name,
      dose: dose ?? this.dose,
      time: time ?? this.time,
      taken: taken ?? this.taken,
    );
  }
}

class MedsPage extends StatefulWidget {
  final List<Med>? initial;
  const MedsPage({Key? key, this.initial}) : super(key: key);

  @override
  State<MedsPage> createState() => _MedsPageState();
}

class _MedsPageState extends State<MedsPage> {
  late List<Med> _meds;

  @override
  void initState() {
    super.initState();
    _meds = List<Med>.from(widget.initial ?? []);
  }

  Future<void> _addMed() async {
    String name = '';
    String dose = '';
    TimeOfDay? time = TimeOfDay.now();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Medication'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  onChanged: (v) => name = v,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Dose (e.g. 1 pill)'),
                  onChanged: (v) => dose = v,
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    const Text('Time: '),
                    TextButton(
                      onPressed: () async {
                        final picked = await showTimePicker(context: context, initialTime: time!);
                        if (picked != null) setState(() => time = picked);
                      },
                      child: Text(time!.format(context)),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (name.trim().isEmpty) return; // require a name
                  setState(() {
                    _meds.add(Med(name: name.trim(), dose: dose.trim().isEmpty ? '1 dose' : dose.trim(), time: time!, taken: false));
                  });
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medications'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _meds),
        ),
      ),
      body: _meds.isEmpty
          ? const Center(child: Text('No medications. Tap + to add one.'))
          : ListView.builder(
        itemCount: _meds.length,
        itemBuilder: (context, index) {
          final m = _meds[index];
          return Dismissible(
            key: ValueKey(m.name + m.time.toString() + index.toString()),
            direction: DismissDirection.endToStart,
            background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
            onDismissed: (_) {
              setState(() {
                _meds.removeAt(index);
              });
            },
            child: ListTile(
              onTap: () async {
                // open edit dialog
                String name = m.name;
                String dose = m.dose;
                TimeOfDay time = m.time;
                bool taken = m.taken;

                await showDialog<void>(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(builder: (context, setState) {
                      return AlertDialog(
                        title: const Text('Edit Medication'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              decoration: const InputDecoration(labelText: 'Name'),
                              controller: TextEditingController(text: name),
                              onChanged: (v) => name = v,
                            ),
                            TextField(
                              decoration: const InputDecoration(labelText: 'Dose'),
                              controller: TextEditingController(text: dose),
                              onChanged: (v) => dose = v,
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              children: [
                                const Text('Time: '),
                                TextButton(
                                  onPressed: () async {
                                    final picked = await showTimePicker(context: context, initialTime: time);
                                    if (picked != null) setState(() => time = picked);
                                  },
                                  child: Text(time.format(context)),
                                ),
                              ],
                            ),
                            Row(children: [const Text('Taken: '), Checkbox(value: taken, onChanged: (v) => setState(() => taken = v ?? false))]),
                          ],
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _meds[index] = _meds[index].copyWith(name: name.trim(), dose: dose.trim(), time: time, taken: taken);
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      );
                    });
                  },
                );
                setState(() {});
              },
              leading: Icon(Icons.medical_services, color: Theme.of(context).colorScheme.primary),
              title: Text(m.name, style: TextStyle(decoration: m.taken ? TextDecoration.lineThrough : TextDecoration.none)),
              subtitle: Text('${m.dose} • ${m.time.format(context)}'),
              trailing: Checkbox(
                value: m.taken,
                onChanged: (val) {
                  setState(() {
                    _meds[index].taken = val ?? false;
                  });
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMed,
        child: const Icon(Icons.add),
      ),
    );
  }
}
