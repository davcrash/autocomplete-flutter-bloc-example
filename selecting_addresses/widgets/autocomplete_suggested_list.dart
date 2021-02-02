import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:llevo/src/models/address.dart';
import 'package:llevo/src/models/favorite_addresses.dart';

import 'package:llevo/src/modules/service_2/blocs/autocomplete/autocomplete_bloc.dart';
import 'package:llevo/src/modules/service_2/blocs/confirm_address/confirm_address_bloc.dart';
import 'package:llevo/src/modules/service_2/blocs/favorite_addresses/favorite_addresses_bloc.dart';
import 'package:llevo/src/modules/service_2/blocs/request_service/request_service_bloc.dart';
import 'package:llevo/src/modules/service_2/blocs/selecting_addresses/selecting_addresses_bloc.dart';
import 'package:llevo/src/modules/service_2/selecting_addresses/ui/confirm_favorite_address_ui.dart';

class AutocompleteSuggestedList extends StatelessWidget {
  final bool isFavoriteAddress;
  final FavoriteAddressType favoriteAddressType;
  final Address address;
  const AutocompleteSuggestedList({
    Key key,
    @required this.isFavoriteAddress,
    this.favoriteAddressType,
    this.address,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    return Stack(
      children: <Widget>[
        BlocBuilder<AutocompleteBloc, AutocompleteState>(
          builder: (context, AutocompleteState state) {
            if (state.isLoading)
              return LinearProgressIndicator(
                backgroundColor: baseTheme.primaryColor.withOpacity(.0),
              );
            return Container();
          },
        ),
        BlocBuilder<AutocompleteBloc, AutocompleteState>(
          builder: (context, AutocompleteState state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (state.results.isNotEmpty)
                  for (final result in state.results)
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1,
                            color: baseTheme.disabledColor.withOpacity(
                              .1,
                            ),
                          ),
                        ),
                      ),
                      child: ListTile(
                        onTap: () {
                          BlocProvider.of<AutocompleteBloc>(context).add(
                            AutocompleteConfirmAddress(
                              result.placeId,
                              isFavoriteAddress,
                            ),
                          );
                        },
                        leading: Icon(Icons.room),
                        title: Text(result?.mainText ?? ""),
                        subtitle: (result?.secondaryText != null)
                            ? Text(result?.secondaryText)
                            : null,
                      ),
                    ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 1,
                        color: baseTheme.disabledColor.withOpacity(
                          .1,
                        ),
                      ),
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.gps_fixed),
                    title: Text("Fijar en el mapa"),
                    onTap: () {},
                  ),
                ),
                if (state.results.isNotEmpty)
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10.0),
                    child: Image.asset(
                      'assets/images/powered_by_google_on_white.png',
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
