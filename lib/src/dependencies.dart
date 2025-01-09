import 'package:macros/macros.dart';
import 'package:meta/meta.dart';

@internal
class TypeDependencies {
  final Identifier statefulWidget;
  final Identifier state;
  final Identifier inheritedModel;
  final Identifier string;

  const TypeDependencies._({
    required this.statefulWidget,
    required this.state,
    required this.inheritedModel,
    required this.string,
  });

  static Future<TypeDependencies> getDependencies(
      TypePhaseIntrospector builder) async {
    final widgetsLibrary =
        Uri.parse('package:flutter/src/widgets/framework.dart');
    final inheritedModelLibrary =
        Uri.parse('package:flutter/src/widgets/inherited_model.dart');
    final dartCoreLibrary = Uri.parse('dart:core');

    final (statefulWidgetI, stateI, stringI, inheritedModelI) = await (
      builder.resolveIdentifier(widgetsLibrary, 'StatefulWidget'),
      builder.resolveIdentifier(widgetsLibrary, 'State'),
      builder.resolveIdentifier(dartCoreLibrary, 'String'),
      builder.resolveIdentifier(inheritedModelLibrary, 'InheritedModel'),
    ).wait;
    return TypeDependencies._(
      statefulWidget: statefulWidgetI,
      state: stateI,
      string: stringI,
      inheritedModel: inheritedModelI,
    );
  }
}

@internal
class DeclarationDependencies {
  final Identifier statefulWidget;
  final Identifier state;
  final Identifier widget;
  final Identifier context;
  final Identifier inheritedModel;
  final Identifier key;
  final Identifier string;
  final Identifier boolIdentifier;
  final Identifier setIdentifier;
  final Identifier override;
  final Identifier object;

  const DeclarationDependencies._({
    required this.statefulWidget,
    required this.state,
    required this.widget,
    required this.context,
    required this.inheritedModel,
    required this.key,
    required this.string,
    required this.boolIdentifier,
    required this.setIdentifier,
    required this.override,
    required this.object,
  });

  static Future<DeclarationDependencies> getDependencies(
      TypePhaseIntrospector builder) async {
    final widgetsLibrary =
        Uri.parse('package:flutter/src/widgets/framework.dart');
    final inheritedModelLibrary =
        Uri.parse('package:flutter/src/widgets/inherited_model.dart');
    final dartCoreLibrary = Uri.parse('dart:core');
    final keyLibrary = Uri.parse('package:flutter/src/foundation/key.dart');

    final (statefulWidgetI, stateI, widgetI, contextI) = await (
      builder.resolveIdentifier(widgetsLibrary, 'StatefulWidget'),
      builder.resolveIdentifier(widgetsLibrary, 'State'),
      builder.resolveIdentifier(widgetsLibrary, 'Widget'),
      builder.resolveIdentifier(widgetsLibrary, 'BuildContext'),
    ).wait;

    final (stringI, boolI, overrideI, setIdentifierI, objectI) = await (
      builder.resolveIdentifier(dartCoreLibrary, 'String'),
      builder.resolveIdentifier(dartCoreLibrary, 'bool'),
      builder.resolveIdentifier(dartCoreLibrary, 'override'),
      builder.resolveIdentifier(dartCoreLibrary, 'Set'),
      builder.resolveIdentifier(dartCoreLibrary, 'Object'),
    ).wait;

    final (inheritedModelI, keyI) = await (
      builder.resolveIdentifier(inheritedModelLibrary, 'InheritedModel'),
      builder.resolveIdentifier(keyLibrary, 'Key')
    ).wait;

    return DeclarationDependencies._(
      statefulWidget: statefulWidgetI,
      state: stateI,
      widget: widgetI,
      context: contextI,
      inheritedModel: inheritedModelI,
      key: keyI,
      string: stringI,
      boolIdentifier: boolI,
      setIdentifier: setIdentifierI,
      override: overrideI,
      object: objectI,
    );
  }
}

extension StringCasingExtension on String {
  String get capitalized =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : '';

  String get lower =>
      length > 0 ? '${this[0].toLowerCase()}${substring(1)}' : '';

  void reportAsDiagnosticError(Builder builder) =>
      builder.report(Diagnostic(DiagnosticMessage(this), Severity.error));
}
