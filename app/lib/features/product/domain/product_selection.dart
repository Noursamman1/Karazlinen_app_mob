class ProductSelectionState {
  const ProductSelectionState({
    this.selectedValues = const <String, String>{},
  });

  final Map<String, String> selectedValues;

  ProductSelectionState select(String code, String value) {
    return ProductSelectionState(
      selectedValues: <String, String>{
        ...selectedValues,
        code: value,
      },
    );
  }
}
