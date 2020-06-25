import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:xr_approval/components/UermWidgets.dart';
import 'package:xr_approval/models/XrProvider.dart';

class IndexScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Radiology Validation'),
      ),
      body: FutureBuilder(
        future: Provider.of<XrProvider>(context, listen: false)
            .populateForValidation(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
            case ConnectionState.waiting:
            case ConnectionState.none:
              return LoadingWidget();
            default:
              return AdaptiveContainer(child: ForValidation());
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
    await Provider.of<XrProvider>(context, listen: false)
        .refreshForValidation();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final List forValidation = Provider.of<XrProvider>(context).forValidation;
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
              return ValidationItem(item: forValidation[index]);
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
  bool _promptDelete = true;
  Future<void> _validateXrRecord({Map xrData, BuildContext context}) async {
    Scaffold.of(context).hideCurrentSnackBar();
    if (_promptDelete) {
      Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        content: Text(
          'Please click on validate again to continue.',
          textAlign: TextAlign.center,
        ),
      ));
      setState(() {
        _promptDelete = false;
      });
      return;
    }

    final response = await Provider.of<XrProvider>(context, listen: false)
        .validateXr(id: xrData['id']);

    if (response['error'] != null) {
      Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).errorColor,
        content: Text(
          response['error'],
          textAlign: TextAlign.center,
        ),
      ));
      setState(() {
        _promptDelete = true;
      });
      return;
    }

    Scaffold.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.green,
      content: Text(
        response['success'],
        textAlign: TextAlign.center,
      ),
    ));
    setState(() {
      _isDetailsShown = false;
      _promptDelete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
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
            height: MediaQuery.of(context).size.height * .35,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(widget.item['result']),
                      SizedBox(
                        height: 20,
                      ),
                      RaisedButton.icon(
                        icon: Icon(FontAwesomeIcons.save),
                        label: Text('Validate'),
                        onPressed: () {
                          _validateXrRecord(
                            xrData: widget.item,
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
      ],
    );
  }
}
