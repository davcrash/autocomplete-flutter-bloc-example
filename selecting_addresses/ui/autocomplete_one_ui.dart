import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ex-package/src/models/address.dart';
import 'package:ex-package/src/modules/service_2/blocs/autocomplete/autocomplete_bloc.dart';
import 'package:ex-package/src/modules/service_2/selecting_addresses/widgets/address_textfield/address_textfield.dart';
import 'package:ex-package/src/modules/service_2/selecting_addresses/widgets/autocomplete_suggested_list.dart';
import 'package:ex-package/src/modules/service_2/selecting_addresses/widgets/recent_addresses_list.dart';
import 'package:ex-package/src/utils/widgets/snackbar_widget.dart';

class AutocompleteOneUI extends StatelessWidget {
  final Address address;
  final int index;
  final int length;

  const AutocompleteOneUI({
    Key key,
    @required this.address,
    @required this.index,
    @required this.length,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(
            (Platform.isIOS) ? Icons.arrow_back_ios : Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.of(context).pop();
            BlocProvider.of<AutocompleteBloc>(context).add(
              AutocompleteChangeIndex(1),
            );
          },
        ),
        title: AddressTextField(
          address: address,
          index: index,
          length: length,
          autofocus: true,
        ),
      ),
      body: BlocListener<AutocompleteBloc, AutocompleteState>(
        listener: (context, AutocompleteState state) {
          if (state.addressSearched != null) {
            Navigator.of(context).pop();
          } else if (state.isFailure) {
            showSnackBar(
              context,
              msg: state.failureMsg,
              type: SnackBarType.error,
            );
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              AutocompleteSuggestedList(),
            ],
          ),
        ),
      ),
    );
  }
}
