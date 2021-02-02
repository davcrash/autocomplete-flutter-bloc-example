import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import 'package:llevo/src/models/address.dart';
import 'package:llevo/src/models/marker_point_type.dart';
import 'package:llevo/src/modules/service_2/blocs/autocomplete/autocomplete_bloc.dart';
import 'package:llevo/src/modules/service_2/blocs/request_service/request_service_bloc.dart';
import 'package:llevo/src/modules/service_2/blocs/selecting_addresses/selecting_addresses_bloc.dart';

class AutocompleteTextField extends StatefulWidget {
  final Address address;
  final int index;
  final MarkerPointType markerPointType;
  final bool autofocus;

  const AutocompleteTextField({
    Key key,
    @required this.index,
    @required this.address,
    this.markerPointType,
    this.autofocus = false,
  }) : super(key: key);
  @override
  _AutocompleteTextFieldState createState() => _AutocompleteTextFieldState();
}

class _AutocompleteTextFieldState extends State<AutocompleteTextField> {
  Timer _debounce;
  final _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  LatLng userLocation;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) _controller.text = widget.address.formatted;

    userLocation = BlocProvider.of<RequestServiceBloc>(context)
        .state
        .userAddress
        ?.getLatLng();
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    _debounce?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SelectingAddressesBloc, SelectingAddressesState>(
      listener: (context, SelectingAddressesState state) {
        if (state is SelectingAddressesLoaded) {
          if (state.addressFocusIndex == widget.index)
            _focusNode.requestFocus();

          final Address addressFocused =
              state.addresses[state.addressFocusIndex];

          if (state.addressFocusIndex == widget.index &&
              addressFocused != null) {
            setTextField(addressFocused);
            emitFocusEventInTextField(state);
          }
        }
      },
      child: TextField(
        maxLines: 1,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 11.0,
            horizontal: 15.0,
          ),
        ),
        controller: _controller,
        onTap: () {
          onTap(context);
        },
        onChanged: (text) {
          _onSearchChanged(context, text);
        },
      ),
    );
  }

  onTap(context) {
    BlocProvider.of<AutocompleteBloc>(context).add(
      AutocompleteChangeIndex(widget.index),
    );
  }

  _onSearchChanged(context, String text) {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (text == "") {
        BlocProvider.of<SelectingAddressesBloc>(
          context,
        ).add(
          SelectingAddressesUpdated(
            index: widget.index,
            newAddress: null,
          ),
        );
        return;
      }

      BlocProvider.of<AutocompleteBloc>(context).add(
        AutocompleteTyping(text, userLocation),
      );
    });
  }

  void setTextField(Address addressFocused) {
    _controller.text = addressFocused.formatted;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
  }

  void emitFocusEventInTextField(SelectingAddressesLoaded state) {
    // Emit event to set the addressFocusIndex
    final indexToValidate = widget.index == 0 ? 1 : 0;
    if (state.addresses[indexToValidate] == null) {
      BlocProvider.of<AutocompleteBloc>(context).add(
        AutocompleteChangeIndex(indexToValidate),
      );
      BlocProvider.of<SelectingAddressesBloc>(
        context,
      ).add(
        SelectingAddressesGoToEditIndex(index: indexToValidate),
      );
    }
  }
}
