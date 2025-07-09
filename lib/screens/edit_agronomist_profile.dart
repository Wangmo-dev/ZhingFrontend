import 'package:flutter/material.dart';

class EditAgronomistProfilePage extends StatefulWidget {
  const EditAgronomistProfilePage({super.key});

  @override
  _EditAgronomistProfilePageState createState() =>
      _EditAgronomistProfilePageState();
}

class _EditAgronomistProfilePageState extends State<EditAgronomistProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController(
    text: 'Agronomist Demo',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'agronomist@example.com',
  );
  final TextEditingController _districtController = TextEditingController(
    text: 'Bumthang',
  );
  final TextEditingController _specializationController = TextEditingController(
    text: 'Crop Diseases',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text(
    'Edit Profile',
    style: TextStyle(color: Colors.white), // 👈 white title text
  ),
  backgroundColor: const Color(0xFF116736), // 👈 green background
  iconTheme: const IconThemeData(color: Colors.white), // 👈 white icon
  actions: [
    IconButton(
      icon: const Icon(Icons.save),
      onPressed: _saveProfile,
    ),
  ],
),

      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(0xFF116736),
                      child: Text(
                        'AD',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.blue,
                        child: IconButton(
                          icon: Icon(Icons.edit, size: 16),
                          onPressed: () {
                            // Implement image change
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _districtController,
                decoration: InputDecoration(
                  labelText: 'District',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _specializationController,
                decoration: InputDecoration(
                  labelText: 'Specialization',
                  prefixIcon: Icon(Icons.agriculture),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF116736),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _districtController.dispose();
    _specializationController.dispose();
    super.dispose();
  }
}
