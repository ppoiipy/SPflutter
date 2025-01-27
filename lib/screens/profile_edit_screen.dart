import 'package:flutter/material.dart';

class ProfileEditScreen extends StatefulWidget {
  final String userEmail;

  const ProfileEditScreen({Key? key, required this.userEmail})
      : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _birthController = TextEditingController();
  final TextEditingController _foodPrefController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _activityLevelController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 20),
              _buildInputRow(
                  label: 'Nickname', controller: _nicknameController),
              _buildInputRow(label: 'Gender', controller: _genderController),
              _buildInputRow(
                  label: 'Weight',
                  controller: _weightController,
                  inputType: TextInputType.number),
              _buildInputRow(
                  label: 'Height',
                  controller: _heightController,
                  inputType: TextInputType.number),
              _buildInputRow(
                  label: 'Weight Goals', controller: _goalController),
              _buildDateInputRow(
                  label: 'Birth date', controller: _birthController),
              _buildInputRow(
                  label: 'Food Preference', controller: _foodPrefController),
              _buildInputRow(
                  label: 'Allergies', controller: _allergiesController),
              _buildInputRow(
                  label: 'Activity Level',
                  controller: _activityLevelController),
              SizedBox(height: 20),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1F5F5B), Color(0xFF40C5BD)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        title: Text(
          'Profile Settings',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildInputRow(
      {required String label,
      required TextEditingController controller,
      TextInputType inputType = TextInputType.text}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25, vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Color(0xFF1F5F5B),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          TextFormField(
            controller: controller,
            keyboardType: inputType,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              hintText: 'Enter $label',
              isDense: true,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '$label is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateInputRow(
      {required String label, required TextEditingController controller}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25, vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Color(0xFF1F5F5B),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          TextFormField(
            controller: controller,
            readOnly: true,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              hintText: 'Select $label',
              isDense: true,
            ),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                controller.text = "${pickedDate.toLocal()}".split(' ')[0];
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a $label';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 300,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              // Handle the profile update
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1F5F5B),
          ),
          child: Text('Apply', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
