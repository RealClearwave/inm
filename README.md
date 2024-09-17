# 📖 inm: Japanese Vocabulary & Text Reader

A Flutter app to help you learn and memorize Japanese vocabulary, translate Japanese texts, and read annotated sentences with Furigana! 🌸

## 🚀 Features

- 🏯 **Japanese Dictionary**: Look up words from JLPT levels N1 to N5 with detailed kana readings and definitions.
- 📚 **Flashcards & Quiz**: Master vocabulary with quizzes that test your knowledge through multiple-choice questions.
- 📖 **Text Reader with Furigana**: Read Japanese texts with kanji annotated with Furigana, and even translate sentences!
- ❤️ **Favorite Words**: Save your favorite words for quick review later.
- 🌐 **Translation Support**: Translate sentences between Japanese and other languages via customizable API settings.
- 📊 **Progress Tracking**: Track your progress on learning each word. Words mastered after three correct answers in a row!
- 🔄 **Cross-Session Persistence**: Your app settings, progress, and favorites are saved even when the app is restarted.

## 🛠️ Installation

### Prerequisites

- Flutter SDK
- An editor like VSCode or Android Studio

### Clone the repository

```bash
git clone https://github.com/yourusername/inm-app.git
cd inm-app
```

### Install dependencies

```bash
flutter pub get
```

### Run the app

```bash
flutter run
```

## 📝 How to Use

1. **Dictionary**: On the dictionary page, type in a Japanese word to look up its reading (kana) and definition.
   - When the query is empty, you can view your recent searches.
   - Long press on the favorite icon to view all your saved words with Furigana annotations.

2. **Quiz**: Start a quiz to practice vocabulary. The quiz pulls words from different JLPT levels. Each word requires three correct answers to be marked as learned.
   - The app generates four types of questions based on kanji, kana, and definitions.
   
3. **Text Reader**: Load a Japanese text file and read it with Furigana annotations. The app will divide the text into sentences and allow you to translate them individually.
   - If translation is enabled, tap on "View Translation" to translate the sentence into your chosen language.

4. **Settings**: 
   - Select your JLPT level for the quiz.
   - Enable or disable translation and configure the translation API URL.

## 🔧 Project Structure

- **lib/modules**: Contains utility modules for quiz, dictionary, and translation.
  - `qzutil.dart`: Manages quiz questions, progress, and JLPT word data.
  - `tblookup.dart`: Handles dictionary lookups and word storage.
  - `transutil.dart`: Manages API calls for translation.
- **lib/components**: UI components for different features of the app.
  - `quizview.dart`: Displays the quiz interface.
  - `furigana.dart`: Displays annotated Furigana text.
- **lib/pages**: Main screens of the app.
  - `dictionary.dart`, `quiz.dart`, `reader.dart`, `settings.dart`: These manage their respective sections.

## 🌐 API Usage

To use translation functionality, this app makes GET requests to an external translation API. The default is [Mozhi's Translation API](https://mozhi.pussthecat.org/api/translate), but you can configure this in the settings.

```plaintext
https://mozhi.pussthecat.org/api/translate?engine=deepl&from=ja&to=zh&text=YOUR_TEXT_HERE
```

You can change the `engine`, `from`, `to`, and `text` parameters as needed. Example for DeepL translation from Japanese to Chinese.

## 🚧 Roadmap

- [ ] Add support for offline translation engines
- [ ] Improve quiz with more question types
- [ ] Add user profiles for multi-user progress tracking
- [ ] Implement dark mode

## 🛡️ License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.

1. Fork the project
2. Create a new branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a pull request

## 🙌 Acknowledgements

- Big thanks to [Kuromoji](https://www.atilika.org/) for providing the Japanese morphological analysis.
- Thanks to [Yomichan](https://github.com/FooSoft/yomichan) for inspiring the dictionary lookup features.
- [DeepL](https://www.deepl.com/) and [Mozhi](https://mozhi.pussthecat.org/) APIs for providing translation services.

---

Feel free to adapt this README to your project's future needs and development!
