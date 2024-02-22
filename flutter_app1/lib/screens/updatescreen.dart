import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class updatesscreen extends StatefulWidget {
  String userid;
  updatesscreen({Key? key, required this.userid}) : super(key: key);

  @override
  State<updatesscreen> createState() => _updatesscreenState();
}

class _updatesscreenState extends State<updatesscreen> {
  double? _avlspace;
  final url1 = "http://192.168.132.76:2500/api/normal";
  final url2 = "http://192.168.132.76:2500/api/corporate";
  final getBalanceUrl = "http://192.168.132.76:3000/getBalanceByEmail";

  var _postjson1 = [];
  var _postjson2 = [];
  var spaced;
  Future<int> _getUserBalance(String email) async {
    try {
      final response = await http.post(
        Uri.parse(getBalanceUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['balance'];
      } else if (response.statusCode == 404) {
        // User not found
        return -1;
      } else {
        // Handle other error responses
        print('Failed to get user balance. Error: ${response.statusCode}');
        return -1;
      }
    } catch (error) {
      // Handle other errors
      print('Error: $error');
      return -1;
    }
  }

  Future<void> _confirmPurchase(String email, int price ,spaced) async {
    int userBalance = await _getUserBalance(email);

    if (userBalance == -1) {
      // User not found, show an error message or take appropriate action
      print('User not found.');
      return;
    }

    if (userBalance >= price) {
      bool confirm = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Confirm Purchase'),
            content: Text('Are you sure you want to make this purchase?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // No, cancel purchase
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  // Deduct user balance and perform additional actions
                  await _deductUserBalance(email, price,spaced);
                  Navigator.of(context).pop(true); // Yes, confirm purchase
                },
                child: Text('Yes'),
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        _getAvlSpace();
        // Perform additional actions related to the purchase
        print('Purchase confirmed!');
        // Show dialog for successful purchase
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Purchase Successful'),
              content: Text('$spaced GB storage purchased'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // Perform actions if the user cancels the purchase
        print('Purchase canceled.');
      }
    } else {
      // Show a message or take action if the balance is insufficient
      print('Insufficient balance to make this purchase.');
    }
  }
  Future<void> _deductUserBalance(String email, int amount, int purchasedSpace) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.132.76:3000/deductBalance'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'amount': amount}),
      );

      if (response.statusCode == 200) {
        // Successfully deducted user balance, now update avlspace
        await _updateAvlSpace(email, purchasedSpace);
        await _getAvlSpace();
      } else {
        // Handle error response
        print('Failed to deduct user balance. Error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle other errors
      print('Error: $error');
    }
  }

  Future<void> _updateAvlSpace(String email, int purchasedSpace) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.132.76:3000/updateAvlSpace'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'purchasedSpace': purchasedSpace}),
      );

      if (response.statusCode == 200) {
        // Successfully updated avlspace in userlogin table
        final Map<String, dynamic> data = jsonDecode(response.body);
        // You can handle the response if needed
        print('avlspace updated successfully: ${data['updatedAvlSpace']}');
      } else {
        // Handle error response
        print('Failed to update avlspace. Error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle other errors
      print('Error: $error');
    }
  }






  Future<void> _getAvlSpace() async {
    final String username = widget.userid;

    if (username.isEmpty) {
      return;
    }

    final Uri apiUrl = Uri.parse('http://192.168.132.76:3000/avlspace?email=$username');

    try {
      final response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = json.decode(response.body);
        print('Avl Space Response: $data');

        if (data != null && data.containsKey('avlspace')) {
          setState(() {
            _avlspace = double.tryParse(data['avlspace'].toString());
          });
          print('Available Space: $_avlspace');
        } else {
          print('Error: Response does not contain avlspace');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }



  void fetchnorm() async {
    try {
      final response1 = await http.get(Uri.parse(url1));
      final jsondata1 = jsonDecode(response1.body) as List;
      setState(() {
        _postjson1 = jsondata1;
      });
    } catch (err) {
      print('Error fetching normal data: $err');
    }
  }

  void fetchcorp() async {
    try {
      final response2 = await http.get(Uri.parse(url2));
      final jsondata2 = jsonDecode(response2.body) as List;
      setState(() {
        _postjson2 = jsondata2;
      });
    } catch (err) {
      print('Error fetching corporate data: $err');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchnorm();
    fetchcorp();


  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("HOME"),
          bottom: TabBar(
            tabs: [
              Tab(text: "Normal User"),
              Tab(text: "Corporate User"),
            ],
          ),
        ),
        body:Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/345.jpg',
                fit: BoxFit.cover,
              ),
            ),


            TabBarView(
              children: [
                ListView.separated(
                  itemCount: _postjson1.length,
                  separatorBuilder: (context, index) {
                    return Divider(height: 4);
                  },
                  itemBuilder: (context, index) {
                    final post = _postjson1[index];
                    return ListTile(
                      title: Text("${post["space"]} GB"),
                      subtitle: Text("Storage you get"),
                      trailing: ElevatedButton(
                        onPressed: () {
                          _confirmPurchase(widget.userid, post["price"],post["space"]);
                        },
                        child: Text("${post["price"]}"),
                      ),
                    );
                  },
                ),
                ListView.separated(
                  itemCount: _postjson2.length,
                  separatorBuilder: (context, index) {
                    return Divider(height: 4);
                  },
                  itemBuilder: (context, index) {
                    final post = _postjson2[index];
                    return ListTile(
                      title: Text("${post["space"]} GB"),
                      subtitle: Text("Storage you get"),
                      trailing: ElevatedButton(
                        onPressed: () {
                          _confirmPurchase(widget.userid, post["price"],post["space"]);
                        },
                        child: Text("${post["price"]}"),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        )
      ),
    );
  }
}

