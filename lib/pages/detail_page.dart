import 'package:flutter/material.dart';

class DetailPage extends StatefulWidget {
  final String id;
  final String endpoint;
  const DetailPage({super.key, required this.id, required this.endpoint});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}