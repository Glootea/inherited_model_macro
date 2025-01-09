import 'package:flutter/material.dart';
import 'package:inherited_model_macro/inherited_model_macro.dart';

/// Modified sample code from [InheritedModel documentation](https://api.flutter.dev/flutter/widgets/InheritedModel-class.html#widgets.InheritedModel.2)
@InheritedModelMacro()
class LogoModel extends InheritedModel<String> {
  final Color? backgroundColor;
  final bool large;

  void toggleColor(BuildContext context) {
    final newValue = (backgroundColor == null) ? Colors.red : null;
    updateState(backgroundColor: newValue);
  }
}

void main() => runApp(const InheritedModelApp());

class InheritedModelApp extends StatelessWidget {
  const InheritedModelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: InheritedModelExample(),
    );
  }
}

class InheritedModelExample extends StatefulWidget {
  const InheritedModelExample({super.key});
  @override
  State<InheritedModelExample> createState() => _InheritedModelExampleState();
}

class _InheritedModelExampleState extends State<InheritedModelExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('InheritedModel Sample')),
      body: const LogoModelHolder(
        backgroundColor: Colors.blue,
        large: false,
        child: Content(),
      ),
    );
  }
}

class Content extends StatelessWidget {
  const Content({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    print("Rebuild content");
    return const Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Center(
          child: BackgroundWidget(
            child: LogoWidget(),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            UpdateBackgroudButton(),
            UpdateSizeButton(),
          ],
        )
      ],
    );
  }
}

class UpdateBackgroudButton extends StatelessWidget {
  const UpdateBackgroudButton({super.key});

  @override
  Widget build(BuildContext context) {
    print("Rebuild UpdateBackgroudButton");
    return ElevatedButton(
      onPressed: () => LogoModel.getInstance(context).toggleColor(context),
      child: const Text('Update background'),
    );
  }
}

class UpdateSizeButton extends StatelessWidget {
  const UpdateSizeButton({super.key});

  @override
  Widget build(BuildContext context) {
    print("Rebuild UpdateSizeButton");
    return ElevatedButton(
      onPressed: () {
        final currentSize = LogoModel.readLarge(context);
        LogoModel.update(context, large: !currentSize);
      },
      child: const Text('Resize Logo'),
    );
  }
}

class BackgroundWidget extends StatelessWidget {
  const BackgroundWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Color? color = LogoModel.watchBackgroundColor(context);
    print("Rebuild BackgroundWidget");
    return AnimatedContainer(
      padding: const EdgeInsets.all(12.0),
      color: color ?? Colors.green,
      duration: const Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
      child: child,
    );
  }
}

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final largeLogo = LogoModel.watchLarge(context) == true;
    print("Rebuild LogoWidget");
    return AnimatedContainer(
      padding: const EdgeInsets.all(20.0),
      duration: const Duration(seconds: 2),
      curve: Curves.fastLinearToSlowEaseIn,
      alignment: Alignment.center,
      child: FlutterLogo(size: largeLogo ? 200.0 : 100.0),
    );
  }
}
