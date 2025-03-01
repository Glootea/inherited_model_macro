import 'package:inherited_model_macro/src/dependencies.dart';
import 'package:macros/macros.dart';
import 'package:meta/meta.dart';

@internal
class InitialClassBuilder {
  final MemberDeclarationBuilder builder;
  final DeclarationDependencies dep;
  final List<FieldDeclaration> fields;
  final List<MethodDeclaration> methods;
  final List<ConstructorDeclaration> constructors;
  final String initialClassName;

  const InitialClassBuilder({
    required this.builder,
    required this.dep,
    required this.fields,
    required this.methods,
    required this.constructors,
    required this.initialClassName,
  });

  void build() {
    _checkRequirements();

    _declareClassStart();
    _declareConstructor();
    _declareUpdateFields();
    _declareUpdateShouldNotify();
    _declareUpdateShouldNotifiDependent();
    _declareUpdateFunction();
    _declareFieldWatchFunctions();
    _declareFieldReadFunctions();
    _declareInstanceOfFunction();
    _declareClassEnd();
  }

  void _declareClassStart() => builder.declareInLibrary(
      DeclarationCode.fromString("augment class $initialClassName{\n"));

  void _declareClassEnd() =>
      builder.declareInLibrary(DeclarationCode.fromString("}"));

  void _checkRequirements() {
    if (constructors.isNotEmpty) {
      "Class $initialClassName must not have constructor as it will be generated"
          .reportAsDiagnosticError(builder);
    }
    final methodNames = methods.map((e) => e.identifier.name).toSet();
    if (methodNames.contains('updateShouldNotify')) {
      "Class $initialClassName must not have updateShouldNotify method as it will be generated"
          .reportAsDiagnosticError(builder);
    }
    if (methodNames.contains('updateShouldNotifyDependent')) {
      "Class $initialClassName must not have updateShouldNotifyDependent method as it will be generated"
          .reportAsDiagnosticError(builder);
    }
    if (methodNames.contains('update')) {
      "Class $initialClassName must not have update method as it will be generated"
          .reportAsDiagnosticError(builder);
    }
    if (methodNames.contains('getInstance')) {
      "Class $initialClassName must not have getInstance method as it will be generated"
          .reportAsDiagnosticError(builder);
    }

    final fieldNames = fields.map((e) => e.identifier.name.capitalized);
    for (final fieldName in fieldNames) {
      if (methodNames.contains('read$fieldName')) {
        "Class $initialClassName must not have read$fieldName field as it will be generated"
            .reportAsDiagnosticError(builder);
      }
      if (methodNames.contains('watch$fieldName')) {
        "Class $initialClassName must not have watch$fieldName field as it will be generated"
            .reportAsDiagnosticError(builder);
      }
    }
  }

  void _declareConstructor() =>
      builder.declareInLibrary(DeclarationCode.fromParts(
        [
          '\tconst ',
          initialClassName,
          '({\n',
          ...fields.map(__constructorFieldDeclaration).expand((e) => e),
          '\t\trequired this.updateState,',
          '\n\t\trequired ',
          dep.widget,
          '\n\t\tchild,',
          dep.key,
          '? key,',
          '\n\t}) : super(child: child, key: key);\n'
        ],
      ));

  Iterable<Object> __constructorFieldDeclaration(FieldDeclaration field) => [
        '\t\trequired this.',
        field.identifier.name,
        ',\n',
      ];

  void _declareUpdateFields() =>
      builder.declareInLibrary(DeclarationCode.fromParts(
        [
          '\n',
          '\t///Use this method to update state directly on instance\n',
          '\tfinal void Function({\n',
          ...fields.map(__updateFieldFieldDeclaration).expand((e) => e),
          '\t}) updateState;\n'
        ],
      ));

  Iterable<Object> __updateFieldFieldDeclaration(FieldDeclaration field) =>
      ['\t\t', field.type.code.asNullable, " ${field.identifier.name},\n"];

  void _declareUpdateShouldNotify() =>
      builder.declareInLibrary(DeclarationCode.fromParts(
        [
          '\n',
          '\t@',
          dep.override,
          '\n\t',
          dep.boolIdentifier,
          ' updateShouldNotify($initialClassName oldWidget) =>\n',
          fields.map(__updateShouldNotifyFieldDeclaration).join(' ||\n'),
          ';\n',
        ],
      ));

  String __updateShouldNotifyFieldDeclaration(FieldDeclaration field) =>
      '\t\t${field.identifier.name} != oldWidget.${field.identifier.name}';

  void _declareUpdateShouldNotifiDependent() =>
      builder.declareInLibrary(DeclarationCode.fromParts(
        [
          '\n\t@',
          dep.override,
          '\n\t',
          dep.boolIdentifier,
          ' updateShouldNotifyDependent(\n\t\t$initialClassName oldWidget,\n\t\t',
          dep.setIdentifier,
          '<',
          dep.string,
          '>',
          ' dependencies) {\n',
          ...fields
              .map(__updateShouldNotifiDependentFieldDeclaration)
              .expand((e) => e),
          '\t\treturn false;\n',
          '\t}\n',
        ],
      ));

  Iterable<Object> __updateShouldNotifiDependentFieldDeclaration(
    FieldDeclaration field,
  ) =>
      [
        '\t\tif(',
        field.identifier.name,
        ' != ',
        'oldWidget.',
        field.identifier.name,
        ' && dependencies.contains("',
        field.identifier.name,
        '"))',
        '  return true;\n',
      ];

  void _declareUpdateFunction() =>
      builder.declareInLibrary(DeclarationCode.fromParts(
        [
          '\n\t///Use this method to find instance of class and update its state\n',
          '\tstatic void update(\n\t\t',
          dep.context,
          ' context, {\n',
          ...fields
              .map((field) => [
                    '\t\t',
                    field.type.code.asNullable,
                    ' ',
                    field.identifier.name,
                    ',\n'
                  ])
              .expand((e) => e),
          '\t}) {\n',
          '\t\tfinal model = getInstance(context);\n',
          '\t\tmodel.updateState(\n',
          ...fields.map(__updateFunctionFieldDeclaration).expand((e) => e),
          '\t\t);\n',
          '\t}\n'
        ],
      ));

  Iterable<Object> __updateFunctionFieldDeclaration(FieldDeclaration field) => [
        '\t\t\t${field.identifier.name}',
        ': ',
        field.identifier.name,
        ',\n',
      ];

  void _declareFieldWatchFunctions() =>
      builder.declareInLibrary(DeclarationCode.fromParts(fields
          .map(
            (field) => [
              '\n\t///Makes the widget listen to changes on `${field.identifier.name}` field\n',
              '\tstatic ',
              field.type.code,
              ' watch',
              field.identifier.name.capitalized,
              '(',
              dep.context,
              ' context) =>\n\t\t',
              dep.inheritedModel,
              '.inheritFrom<',
              initialClassName,
              ">(\n\t\t\tcontext,\n\t\t\taspect: '",
              field.identifier.name,
              "',\n\t\t)!.",
              field.identifier.name,
              ";\n",
            ],
          )
          .expand((e) => e)
          .toList()));

  void _declareFieldReadFunctions() =>
      builder.declareInLibrary(DeclarationCode.fromParts(fields
          .map(
            (field) => [
              '\n\t///Returns value of `${field.identifier.name}` field without listening to it\n',
              '\tstatic ',
              field.type.code,
              ' read',
              field.identifier.name.capitalized,
              '(',
              dep.context,
              ' context) =>\n\t\t',
              initialClassName,
              '.getInstance(context).${field.identifier.name}'
                  ";\n",
            ],
          )
          .expand((e) => e)
          .toList()));

  void _declareInstanceOfFunction() =>
      builder.declareInLibrary(DeclarationCode.fromParts(
        [
          '\n\tstatic ',
          initialClassName,
          ' getInstance(',
          dep.context,
          ' context) =>\n\t\t',
          'context.getInheritedWidgetOfExactType',
          '<',
          initialClassName,
          '>()!;\n',
        ],
      ));
}
