import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_round_slider/flutter_round_slider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double value = 0;
  final valueTween = Tween<double>(begin: -120, end: 120);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Flutter Round Slider'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () {
                setState(() {
                  value = Random.secure().nextDouble();
                });
              },
              child: Text(
                  'Random value (${valueTween.transform(value).toStringAsFixed(1)})')),
          Row(
            children: [
              RoundSlider(
                style: RoundSliderStyle(
                  alignment: RoundSliderAlignment.left,
                ),
                value: value,
                onChanged: (double value) {
                  setState(() {
                    this.value = value;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Temperature °F',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${valueTween.transform(value).round()}',
                      style: TextStyle(
                        fontSize: 64,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Temperature °F',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${valueTween.transform(value).round()}',
                      style: TextStyle(
                        fontSize: 64,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              RoundSlider(
                style: RoundSliderStyle(
                  alignment: RoundSliderAlignment.right,
                ),
                value: value,
                onChanged: (double value) {
                  setState(() {
                    this.value = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
