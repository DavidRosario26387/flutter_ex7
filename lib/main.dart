import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    title: "Doctor Appointment Booking",
    home: AppointmentScreen(),
  ));
}

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientController = TextEditingController();
  final _doctorController = TextEditingController();
  final _dateController = TextEditingController();
  String _status = "";

  final CollectionReference appointments =
      FirebaseFirestore.instance.collection("appointments");

  Future<void> _addAppointment() async {
    if (_formKey.currentState!.validate()) {
      await appointments.add({
        'patientName': _patientController.text,
        'doctorName': _doctorController.text,
        'date': _dateController.text,
      });

      _patientController.clear();
      _doctorController.clear();
      _dateController.clear();

      setState(() {
        _status = "Appointment Booked Successfully!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Appointment Booking"),
        backgroundColor: Colors.indigo,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _patientController,
                      decoration: const InputDecoration(
                        labelText: "Enter Patient Name",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? "Please enter the patient's name"
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _doctorController,
                      decoration: const InputDecoration(
                        labelText: "Enter Doctor Name",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? "Please enter the doctor's name"
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: "Enter Appointment Date (DD/MM/YYYY)",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? "Please enter appointment date"
                          : null,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _addAppointment,
                      child: const Text("Book Appointment"),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _status,
                      style: const TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: appointments.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final records = snapshot.data!.docs;
                  if (records.isEmpty) {
                    return const Center(child: Text("No Appointments Found"));
                  }

                  return ListView.builder(
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final appt = records[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(appt['patientName'][0].toUpperCase()),
                          backgroundColor:
                              appt['doctorName'].toLowerCase().contains("surgeon")
                                  ? Colors.red
                                  : Colors.blue,
                        ),
                        title: Text(appt['patientName']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Doctor: ${appt['doctorName']}"),
                            Text("Date: ${appt['date']}"),
                            if (appt['doctorName']
                                .toLowerCase()
                                .contains("surgeon"))
                              const Text(
                                "Priority Case!",
                                style: TextStyle(color: Colors.red),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
