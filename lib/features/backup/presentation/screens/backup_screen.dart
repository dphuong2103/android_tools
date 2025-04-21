import 'package:android_tools/core/device_list/device_list_cubit.dart';
import 'package:android_tools/core/util/date_util.dart';
import 'package:android_tools/features/backup/presentation/cubit/backup_cubit.dart';
import 'package:android_tools/injection_container.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BackupCubit>(
      create: (context) => sl()..init(),
      child: BackupView(),
    );
  }
}

class BackupView extends StatefulWidget {
  const BackupView({super.key});

  @override
  State<BackupView> createState() => _BackupViewState();
}

class _BackupViewState extends State<BackupView> {
  late TextEditingController _searchTextController;
  late TextEditingController _searchSerialNumberController;
  String? _selectedSerialNumber;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _searchTextController = TextEditingController();
    _searchSerialNumberController = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _searchTextController.dispose();
    _searchSerialNumberController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BackupCubit, BackupState>(
      listener: (context, state) {},
      builder: (context, state) {
        switch (state) {
          case BackupStateList():
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      //write a search box and a search button
                      SizedBox(
                        width: 250,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: "Search",
                            border: OutlineInputBorder(),
                          ),
                          controller: _searchTextController,
                        ),
                      ),
                      Gap(10),
                      //A button to search
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          _searchTextController.text =
                              _searchTextController.text.trim();
                          context.read<BackupCubit>().onSearch(
                            _searchTextController.text.trim(),
                          );
                        },
                      ),
                      Gap(10),
                      //create a dropdown button with list of serial number, a button to filter by serial number
                      DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: Text('Serial Number', style: TextStyle(fontSize: 14)),
                          items: buildSerialNumberList(state.serialNumbers),
                          value: _selectedSerialNumber,
                          onChanged: (value) {
                            setState(() {
                              _selectedSerialNumber = value;
                            });
                            if (value != null) {
                              context
                                  .read<BackupCubit>()
                                  .onFilterBySerialNumber(value);
                            }
                          },
                          buttonStyleData: const ButtonStyleData(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            height: 40,
                            width: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                              color: Colors.white,
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                          dropdownStyleData: const DropdownStyleData(
                            maxHeight: 200,
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                          ),
                          dropdownSearchData: DropdownSearchData(
                            searchController: _searchSerialNumberController,
                            searchInnerWidgetHeight: 50,
                            searchInnerWidget: Container(
                              height: 50,
                              padding: const EdgeInsets.only(
                                top: 8,
                                bottom: 4,
                                right: 8,
                                left: 8,
                              ),
                              child: TextFormField(
                                expands: true,
                                maxLines: null,
                                controller: _searchSerialNumberController,
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  hintText: 'Search for an item...',
                                  hintStyle: const TextStyle(fontSize: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            searchMatchFn: (item, searchValue) {
                              return item.value.toString().contains(
                                searchValue,
                              );
                            },
                          ),
                          //This to clear the search value when you close the menu
                          onMenuStateChange: (isOpen) {
                            if (!isOpen) {
                              _searchSerialNumberController.clear();
                            }
                          },
                        ),
                      ),

                      IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchSerialNumberController.clear();
                          setState(() {
                            _selectedSerialNumber = null;
                          });
                          context.read<BackupCubit>().onFilterBySerialNumber(
                            "",
                          );
                        },
                      ),
                      Expanded(child: Container()),

                      ElevatedButton(
                        onPressed: () {
                          var selectedFolders =
                              (context.read<BackupCubit>().state
                                      as BackupStateList)
                                  .filteredBackUpFiles
                                  .where((file) => file.isSelected)
                                  .toList();

                          //check if duplicate serial number
                          var serialNumbers =
                              selectedFolders
                                  .map((file) => file.serialNumber)
                                  .toSet();
                          if (serialNumbers.length != selectedFolders.length) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Only 1 backup for each serial number is allowed",
                                ),
                              ),
                            );
                            return;
                          }

                          if (selectedFolders.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Please select at least one item",
                                ),
                              ),
                            );
                            return;
                          }
                          context.read<BackupCubit>().onRestoreSelect();
                        },

                        child: Text("Restore"),
                      ),

                      IconButton(
                        icon: Icon(Icons.refresh, color: Colors.green),
                        onPressed: () {
                          context.read<BackupCubit>().onRefresh();
                        },
                      ),

                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          if (!context.read<BackupCubit>().hasSelectedFiles()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Please select at least one item",
                                ),
                              ),
                            );
                            return;
                          }
                          if (await confirm(
                            context,
                            title: const Text('Confirm Delete'),
                            content: const Text('Would you like to remove?'),
                            textOK: const Text('Yes'),
                            textCancel: const Text('No'),
                          )) {
                            if (context.mounted) {
                              context.read<BackupCubit>().onDeleteSelected();
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  Gap(5),
                  Expanded(
                    child: DataTable2(
                      headingCheckboxTheme: const CheckboxThemeData(
                        side: BorderSide(width: 2.0),
                      ),
                      onSelectAll: (bool? isSelectAll) {
                        context.read<BackupCubit>().onSelectAll(isSelectAll);
                      },
                      columns: [
                        DataColumn2(label: Text("Name")),
                        DataColumn2(label: Text("Size")),
                        DataColumn2(
                          label: Text("Created At"),

                        ),
                        DataColumn2(
                          label: Text("Serial Number"),

                        ),
                        DataColumn2(
                          label: Text("Restore Status"),
                        ),
                      ],
                      rows:
                          state.filteredBackUpFiles
                              .map(
                                (file) => DataRow2(
                                  onSelectChanged: (bool? selected) {
                                    context
                                        .read<BackupCubit>()
                                        .onToggleSelectFile(
                                          filePath: file.path,
                                          selected: selected ?? false,
                                        );
                                  },
                                  selected: file.isSelected,
                                  cells: [
                                    DataCell(Text(file.name)),
                                    DataCell(
                                      SelectableText(
                                        "${file.size.toStringAsFixed(2)} MB",
                                      ),
                                    ),
                                    DataCell(
                                      SelectableText(
                                        formatDateTime(
                                          dateTime: file.createdAt,
                                        ),
                                      ),
                                    ),
                                    DataCell(SelectableText(file.serialNumber)),
                                    DataCell(SelectableText(file.restoreStatus ?? "")),
                                  ],
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ],
              ),
            );
          case BackupStateError():
            return Center(child: Text(state.errorMessage));
          default:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  List<DropdownMenuItem<String>> buildSerialNumberList(
    List<String> serialNumbers,
  ) {
    return serialNumbers.map((serialNumber) {
      return DropdownMenuItem<String>(
        value: serialNumber,
        child: Text(
          serialNumber,
          style: const TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList();
  }
}
