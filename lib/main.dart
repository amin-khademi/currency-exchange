import 'package:currency_exchange/Model/currency.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          textTheme: GoogleFonts.poppinsTextTheme(TextTheme(
              titleLarge: TextStyle(fontSize: 19, color: Colors.white),
              bodyMedium: TextStyle(fontSize: 14, color: Colors.black),
              bodyLarge: TextStyle(fontSize: 18, color: Colors.white)))
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.

          ),
      home: Homepage(),
    );
  }
}

class Homepage extends StatefulWidget {
  Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<Currency> currency = [];

  Future getParameters(BuildContext cntx) async {
    var url =
        "https://sasansafari.com/flutter/api.php?access_key=flutter123456";
    var value = await http.get(Uri.parse(url));
    if (value.statusCode == 200) {
      _snackbar(context, "successfully refreshed");
      List jsonList = convert.jsonDecode(value.body);

      if (currency.isEmpty) {
        if (jsonList.length > 0) {
          for (int i = 0; i < jsonList.length; i++) {
            setState(() {
              currency.add(Currency(
                  id: jsonList[i]["id"],
                  title: jsonList[i]["title"],
                  price: jsonList[i]["price"],
                  changes: jsonList[i]["changes"],
                  status: jsonList[i]["status"]));
            });
          }
        }
      }
      return value;
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    getParameters(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.bars,
              size: 30,
            ),
            const SizedBox(
              width: 16,
            ),
            Text(
              "currency exchange",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Color(0xff05028F),
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30)),
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height / 20,
              decoration: BoxDecoration(
                  color: Colors.blueGrey.shade300,
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Text("currency"),
                  Text("price"),
                  Text("changes")
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          SizedBox(
              height: MediaQuery.of(context).size.height / 2,
              child: listFutureBuilder(context)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height / 16,
              decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(30)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "last refresh  ${_time()}",
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 16,
                    width: MediaQuery.of(context).size.width / 3,
                    child: TextButton.icon(
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30))),
                            backgroundColor: MaterialStateProperty.all(
                                const Color(0xff05028F))),
                        onPressed: () {
                          currency.clear();
                          listFutureBuilder(context);
                        },
                        icon: const Icon(
                          CupertinoIcons.refresh,
                          size: 20,
                          color: Colors.white,
                        ),
                        label: Text(
                          "refresh",
                          style: Theme.of(context).textTheme.bodyLarge,
                        )),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  FutureBuilder<dynamic> listFutureBuilder(BuildContext context) {
    return FutureBuilder(
      future: getParameters(context),
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: currency.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MainItems(currency, index),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  if (index % 9 == 0) {
                    return Container();
                  } else {
                    return Container();
                  }
                },
              )
            : const Center(
                child: RefreshProgressIndicator(),
              );
      },
    );
  }
}

var datetime = DateTime.now();
String _time() {
  DateTime now = DateTime.now();
  return DateFormat("kk:mm:ss").format(now);
}

class MainItems extends StatelessWidget {
  int index;
  List<Currency> currency;
  MainItems(this.currency, this.index);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(colors: [
          Color(0xffDDDDDD).withOpacity(0.4),
          Color(0xffC7C9C8).withOpacity(0.4),
          Color(0xffDDDDDD).withOpacity(0.4)
        ]),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(currency[index].title!),
          Text(currency[index].price!),
          Text(
            currency[index].changes!,
            style: currency[index].status == "n"
                ? TextStyle(color: Colors.red)
                : TextStyle(color: Colors.green),
          )
        ],
      ),
    );
  }
}

class Other_item extends StatelessWidget {
  const Other_item({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), color: Colors.red),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              "True",
              style: Theme.of(context).textTheme.bodyLarge,
            )
          ],
        ),
      ),
    );
  }
}

void _snackbar(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg),
    backgroundColor: const Color(0xffD80303),
  ));
}
