import 'package:flutter/material.dart';
import 'dart:ui';

class DatesScreen extends StatefulWidget {
  const DatesScreen({super.key});

  @override
  State<DatesScreen> createState() => _DatesScreenState();
}

class _DatesScreenState extends State<DatesScreen> {
  // Example data structure for dates
  List<Map<String, dynamic>> dates = [
    {
      'id': 1,
      'user': 'Luna',
      'date': DateTime(2025, 8, 10),
      'status': 'pendiente',
    },
    {
      'id': 2,
      'user': 'Max',
      'date': DateTime(2025, 8, 12),
      'status': 'aceptado',
    },
    {
      'id': 3,
      'user': 'Chispa',
      'date': DateTime(2025, 8, 15),
      'status': 'cancelado',
    },
  ];

  String? selectedStatus;
  String? selectedUser;
  DateTime? selectedDate;

  List<Map<String, dynamic>> get filteredDates {
    return dates.where((d) {
      final statusMatch = selectedStatus == null || d['status'] == selectedStatus;
      final userMatch = selectedUser == null || d['user'] == selectedUser;
      final dateMatch = selectedDate == null || (d['date'].year == selectedDate!.year && d['date'].month == selectedDate!.month && d['date'].day == selectedDate!.day);
      return statusMatch && userMatch && dateMatch;
    }).toList();
  }

  void updateStatus(int id, String newStatus) {
    setState(() {
      final idx = dates.indexWhere((d) => d['id'] == id);
      if (idx != -1) dates[idx]['status'] = newStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final users = dates.map((d) => d['user'] as String).toSet().toList();
    final statuses = ['pendiente', 'aceptado', 'cancelado'];
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Citas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedContainer(
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF7A45D1),
                  Color(0xFFE040FB),
                  Color(0xFFF8BBD0),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Filter by user
                          DropdownButton<String>(
                            hint: const Text('Usuario'),
                            value: selectedUser,
                            items: users.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                            onChanged: (v) => setState(() => selectedUser = v),
                          ),
                          const SizedBox(width: 8),
                          // Filter by status
                          DropdownButton<String>(
                            hint: const Text('Estado'),
                            value: selectedStatus,
                            items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (v) => setState(() => selectedStatus = v),
                          ),
                          const SizedBox(width: 8),
                          // Filter by date
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE040FB),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                            ),
                            child: Text(selectedDate == null ? 'Fecha' : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) setState(() => selectedDate = picked);
                            },
                          ),
                          if (selectedDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(() => selectedDate = null),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: filteredDates.isEmpty
                    ? const Center(child: Text('No hay citas con estos filtros.', style: TextStyle(color: Color(0xFF7A45D1), fontWeight: FontWeight.bold)))
                    : ListView.builder(
                        itemCount: filteredDates.length,
                        itemBuilder: (context, index) {
                          final cita = filteredDates[index];
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: cita['status'] == 'aceptado'
                                          ? [const Color(0xFFE1BEE7), const Color(0xFF7A45D1).withOpacity(0.15)]
                                          : cita['status'] == 'cancelado'
                                              ? [const Color(0xFFF8BBD0), const Color(0xFFE040FB).withOpacity(0.15)]
                                              : [Colors.white.withOpacity(0.85), const Color(0xFFE040FB).withOpacity(0.08)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.purple.withOpacity(0.08),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                    leading: CircleAvatar(
                                      backgroundColor: cita['status'] == 'aceptado'
                                          ? const Color(0xFF7A45D1)
                                          : cita['status'] == 'cancelado'
                                              ? const Color(0xFFE040FB)
                                              : const Color(0xFFF8BBD0),
                                      child: const Icon(Icons.event, color: Colors.white),
                                    ),
                                    title: Text(
                                      '${cita['user']} - ${cita['date'].day}/${cita['date'].month}/${cita['date'].year}',
                                      style: const TextStyle(color: Color(0xFF7A45D1), fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                    subtitle: Text('Estado: ${cita['status']}', style: const TextStyle(color: Color(0xFFE040FB), fontWeight: FontWeight.w600)),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (cita['status'] != 'aceptado')
                                          Tooltip(
                                            message: 'Aprobar',
                                            child: IconButton(
                                              icon: const Icon(Icons.check, color: Color(0xFF7A45D1)),
                                              onPressed: () => updateStatus(cita['id'], 'aceptado'),
                                            ),
                                          ),
                                        if (cita['status'] != 'cancelado')
                                          Tooltip(
                                            message: 'Cancelar',
                                            child: IconButton(
                                              icon: const Icon(Icons.cancel, color: Color(0xFFE040FB)),
                                              onPressed: () => updateStatus(cita['id'], 'cancelado'),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
