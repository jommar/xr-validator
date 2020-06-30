import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:xr_approval/components/UermWidgets.dart';
import 'package:xr_approval/models/ValidatorProvider.dart';

class IndexScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Result Validation'),
      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              child: Text(
                'UERM Apps',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headline5
                    .copyWith(color: Colors.white),
              ),
              decoration: BoxDecoration(color: Colors.blue[700]),
            ),
            ListTile(
              onTap: () {},
              leading: Icon(FontAwesomeIcons.globe),
              title: Text('UERM Web Apps'),
            ),
          ],
        ),
      ),
      body: FutureBuilder(
        future: Provider.of<ValidatorProvider>(context, listen: false)
            .populateForValidation(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
            case ConnectionState.waiting:
            case ConnectionState.none:
              return LoadingWidget();
            default:
              return ForValidation();
          }
        },
      ),
    );
  }
}

class ForValidation extends StatelessWidget {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  _populateForValidation({BuildContext context}) async {
    await Provider.of<ValidatorProvider>(context, listen: false)
        .refreshForValidation();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final List forValidation =
        Provider.of<ValidatorProvider>(context).forValidation;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (forValidation.length < 1) {
          return SmartRefresher(
            controller: _refreshController,
            onRefresh: () {
              _populateForValidation(context: context);
            },
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No radiology record for validation available.',
                    style: Theme.of(context).textTheme.headline4,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  RaisedButton.icon(
                    onPressed: () {
                      _populateForValidation(context: context);
                    },
                    icon: Icon(FontAwesomeIcons.syncAlt),
                    label: Text('Reload'),
                  )
                ],
              ),
            ),
          );
        }
        return SmartRefresher(
          controller: _refreshController,
          onRefresh: () {
            _populateForValidation(context: context);
          },
          child: ListView.builder(
            itemCount: forValidation.length,
            itemBuilder: (context, index) {
              return AdaptiveContainer(
                child: ValidationItem(item: forValidation[index]),
              );
            },
          ),
        );
      },
    );
  }
}

class ValidationItem extends StatefulWidget {
  final Map item;
  ValidationItem({this.item});

  @override
  _ValidationItemState createState() => _ValidationItemState();
}

class _ValidationItemState extends State<ValidationItem> {
  bool _isDetailsShown = false;
  bool _promptValidate = true;
  Future<void> _validateXrRecord({
    int id,
    BuildContext context,
    GlobalKey<FormBuilderState> formKey,
  }) async {
    if (formKey.currentState.saveAndValidate()) {
      Scaffold.of(context).hideCurrentSnackBar();
      Map form = {
        ...{'id': id},
        ...formKey.currentState.value,
      };
      if (_promptValidate) {
        Scaffold.of(context).showSnackBar(SnackBar(
          backgroundColor: Theme.of(context).primaryColorDark,
          content: Text(
            'Please click on validate again to continue.',
            textAlign: TextAlign.center,
          ),
        ));
        setState(() {
          _promptValidate = false;
        });
        return;
      }
      setState(() {
        _promptValidate = true;
      });

      final response =
          await Provider.of<ValidatorProvider>(context, listen: false)
              .validateXr(form: form);

      if (response['error'] != null) {
        Scaffold.of(context).showSnackBar(SnackBar(
          backgroundColor: Theme.of(context).errorColor,
          content: Text(
            response['message'],
            textAlign: TextAlign.center,
          ),
        ));
        return;
      }

      Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          response['message'],
          textAlign: TextAlign.center,
        ),
      ));
      setState(() {
        _promptValidate = true;
        _isDetailsShown = false;
      });

      print(response);
    }
    return;
    Scaffold.of(context).hideCurrentSnackBar();
    if (_promptValidate) {
      Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        content: Text(
          'Please click on validate again to continue.',
          textAlign: TextAlign.center,
        ),
      ));
      setState(() {
        _promptValidate = false;
        _isDetailsShown = false;
      });
      return;
    }

    // final response = await Provider.of<XrProvider>(context, listen: false)
    //     .validateXr(id: id);

    // if (response['error'] != null) {
    //   Scaffold.of(context).showSnackBar(SnackBar(
    //     backgroundColor: Theme.of(context).errorColor,
    //     content: Text(
    //       response['error'],
    //       textAlign: TextAlign.center,
    //     ),
    //   ));
    //   setState(() {
    //     _promptValidate = true;
    //   });
    //   return;
    // }

    // Scaffold.of(context).showSnackBar(SnackBar(
    //   backgroundColor: Colors.green,
    //   content: Text(
    //     response['success'],
    //     textAlign: TextAlign.center,
    //   ),
    // ));
    // setState(() {
    //   _isDetailsShown = false;
    //   _promptValidate = true;
    // });
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          onTap: () {},
          title: Text(widget.item['patientName']),
          subtitle: Text(widget.item['diagnosis']),
          leading: CircleAvatar(
            child: IconButton(
              iconSize: 20,
              onPressed: () {
                setState(() {
                  _isDetailsShown = !_isDetailsShown;
                });
              },
              icon: _isDetailsShown
                  ? Icon(FontAwesomeIcons.solidEyeSlash)
                  : Icon(FontAwesomeIcons.solidEye),
            ),
          ),
        ),
        if (_isDetailsShown)
          Container(
            // padding: EdgeInsets.all(20),
            // color: Colors.blue[50],
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SingleChildScrollView(
                  child: FormBuilder(
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
                            // print(widget.item);
                            // return;
                            _validateXrRecord(
                              formKey: _formKey,
                              id: widget.item['id'],
                              // xrData: widget.item,
                              context: context,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
