import 'dart:async';
import 'package:inherited_model_macro/src/builders/holder_class_builder.dart';
import 'package:inherited_model_macro/src/builders/initial_class_builder.dart';
import 'package:inherited_model_macro/src/builders/state_class_builder.dart';
import 'package:inherited_model_macro/src/dependencies.dart';
import 'package:macros/macros.dart';

/// Macro that generate boilerplate code for `InheritedModel`
macro class InheritedModelMacro implements ClassTypesMacro, ClassDeclarationsMacro {
/// ## Macro that generate boilerplate code for `InheritedModel`
///Declare class with field (and methods to update them) and annotate it with `@InheritedModelMacro()` to generate code for full `InheritedModel` (it must extend `InheritedModel<String>`):
///
///``` dart
/// @InheritedModelMacro()
/// class LogoModel extends InheritedModel<String> {
///   final Color? backgroundColor; // setting values to null is also supported in update methods
///   final bool large;
///
///   void toggleColor(BuildContext context) {
///     final newValue = (backgroundColor == null) ? Colors.red : null;
///     updateState(backgroundColor: newValue); // updateState is generated method
///   }
///
///   void toggleSize(BuildContext context) {
///     updateState(large: large != true);
///   }
/// }
///```
///
///Then insert generated Holder class in a tree like `Provider` or `InheritedWidget` and provide initial values for fields:
///``` dart
///Scaffold(
///   body: const LogoModelHolder(
///     backgroundColor: Colors.blue,
///     large: false,
///     child: Content(),
/// )
///```
///
///In your class this code will be generated:
///``` dart
///class LogoModel {
///  // get field value
///  static FieldType readField(context) // for every field
///
///  // get field value and subscribe to it's changes. When value changes, widget will be redrawn
///  static FieldType watchField(context) // for every field
///
///  // find instance and update given fields
///  static void update(context, {fields?}) 
///
///  // update fields directly
///  void updateState({fields?}) 
///
///  // get nearest instanse of class up in the tree
///  static Type getInstance(context) 
///}
///```
///
///Then you can use it like this:
///```dart
///// get current value and update it
///final currentSize = LogoModel.readLarge(context);
///LogoModel.update(context, large: !currentSize);
///
///// subscribe to changes 
///final Color? color = LogoModel.watchBackgroundColor(context);
///```
  const InheritedModelMacro();

	String _classHolderName(ClassDeclaration clazz) => "${clazz.identifier.name}Holder";
	String _classHolderStateName(ClassDeclaration clazz) => "_${clazz.identifier.name}HolderState";
  String _getStubName(ClassDeclaration clazz) => '_${clazz.identifier.name.lower}Stub';

  @override
  FutureOr<void> buildTypesForClass(
      ClassDeclaration clazz,
      ClassTypeBuilder builder,
  ) async {
    final dep  = await (TypeDependencies.getDependencies(builder));

    _checkCorrectSuperClass(clazz, builder, dep);

    _declareHolderType( dep, clazz, builder);
    _declareStateType( dep, clazz, builder); 
  }
   

  @override
  FutureOr<void> buildDeclarationsForClass(
    ClassDeclaration clazz,
    MemberDeclarationBuilder builder,
  ) async {
    final (dep, fields, methods, constructors) = await (
      DeclarationDependencies.getDependencies(builder),
      builder.fieldsOf(clazz),
      builder.methodsOf(clazz),
      builder.constructorsOf(clazz),
    ).wait;

    final holderType = _classHolderName(clazz);
    final stateType = _classHolderStateName(clazz);
    final stubName = _getStubName(clazz);
    final initialClassName = clazz.identifier.name;

    final holderClassBuilder = HolderClassBuilder(
      builder: builder,
      dep: dep,
      holderType: holderType,
      stateClass: stateType,
      fields: fields,
    );
     holderClassBuilder.build();

    final holderStateClassBuilder = StateClassBuilder(
      builder: builder,
      dep: dep,
      fields: fields,
      stateClassName: stateType,
      initialClassName: initialClassName,
      stubName: stubName,
    );

      holderStateClassBuilder.build();

    final initialClassBuilder = InitialClassBuilder(
      builder: builder,
      dep: dep,
      fields: fields,
      methods: methods, 
      constructors: constructors,
      initialClassName: initialClassName,
    );

   initialClassBuilder.build();
  

  _declareStub( stubName, dep, builder);
  }

  void _checkCorrectSuperClass(
    ClassDeclaration clazz,
    ClassTypeBuilder builder,
    TypeDependencies dep,
  ) {
    final actual = clazz.superclass;
    final expected = NamedTypeAnnotationCode(
        name: dep.inheritedModel,
        typeArguments: [NamedTypeAnnotationCode(name: dep.string)]);
    final actualArgumentName =
        (actual?.typeArguments.firstOrNull?.code.parts.firstOrNull as Identifier?)
            ?.name;
    if (actual?.identifier.name != expected.name.name ||
        actualArgumentName != 'String') {
      // TODO: find better solution for checking argument names
      final diagnostic = Diagnostic(
          DiagnosticMessage(
              "Class ${clazz.identifier.name} must extend InheritedModel<String>, currently: ${clazz.superclass?.identifier.name}<$actualArgumentName>"),
          Severity.error);
      builder.report(diagnostic);
    }
  }

  void _declareHolderType(
    TypeDependencies dep,
    ClassDeclaration clazz,
    ClassTypeBuilder builder,
  ) {
    final holderCode = DeclarationCode.fromParts(
        ["class ${_classHolderName(clazz)} extends ", dep.statefulWidget, "{}"]);
    builder.declareType(_classHolderName(clazz), holderCode);
  }

  void _declareStateType(
    TypeDependencies dep,
    ClassDeclaration clazz,
    ClassTypeBuilder builder,
  ) {
    final stateCode = DeclarationCode.fromParts([
      "class ${_classHolderStateName(clazz)} extends ",
      dep.state,
      "<${_classHolderName(clazz)}>",
      "{}"
    ]);

    builder.declareType(_classHolderStateName(clazz), stateCode);
  }

  void _declareStub(
    String stubName,
    DeclarationDependencies dep,
    MemberDeclarationBuilder builder,
  ) {
    final stub =
        DeclarationCode.fromParts(['const $stubName = ', dep.object, '();\n']);

    builder.declareInLibrary(stub);
  }
}

