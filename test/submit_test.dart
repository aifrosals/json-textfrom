import 'package:flutter_test/flutter_test.dart';
import 'package:json_schema_form/models/Schema.dart';

void main() {
  group("Submit test", () {
    test("Submit value on textfield", () {
      var testData = [
        {
          "label": "Name",
          "readonly": false,
          "extra": {},
          "name": "name",
          "widget": "text",
          "required": false,
          "translated": false,
          "validations": {}
        },
        {
          "label": "Description",
          "readonly": false,
          "extra": {},
          "name": "description",
          "widget": "text",
          "required": false,
          "translated": false,
          "validations": {}
        }
      ];
      List<Schema> ss = Schema.convertFromList(testData);
      ss.forEach((Schema data) {
        var result = data.onSubmit();
        expect(result['key'], data.name);
        expect(result['value'], data.value);
      });
    });


    test("Submit value on forignkey", () {
      var testData = [
        {
          "label": "Name",
          "readonly": false,
          "extra": {},
          "name": "name",
          "widget": "forignkey",
          "required": false,
          "translated": false,
          "validations": {}
        },
        {
          "label": "Description",
          "readonly": false,
          "extra": {},
          "name": "description",
          "widget": "forignkey",
          "required": false,
          "translated": false,
          "validations": {}
        }
      ];
      List<Schema> ss = Schema.convertFromList(testData);
      ss.forEach((Schema data) {
        var result = data.onSubmit();
        expect(result['key'], data.name);
        expect(result['value'], data.value);
      });
    });

    test("Submit value on selectionfield", () {
      var testData = [
        {
          "label": "Name",
          "readonly": false,
          "extra": {},
          "name": "name",
          "widget": "select",
          "required": false,
          "translated": false,
          "validations": {}
        },
        {
          "label": "Description",
          "readonly": false,
          "extra": {},
          "name": "description",
          "widget": "select",
          "required": false,
          "translated": false,
          "validations": {}
        }
      ];
      List<Schema> ss = Schema.convertFromList(testData);
      ss.forEach((Schema data) {
        var result = data.onSubmit();
        expect(result['key'], data.name);
        expect(result['value'], data.value);
      });
    });
  });
}
