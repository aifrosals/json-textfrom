import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:json_schema_form/json_textform/components/JSONCheckboxField.dart';
import 'package:json_schema_form/json_textform/components/JSONDateTimeField.dart';
import 'package:json_schema_form/json_textform/components/JSONFileField.dart';
import 'package:json_schema_form/json_textform/components/JSONForeignkeyField.dart';
import 'package:json_schema_form/json_textform/components/JSONManyToManyField.dart';
import 'package:json_schema_form/json_textform/components/JSONSelectField.dart';
import 'package:json_schema_form/json_textform/components/JSONTextFormField.dart';
import 'package:json_schema_form/json_textform/models/components/Action.dart';
import 'package:json_schema_form/json_textform/models/Controller.dart';
import 'package:json_schema_form/json_textform/models/Schema.dart';
import 'package:json_schema_form/json_textform/utils.dart';

import 'models/components/AvaliableWidgetTypes.dart';
import 'models/components/Icon.dart';

/// A schema values which represents both schema and its values.
class SchemaValues {
  /// schema data.
  List<Map<String, dynamic>> schema;

  /// schema's value
  Map<String, dynamic> values;

  SchemaValues({@required this.schema, @required this.values});
}

typedef Future<List<Choice>> OnSearch(String path, String keyword);

/// Will be called when user clicks submit button or uses controller to submit
typedef Future OnSubmit(Map<String, dynamic> json);

/// Fetch schema based on the [path] and [id].
/// If this function has been called when user want to edit a foreignkey's value,
/// then [isEdit] will be true and id will be provided. Otherwise, id will be null.
///
/// This function should return a [schemaValues] which includes both schema and its value.
typedef Future<SchemaValues> OnFetchingSchema(
    String path, bool isEdit, dynamic id);

/// Fetch list of foreignkey's selections based on the [path].
/// This will be called when user want to select a foreignkey(s).
typedef Future<List<Choice>> OnFetchforeignKeyChoices(String path);

/// This function will be called when user wants
/// to update a foreign key's value based on the [path].
///
/// [values] and [id] will be provided for you so that you can use them
/// to do something like making an api request.
typedef Future<Choice> OnUpdateforeignKeyField(
    String path, Map<String, dynamic> values, dynamic id);

/// This function will be called when user wants to add a foreignkey.
/// The [values] and [path] will be provided so that you can use them
/// to make a api request.
typedef Future<Choice> OnAddforeignKeyField(
    String path, Map<String, dynamic> values);

/// Delete a foreignkey based on the [path] and [id]
typedef Future<Choice> OnDeleteforeignKeyField(String path, dynamic id);

/// Open a file based on the platform.
///
/// For example, use [FilePicker] to pick a file on mobile platform
typedef Future<File> OnFileUpload(String path);

/// A JSON Schema Form Widget
/// Which will take a schema input
/// and generate a form
class JSONForm extends StatefulWidget {
  final bool filled;
  final bool showSubmitButton;
  final bool useRadioButton;

  final OnSearch onSearch;

  /// Fetching foreignkey's schema
  final OnFetchingSchema onFetchingSchema;

  final OnFetchforeignKeyChoices onFetchforeignKeyChoices;

  final OnUpdateforeignKeyField onUpdateforeignKeyField;

  final OnAddforeignKeyField onAddforeignKeyField;

  final OnFileUpload onFileUpload;

  final OnDeleteforeignKeyField onDeleteforeignKeyField;

  final bool useDialog;

  /// [optional] Schema controller.
  /// Call this to get value back from fields if you want to have
  /// your custom submit button.
  final JSONSchemaController controller;

  /// Schema's name
  /// Use this to identify the actions and icons
  /// if foreignkey text field has the same name as the home screen's field.
  /// Default is null
  final String schemaName;

  /// Schema you want to have. This is a JSON object
  /// Using dart's map data structure
  final List<Map<String, dynamic>> schema;

  /// List of actions. Each field will only have one action.
  /// If not, the last one will replace the first one.
  final List<FieldAction> actions;

  /// List of icons. Each field will only have one icon.
  /// If not, the last one will replace the first one.
  final List<FieldIcon> icons;

  /// Default values for each field
  final Map<String, dynamic> values;

  /// Will call this function after user
  /// clicked the submit button
  final OnSubmit onSubmit;

  /// Round corner of text field
  final bool rounded;

  /// Whether use dropdown button instead of using
  /// another page to show choices.
  /// This will only apply for the select field,
  /// but not foreign key field based on current
  /// implementation. Default is false
  final bool useDropdownButton;

  JSONForm({
    @required this.schema,
    @required this.onSearch,
    this.filled = false,
    this.onSubmit,
    this.icons,
    this.actions,
    this.values,
    this.rounded = false,
    this.schemaName,
    this.controller,
    this.showSubmitButton = false,
    this.useDropdownButton,
    this.useRadioButton,
    @required this.useDialog,
    @required this.onDeleteforeignKeyField,
    @required this.onFileUpload,
    @required this.onFetchingSchema,
    @required this.onFetchforeignKeyChoices,
    @required this.onAddforeignKeyField,
    @required this.onUpdateforeignKeyField,
  });

  @override
  _JSONSchemaFormState createState() => _JSONSchemaFormState();
}

class _JSONSchemaFormState extends State<JSONForm> {
  final _formKey = GlobalKey<FormState>();
  List<Schema> schemaList = [];
  _JSONSchemaFormState();

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(JSONForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool schemaEquals =
        jsonEncode(widget.schema) == jsonEncode(oldWidget.schema);
    bool valueEquals =
        jsonEncode(widget.values) == jsonEncode(oldWidget.values);

    if (!schemaEquals || !valueEquals) {
      this.schemaList = _init();
    }
  }

  List<Schema> _init() {
    schemaList = Schema.convertFromList(widget.schema);

    /// Merge actions
    if (widget.actions != null) {
      // if (Platform.isIOS || Platform.isAndroid) {
      //   PermissionHandler()
      //       .requestPermissions([PermissionGroup.camera]).then((m) => null);
      // }

      schemaList =
          FieldAction().merge(schemaList, widget.actions, widget.schemaName);
    }

    /// Merge icons
    if (widget.icons != null) {
      schemaList =
          FieldIcon().merge(schemaList, widget.icons, widget.schemaName);
    }

    /// Merge values
    if (widget.values != null) {
      schemaList = Schema.mergeValues(schemaList, widget.values);
    }
    if (widget.controller != null) {
      widget.controller.onSubmit = this.onPressSubmitButton;
    }

    return schemaList;
  }

  /// Render body widget based on widget type
  Widget _buildBody(Schema schema) {
    switch (schema.widget) {
      case WidgetType.datetime:
        return JSONDateTimeField(
          filled: widget.filled,
          key: Key(schema.name),
          schema: schema,
          isOutlined: widget.rounded,
          onSaved: (String value) {
            setState(() {
              schema.value = value;
            });
          },
        );
      case WidgetType.simpleText :
        return Text(schema.label);
      case WidgetType.checkbox:
        return JSONCheckboxField(
          schema: schema,
          isOutlined: widget.rounded,
          onSaved: (v) {
            setState(() {
              schema.value = v;
            });
          },
        );
      case WidgetType.select:
        return JSONSelectField(
          useRadioButton: widget.useRadioButton,
          useDialog: widget.useDialog,
          filled: widget.filled,
          isOutlined: widget.rounded,
          schema: schema,
          useDropdownButton: widget.useDropdownButton,
          onSaved: (Choice value) {
            setState(() {
              schema.value = value.value;
              schema.choice = value;
            });
          },
        );
      case WidgetType.manytomanyLists:
        return JSONManyToManyField(
          onSearch: widget.onSearch,
          schema: schema,
          filled: widget.filled,
          useDialog: widget.useDialog,
          isOutlined: widget.rounded,
          onAddforeignKeyField: widget.onAddforeignKeyField,
          onUpdateforeignKeyField: widget.onUpdateforeignKeyField,
          onFetchingforeignKeyChoices: widget.onFetchforeignKeyChoices,
          onDeleteforeignKeyField: widget.onDeleteforeignKeyField,
          onFetchingSchema: widget.onFetchingSchema,
          onFileUpload: widget.onFileUpload,
          icons: widget.icons,
          actions: widget.actions,
          onSaved: (choices) {
            setState(() {
              schema.value = choices.map((e) => e.value).toList();
              schema.choices = choices;
            });
          },
        );

      case WidgetType.foreignkey:
        return JSONForeignkeyField(
          onSearch: widget.onSearch,
          filled: widget.filled,
          useDialog: widget.useDialog,
          onAddforeignKeyField: widget.onAddforeignKeyField,
          onUpdateforeignKeyField: widget.onUpdateforeignKeyField,
          onDeleteforeignKeyField: widget.onDeleteforeignKeyField,
          onFetchingforeignKeyChoices: widget.onFetchforeignKeyChoices,
          onFetchingSchema: widget.onFetchingSchema,
          onFileUpload: widget.onFileUpload,
          isOutlined: widget.rounded,
          schema: schema,
          actions: widget.actions,
          icons: widget.icons,
          onSaved: (Choice value) {
            setState(() {
              schema.value = value.value;
              schema.choice = value;
            });
          },
        );

      case WidgetType.file:
        return JSONFileField(
          schema: schema,
          isOutlined: widget.rounded,
          filled: widget.filled,
          onFileUpload: widget.onFileUpload,
          onSaved: (value) {
            setState(() {
              schema.value = value;
            });
          },
        );

      case WidgetType.text:
      case WidgetType.number:
      case WidgetType.unknown:
      case WidgetType.url:
        return JSONTextFormField(
          key: Key(schema.name),
          schema: schema,
          isOutlined: widget.rounded,
          filled: widget.filled,
          onSaved: (String value) {
            setState(() {
              schema.value = value;
            });
          },
        );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              for (var schema in schemaList)
                schema.readOnly || schema.widget == WidgetType.unknown
                    ? Container()
                    : _buildBody(schema),
              widget.showSubmitButton
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 10),
                          child: Container(
                            width: 300,
                            height: 40,
                            child: RaisedButton(
                              color: Theme.of(context).buttonColor,
                              child: Text(
                                "Submit",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .primaryTextTheme
                                        .headline6
                                        .color),
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      new BorderRadius.circular(30.0)),
                              onPressed: () async {
                                await onPressSubmitButton(context);
                              },
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> onPressSubmitButton(
      [BuildContext context]) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      // hide keyboard
      if (context != null) {
        FocusScope.of(context).requestFocus(FocusNode());
      }
      Map<String, dynamic> ret = getSubmitJSON(schemaList);
      // call on submit function
      if (widget.onSubmit != null) {
        await widget.onSubmit(ret);
      }
      // clear the content
      _formKey.currentState.reset();
      return ret;
    } else {
      print("Form is not vaild");
      return {};
    }
  }
}
