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

  void build() {
    _declareClassStart();
    _declareFields();
    _declareChild();
    _declareConstructor();
    _declareCreateState();
    _declareClassEnd();
  }

  void _declareClassStart() => builder.declareInLibrary(
      DeclarationCode.fromString("augment class $holderType {"));

  void _declareClassEnd() =>
      builder.declareInLibrary(DeclarationCode.fromString("}"));

  void _declareChild() => builder.declareInLibrary(DeclarationCode.fromParts([
        "\tfinal ",
        dep.widget,
        " child;",
      ]));

  void _declareFields() => builder.declareInLibrary(DeclarationCode.fromParts(
      fields.map(__declareField).expand((e) => e).toList()));

  Iterable<Object> __declareField(FieldDeclaration field) => [
        "\tfinal ",
        field.type.code,
        " ",
        field.identifier.name,
        ";\n",
      ];

  void _declareConstructor() =>
      builder.declareInLibrary(DeclarationCode.fromParts([
        "\n\tconst ",
        holderType,
        "({",
        ...fields.map(__declareConstructorField).expand((e) => e),
        "\n\t\trequired this.child,",
        "\n\t});"
      ]));

  Iterable<Object> __declareConstructorField(FieldDeclaration field) =>
      ['\n\t\trequired this.${field.identifier.name},'];

  void _declareCreateState() =>
      builder.declareInLibrary(DeclarationCode.fromParts([
        "\n\t@",
        dep.override,
        "\n\t",
        dep.state,
        "<",
        holderType,
        ">",
        " createState() => ",
        stateClass,
        "();"
      ]));
}
