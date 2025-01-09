## Macro that generates boilerplate code for `InheritedModel` and simplifies state management

Usage can also be found in [example](example/example.dart).

All you need to do is declare class with fields (and methods to update values) and annotate it with `@InheritedModelMacro()`:

``` dart
 @InheritedModelMacro()
 class LogoModel extends InheritedModel<String> {
   final Color? backgroundColor; // nullable types are also supported in update methods
   final bool large;

   void toggleColor(BuildContext context) {
     final newValue = (backgroundColor == null) ? Colors.red : null;
     updateState(backgroundColor: newValue);
   }

   void toggleSize(BuildContext context) {
     updateState(large: large != true);
   }
 }
```

Then insert generated Holder class in a tree like `Provider` or `InheritedWidget`. 
``` dart
Scaffold(
   body: const LogoModelHolder(
     backgroundColor: Colors.blue,
     large: false,
     child: Content(),
 )
```
### Notes: 
- Your class MUST extends InheritedModel\<String> until future versions when macros feature `extendType` stops breaking analyzer
- Dart sdk version must be ^3.5.0-152 or higher and macros must be enabled in analysis_options.yaml and during build ([Documentation](https://dart.dev/language/macros)) 
- Analyzer might throw errors that generated code is not there when applying macro on different projects, than macro itself ([issue](https://github.com/dart-lang/sdk/issues/55670)). 
Instead of working with code, that does not exist, you can try to [dart unpack](https://dart.dev/tools/pub/cmd/pub-unpack) this package into your project

# Generated code
## Holder class

## Your class
``` dart
class LogoModel {
  // get field value
  static FieldType readField(context) 

  // get field value and subscribe to it's changes. When value changes, widget will be redrawn
  static FieldType watchField(context) 

  // find instance and update given fields
  static void update(context, fields?) 

  // update fields directly
  void updateState(fields?) 

  // get nearest instanse of class up in the tree
  static Type getInstance(context) 
}
```

# Under the hood
Holder class provided `setState` callback to your class that updates values inside holder and provides them down to your class. 

`InheritedModel`, like other `InheritedWidgets`, is needed for O(1) tree search.
But it's marked `@immutable`, so all fields are supposed to be final and can't be changed -> are provided by holder.

Also `InheritedModel` is useful as it allows to separatly subscribe to changes of fields. 
This is done by passing field name as `aspect` to `inheritFrom` method. 
That is why your class must extend `InheritedModel<String>`.

Setting nullable fields are implemented by getting `Object stub` in case of passing nothing as default argument and comparing it to current field value.

The rest is basic InheritedModel boilerplate code.  
