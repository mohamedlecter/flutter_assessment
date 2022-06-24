import 'dart:convert';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jiffy/jiffy.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List contactList = [];
  List _displayList = [];
  bool isTimeAgo = true;
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      Future.microtask(() async {
        SharedPreferences storage = await SharedPreferences.getInstance();
        setState(() {
          isTimeAgo = storage.getBool('timeAgo') == null
              ? true
              : storage.getBool('timeAgo')!;
          isLoading = false;
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(7),
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    ),
                  )
                : ToggleButtons(
                    fillColor: Colors.white,
                    borderColor: Colors.white,
                    selectedColor: Colors.indigo,
                    borderRadius: BorderRadius.circular(30),
                    isSelected: [isTimeAgo],
                    onPressed: (e) async {
                      setState(() {
                        isTimeAgo = !isTimeAgo;
                      });
                      SharedPreferences storage =
                          await SharedPreferences.getInstance();
                      await storage.setBool('timeAgo', isTimeAgo);
                      // ignore: avoid_print
                      print(isTimeAgo);
                    },
                    children: const [
                      Text('Time Ago'),
                    ],
                  ),
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder(
          future: rootBundle.loadString('data/contact_list.json'),
          builder: (contxt, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data != null) {
                if (contactList.isEmpty) {
                  contactList = json.decode(snapshot.data.toString());
                }
                contactList!.sort((b, a) {
                  return (a['check-in']).compareTo(b['check-in']);
                });
                // sortList(contactList);
                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      for (int x = 0; x < 5; x++) {
                        contactList.add(
                          json.decode(
                            '''{
                                "user": "${faker.person.name()}",
                                "phone": "${faker.phoneNumber.random.fromPattern([
                                  '01########'
                                ])}",
                                "check-in": "${faker.date.dateTime(minYear: 2019, maxYear: 2022)}"
                              }''',
                          ),
                        );
                      }
                      // ignore: avoid_print
                      print(contactList);
                    });
                    // ignore: prefer_const_constructors
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text(
                        'Page Refreshed',
                        textAlign: TextAlign.center,
                      ),
                    ));
                  },
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: contactList.length + 1,
                    itemBuilder: (context, index) {
                      // if the list reached the end
                      if (index == contactList.length) {
                        // ignore: prefer_const_constructors
                        return Center(
                          // ignore: prefer_const_constructors
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: const Text(
                              ' You have reached the end of the list ',
                            ),
                          ),
                        );
                      }
                      var contact = contactList[index];
                      DateTime time = DateTime.parse(contact['check-in']);
                      return ListTile(
                        leading: IconButton(
                          icon: const Icon(
                            Icons.share,
                            color: Colors.teal,
                          ),
                          onPressed: () {
                            Share.share(contact[snapshot].toString());
                          },
                        ),
                        title: Text(contact['user']),
                        subtitle: Text(contact['phone']),
                        trailing: Text(
                          isTimeAgo ? Jiffy(time).fromNow() : time.toString(),
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            }
            return const Text("You dont have any contacts");
          },
        ),
      ),
    );
  }
}
