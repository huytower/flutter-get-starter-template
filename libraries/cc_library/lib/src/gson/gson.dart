library gson;

import 'package:cc_library/src/gson/src/decoder.dart';
import 'package:cc_library/src/gson/src/encoder.dart';
import 'package:cc_library/src/gson/src/values.dart';

class Gson {
  /// The decoder
  GsonDecoder decoder = GsonDecoder();

  /// The encoder
  GsonEncoder encoder = GsonEncoder();

  /// The adapter to decode and encode gson
  Gson() {
    decoder = GsonDecoder();
  }

  /// Simplify converts gson results to something you can easily deal with. some of these changes can't be recreated from the results.
  /// Also in gson booleans are encoded as bytes and bytes are converted to integers in here, so instead of a true you will probably get 1 and instead of false 0
  /// The results of this method are compatible with the json src, you can encode them as json
  dynamic simplify(dynamic value) {
    if (value is Map<String, dynamic>) {
      var map = {};
      value.forEach((k, v) {
        map[k] = simplify(v);
      });
    } else if (value is List<dynamic>) {
      var list = [];
      value.forEach((v) {
        list.add(simplify(v));
      });
    } else if (value is GsonValue) {
      return value.toSimple();
    } else {
      return value;
    }
  }

  /// Encode gson
  /// ``` dart
  /// gson.encode({"hello": "world"}) // >> {hello: "world"}
  /// ```
  /// for beautier gson
  /// ``` dart
  /// gson.encode({"hello": "world"},beautify: true);
  /// // >> {
  /// // >>   hello: "world"
  /// // >> }
  /// ```
  /// You can also set the indent (the amount of spaces the gson is indented with)
  String encode(dynamic obj, {bool beautify = false, int indent = 2, jsonBooleans = false, quoteMapKeys = false}) {
    return encoder.encode(obj,
        beautify: beautify, indent: indent, jsonBooleans: jsonBooleans, quoteMapKeys: quoteMapKeys);
  }

  /// Decode gson
  /// ``` dart
  /// gson.decode("{hello: "world"}") // >> {"hello": "world"}
  /// ```
  /// if you want to have easy-usable contents set simplify to true, the simplify method will be automatically ran over your results.
  /// Simplify converts gson results to something you can easily deal with. some of these changes can't be recreated from the results.
  /// Also in gson booleans are encoded as bytes and bytes are converted to integers in here, so instead of a true you will probably get 1 and instead of false 0.
  /// The results are **just** compatible with the json src of dart if you use simplify
  /// ``` dart
  /// json.encode( gson.decode("{hello: "world"}", simplify: true) );  // >> {"hello": "world"}
  /// ```
  dynamic decode(String gson, {simplify = false}) {
    return simplify ? this.simplify(decoder.decode(gson)) : decoder.decode(gson);
  }
}

Gson _gson = Gson();

/// use `gson.encode` to encode gson and `gson.decode` to decode gson
Gson get gson => _gson;

/// Encode gson
/// ``` dart
/// gsonEncode({"hello": "world"}) // >> {hello: "world"}
/// ```
String gsonEncode(dynamic obj) {
  return gson.encode(obj);
}

/// Decode gson
/// ``` dart
/// gsonDecode("{hello: "world"}") // >> Map {"hello": "world"}
/// ```
dynamic gsonDecode(String str) {
  return gson.decode(str);
}
