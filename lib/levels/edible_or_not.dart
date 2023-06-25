import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:kids_development/my_localizations.dart';
import 'package:kids_development/star_animation/particles.dart';
import 'package:kids_development/string_keys.dart';

enum Type { Edible, NotEdible }

class EdibleOrNotPage extends StatefulWidget {
  final String _locale;
  final Function _showAd;

  EdibleOrNotPage(this._locale, this._showAd);

  @override
  State<StatefulWidget> createState() {
    return EdibleOrNotPageState();
  }
}

class EdibleOrNotPageState extends State<EdibleOrNotPage>
    with SingleTickerProviderStateMixin {
  bool _firstScreenLoaded = false;
  late double _width;
  late double _height;
  int _optionsNumOnScreen = 4;
  int _screenNumber = 1;
  AudioPlayer _audioPlayer = AudioPlayer();
  bool _allItemsSorted = false;
  late int _numberOfScreens;
  late ValueNotifier<bool> _animationFinished;
  late Particles _particles;
  late FlutterTts _flutterTts;
  List<Item> _items = [];
  List<Item> _itemsOptions = [];
  Map<String, bool> _matched = {};

  @override
  void initState() {
    super.initState();
    _fillData();
    _numberOfScreens = _items.length ~/ _optionsNumOnScreen;
    _animationFinished = ValueNotifier(false);
    initTts();
    _particles = Particles(30, _animationFinished);
  }

  @override
  Widget build(BuildContext context) {
    if (!_firstScreenLoaded) {
      _width = MediaQuery.of(context).size.width * 0.4;
      _height = MediaQuery.of(context).size.height * 0.25;
      _firstScreenLoaded = true;
      _speak();
    }

    if (_screenNumber == _numberOfScreens && _allItemsSorted) {
      _playSound('sounds/you_win.mp3');
    }

    Widget body;

    if (_screenNumber == _numberOfScreens && _allItemsSorted) {
      body = Stack(
        children: <Widget>[
          _drawPageContent(),
          Positioned.fill(child: _particles)
        ],
      );
    } else {
      body = _drawPageContent();
    }

    return WillPopScope(
      onWillPop: () async {
        widget._showAd();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: FittedBox(
            child: Text(MyLocalizations.of(
                widget._locale, StringKeys.edibleOrNotEdible)),
            fit: BoxFit.scaleDown,
          ),
        ),
        body: body,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.play_arrow),
          backgroundColor:
              (_screenNumber == _numberOfScreens || !_allItemsSorted)
                  ? Colors.grey
                  : Colors.amber,
          onPressed: () {
            if (_screenNumber < _numberOfScreens && _allItemsSorted) {
              _loadNextScreen();
            }
          },
        ),
      ),
    );
  }

  void _fillData() {
    _items.add(Item('broccoli', Type.Edible));
    _items.add(Item('cherry', Type.Edible));
    _items.add(Item('orange', Type.Edible));
    _items.add(Item('pizza', Type.Edible));
    _items.add(Item('taco', Type.Edible));
    _items.add(Item('watermelon', Type.Edible));

    _items.add(Item('bulldozer', Type.NotEdible));
    _items.add(Item('cactus', Type.NotEdible));
    _items.add(Item('flower5_white', Type.NotEdible));
    _items.add(Item('ladybug', Type.NotEdible));
    _items.add(Item('rocket', Type.NotEdible));
    _items.add(Item('tree', Type.NotEdible));

    _items.shuffle();
    _fillItemsOptions();
  }

  void _fillItemsOptions() {
    _itemsOptions.clear();

    for (int i = (_screenNumber - 1) * _optionsNumOnScreen;
        i < _screenNumber * _optionsNumOnScreen;
        i++) {
      _itemsOptions.add(_items[i]);
    }

    _itemsOptions.shuffle();
  }

  void _loadNextScreen() {
    setState(() {
      _screenNumber++;
      _matched.clear();
      _allItemsSorted = false;
      _fillItemsOptions();
    });
  }

  Widget _drawPageContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[_drawItemsPart(), _drawHomePart()],
    );
  }

  Widget _drawItemsPart() {
    if (_itemsOptions.length > 0) {
      List<Column> itemsColumns = [];

      for (int i = 0; i < _itemsOptions.length; i = i + 2) {
        Column column;
        if (i + 1 < _itemsOptions.length) {
          column = Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _drawItemChoice(_itemsOptions[i]),
              SizedBox(width: 10.0, height: 20.0),
              _drawItemChoice(_itemsOptions[i + 1])
            ],
          );
        } else
          column = Column(
            children: <Widget>[_drawItemChoice(_itemsOptions[i])],
          );
        itemsColumns.add(column);
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: itemsColumns,
      );
    } else
      return Container();
  }

  Widget _drawHomePart() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        _drawHomeOption('edible', Type.Edible),
        _drawHomeOption('not_edible', Type.NotEdible)
      ],
    );
  }

  Widget _drawItemChoice(Item item) {
    String image = _matched[item.name] == true
        ? 'images/checkmark.png'
        : 'images/${item.name}.png';
    int maxSimultaneousDrags = _matched[item.name] == true ? 0 : 1;
    return Draggable<Item>(
      data: item,
      maxSimultaneousDrags: maxSimultaneousDrags,
      child: Image.asset(image,
          width: _width, height: _height, fit: BoxFit.contain),
      feedback: Image.asset('images/${item.name}.png',
          width: _width, height: _height, fit: BoxFit.contain),
      childWhenDragging: Container(width: _width, height: _height),
    );
  }

  Widget _drawHomeOption(String picture, Type type) {
    return DragTarget<Item>(
      builder: (BuildContext context, List incoming, List rejected) {
        return Image.asset('images/$picture.png',
            width: _width, height: _height, fit: BoxFit.contain);
      },
      onWillAccept: (data) {
        return data?.type == type;
      },
      onAccept: (data) {
        setState(() {
          _matched[data.name] = true;
          _allItemsSorted = (_matched.length == _optionsNumOnScreen);
          _playSound('sounds/correct.mp3');
        });
      },
    );
  }

  initTts() {
    _flutterTts = FlutterTts()..setSpeechRate(0.8);

    _flutterTts.setStartHandler(() {
      setState(() {});
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {});
    });

    _flutterTts.setErrorHandler((msg) {
      setState(() {});
    });
  }

  Future _playSound(String soundName) async {
    await _audioPlayer.play(AssetSource(soundName));
  }

  Future _speak() async {
    var result = await _flutterTts.speak(
        MyLocalizations.of(widget._locale, StringKeys.edibleOrNotEdibleTask));
    if (result == 1) setState(() => {});
  }

  @override
  void dispose() {
    super.dispose();
    _flutterTts.stop();
  }
}

class Item {
  String name;
  Type type;

  Item(this.name, this.type);
}
