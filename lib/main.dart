import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _counterChannel = MethodChannel('com.counter.counter/counter');
const _defaultWidgetTransparency = 22;
const _defaultWidgetShadow = 50;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // State variables for the theme color (R, G, B)
  int _red = 255; // Default color (Yellow)
  int _green = 255;
  int _blue = 0;

  void _updateColor(int r, int g, int b) {
    setState(() {
      _red = r;
      _green = g;
      _blue = b;
    });
  }

  @override
  Widget build(BuildContext context) {
    final customColor = Color.fromARGB(255, _red, _green, _blue);

    return MaterialApp(
      title: 'Flutter Counter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: customColor),
        useMaterial3: true,
      ),
      home: MyHomePage(
        title: 'Counter',
        red: _red,
        green: _green,
        blue: _blue,
        onRedChange: (value) => _updateColor(value, _green, _blue),
        onGreenChange: (value) => _updateColor(_red, value, _blue),
        onBlueChange: (value) => _updateColor(_red, _green, value),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title,
    this.red = 255,
    this.green = 255,
    this.blue = 0,
    this.onRedChange,
    this.onGreenChange,
    this.onBlueChange,
  });

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final int red;
  final int green;
  final int blue;
  final ValueChanged<int>? onRedChange;
  final ValueChanged<int>? onGreenChange;
  final ValueChanged<int>? onBlueChange;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool _isLoadingCounter = true;
  int _widgetTransparency = _defaultWidgetTransparency;
  int _widgetShadow = _defaultWidgetShadow;

  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  Future<void> _loadCounter() async {
    var savedCount = 0;
    var transparency = _defaultWidgetTransparency;
    var shadow = _defaultWidgetShadow;
    try {
      savedCount = await _counterChannel.invokeMethod<int>('loadCounter') ?? 0;
      final appearance = await _counterChannel.invokeMapMethod<String, dynamic>(
        'loadWidgetAppearance',
      );
      transparency = appearance?['transparency'] as int? ?? transparency;
      shadow = appearance?['shadow'] as int? ?? shadow;
    } catch (error) {
      debugPrint('Could not load the saved counter or widget appearance: $error');
    }

    if (!mounted) return;
    setState(() {
      _counter = savedCount;
      _widgetTransparency = transparency;
      _widgetShadow = shadow;
      _isLoadingCounter = false;
    });
  }

  Future<void> _saveWidgetAppearance() async {
    try {
      await _counterChannel.invokeMethod<void>(
        'saveWidgetAppearance',
        {
          'transparency': _widgetTransparency,
          'shadow': _widgetShadow,
        },
      );
    } catch (error) {
      debugPrint('Could not save the home-screen widget appearance: $error');
    }
  }

  Future<void> _incrementCounter() async {
    final updatedCount = _counter + 1;
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter = updatedCount;
    });

    try {
      await _counterChannel.invokeMethod<void>(
        'saveCounter',
        {'count': updatedCount},
      );
    } catch (error) {
      debugPrint('Could not save the counter or refresh its home-screen widget: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: .center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              // Counter display
              CounterWidget(
                count: _counter,
                transparencyPercent: _widgetTransparency,
                shadowPercent: _widgetShadow,
              ),
              
              const SizedBox(height: 40), // Padding before color controls
              Text('Widget transparency: $_widgetTransparency%'),
              Slider(
                value: _widgetTransparency.toDouble(),
                min: 0,
                max: 100,
                label: '$_widgetTransparency%',
                onChanged: _isLoadingCounter ? null : (value) {
                  setState(() {
                    _widgetTransparency = value.round();
                  });
                },
                onChangeEnd: _isLoadingCounter ? null : (_) => _saveWidgetAppearance(),
              ),
              Text('Widget drop shadow: $_widgetShadow%'),
              Slider(
                value: _widgetShadow.toDouble(),
                min: 0,
                max: 100,
                label: '$_widgetShadow%',
                onChanged: _isLoadingCounter ? null : (value) {
                  setState(() {
                    _widgetShadow = value.round();
                  });
                },
                onChangeEnd: _isLoadingCounter ? null : (_) => _saveWidgetAppearance(),
              ),
              // Red Color Setting
              Text('Red Value: ${widget.red}'),
              Slider(
                value: widget.red.toDouble(),
                min: 0,
                max: 255,
                onChanged: (value) {
                  if (widget.onRedChange != null) {
                    widget.onRedChange!(value.toInt());
                  }
                },
              ),
              const SizedBox(height: 30),
              
              // Green Color Setting
              Text('Green Value: ${widget.green}'),
              Slider(
                value: widget.green.toDouble(),
                min: 0,
                max: 255,
                onChanged: (value) {
                  if (widget.onGreenChange != null) {
                    widget.onGreenChange!(value.toInt());
                  }
                },
              ),
              const SizedBox(height: 30),
              
              // Blue Color Setting
              Text('Blue Value: ${widget.blue}'),
              Slider(
                value: widget.blue.toDouble(),
                min: 0,
                max: 255,
                onChanged: (value) {
                  if (widget.onBlueChange != null) {
                    widget.onBlueChange!(value.toInt());
                  }
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoadingCounter ? null : _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// New Stateless Widget for the counter display with frosted glass effect
class CounterWidget extends StatelessWidget {
  final int count;
  final int transparencyPercent;
  final int shadowPercent;

  const CounterWidget({
    super.key,
    required this.count,
    required this.transparencyPercent,
    required this.shadowPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black.withValues(
          alpha: (100 - transparencyPercent) / 100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: shadowPercent / 100 * 0.45,
            ),
            blurRadius: shadowPercent / 100 * 18,
            offset: Offset(0, shadowPercent / 100 * 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('You have pushed the button this many times:'),
          Text(
            '$count',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }
}
