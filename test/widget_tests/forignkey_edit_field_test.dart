import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_schema_form/json_textform/JSONForm.dart';
import 'package:json_schema_form/json_textform/components/pages/JSONForignKeyEditField.dart';
import 'package:json_schema_form/json_textform/models/NetworkProvider.dart';

import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockHttpClient extends Mock implements Dio {}

class MockProvider extends Mock implements NetworkProvider {}

void main() {
  group("Test foreignkey", () {
    Dio httpClient = MockHttpClient();
    testWidgets("Get schema with null data", (tester) async {
      NetworkProvider provider = NetworkProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => provider,
            )
          ],
          child: MaterialApp(
            home: Material(
              child: JSONforeignKeyEditField(
                onSearch: null,
                isEdit: false,
                filled: false,
                useDialog: false,
                onFetchingforeignKeyChoices: null,
                onAddforeignKeyField: null,
                onUpdateforeignKeyField: null,
                onDeleteforeignKeyField: null,
                onFetchingSchema: (path, isEdit, id) async {
                  return SchemaValues(
                    schema: [
                      {
                        "label": "description",
                        "readonly": false,
                        "extra": {},
                        "name": "description",
                        "widget": "text",
                        "required": false,
                        "translated": false,
                        "validations": {
                          "length": {"maximum": 1024}
                        }
                      },
                    ],
                    values: null,
                  );
                },
                path: "abc",
                name: "name_id",
                onFileUpload: (String path) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("description"), findsOneWidget);
    }, skip: false);

    testWidgets("Get schema with data", (tester) async {
      NetworkProvider provider = NetworkProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => provider,
            )
          ],
          child: MaterialApp(
            home: Material(
              child: JSONforeignKeyEditField(
                isEdit: false,
                useDialog: false,
                onFetchingforeignKeyChoices: null,
                onAddforeignKeyField: null,
                filled: false,
                onSearch: null,
                onUpdateforeignKeyField: null,
                onDeleteforeignKeyField: null,
                onFetchingSchema: (path, isEdit, id) async {
                  return SchemaValues(
                    schema: [
                      {
                        "label": "description",
                        "readonly": false,
                        "extra": {},
                        "name": "description",
                        "widget": "text",
                        "required": false,
                        "translated": false,
                        "validations": {
                          "length": {"maximum": 1024}
                        }
                      },
                    ],
                    values: {
                      "description": "hello",
                    },
                  );
                },
                path: "abc",
                name: "name_id",
                onFileUpload: (String path) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("description"), findsOneWidget);
      expect(find.text("hello"), findsOneWidget);
    }, skip: false);
  }, skip: false);
}
