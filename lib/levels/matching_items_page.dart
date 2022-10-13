import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:kids_development/my_localizations.dart';
import 'package:kids_development/star_animation/particles.dart';
import 'package:kids_development/string_keys.dart';

class MatchingItemsPage extends StatefulWidget {
  final String _locale;
  final Function _showAd;

  MatchingItemsPage(this._locale, this._showAd);

  @override
  State<StatefulWidget> createState() {
    return MatchingItemsPageState();
  }
}

class MatchingItemsPageState extends State<MatchingItemsPage>
    with SingleTickerProviderStateMixin {
  late Widget _pageContent;
  bool _firstScreenLoaded = false;
  late double _width;
  late double _height;
  late Map<String, String> _optionsMap;
  Map<String, bool> _matched = {};
  List<OptionPair> _optionPairsList = [];
  List<String> _itemsToMatch = [];
  List<String> _itemsToMatchWith = [];
  int _optionsNumOnScreen = 4;
  int _screenNumber = 1;
  AudioPlayer _audioPlayer = AudioPlayer();
  bool _allItemsMatched = false;
  late int _numberOfScreens;
  late ValueNotifier<bool> _animationFinished;
  late Particles _particles;
  late FlutterTts _flutterTts;

  @override
  void initState() {
    super.initState();
    _fillData();
    _numberOfScreens = _optionPairsList.length ~/ _optionsNumOnScreen;
    _animationFinished = ValueNotifier(false);
    initTts();
    _particles = Particles(30, _animationFinished);
  }

  @override
  Widget build(BuildContext context) {
    if (!_firstScreenLoaded) {
      _width = MediaQuery.of(context).size.width * 0.4;
      _height = MediaQuery.of(context).size.height * 0.17;
      _pageContent = _buildPageContent();
      _firstScreenLoaded = true;
      _speak();
    }

    if (_screenNumber == _numberOfScreens && _allItemsMatched) {
      _playSound('sounds/you_win.mp3');
    }

    Widget body;

    if (_screenNumber == _numberOfScreens && _allItemsMatched) {
      body = Stack(
        children: <Widget>[
          _buildPageContent(),
          Positioned.fill(child: _particles)
        ],
      );
    } else {
      body = _buildPageContent();
    }

    return WillPopScope(
      onWillPop: () async {
        widget._showAd();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              MyLocalizations.of(widget._locale, StringKeys.matchingItems)),
        ),
        //body: OptionsScreenPart(_optionPictures, _optionsSetList, width, height,
        //   _questionNumber, _handleRightAnswerTap, _picturesClicked, _controller),
        body: body,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.play_arrow),
          backgroundColor:
              (_screenNumber == _numberOfScreens || !_allItemsMatched)
                  ? Colors.grey
                  : Colors.amber,
          onPressed: () {
            if (_screenNumber < _numberOfScreens && _allItemsMatched) {
              _loadNextScreen();
            }
          },
        ),
      ),
    );
  }

  Widget _buildPageContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[_drawOccupationsColumn(), _drawVehiclesColumn()],
    );
  }

  Widget _drawOccupationsColumn() {
    List<Widget> occupationPictures = [];

    for (int i = 0; i < _itemsToMatch.length; i++) {
      occupationPictures.add(SizedBox(width: 10, height: 20));
      occupationPictures.add(_drawItemsToMatchChoice(_itemsToMatch[i]));
    }

    return Column(children: occupationPictures);
  }

  Widget _drawVehiclesColumn() {
    List<Widget> vehiclesPictures = [];

    for (int i = 0; i < _itemsToMatchWith.length; i++) {
      vehiclesPictures.add(SizedBox(width: 10, height: 20));
      vehiclesPictures.add(_drawItemsToMatchWithOption(_itemsToMatchWith[i]));
    }

    return Column(children: vehiclesPictures);
  }

  void _fillData() {
    _optionsMap = {
      'laptop': 'computer_mouse',
      'cow': 'milk',
      'hammer': 'nail',
      't-shirt': 'hanger',
      'lock': 'key',
      'mailbox': 'mail',
      'paints': 'paintbrush',
      'web': 'spider',
      'vase': 'tulp_red',
      'cake': 'present',
      'table': 'chair',
      'cloud': 'umbrella'
    };

    _optionsMap.forEach((itemToMatchWith, itemToMatch) =>
        _optionPairsList.add(OptionPair(itemToMatchWith, itemToMatch)));
    _optionPairsList.shuffle();

    _fillItemsToMatchAndItemsToMatchWith();
  }

  Widget _drawItemsToMatchChoice(String picture) {
    String image = _matched[picture] == true
        ? 'images/checkmark.png'
        : 'images/$picture.png';
    int maxSimultaneousDrags = _matched[picture] == true ? 0 : 1;
    return Draggable<String>(
      maxSimultaneousDrags: maxSimultaneousDrags,
      data: picture,
      child: Image.asset(image,
          width: _width, height: _height, fit: BoxFit.contain),
      feedback: Image.asset('images/$picture.png',
          width: _width, height: _height, fit: BoxFit.contain),
      childWhenDragging: Container(width: _width, height: _height),
    );
  }

  Widget _drawItemsToMatchWithOption(String itemToMatchWithPicture) {
    String? itemToMatchPicture = _optionsMap[itemToMatchWithPicture];
    return itemToMatchPicture == null
        ? Container()
        : DragTarget<String>(
            builder:
                (BuildContext context, List<String?> incoming, List rejected) {
              if (_matched[itemToMatchPicture] == true) {
                return Stack(
                  alignment: AlignmentDirectional.center,
                  children: <Widget>[
                    Image.asset(
                      'images/$itemToMatchWithPicture.png',
                      width: _width,
                      height: _height,
                      fit: BoxFit.contain,
                    ),
                    Image.asset(
                      'images/$itemToMatchPicture.png',
                      width: _width,
                      height: _height,
                      fit: BoxFit.contain,
                    ),
                  ],
                );
              } else {
                return Image.asset('images/$itemToMatchWithPicture.png',
                    width: _width, height: _height, fit: BoxFit.contain);
              }
            },
            onWillAccept: (data) => data == itemToMatchPicture,
            onAccept: (data) {
              setState(() {
                _matched[itemToMatchPicture] = true;
                _allItemsMatched = (_matched.length == _optionsNumOnScreen);
                  _playSound('sounds/correct.mp3');
              });
            },
          );
  }

  void _loadNextScreen() {
    setState(() {
      _screenNumber++;
      _matched.clear();
      _allItemsMatched = false;
      _fillItemsToMatchAndItemsToMatchWith();
      _pageContent = _buildPageContent();
    });
  }

  void _fillItemsToMatchAndItemsToMatchWith() {
    _itemsToMatch.clear();
    _itemsToMatchWith.clear();

    for (int i = (_screenNumber - 1) * _optionsNumOnScreen;
        i < _screenNumber * _optionsNumOnScreen;
        i++) {
      _itemsToMatch.add(_optionPairsList[i].itemToMatch);
      _itemsToMatchWith.add(_optionPairsList[i].itemToMatchWith);
    }

    _itemsToMatch.shuffle();
    _itemsToMatchWith.shuffle();
  }

  Future _playSound(String soundName) async {
    await _audioPlayer.play(AssetSource(soundName));
  }

  initTts() {
    _flutterTts = FlutterTts()..setSpeechRate(0.8);

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

  Future _speak() async {
    var result = await _flutterTts.speak(
        MyLocalizations.of(widget._locale, StringKeys.matchingItemsTask));
    if (result == 1) setState(() => {});
  }

  @override
  void dispose() {
    super.dispose();
    _flutterTts.stop();
  }
}

class OptionPair {
  String itemToMatchWith;
  String itemToMatch;

  OptionPair(this.itemToMatchWith, this.itemToMatch);
}
