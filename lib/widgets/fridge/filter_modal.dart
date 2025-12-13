// import 'package:flutter/material.dart';

// class FilterModal extends StatefulWidget {
//   final List<String> filterCategories;
//   final Set<String> initialSelectedFilters;
//   final Color mainColor;

//   const FilterModal({
//     super.key,
//     required this.filterCategories,
//     required this.initialSelectedFilters,
//     required this.mainColor,
//   });

//   @override
//   State<FilterModal> createState() => _FilterModalState();
// }

// class _FilterModalState extends State<FilterModal> {
//   late Set<String> selectedFilters;

//   @override
//   void initState() {
//     super.initState();
//     selectedFilters = Set.from(widget.initialSelectedFilters);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Container(
//         constraints: const BoxConstraints(maxWidth: 400),
//         color: Color(0xFFF0F1F1),
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Header với nút X
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 IconButton(
//                   onPressed: () {
//                     Navigator.of(context).pop(selectedFilters);
//                   },
//                   icon: const Icon(Icons.close),
//                   padding: EdgeInsets.zero,
//                   constraints: const BoxConstraints(),
//                 ),
//               ],
//             ),

//             // Search box
//             Container(
//               height: 48,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFE7EAE9),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               child: const Row(
//                 children: [
//                   Icon(Icons.search, size: 20, color: Colors.grey),
//                   SizedBox(width: 8),
//                   Expanded(
//                     child: TextField(
//                       decoration: InputDecoration(
//                         hintText: 'search type of ingredients...',
//                         hintStyle: TextStyle(
//                           color: Colors.grey,
//                           fontSize: 14,
//                         ),
//                         border: InputBorder.none,
//                         isDense: true,
//                         contentPadding: EdgeInsets.zero,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 20),

//             // Grid của checkboxes
//             GridView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 childAspectRatio: 3.5,
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 12,
//               ),
//               itemCount: widget.filterCategories.length,
//               itemBuilder: (context, index) {
//                 final category = widget.filterCategories[index];
//                 final isSelected = selectedFilters.contains(category);

//                 return InkWell(
//                   onTap: () {
//                     setState(() {
//                       if (isSelected) {
//                         selectedFilters.remove(category);
//                       } else {
//                         selectedFilters.add(category);
//                       }
//                     });
//                   },
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 24,
//                         height: 24,
//                         decoration: BoxDecoration(
//                           border: Border.all(
//                             color: isSelected ? widget.mainColor : Colors.grey,
//                             width: 2,
//                           ),
//                           borderRadius: BorderRadius.circular(4),
//                           color: isSelected
//                               ? widget.mainColor
//                               : Colors.transparent,
//                         ),
//                         child: isSelected
//                             ? const Icon(
//                                 Icons.check,
//                                 size: 16,
//                                 color: Colors.white,
//                               )
//                             : null,
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           category,
//                           style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w600,
//                             color: widget.mainColor,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class FilterModal extends StatefulWidget {
  final List<String> filterCategories;
  final Set<String> initialSelectedFilters;
  final Color mainColor;

  const FilterModal({
    super.key,
    required this.filterCategories,
    required this.initialSelectedFilters,
    required this.mainColor,
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  late Set<String> selectedFilters;
  late Set<String> tempSelectedFilters;

  @override
  void initState() {
    super.initState();
    selectedFilters = Set.from(widget.initialSelectedFilters);
    tempSelectedFilters = Set.from(widget.initialSelectedFilters);
  }

  void resetFilters() {
    setState(() {
      tempSelectedFilters.clear();
    });
  }

  void applyFilters() {
    Navigator.of(context).pop(tempSelectedFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header với nút X
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop(selectedFilters);
                  },
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Search box
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Row(
                children: [
                  Icon(Icons.search, size: 20, color: Colors.grey),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'search type of ingredients...',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Grid của checkboxes
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3.5,
                crossAxisSpacing: 20,
                mainAxisSpacing: 16,
              ),
              itemCount: widget.filterCategories.length,
              itemBuilder: (context, index) {
                final category = widget.filterCategories[index];
                final isSelected = tempSelectedFilters.contains(category);

                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        tempSelectedFilters.remove(category);
                      } else {
                        tempSelectedFilters.add(category);
                      }
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? widget.mainColor : const Color(0xFFCCCCCC),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          color: isSelected
                              ? widget.mainColor
                              : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: resetFilters,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                      backgroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: applyFilters,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: widget.mainColor,
                      elevation: 0,
                    ),
                    child: const Text(
                      'Apply',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}