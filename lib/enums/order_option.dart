enum OrderOption {
  title('Title'),

  dateModified('Date Modified'),

  dateCreated('Date Created');

  const OrderOption(this.displayName);

  final String displayName;
}