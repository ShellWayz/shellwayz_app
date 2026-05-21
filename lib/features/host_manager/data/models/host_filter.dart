class HostFilter {
  final List<int>? tagIds;

  const HostFilter({this.tagIds});

  bool get hasTags => tagIds != null && tagIds!.isNotEmpty;
}
