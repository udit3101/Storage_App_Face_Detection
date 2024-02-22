

import 'package:flutter/material.dart';

class Form_field{
  static customtextfield(TextEditingController controller, bool tohide,
      String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: tohide,
        decoration: InputDecoration(
            hintText: text,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
            )),
      ),
    );
  }




  static liste(String data) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.green,
        ),
        height: 60,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$data",
                style: TextStyle(fontSize: 18),
              ),
              Text("I", style: TextStyle(fontSize: 18))
            ],
          ),
        ));
  }
}