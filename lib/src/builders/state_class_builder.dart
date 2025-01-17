import 'package:inherited_model_macro/src/dependencies.dart';
import 'package:macros/macros.dart';
import 'package:meta/meta.dart';

@internal
class StateClassBuilder {
  final MemberDeclarationBuilder builder;
  final DeclarationDependencies dep;
  final List<FieldDeclaration> fields;
  final String stateClassName;
  final String initialClassName;
  final String stubName;

  const StateClassBuilder({
    required this.builder,
    required this.dep,
    required this.fields,
    required this.stateClassName,
    required this.initialClassName,
    required this.stubName,
  });

  void build() {
    _declareClassStart();
    _fieldsDeclaration();
    _initStateDeclaration();
    _updateMethodDeclaration();
    _buildMethodDeclaration();
    _declareClassEnd();
  }

  void _declareClassStart() => builder.declareInLibrary(
      DeclarationCode.fromString("augment class $stateClassName {\n"));

  void _declareClassEnd() =>
      builder.declareInLibrary(DeclarationCode.fromString("}"));

  void _fieldsDeclaration() => builder.declareInLibrary(
        DeclarationCode.fromParts(
            fields.map(__declareField).expand((e) => e).toList()),
      );

  Iterable<Object> __declareField(FieldDeclaration field) => [
        "\t late ",
        field.type.code,
        " ${field.identifier.name};\n",
      ];

  void _initStateDeclaration() =>
      builder.declareInLibrary(DeclarationCode.fromParts(
        [
          "\n\t",
          "@",
          dep.override,
          "\n\tvoid initState() {\n",
          "\t\tsuper.initState();\n",
          ...fields.map(__initStateFieldDeclaration).expand((e) => e),
          "\t}\n",
        ],
      ));

  Iterable<Object> __initStateFieldDeclaration(
    FieldDeclaration field,
  ) =>
      [
        "\t\t",
        field.identifier.name,
        " = ",
        "widget.${field.identifier.name};\n",
      ];

  void _updateMethodDeclaration() =>
      builder.declareInLibrary(DeclarationCode.fromParts(
        [
          "\n\tvoid _update({\n",
          ...fields.map(__updateMethodFieldDeclaration).expand((e) => e),
          '\t}) => \n',
          '\t\tsetState(() {\n',
          ...fields.map(__updateMethodFieldAssignDeclaration).expand((e) => e),
          '\t\t});\n',
        ],
      ));

  Iterable<Object> __updateMethodFieldDeclaration(
    FieldDeclaration field,
  ) =>
      [
        "\t\t",
        dep.object,
        "? ${field.identifier.name} = $stubName",
        ",\n",
      ];

  Iterable<Object> __updateMethodFieldAssignDeclaration(
    FieldDeclaration field,
  ) =>
      [
        "\t\t\tthis.",
        field.identifier.name,
        ' = (',
        field.identifier.name,
        ' != ',
        stubName,
        ')? ',
        field.identifier.name,
        ' as ',
        field.type.code,
        '  : this.${field.identifier.name};\n',
      ];

  void _buildMethodDeclaration() =>
      builder.declareInLibrary(DeclarationCode.fromParts(
        [
          '\n\t@',
          dep.override,
          '\n\t',
          dep.widget,
          ' build(',
          dep.context,
          ' context) =>\n\t\t',
          initialClassName,
          '(\n',
          ...fields.map(__buildMethodFieldDeclaration).expand((e) => e),
          '\t\t\tupdateState: _update,\n',
          '\t\t\tchild: widget.child,\n',
          '\t\t);\n',
        ],
      ));

  Iterable<Object> __buildMethodFieldDeclaration(FieldDeclaration field) => [
        '\t\t\t',
        field.identifier.name,
        ': ',
        field.identifier.name,
        ',\n',
      ];
}
