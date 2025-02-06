import 'package:flutter/material.dart';

import 'constants.dart';

class PickedColour extends StatelessWidget {
  final Color pickedColour;
  final String label;
  final String hexCode;
  final IconButton icon;

  const PickedColour({
    super.key,
    required this.pickedColour,
    required this.hexCode,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.01),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
              height: MediaQuery.of(context).size.height * 0.08,
              width: MediaQuery.of(context).size.width * 0.18,
              decoration: BoxDecoration(
                color: pickedColour,
                border: Border.all(color: kPrimaryColor, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: icon,
              )),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            hexCode,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
