part of 'autocomplete_bloc.dart';

abstract class AutocompleteEvent extends Equatable {
  const AutocompleteEvent();
}

class AutocompleteTyping extends AutocompleteEvent {
  final String queryText;
  final LatLng userLocation;

  const AutocompleteTyping(this.queryText, this.userLocation);

  @override
  List<Object> get props => [queryText];

  @override
  String toString() =>
      'AutocompleteTyping{queryText:$queryText,userLocation:$userLocation}';
}

class AutocompleteConfirmAddress extends AutocompleteEvent {
  final String placeId;
  final bool isFavoriteAddress;
  const AutocompleteConfirmAddress(this.placeId, this.isFavoriteAddress);

  @override
  List<Object> get props => [placeId, isFavoriteAddress];

  @override
  String toString() =>
      'AutocompleteConfirmAddress{placeId:$placeId,isFavoriteAddress:$isFavoriteAddress}';
}

class AutocompleteChangeIndex extends AutocompleteEvent {
  final int newIndex;

  const AutocompleteChangeIndex(this.newIndex);

  @override
  List<Object> get props => [newIndex];

  @override
  String toString() => 'AutocompleteChangeIndex{newIndex:$newIndex}';
}
