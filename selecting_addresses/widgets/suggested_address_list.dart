import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ex-package/src/modules/service_2/blocs/selecting_addresses/selecting_addresses_bloc.dart';
import 'package:ex-package/src/modules/service_2/selecting_addresses/widgets/favorite_addresses_list.dart';
import 'package:ex-package/src/modules/service_2/selecting_addresses/widgets/recent_addresses_list.dart';

import 'autocomplete_suggested_list.dart';

class SuggestedAddressList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectingAddressesBloc, SelectingAddressesState>(
      builder: (context, SelectingAddressesState state) {
        if (state is SelectingAddressesLoaded && state.addresses.length <= 2) {
          return Column(
            children: <Widget>[
              AutocompleteSuggestedList(
                isFavoriteAddress: false,
              ),
            ],
          );
        }
        return Container();
      },
    );
  }
}
