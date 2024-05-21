import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List of tool names (for demo purpose)
  final List<String> _toolNames = [
    'Tool 1',
    'Tool 2',
    'Tool 3',
    'Tool 4',
    'Tool 5'
  ];

  // List of variables for each tool (for demo purpose)
  final Map<String, List<String>> _toolVariables = {
    'Tool 1': ['Variable 1', 'Variable 2', 'Variable 3'],
    'Tool 2': ['Variable 4', 'Variable 5', 'Variable 6'],
    'Tool 3': ['Variable 7', 'Variable 8', 'Variable 9'],
    'Tool 4': ['Variable 10', 'Variable 11', 'Variable 12'],
    'Tool 5': ['Variable 13', 'Variable 14', 'Variable 15'],
  };

  // Selected tool
  late String _selectedTool = _toolNames.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 200,
            color: Colors.grey[200],
            child: ListView.builder(
              itemCount: _toolNames.length,
              itemBuilder: (context, index) {
                final toolName = _toolNames[index];
                return ListTile(
                  title: Text(toolName),
                  selected: toolName == _selectedTool,
                  selectedColor: Colors.white,
                  selectedTileColor: Colors.blue,
                  onTap: () {
                    setState(() {
                      _selectedTool = toolName;
                    });
                  },
                );
              },
            ),
          ),

          // Main Content Area
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Variable Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Variables for $_selectedTool',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _toolVariables[_selectedTool]!
                            .map((variable) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        '$variable:',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextField(
                                          decoration: InputDecoration(
                                            hintText: 'Enter $variable',
                                            border: const OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),

                // Output Section
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Output',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Scrollbar(
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    'This is the output area where the result of running the selected tool will be displayed.',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
