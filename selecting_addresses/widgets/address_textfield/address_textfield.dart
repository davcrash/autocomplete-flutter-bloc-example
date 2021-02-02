import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ex-package/src/models/address.dart';
import 'package:ex-package/src/models/marker_point_type.dart';
import 'package:ex-package/src/modules/service_2/blocs/autocomplete/autocomplete_bloc.dart';

import 'autocomplete_textfield.dart';
import '../../../marker_point_widget.dart';

class AddressTextField extends StatefulWidget {
  final Address address;
  final int index;
  final int length;
  final bool autofocus;

  const AddressTextField({
    Key key,
    @required this.address,
    @required this.index,
    @required this.length,
    this.autofocus = false,
  }) : super(key: key);

  @override
  _AddressTextFieldState createState() => _AddressTextFieldState();
}

class _AddressTextFieldState extends State<AddressTextField> {
  @override
  void initState() {
    if (widget.autofocus) {
      BlocProvider.of<AutocompleteBloc>(context).add(
        AutocompleteChangeIndex(widget.index),
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            right: 10,
          ),
          child: MarkerPointWidget(
            markerPointType: getTypeByIndexAndLength(
              widget.index,
              widget.length,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              right: 20,
            ),
            child: AutocompleteTextField(
              index: widget.index,
              address: widget.address,
              autofocus: widget.autofocus,
            ),
          ),
        ),
      ],
    );
  }
}
