import 'package:flutter/material.dart';

class DividerWidget extends StatelessWidget {
  const DividerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: const [
          Expanded(
            child: Divider(
              color: Color.fromARGB(255, 223, 221, 221),
              thickness: 1.5,
            ),
          ),
          Expanded(
            child: Divider(
              color: Color.fromARGB(255, 223, 221, 221),
              thickness: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
