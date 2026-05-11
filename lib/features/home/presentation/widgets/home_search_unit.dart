import 'package:flutter/material.dart';
import 'property_type_tabs.dart';
import 'search/search_filter_bar.dart';

class HomeSearchUnit extends StatelessWidget {
  const HomeSearchUnit({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PropertyTypeTabs(),
        SearchFilterBar(),
      ],
    );
  }
}
