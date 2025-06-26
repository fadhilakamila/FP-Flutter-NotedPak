enum OrderOption {
  dateModified,
  dateCreated, title;

  String get name {
    return switch (this) {
      OrderOption.dateModified => 'Modified Date',
      OrderOption.dateCreated => 'Created Date',
      OrderOption.title => throw UnimplementedError(),
    };
  }
}
