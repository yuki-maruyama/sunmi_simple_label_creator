import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
    return MaterialApp(
      title: 'SUNMI Simple label creator',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const MyHomePage(title: 'SUNMI Simple label creator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _text = '';
  int _fontSize = 60;

  @override
  void initState() {
    super.initState();
    SunmiPrinter.bindingPrinter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  'Text:',
                  style: TextStyle(fontSize: 25   ),
                ),
              ),
            ),
            TextFormField(
              style: const TextStyle(fontSize: 25),
              decoration: (
                const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter text to print',
                )
              ),
              onChanged: (String value) {
                setState(() {
                  _text = value;
                });
              },
              textAlign: TextAlign.center,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20)
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  'Font size:',
                  style: TextStyle(fontSize: 25),
                ),
              ),
            ),
            TextFormField(
              style: const TextStyle(fontSize: 25),
              initialValue: _fontSize.toString(),
              onChanged: (String value) {
                setState(() {
                  if (int.tryParse(value) != null) {
                    _fontSize = int.parse(value);
                  }
                });
              },
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
              },
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(200, 50),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              onPressed: () async {
                if (_text.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: const Text('Text to print is empty\nPlease enter text to print'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }
                bool? isPrinted = await printLabel(_fontSize, _text);
                if (!mounted) return;
                // show snackbar if printed
                if (isPrinted != null && isPrinted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Label printed'),
                    ),
                  );
                }
              },
              child: const Text(
                'Print',
                style: TextStyle(fontSize: 25),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


Future<bool?> printLabel(int fontSize, String text) async {
  await SunmiPrinter.startTransactionPrint();
  await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
  await SunmiPrinter.setCustomFontSize(fontSize);
  await SunmiPrinter.printText(text);
  await SunmiPrinter.lineWrap(4);
  await SunmiPrinter.submitTransactionPrint();
  await SunmiPrinter.exitTransactionPrint(true);
  return true;
}