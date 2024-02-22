import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_app1/constant/utils.dart';

Future userLogin(String email,String Password) async{
  final response=await http.post(Uri.parse('${Utils.baseUrl}/user/login'),
      headers: {"Accept":"Application/json"},
      body: {'email':email,'password':Password}
  );


  var decodedData=jsonDecode(response.body);
  return decodedData;
}


Future userRegister(String username,String email,String Password,String phone) async{
  final response=await http.post(Uri.parse('${Utils.baseUrl}/user/register'),
      headers: {"Accept":"Application/json"},
      body: {'name':username,'email':email,'password':Password,'phone':phone}
  );


  var decodedData=jsonDecode(response.body);
  return decodedData;
}