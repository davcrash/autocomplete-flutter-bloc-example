import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ex-package/src/models/address.dart';
import 'package:ex-package/src/models/marker_point_type.dart';
import 'package:ex-package/src/modules/service_2/blocs/autocomplete/autocomplete_bloc.dart';
import 'package:ex-package/src/modules/service_2/blocs/confirm_address/confirm_address_bloc.dart';
import 'package:ex-package/src/modules/service_2/blocs/recent_addresses/bloc.dart';
import 'package:ex-package/src/modules/service_2/blocs/request_service/request_service_bloc.dart';
import 'package:ex-package/src/modules/service_2/blocs/selecting_addresses/selecting_addresses_bloc.dart';
import 'package:ex-package/src/modules/service_2/selecting_addresses/ui/autocomplete_one_ui.dart';

import '../../../marker_point_widget.dart';

class AddressButton extends StatelessWidget {
  final Address address;
  final int index;
  final int length;

  const AddressButton({
    Key key,
    @required this.address,
    this.index,
    this.length,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 10.0,
          ),
          child: MarkerPointWidget(
            markerPointType: getTypeByIndexAndLength(
              index,
              length,
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              BlocProvider.of<AutocompleteBloc>(context).add(
                AutocompleteChangeIndex(index),
              );
              goToAutoCompleteOneAddress(context);
            },
            child: Container(
              padding: const EdgeInsets.only(
                top: 9.0,
                bottom: 11.0,
                left: 14.0,
                right: 14.0,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: baseTheme.disabledColor,
                ),
                borderRadius: BorderRadius.circular(7.0),
              ),
              child: Text(
                address?.formatted ?? "",
                style: baseTheme.textTheme.subhead,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: InkWell(
            onTap: () {
              //CODE
            },
            child: Container(
              width: 40,
              height: 40,
              child: Icon(
                Icons.close,
                color: baseTheme.disabledColor,
                size: 20.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void goToAutoCompleteOneAddress(context) {
    //ignore: close_sinks
    final autocompleteBloc = BlocProvider.of<AutocompleteBloc>(
      context,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<AutocompleteBloc>.value(
                value: autocompleteBloc,
              ),
              //Others Providers
            ],
            child: AutocompleteOneUI(
              address: address,
              index: index,
              length: length,
            ),
          );
        },
      ),
    );
  }
}
