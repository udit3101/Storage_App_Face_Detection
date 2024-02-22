import 'package:flutter/material.dart';
import 'package:flutter_app1/screens/home_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flip_card/flip_card.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'home_page.dart';




class GetBalancePage extends StatefulWidget {

  final String userEmail;

  GetBalancePage({Key? key, required this.userEmail}) : super(key: key);

  @override
  _GetBalancePageState createState() => _GetBalancePageState();
}

class _GetBalancePageState extends State<GetBalancePage> {
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  int userBalance = 0;
  bool showBalance = false;
  String? username; // Declare username variable

  @override
  void initState() {
    super.initState();
    _getUserBalance();
    _fetchUserData(); // Call function to fetch username
  }

  Future<void> _fetchUserData() async {
    try {
      final String? fetchedUsername = await fetchUsername(widget.userEmail);
      setState(() {
        username = fetchedUsername; // Set the fetched username
      });
    } catch (e) {
      print('Error fetching username: $e');
    }
  }


  Future<String?> fetchUsername(String email) async {
    final response = await http.get(Uri.parse('http://192.168.132.76:3000/getUsername?email=$email'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['name'];
    } else {
      throw Exception('Failed to load username');
    }
  }




  Future<void> _getUserBalance() async {
    final String url = 'http://192.168.132.76:3000/getBalanceByEmail';
    final Map<String, String> headers = {'Content-Type': 'application/json'};
    final String email = widget.userEmail;

    final http.Response response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      setState(() {
        userBalance = data['balance'];
        showBalance = true;
        data['balance'];
      });
    } else {
      print('Failed to get user balance. Error: ${response.statusCode}');
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Balance'),
      ),
      body:SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,

          children: [
            Padding(padding: EdgeInsets.fromLTRB(10, 25, 10, 0),
              child: FlipCard(
                key: cardKey,
                flipOnTouch: false,
                front: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.lightBlueAccent,
                  ),
                  width: 380,
                  height: 200,
                  child:Column(

                    children: [

                     Padding(padding: EdgeInsets.only(top: 12,bottom: 6),
                     child:  Text("User Details",style: TextStyle(fontSize: 30),),
                         ),
                      Padding(padding: EdgeInsets.only(top:10),child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(
                            Icons.person,
                            size: 80,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Username: ', // Use fetched username
                                    style: TextStyle(fontSize: 26),
                                  ),
                                  Text(
                                    username ?? 'Username', // Use fetched username
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Text(
                                    'Email: ', // Use fetched username
                                    style: TextStyle(fontSize: 26),
                                  ),
                                  Text(
                                    widget.userEmail, // Use fetched username
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              ) ,



                            ],
                          ),

                        ],
                      ))
                    ],
                  )
                ),
                back:Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.red

                  ),
                  width: 400,
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Available Balance :",style: TextStyle(fontSize: 36),),
                      Padding(padding: EdgeInsets.fromLTRB(15, 8, 0, 0),
                        child:   Text("${userBalance.toStringAsFixed(2)}",style: TextStyle(fontSize: 30),)
                        ,)                      ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                cardKey.currentState?.toggleCard();
                _getUserBalance();
              },
              child: Text('Check Balance'),
            ),
            SizedBox(height: 20),

            Container(
                height: 250,
                width: 400,
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 2,
                        color: Colors.black
                    )
                ),
                child: RazorpayPage(userd: widget.userEmail,)
            )
          ],
        ),
      )
    );
  }
}



class RazorpayPage extends StatefulWidget {

   String userd;

  // Constructor to receive the user ID from the previous page
  RazorpayPage({Key? key, required this.userd}) : super(key: key);
  @override
  _RazorpayPageState createState() => _RazorpayPageState();
}

class _RazorpayPageState extends State<RazorpayPage> {
  final TextEditingController amountController = TextEditingController();
  Razorpay _razorpay = Razorpay();
  // Replace with actual user email

  @override
  void initState() {
    super.initState();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Handle successful payment
    print('Payment Successful: ${response.paymentId}');

    // Update the user's balance using the API
    _updateUserBalance(int.parse(amountController.text));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Handle payment failure
    print('Payment Error: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet usage
    print('External Wallet: ${response.walletName}');
  }

  void _updateUserBalance(int amountPaid) async {
    final String url = 'http://192.168.132.76:3000/updateBalance';
    final Map<String, String> headers = {'Content-Type': 'application/json'};

    final http.Response apiResponse = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode({'email': widget.userd, 'amountPaid': amountPaid}),
    );

    if (apiResponse.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(apiResponse.body);
      print('Balance Updated: ${data['updatedBalance']}');
    } else {
      print('Failed to update balance. Error: ${apiResponse.statusCode}');
    }
  }

  void _openRazorpay() {
    int amount = int.parse(amountController.text) * 100; // Amount in paisa

    var options = {
      'key': 'rzp_test_NeP3oUSyPpL26A', // Replace with your Razorpay key
      'amount': amount,
      'name': 'Your App Name',
      'description': 'Payment for services',
      'prefill': {'contact': '1234567890', 'email': widget.userd},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error opening Razorpay: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(

          body:
          Padding(
            padding: const EdgeInsets.all(45.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Enter Amount',

                      border: OutlineInputBorder(

                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 8,

                          ),borderRadius: BorderRadius.circular(15)
                      )),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _openRazorpay,
                  child: Text('Deposit'),
                ),
              ],
            ),
          ),


        );

  }
}



















































