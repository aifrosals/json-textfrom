import 'package:json_schema_form/json_textform/models/Schema.dart';
import 'dart:convert';

String getURL(String base, String path) {
  return "$base/$path";
}

/// Will return the json like object base on the
/// schema's value and name in [schemaList].
/// For example {name: 'abc'} for textfield.
/// {'author': 1} for foreignkey field, where 1 is the id of the author.
///
Map<String, dynamic> getSubmitJSON(List<Schema> schemaList) {
  List<Map<String, dynamic>> json = schemaList
      .where((s) => !s.readOnly)
      .map((schema) => schema.onSubmit())
      .where((schema) => schema != null)
      .toList();
  var data = jsonEncode(json);
  Map<String, dynamic> ret =
  {'data' : data};
  return ret;
}
