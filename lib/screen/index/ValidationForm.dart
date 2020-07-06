import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:xr_approval/models/ValidatorProvider.dart';

class ValidationContainer extends StatelessWidget {
  final item;
  ValidationContainer({this.item});

  bool _isDetailsShown = true;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          onTap: () {},
          title: Text(item['patientName']),
          subtitle: Text(item['diagnosis']),
          leading: CircleAvatar(
            child: IconButton(
              iconSize: 20,
              onPressed: () {
                // setState(() {
                //   _isDetailsShown = !_isDetailsShown;
                // });
              },
              icon: _isDetailsShown
                  ? Icon(FontAwesomeIcons.solidEyeSlash)
                  : Icon(FontAwesomeIcons.solidEye),
            ),
          ),
        ),
        if (_isDetailsShown)
          Container(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SingleChildScrollView(
                  child: ValidationForm(item: item),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class ValidationForm extends StatefulWidget {
  final item;
  const ValidationForm({this.item});

  @override
  _ValidationFormState createState() => _ValidationFormState();
}

class _ValidationFormState extends State<ValidationForm> {
  GlobalKey<FormBuilderState> _formKey;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _formKey = GlobalKey<FormBuilderState>();
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Text(widget.item['result']),
          FormBuilderTextField(
            attribute: 'result',
            keyboardType: TextInputType.multiline,
            minLines: 4,
            maxLines: 10,
            initialValue: widget.item['result'],
          ),
          SizedBox(
            height: 20,
          ),
          RaisedButton.icon(
            icon: Icon(FontAwesomeIcons.save),
            label: Text('Save and Validate'),
            onPressed: () {
              // _validateXrRecord(
              //   formKey: _formKey,
              //   id: item['id'],
              //   context: context,
              // );
            },
          ),
        ],
      ),
    );
  }
}
