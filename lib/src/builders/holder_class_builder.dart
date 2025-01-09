import 'package:inherited_model_macro/src/dependencies.dart';
import 'package:macros/macros.dart';
import 'package:meta/meta.dart';

@internal
class HolderClassBuilder {
  final MemberDeclarationBuilder builder;
  final DeclarationDependencies dep;
  final List<FieldDeclaration> fields;
  final String holderType;
  final String stateClass;

  const HolderClassBuilder({
    required this.builder,
    required this.dep,
    required this.fields,
    required this.holderType,
    required this.stateClass,
  });

  Future<void> build() async {
    final code = <Object>[
      "augment class $holderType {\n",
      ..._fieldsDeclaration(),
      ..._childDeclaration(),
      ..._constructorDeclaration(),
      ..._createStateDeclaration(),
      "}\n",
    ];

    builder.declareInLibrary(DeclarationCode.fromParts(code));
  }

  Iterable<Object> _childDeclaration() => [
        "\tfinal ",
        dep.widget,
        " child;\n",
      ];

  Iterable<Object> _fieldsDeclaration() =>
      fields.map(__declareField).expand((e) => e);

  Iterable<Object> __declareField(FieldDeclaration field) => [
        "\tfinal ",
        field.type.code,
        " ",
        field.identifier.name,
        ";\n",
      ];

  Iterable<Object> _constructorDeclaration() => [
        "\n\tconst ",
        holderType,
        "({",
        ...fields.map(__declareConstructorField).expand((e) => e),
        "\n\t\trequired this.child,",
        "\n\t});\n"
      ];

  Iterable<Object> __declareConstructorField(FieldDeclaration field) =>
      ['\n\t\trequired this.${field.identifier.name},'];

  Iterable<Object> _createStateDeclaration() => [
        "\n\t@",
        dep.override,
        "\n\t",
        dep.state,
        "<",
        holderType,
        ">",
        " createState() => ",
        stateClass,
        "();\n"
      ];
}
