## Macro that generates boilerplate code for `InheritedModel` and simplifies state management
> Dart macros feature was under development and is currently [suspended](https://medium.com/dartlang/an-update-on-dart-macros-data-serialization-06d3037d4f12), so this package may not work and won't be fixed until macros feature is released.

Declare class with field (and methods to update them) and annotate it with `@InheritedModelMacro()` to generate code for full `InheritedModel` (it must extend `InheritedModel<String>`):

``` dart
 @InheritedModelMacro()
 class LogoModel extends InheritedModel<String> {
   final Color? backgroundColor; // setting values to null is also supported in update methods
   final bool large;

   void toggleColor(BuildContext context) {
     final newValue = (backgroundColor == null) ? Colors.red : null;
     updateState(backgroundColor: newValue); // updateState is generated method
   }

   void toggleSize(BuildContext context) {
     updateState(large: large != true);
   }
 }
```

Then insert generated Holder class in a tree like `Provider` or `InheritedWidget` and provide initial values for fields:
``` dart
Scaffold(
   body: const LogoModelHolder(
     backgroundColor: Colors.blue,
     large: false,
     child: Content(),
 )
```

In your class this code will be generated:
``` dart
class LogoModel {
  // get field value
  static FieldType readField(context) // for every field

  // get field value and subscribe to it's changes. When value changes, widget will be redrawn
  static FieldType watchField(context) // for every field

  // find instance and update given fields
  static void update(context, {fields?}) 

  // update fields directly
  void updateState({fields?}) 

  // get nearest instanse of class up in the tree
  static Type getInstance(context) 
}
```

Then you can use it like this:
```dart
// get current value and update it
final currentSize = LogoModel.readLarge(context);
LogoModel.update(context, large: !currentSize);

// subscribe to changes 
final Color? color = LogoModel.watchBackgroundColor(context);
```

Usage can also be found in [example](example/example.dart). Generated code is presented [here](example/generated_code_example.dart).

## Notes: 
- Your class MUST extends InheritedModel\<String> until future versions when macros feature `extendType` stops breaking analyzer
- Dart sdk version must be ^3.5.0-152 or higher and macros must be enabled in analysis_options.yaml and during build ([Documentation](https://dart.dev/language/macros)) 
- Analyzer might throw errors that generated code is not there when applying macro on different projects other than macro itself ([issue](https://github.com/dart-lang/sdk/issues/55670)). 
Instead of working with code, that does not exist, you can try to [dart unpack](https://dart.dev/tools/pub/cmd/pub-unpack) this package into your project

# Under the hood
Holder class provided `setState` callback to your class that updates values inside holder and provides them down to your class. 

`InheritedModel`, like other `InheritedWidgets`, is needed for O(1) tree search.
But it's marked `@immutable`, so all fields are supposed to be final and can't be changed -> are provided by holder.

Also `InheritedModel` is useful as it allows to separatly subscribe to changes of fields. 
This is done by passing field name as `aspect` to `inheritFrom` method. 
That is why your class must extend `InheritedModel<String>`.

Setting nullable fields are implemented by getting `Object stub` in case of passing nothing as default argument and comparing it to current field value.

The rest is basic InheritedModel boilerplate code.  
