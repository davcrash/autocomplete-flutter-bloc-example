import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ex-package/src/modules/service_2/blocs/autocomplete/autocomplete_bloc.dart';
import 'package:ex-package/src/modules/service_2/blocs/selecting_addresses/selecting_addresses_bloc.dart';

class AddAddressButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    return Row(
      children: <Widget>[
        InkWell(
          onTap: () {
            _onPressButton(context);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "Agregar",
                style: baseTheme.textTheme.body1.copyWith(
                  color: baseTheme.disabledColor,
                ),
              ),
              Icon(
                Icons.add,
                size: 20.0,
                color: baseTheme.disabledColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onPressButton(context) {
    BlocProvider.of<SelectingAddressesBloc>(context).add(
      SelectingAddressesAdd(),
    );
    BlocProvider.of<AutocompleteBloc>(context).add(
      AutocompleteChangeIndex(1),
    );
  }
}
