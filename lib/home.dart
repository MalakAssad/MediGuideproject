import 'package:flutter/material.dart';
import 'meds.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // fields for manual readings
  String _bp = '';
  String _sugar = '';
  String _advice = 'Stay hydrated and follow your medication schedule.';

  // medications list returned from MedsPage
  List<Med> meds = [];

  int get takenCount => meds.where((m) => m.taken).length;
  int get adherencePercent =>
      meds.isEmpty ? 0 : ((takenCount / meds.length) * 100).round();

  final List<String> tips = [
    'Walk 20 minutes after breakfast.',
    'Keep hydrated: drink water between medications.',
    'Keep a small notebook of your readings for the doctor.',
  ];

  void updateBP(String text) {
    setState(() {
      _bp = text;
    });
    _analyze();
  }

  void updateSugar(String text) {
    setState(() {
      _sugar = text;
    });
    _analyze();
  }

  void _analyze() {
    final bp = double.tryParse(_bp);
    final sugar = double.tryParse(_sugar);
    String advice = 'All readings normal. Keep a healthy routine.';

    if ((bp != null && bp >= 140) && (sugar != null && sugar >= 200)) {
      advice = 'High BP and high sugar — consider visiting your doctor.';
    } else if (bp != null && bp >= 140) {
      advice = 'High blood pressure detected. Seek medical advice.';
    } else if (sugar != null && sugar >= 200) {
      advice = 'High blood sugar detected. Seek medical advice.';
    }

    setState(() {
      _advice = advice;
    });
  }

  Future<void> _openMeds() async {
    final result = await Navigator.push<List<Med>>(
      context,
      MaterialPageRoute(builder: (context) => MedsPage(initial: meds)),
    );

    if (result != null) {
      setState(() {
        meds = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade200],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('MediGuide'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                children: [
                  // Profile banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white24,
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'MediGuide',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4.0),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _openMeds,
                          icon: const Icon(Icons.medication),
                          label: const Text('Manage'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              66,
                              239,
                              206,
                              206,
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18.0),

                  // Tips carousel
                  SizedBox(
                    height: 110,
                    child: PageView.builder(
                      controller: PageController(viewportFraction: 0.9),
                      itemCount: tips.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Health Tip',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                tips[index],
                                style: const TextStyle(fontSize: 14.0),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 18.0),

                  // Readings card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Record a reading',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        MyTextField(
                          hint: 'Blood pressure (e.g. 120)',
                          f: updateBP,
                        ),
                        const SizedBox(height: 12.0),
                        MyTextField(
                          hint: 'Blood sugar (e.g. 110)',
                          f: updateSugar,
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          'Analysis: $_advice',
                          style: const TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18.0),

                  // Timeline / today's meds
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Today\'s Timeline',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Adherence: $adherencePercent%',
                              style: const TextStyle(fontSize: 12.0),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        meds.isEmpty
                            ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'No medications scheduled. Tap Manage to add.',
                          ),
                        )
                            : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: meds.length,
                          itemBuilder: (context, index) {
                            final m = meds[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1),
                                child: Icon(
                                  Icons.medication,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                ),
                              ),
                              title: Text(
                                m.name,
                                style: TextStyle(
                                  decoration: m.taken
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                              subtitle: Text(
                                '${m.dose} • ${m.time.format(context)}',
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  m.taken
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: m.taken
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                onPressed: () =>
                                    setState(() => m.taken = !m.taken),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Simple reusable TextField widget following your sample style
class MyTextField extends StatelessWidget {
  final Function(String) f; // hold a variable function
  final String hint; // holds the hintText of the TextField

  const MyTextField({required this.hint, required this.f, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320.0,
      height: 50.0,
      child: TextField(
        style: const TextStyle(fontSize: 18.0),
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: hint,
        ),
        onChanged: (text) {
          f(text);
        },
      ),
    );
  }
}
