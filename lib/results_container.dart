import 'package:dac_colour_contrast/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class ResultsContainer extends StatefulWidget {
  const ResultsContainer({super.key});

  @override
  State<ResultsContainer> createState() => _ResultsContainerState();
}

class _ResultsContainerState extends State<ResultsContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height:
            MediaQuery.sizeOf(context).height * 0.4, // 40% of the screen height
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(2, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    onPressed: () => print('Results'),
                    icon: Icon(Icons.download_rounded)),
                const Text(
                  'Results',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: kPrimaryColor),
                ),
                IconButton(
                    onPressed: () => print('Results'),
                    icon: Icon(Icons.share_rounded)),
              ],
            ),
            Divider(
              color: kPrimaryColor.withOpacity(0.5),
              thickness: 0.2,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PickedColour(
                  pickedColour: kPrimaryColor,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '1.0:1',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                    ),
                    Text(
                      'Pass',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.green,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                PickedColour(
                  pickedColour: Colors.deepOrange,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          onPressed: () => {},
                          icon: const Icon(Ionicons.eyedrop_outline)),
                      const Text(
                        'FG Picker',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Row(
                  children: [
                    WCAGTextResult(),
                    SizedBox(width: 10),
                    WCAGTextResult(),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          onPressed: () => {},
                          icon: Icon(Ionicons.eyedrop)),
                      const Text(
                        'BG Picker',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ));
  }
}

class WCAGTextResult extends StatelessWidget {
  const WCAGTextResult({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Text',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text('Fail (AA)'),
        Text('Fail (AAA)'),
      ],
    );
  }
}

class PickedColour extends StatelessWidget {
  final Color pickedColour;

  const PickedColour({
    super.key,
    required this.pickedColour,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: pickedColour,
              border: Border.all(color: kPrimaryColor, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const Text(
            'Foreground',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const Text(
            '#FFFFFF',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
