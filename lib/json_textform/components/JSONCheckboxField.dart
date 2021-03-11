import 'package:flutter/material.dart';
import '../models/Schema.dart';
import 'dart:core';

typedef void OnChange(List<dynamic> value);

class JSONCheckboxField extends StatelessWidget {
  final Schema schema;
  final OnChange onSaved;
  final bool showIcon;
  final bool isOutlined;

  JSONCheckboxField({
    @required this.schema,
    this.onSaved,
    this.showIcon = true,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {

 return
    Column(
      mainAxisSize: MainAxisSize.min,
     children :
        <Widget>[
           Align(
             alignment: Alignment.topCenter,
           child: Text(schema.label),
           ),
        ListView.builder(
        shrinkWrap: true,
        itemCount: schema.options.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return CheckboxListTile(
            value: (schema.value == null) ? false : schema.value.asMap().containsKey(index) ? schema.value[index]["optionValue"] ? true : false : false,
            onChanged: (v) {
              print('this is v');
              schema.options[index]['optionValue'] = v;
              // List<dynamic> list = data;

              onSaved(schema.options);
            },
            title: Text("${schema.options[index]['optionLabel']}"),
          );
        }),
   ],
    );

  }
}
