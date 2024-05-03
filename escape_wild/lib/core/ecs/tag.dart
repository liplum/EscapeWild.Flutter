import 'package:json_annotation/json_annotation.dart';

mixin TagsMixin {
  @JsonKey(includeIfNull: false)
  final Set<String> tags = {};
}

extension TagsMixinX<T extends TagsMixin> on T {
  T tagged(dynamic tag) {
    if (tag is Iterable) {
      for (final t in tag) {
        tags.add(t.toString());
      }
    } else {
      tags.add(tag.toString());
    }
    return this;
  }

  T untag(dynamic tag) {
    if (tag is Iterable) {
      for (final t in tag) {
        tags.remove(t.toString());
      }
    } else {
      tags.remove(tag.toString());
    }
    return this;
  }

  bool hasTag(String tag) => tags.contains(tag);

  bool hasTags(Iterable<String> tags) => this.tags.containsAll(tags);

  bool hasAnyTag(Iterable<String> tags) {
    for (final tag in tags) {
      if (this.tags.contains(tag)) return true;
    }
    return false;
  }
}
