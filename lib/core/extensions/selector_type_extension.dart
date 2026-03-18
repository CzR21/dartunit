import '../enums/selector_type.dart';
import 'package:yaml/yaml.dart';
import '../selector/class_selector.dart';
import '../selector/file_selector.dart';
import '../selector/layer_selector.dart';
import '../entities/selector.dart' show Selector;

extension SelectorTypeBuilder on SelectorType {

  /// Constructs the [Selector] corresponding to this type using [where] filters.
  Selector build(YamlMap? where) => switch (this) {
    SelectorType.classSelector => ClassSelector(
      folder: where?['folder'] as String?,
      namePattern: where?['namePattern'] as String?,
      annotatedWith: where?['annotatedWith'] as String?,
      extendsType: where?['extends'] as String?,
      implementsType: where?['implements'] as String?,
      excludeNames: (where?['excludeNames'] as YamlList?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    ),
    SelectorType.file => FileSelector(
      folder: where?['folder'] as String?,
      namePattern: where?['namePattern'] as String?,
    ),
    SelectorType.layer => LayerSelector(
      layerName: where?['name'] as String? ?? '',
      layerFolder: where?['folder'] as String? ?? '',
    ),
  };
}