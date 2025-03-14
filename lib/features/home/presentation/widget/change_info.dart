import 'package:android_tools/features/home/domain/entity/device_info.dart';
import 'package:android_tools/features/home/presentation/cubit/home_cubit.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';

class ChangeDeviceInfo extends StatefulWidget {
  const ChangeDeviceInfo({super.key});

  @override
  State<ChangeDeviceInfo> createState() => _ChangeDeviceInfoState();
}

class _ChangeDeviceInfoState extends State<ChangeDeviceInfo> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (BuildContext context, HomeState state) {},
      builder: (context, state) {
        return FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: GridView.count(
                  childAspectRatio: 5.0,
                  primary: false,
                  padding: const EdgeInsets.all(20),
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  crossAxisCount: 2,
                  children: [
                    textField(
                      name: "model",
                      labelText: "Model",
                      validator: FormBuilderValidators.compose([
                        (val) {
                          return val == null ? "Required" : null;
                        },
                        FormBuilderValidators.required(),
                      ]),
                    ),
                    textField(
                      name: "brand",
                      labelText: "Brand",
                      validator: FormBuilderValidators.compose([
                        (val) {
                          return val == null ? "Required" : null;
                        },
                        FormBuilderValidators.required(),
                      ]),
                    ),
                    textField(
                      name: "manufacturer",
                      labelText: "Manufacturer",
                      validator: FormBuilderValidators.compose([
                        (val) {
                          return val == null ? "Required" : null;
                        },
                        FormBuilderValidators.required(),
                      ]),
                    ),
                    textField(
                      name: "serialNo",
                      labelText: "Serial No.",
                      validator: FormBuilderValidators.compose([
                        (val) {
                          return val == null ? "Required" : null;
                        },
                        FormBuilderValidators.required(),
                      ]),
                    ),
                    textField(
                      name: "device",
                      labelText: "Device",
                      validator: FormBuilderValidators.compose([
                        (val) {
                          return val == null ? "Required" : null;
                        },
                        FormBuilderValidators.required(),
                      ]),
                    ),
                    textField(
                      name: "name",
                      labelText: "Name",
                      validator: FormBuilderValidators.compose([
                        (val) {
                          return val == null ? "Required" : null;
                        },
                        FormBuilderValidators.required(),
                      ]),
                    ),
                    textField(
                      name: "fingerPrint",
                      labelText: "Finger Print",
                      validator: FormBuilderValidators.compose([
                        (val) {
                          return val == null ? "Required" : null;
                        },
                        FormBuilderValidators.required(),
                      ]),
                    ),
                    textField(
                      name: "versionRelease",
                      labelText: "Version Release",
                      validator: FormBuilderValidators.compose([
                        (val) {
                          return val == null ? "Required" : null;
                        },
                        FormBuilderValidators.required(),
                      ]),
                    ),
                    textField(
                      name: "sdkVersion",
                      labelText: "SDK Version",
                      validator: FormBuilderValidators.compose([
                        (val) {
                          return val == null ? "Required" : null;
                        },
                        FormBuilderValidators.required(),
                      ]),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      var hasSelectDevice = state.devices.firstWhereOrNull(
                        (device) => device.isSelected,
                      );
                      if (hasSelectDevice == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please select at least 1 device"),
                          ),
                        );
                        return;
                      }
                      if (!(_formKey.currentState?.saveAndValidate() ??
                          false)) {
                        return;
                      }
                      var device = DeviceInfo(
                        model: _formKey.currentState?.value["model"],
                        brand: _formKey.currentState?.value["brand"],
                        manufacturer:
                            _formKey.currentState?.value["manufacturer"],
                        device: _formKey.currentState?.value["device"],
                        productName:
                            _formKey.currentState?.value["productName"],
                        releaseVersion:
                            _formKey.currentState?.value["releaseVersion"],
                        sdkVersion: _formKey.currentState?.value["sdkVersion"],
                      );
                    },
                    child: Text("Change"),
                  ),
                  Gap(10),
                  ElevatedButton(
                    onPressed: () {
                      context.read<HomeCubit>().runCommand(changeDeviceInfoRandomCommand);
                    },
                    child: Text("Change Random"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget textField({
  required String name,
  required String labelText,
  String? Function(String?)? validator,
}) {
  return FormBuilderTextField(
    name: name,
    validator: validator,
    decoration: InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(),
    ),
  );
}
