import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:morden_ecommerce_app/component/address_form_field.dart';
import 'package:morden_ecommerce_app/component/my_button.dart';
import 'package:morden_ecommerce_app/models/address_model.dart';
import 'package:uuid/uuid.dart';

class AddressForm extends StatefulWidget {
  final AddressModel? existingAddress;
  const AddressForm({super.key, this.existingAddress});

  @override
  State<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  late TextEditingController emailController;
  late TextEditingController fullNameController;
  late TextEditingController stateController;
  late TextEditingController cityController;
  late TextEditingController streetAddressController;
  late TextEditingController phoneNumberController;
  late TextEditingController whatsAppNumberController;
  bool _isDefault = false;

  // Convenience getter — true if we're editing, false if creating
  bool get isEditing => widget.existingAddress != null;

  @override
  void initState() {
    super.initState();

    final addr = widget.existingAddress;

    // If editing, pre-fill with existing data. If new, start empty.
    fullNameController = TextEditingController(text: addr?.fullName ?? '');
    emailController = TextEditingController(text: addr?.email ?? '');
    phoneNumberController = TextEditingController(
      text: addr?.phoneNumber ?? '',
    );
    whatsAppNumberController = TextEditingController(
      text: addr?.whatsAppNumber ?? '',
    );
    streetAddressController = TextEditingController(
      text: addr?.streetAddress ?? '',
    );
    cityController = TextEditingController(text: addr?.city ?? '');
    stateController = TextEditingController(text: addr?.state ?? '');
    _isDefault = addr?.isDefault ?? false;
  }

  @override
  void dispose() {
    emailController.dispose();
    fullNameController.dispose();
    stateController.dispose();
    cityController.dispose();
    streetAddressController.dispose();
    phoneNumberController.dispose();
    whatsAppNumberController.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void onSubmit() {
    final address = AddressModel(
      // Keep the existing ID if editing, generate a new one if creating
      addressId: widget.existingAddress?.addressId ?? const Uuid().v4(),
      fullName: fullNameController.text.trim(),
      email: emailController.text.trim(),
      phoneNumber: phoneNumberController.text.trim(),
      whatsAppNumber: whatsAppNumberController.text.trim(),
      streetAddress: streetAddressController.text.trim(),
      city: cityController.text.trim(),
      state: stateController.text.trim(),
      isDefault: _isDefault,
    );

    // Pop and return the address back to the caller
    Navigator.pop(context, address);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Address' : 'Add New Address'),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios_new_rounded),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      /// EMAIL
                      AddressFormField(
                        label: "Email Address",
                        controller: emailController,
                        hintText: "example@gmail.com",
                        isRequired: true,
                        errorText: emailController.text.isEmpty
                            ? null
                            : !isValidEmail(emailController.text)
                            ? "Invalid Email Format"
                            : null,
                      ),

                      /// FULL NAME
                      AddressFormField(
                        label: "Full Name",
                        controller: fullNameController,
                        isRequired: true,
                      ),

                      /// STATE
                      AddressFormField(
                        label: "State",
                        controller: stateController,
                        isRequired: true,
                        hintText: 'e.g Abuja',
                      ),

                      /// CITY
                      AddressFormField(
                        label: "City",
                        controller: cityController,
                        isRequired: true,
                        hintText: 'e.g Maitama',
                      ),

                      /// STREET
                      AddressFormField(
                        label: "Street Address",
                        controller: streetAddressController,
                        hintText: "Street, Address, house No, Company Name",
                        isRequired: true,
                      ),

                      /// PHONE
                      AddressFormField(
                        label: "Phone Number",
                        controller: phoneNumberController,
                        hintText: "Please provide your 10-digit phone number",
                        isRequired: true,
                        prefix: Padding(
                          padding: const EdgeInsets.only(right: 4, top: 7),
                          child: Text(
                            "+234 |",
                            style: GoogleFonts.dmSans(color: Colors.grey),
                          ),
                        ),
                      ),

                      /// WHATSAPP
                      AddressFormField(
                        label: "WhatsApp Number",
                        controller: whatsAppNumberController,
                        hintText:
                            "For backup contact number in logistics delivery",
                        isRequired: true,
                      ),
                    ],
                  ),
                ),
              ),
              SwitchListTile(
                title: const Text('Set as default'),
                value: _isDefault,
                onChanged: (val) => setState(() => _isDefault = val),
              ),
              MyButton(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                margin: EdgeInsets.symmetric(vertical: 10),
                borderRadius: BorderRadius.circular(12),
                text: isEditing ? 'Save changes' : 'Add Address',
                onTap: onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
