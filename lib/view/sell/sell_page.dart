import 'package:flutter/material.dart';
import 'package:pashu_app/view/sell/widget/custom_button.dart';
import 'package:pashu_app/view/sell/widget/location_section.dart';
import 'package:pashu_app/view/sell/widget/submit_and_pay_button.dart';
import 'package:pashu_app/view/sell/widget/upload_pashu_images.dart';

class SellPashuScreen extends StatefulWidget {
  const SellPashuScreen({super.key});

  @override
  State<SellPashuScreen> createState() => _SellPashuScreenState();
}

class _SellPashuScreenState extends State<SellPashuScreen> {
  String? selectedType;
  String? selectedCategory;

  final Map<String, List<String>> categoryMap = {
    'Traditional Sports Animal': [
      'Bull',
      'Camel',
      'Bird',
      'Pigeon',
      'Cock',
      'Dog',
      'Goat',
      'Horse',
      'Other',
    ],
    'Livestock Animal': [
      'Buffalo',
      'Sheep',
      'Goat',
      'Pigs',
      'Other',
    ],
    'Pet Animal': [
      'Dog',
      'Cat',
      'Bird',
      'Fishes',
      'Small Mammals',
      'Other',
    ],
    'Farm House Animal': ['Other'],
  };

  List<String> get types => categoryMap.keys.toList();

  List<String> get categories =>
      categoryMap[selectedType] ?? [];

  Future<void> showSelectionModal({
    required List<String> options,
    required String title,
    required Function(String) onSelected,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // allows full-height modal
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6, // 60% screen height
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.separated(
                  itemCount: options.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final option = options[index];
                    return ListTile(
                      title: Text(option),
                      onTap: () {
                        Navigator.pop(context);
                        onSelected(option);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget buildSelectorBox(String? value, String hint, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          value ?? hint,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: value == null ? Colors.grey : Colors.black,
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeader(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildLabel('Animal Types'),
                  buildSelectorBox(
                    selectedType,
                    'Select Animal Type',
                        () => showSelectionModal(
                      options: types,
                      title: 'Select Animal Type',
                      onSelected: (type) {
                        setState(() {
                          selectedType = type;
                          selectedCategory = null; // reset category
                        });
                      },
                    ),
                  ),

                  buildLabel('Animal Category'),
                  buildSelectorBox(
                    selectedCategory,
                    selectedType == null
                        ? 'Please select animal type first'
                        : 'Select Animal Category',
                    selectedType == null
                        ? () {}
                        : () => showSelectionModal(
                      options: categories,
                      title: 'Select Category',
                      onSelected: (cat) {
                        setState(() {
                          selectedCategory = cat;
                        });
                      },
                    ),
                  ),
                  buildLabel('Name of The Animal'),
                  buildTextField('Name of The Animal'),
                  buildLabel('Enter Animal Age'),
                  buildTextField('Enter Animal Age'),
                  buildLabel('Select Gender of Animal'),
                  buildDropdown('Select Gender of Animal'),
                  buildLabel('Price'),
                  buildTextField('Price'),
                  buildLabel('Negotiable'),
                  buildTextField('Negotiable'),
                  buildLabel('Your Phone Number'),
                  buildTextField('Enter your phone number'),
                  buildLabel('Animal Description'),
                  buildMultilineTextField('Enter Animal Description'),
                  buildLabel('Get Address for Pashu'),
                  const LocationSection(),
                  UploadPashuImages(),
                  SizedBox(height: 20,),
                  SubmitAndPayButton(text: "Submit & Pay ₹15", onPressed: (){})
                ],
              ),
            )
          ],
        ),
      ),

      // Removed BottomNavigationBar
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildDropdown(String hint) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: DropdownButtonFormField<String>(
        value: null,
        decoration: const InputDecoration.collapsed(hintText: ''),
        isExpanded: true,
        style: const TextStyle(fontSize: 14),
        hint: Text(
          hint,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        items: const [],
        onChanged: (value) {},
      ),
    );
  }

  Widget buildMultilineTextField(String hint) {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontWeight: FontWeight.w500),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String hint) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontWeight: FontWeight.w500),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: const Color(0xFF1E4A59), // Light green header color
      child: const Center(
        child: Text(
          'Sell Pashu',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Dark text
          ),
        ),
      ),
    );
  }
}
