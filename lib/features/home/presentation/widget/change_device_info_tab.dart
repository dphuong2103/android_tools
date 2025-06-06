import 'package:android_tools/core/device_list/device_list_cubit.dart';
import 'package:android_tools/features/home/domain/entity/command.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';

class ChangeDeviceInfoTab extends StatefulWidget {
  const ChangeDeviceInfoTab({super.key});

  @override
  State<ChangeDeviceInfoTab> createState() => _ChangeDeviceInfoTabState();
}

class _ChangeDeviceInfoTabState extends State<ChangeDeviceInfoTab> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeviceListCubit, DeviceListState>(
      listener: (BuildContext context, DeviceListState state) {},
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
                    textField(
                      name: "macSuffix",
                      labelText: "Mac Suffix",
                      validator: FormBuilderValidators.compose([
                        (val) {
                          return val == null ? "Required" : null;
                        },
                        FormBuilderValidators.required(),
                      ]),
                    ),
                    textField(
                      name: "androidId",
                      labelText: "Android ID",
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
                      // var device = DeviceInfo(
                      //   model: _formKey.currentState?.value["model"],
                      //   brand: _formKey.currentState?.value["brand"],
                      //   manufacturer:
                      //       _formKey.currentState?.value["manufacturer"],
                      //   device: _formKey.currentState?.value["device"],
                      //   productName:
                      //       _formKey.currentState?.value["productName"],
                      //   releaseVersion:
                      //       _formKey.currentState?.value["releaseVersion"],
                      //   sdkVersion: _formKey.currentState?.value["sdkVersion"],
                      //   serialNo: _formKey.currentState?.value["serialNo"],
                      //   fingerprint:
                      //       _formKey.currentState?.value["fingerprint"],
                      //   macAddress: _formKey.currentState?.value["macSuffix"],
                      //   androidId: _formKey.currentState?.value["androidId"],
                      //   ssid: _formKey.currentState?.value["ssid"],
                      //   advertisingId: _formKey.currentState?.value["advertisingId"],
                      //   emei:
                      // );
                    },
                    child: Text("Change"),
                  ),
                  Gap(10),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DeviceListCubit>().executeCommandForSelectedDevices(
                        command: ChangeRandomDeviceInfoCommand(),
                      );
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
