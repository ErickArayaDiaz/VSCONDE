import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../models/project.dart';

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Nuevo Proyecto")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nombre del proyecto",
                ),
                validator: (value) =>
                    value!.isEmpty ? "Ingresa un nombre" : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Descripción"),
                validator: (value) =>
                    value!.isEmpty ? "Ingresa una descripción" : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    _selectedDate == null
                        ? "Selecciona fecha límite"
                        : "Fecha: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    child: const Text("Seleccionar"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      _selectedDate != null) {
                    final newProject = Project(
                      name: _nameController.text,
                      description: _descriptionController.text,
                      deadline: _selectedDate!,
                    );
                    projectProvider.addProject(newProject);
                    Navigator.pop(context);
                  }
                },
                child: const Text("Guardar Proyecto"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
