// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'main.dart';

void main() => runApp(const Gui());

class Gui extends StatelessWidget {
  const Gui({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Prodotto? prodotto =
        ModalRoute.of(context)?.settings.arguments as Prodotto?;

    if (prodotto != null) {
      return MaterialApp(
        title: 'Buy Green',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: MyHomePage(prodotto: prodotto),
      );
    } else {
      return const Scaffold(
        body: Center(
          child: Text('Errore: dati prodotto mancanti o non validi.'),
        ),
      );
    }
  }
}

class MyHomePage extends StatelessWidget {
  final Prodotto prodotto;

  const MyHomePage({Key? key, required this.prodotto}) : super(key: key);

  String getImagePath(double tot) {
    String imagePath;

    if (tot <= 25) {
      imagePath = "assets/green.png";
    } else if (tot <= 50) {
      imagePath = "assets/yellow.png";
    } else if (tot <= 75) {
      imagePath = "assets/orange.png";
    } else {
      imagePath = "assets/red.png";
    }

    return imagePath;
  }

  @override
  Widget build(BuildContext context) {
    double tot = ((double.parse(prodotto.co2) + double.parse(prodotto.energy)) *
            (100 - double.parse(prodotto.rec))) /
        100;
    if (tot > 100) {
      tot = 100;
    }
    String tot2 = tot.toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(
              width: 40,
              child: Image.asset("assets/logo_round.png"),
            ),
            const SizedBox(width: 15),
            const Text("Buy Green"),
          ],
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildFileSizeChart(
                        prodotto.name,
                        Colors.green,
                        .3,
                        constraints,
                      ),
                      buildFileSizeChart(
                        prodotto.company,
                        Colors.green,
                        .3,
                        constraints,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      getImagePath(tot),
                      width: constraints.maxWidth * 0.5,
                      height: constraints.maxWidth * 0.5,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Impact Percentage",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LinearPercentIndicator(
                      width: 140.0,
                      lineHeight: 14.0,
                      percent: (tot / 100),
                      animation: true,
                      animationDuration: 1000,
                      backgroundColor: Colors.grey,
                      progressColor: Colors.green,
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$tot2%",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
                const Divider(height: 16),
                ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    6,
                    18,
                    18,
                  ),
                  children: [
                    const Text(
                      "Parameters",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildFileColumn(
                          'CO2',
                          'Emitted',
                          "${prodotto.co2}Kg",
                          constraints,
                        ),
                        buildFileColumn(
                          'Energy',
                          'Consumed',
                          "${prodotto.energy}kW",
                          constraints,
                        ),
                        buildFileColumn(
                          'Recyclability',
                          'Percentage',
                          "${prodotto.rec}%",
                          constraints,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MyApp(),
            ),
          );
        },
        label: const Text("Back"),
      ),
    );
  }

  Column buildFileColumn(String filename, String filename2, String text,
      BoxConstraints constraints) {
    final circleSize = constraints.maxWidth * 0.2;

    return Column(
      children: [
        RichText(
          text: TextSpan(
            text: filename,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
        ),
        RichText(
          text: TextSpan(
            text: filename2,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            color: Colors.green.shade300,
            borderRadius: BorderRadius.circular(circleSize / 2),
          ),
          padding: EdgeInsets.all(circleSize * 0.15),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Column buildFileSizeChart(String title, Color color, double widthPercentage,
      BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: constraints.maxWidth * widthPercentage,
          height: 4,
          color: Colors.blue,
        ),
      ],
    );
  }
}
