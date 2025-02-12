import 'package:flutter/material.dart';

class SearchItem {
  final String title;
  final String category;
  final String? description;
  final Function onTap;
  final IconData icon;

  SearchItem({
    required this.title,
    required this.category,
    this.description,
    required this.onTap,
    required this.icon,
  });
}
