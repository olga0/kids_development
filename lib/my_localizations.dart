import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kids_development/string_keys.dart';

class MyLocalizations {
  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // MAIN PAGE
      // title
      StringKeys.kidsDevelopment: 'Kids development',
      // button labels
      StringKeys.oddOneOut: 'Odd one out',
      StringKeys.occupationsAndVehicles: 'Occupations and vehicles',
      StringKeys.wildOrFarm: 'Wild or farm',
      StringKeys.edibleOrNotEdible: 'Edible or not edible',
      StringKeys.matchingItems: 'Matching items',
      // language dialog
      StringKeys.languageDialogTitle: 'Choose a language',
      StringKeys.languageDialogOption1: 'English',
      StringKeys.languageDialogOption2: 'Russian',
      // market dialog
      StringKeys.marketDialogText: 'Would you like to remove ads from this app for ',
      StringKeys.marketDialogPosButLabel: 'Buy',
      StringKeys.marketDialogNegButLabel: 'Close',
      StringKeys.marketDialogTitle: 'Remove ads',

      // ODD ONE OUT
      StringKeys.oddOneOutTask: 'Choose the picture that does not fit the group.',

      // OCCUPATIONS AND VEHICLES
      StringKeys.occupationsAndVehiclesTask: 'Put each person in his vehicle',

      // WILD OR FARM
      StringKeys.wildTask: 'Sort wild and farm animals.',

      // EDIBLE OR NOT EDIBLE
      StringKeys.edibleOrNotEdibleTask: 'Sort edible and not edible items.',

      // MATCHING ITEMS
      StringKeys.matchingItemsTask: 'Make pairs of matching items.',
    },

    'ru': {
      // MAIN PAGE
      // title
      StringKeys.kidsDevelopment: 'Развивающие игры для детей',
      // button labels
      StringKeys.oddOneOut: 'Четвёртый лишний',
      StringKeys.occupationsAndVehicles: 'Професии и транспорт',
      StringKeys.wildOrFarm: 'Дикий или домашний',
      StringKeys.edibleOrNotEdible: 'Съедобный или несъедобный',
      StringKeys.matchingItems: 'Найди пару',
      // language dialog
      StringKeys.languageDialogTitle: 'Выберите язык',
      StringKeys.languageDialogOption1: 'английский',
      StringKeys.languageDialogOption2: 'русский',

      // market dialog
      StringKeys.marketDialogText: 'Хотите удалить рекламу из этого приложения за ',
      StringKeys.marketDialogPosButLabel: 'Купить',
      StringKeys.marketDialogNegButLabel: 'Закрыть',
      StringKeys.marketDialogTitle: 'Убрать рекламу',

      // ODD ONE OUT
      StringKeys.oddOneOutTask: 'Найди лишнюю картинку.',

      // OCCUPATIONS AND VEHICLES
      StringKeys.occupationsAndVehiclesTask: 'Угадай кто чем управляет',

      // WILD OR FARM
      StringKeys.wildTask: 'Перетащи диких животных в лес а домашних на ферму.',

      // EDIBLE OR NOT EDIBLE
      StringKeys.edibleOrNotEdibleTask: 'Рассортируй съедобное и несъедобное.',

      // MATCHING ITEMS
      StringKeys.matchingItemsTask: 'Составь пары из подходящих друг к другу предметов.',
    }
  };

  String translate(language, key) {
    if (language == 'ru')
      return _localizedValues['ru']?[key] ?? '';
    else
      return _localizedValues['en']?[key] ?? '';
  }

  static String of(String language, String key) {
    MyLocalizations myLocalizations = MyLocalizations();
    return myLocalizations.translate(language, key);
  }
}

class MyLocalizationsDelegate extends LocalizationsDelegate<MyLocalizations> {
  const MyLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ru'].contains(locale.languageCode);

  @override
  Future<MyLocalizations> load(Locale locale) {
    return SynchronousFuture<MyLocalizations>(MyLocalizations());
  }

  @override
  bool shouldReload(MyLocalizationsDelegate old) => false;
}
