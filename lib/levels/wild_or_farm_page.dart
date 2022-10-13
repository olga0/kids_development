import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:kids_development/my_localizations.dart';
import 'package:kids_development/star_animation/particles.dart';
import 'package:kids_development/string_keys.dart';

enum Type { Wild, Farm }

class WildOrFarmPage extends StatefulWidget {
  final String _locale;
  final Function _showAd;

  WildOrFarmPage(this._locale, this._showAd);

  @override
  State<StatefulWidget> createState() {
    return WildOrFarmPageState();
  }
}

class WildOrFarmPageState extends State<WildOrFarmPage>
    with SingleTickerProviderStateMixin {
  bool _firstScreenLoaded = false;
  late double _width;
  late double _height;
  int _optionsNumOnScreen = 4;
  int _screenNumber = 1;
  AudioPlayer _audioPlayer = AudioPlayer();
  bool _allAnimalsFoundHome = false;
  late int _numberOfScreens;
  late ValueNotifier<bool> _animationFinished;
  late Particles _particles;
  late FlutterTts _flutterTts;
  List<Animal> _animals = [];
  List<Animal> _animalsOptions = [];
  Map<String, bool> _matched = {};

  @override
  void initState() {
    super.initState();
    _fillData();
    _numberOfScreens = _animals.length ~/ _optionsNumOnScreen;
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
      print('----call speak-----');
      _speak();
    }

    if (_screenNumber == _numberOfScreens && _allAnimalsFoundHome) {
      _playSound('sounds/you_win.mp3');
    }

    Widget body;

    if (_screenNumber == _numberOfScreens && _allAnimalsFoundHome) {
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
          title:
              Text(MyLocalizations.of(widget._locale, StringKeys.wildOrFarm)),
        ),
        body: body,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.play_arrow),
          backgroundColor:
              (_screenNumber == _numberOfScreens || !_allAnimalsFoundHome)
                  ? Colors.grey
                  : Colors.amber,
          onPressed: () {
            if (_screenNumber < _numberOfScreens && _allAnimalsFoundHome) {
              _loadNextScreen();
            }
          },
        ),
      ),
    );
  }

  void _fillData() {
    _animals.add(Animal('deer', Type.Wild));
    _animals.add(Animal('elephant', Type.Wild));
    _animals.add(Animal('panther', Type.Wild));
    _animals.add(Animal('tiger', Type.Wild));
    _animals.add(Animal('wolf', Type.Wild));
    _animals.add(Animal('zebra', Type.Wild));

    _animals.add(Animal('cow', Type.Farm));
    _animals.add(Animal('goat', Type.Farm));
    _animals.add(Animal('horse', Type.Farm));
    _animals.add(Animal('lamb', Type.Farm));
    _animals.add(Animal('pig', Type.Farm));
    _animals.add(Animal('rooster', Type.Farm));

    _animals.shuffle();
    _fillAnimalsOptions();
  }

  void _fillAnimalsOptions() {
    _animalsOptions.clear();

    for (int i = (_screenNumber - 1) * _optionsNumOnScreen;
        i < _screenNumber * _optionsNumOnScreen;
        i++) {
      _animalsOptions.add(_animals[i]);
    }

    _animalsOptions.shuffle();
  }

  void _loadNextScreen() {
    setState(() {
      _screenNumber++;
      _matched.clear();
      _allAnimalsFoundHome = false;
      _fillAnimalsOptions();
    });
  }

  Widget _drawPageContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[_drawAnimalPart(), _drawHomePart()],
    );
  }

  Widget _drawAnimalPart() {
    if (_animalsOptions.length > 0) {
      List<Column> animalColumns = [];

      for (int i = 0; i < _animalsOptions.length; i = i + 2) {
        Column column;
        if (i + 1 < _animalsOptions.length) {
          column = Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _drawAnimalChoice(_animalsOptions[i]),
              SizedBox(width: 10.0, height: 20.0),
              _drawAnimalChoice(_animalsOptions[i + 1])
            ],
          );
        } else
          column = Column(
            children: <Widget>[_drawAnimalChoice(_animalsOptions[i])],
          );
        animalColumns.add(column);
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: animalColumns,
      );
    } else
      return Container();
  }

  Widget _drawHomePart() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        _drawHomeOption('farm', Type.Farm),
        _drawHomeOption('forest', Type.Wild)
      ],
    );
  }

  Widget _drawAnimalChoice(Animal animal) {
    String image = _matched[animal.name] == true
        ? 'images/checkmark.png'
        : 'images/${animal.name}.png';
    int maxSimultaneousDrags = _matched[animal.name] == true ? 0 : 1;
    return Draggable<Animal>(
      data: animal,
      maxSimultaneousDrags: maxSimultaneousDrags,
      child: Image.asset(image,
          width: _width, height: _height, fit: BoxFit.contain),
      feedback: Image.asset('images/${animal.name}.png',
          width: _width, height: _height, fit: BoxFit.contain),
      childWhenDragging: Container(width: _width, height: _height),
    );
  }

  Widget _drawHomeOption(String picture, Type type) {
    return DragTarget<Animal>(
      builder: (BuildContext context, List<Animal?> incoming, List rejected) {
        return Image.asset('images/$picture.png',
            width: _width, height: _height, fit: BoxFit.contain);
      },
      onWillAccept: (data) {
        return data?.type == type;
      },
      onAccept: (data) {
        setState(() {
          _matched[data.name] = true;
          _allAnimalsFoundHome = (_matched.length == _optionsNumOnScreen);
          _playSound('sounds/correct.mp3');
        });
      },
    );
  }

  initTts() {
    _flutterTts = FlutterTts()..setSpeechRate(0.8);
    _flutterTts.setLanguage(widget._locale);

    _flutterTts.setStartHandler(() {
      setState(() {});
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
      });
    });

    _flutterTts.setErrorHandler((msg) {
      setState(() {});
    });
  }

  Future _playSound(String soundName) async {
    await _audioPlayer.play(AssetSource(soundName));
  }

  Future _speak() async {
    var result = await _flutterTts
        .speak(MyLocalizations.of(widget._locale, StringKeys.wildTask));
    if (result == 1) setState(() => {});
  }

  @override
  void dispose() {
    super.dispose();
    _flutterTts.stop();
  }
}

class Animal {
  String name;
  Type type;

  Animal(this.name, this.type);
}
