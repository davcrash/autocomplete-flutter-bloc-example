part of 'autocomplete_bloc.dart';

class AutocompleteState extends Equatable {
  final String token;
  final bool isLoading;
  final bool isFailure;
  final String failureMsg;
  final List<AutocompleteResult> results;

  final int addressIndex;
  final Address addressSearched;
  final bool isFavoriteAddress;

  const AutocompleteState({
    this.token,
    this.isLoading: false,
    this.isFailure: false,
    this.failureMsg,
    this.results = const [],
    this.addressIndex = 0,
    this.addressSearched,
    this.isFavoriteAddress = false,
  });

  @override
  List<Object> get props => [
        token,
        isLoading,
        isFailure,
        failureMsg,
        results,
        addressIndex,
        addressSearched,
        isFavoriteAddress
      ];

  AutocompleteState copyWith({
    String token,
    bool isLoading,
    bool isFailure,
    String failureMsg,
    List results,
    int addressIndex,
    Address addressSearched,
    bool isFavoriteAddress,
  }) =>
      AutocompleteState(
        token: token ?? this.token,
        isLoading: isLoading ?? this.isLoading,
        isFailure: isFailure ?? this.isFailure,
        failureMsg: failureMsg ?? this.failureMsg,
        results: results ?? this.results,
        addressIndex: addressIndex ?? this.addressIndex,
        addressSearched: addressSearched ?? this.addressSearched,
        isFavoriteAddress: isFavoriteAddress ?? this.isFavoriteAddress,
      );
}
