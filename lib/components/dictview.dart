import 'package:flutter/material.dart';
import 'package:inm/pages/dictionary.dart';
import '../modules/tblookup.dart';  // 引入查询模块
import '../components/furigana.dart';  // 引入 Furigana 用于日文解析
import '../modules/semantic.dart';  // 引入 Kuromoji 解析模块
import 'package:shared_preferences/shared_preferences.dart';  // 导入 SharedPreferences

class DictView extends StatefulWidget {
  final String query;

  const DictView({super.key, required this.query});

  @override
  State<DictView> createState() => _DictViewState();
}

class _DictViewState extends State<DictView> {
  Map<String,List<String>> posSet = {};
  bool _isFavorite = false;
  List<String> recentQueries = [];

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();  // 检查是否已收藏
    _addToRecentQueries(widget.query);  // 添加到最近查询
  }

  // 检查是否为收藏词汇
  void _checkIfFavorite() async {
    final favorites = await TbLookup.getFavorites();
    setState(() {
      _isFavorite = favorites.contains(widget.query);
    });
  }

  // 保存查询记录
  Future<void> _addToRecentQueries(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    recentQueries = prefs.getStringList('recentQueries') ?? [];
    if (query.isNotEmpty && !recentQueries.contains(query)) {
      recentQueries.insert(0, query);
      if (recentQueries.length > 10) {
        recentQueries = recentQueries.sublist(0, 10);  // 保留最近10条
      }
      await prefs.setStringList('recentQueries', recentQueries);
    }
  }

  // 获取最近查询记录
  Future<List<String>> _getRecentQueries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('recentQueries') ?? [];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.query.isEmpty) {
      return FutureBuilder<List<String>>(
        future: _getRecentQueries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('暂无最近查询'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index]),
                  onTap: () {
                    _navigateToDictionary(context, snapshot.data![index]);
                  },
                );
              },
            );
          }
        },
      );
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: TbLookup.lookup(widget.query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('查询失败 : ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('未找到结果'));
        } else {
          //debugPrint('snapshot: ${snapshot.data!}', wrapWidth: 4096);
          final allJapaneseExamples = _getAllJapaneseExamples(snapshot.data!);
          final allTranslations = _getAllTranslations(snapshot.data!);
          //debugPrint('allJapaneseExamples: $allJapaneseExamples', wrapWidth: 4096);
          return FutureBuilder<Map<String,List<List<FuriganaChar>>>>(
            future: _parseAllExamples(allJapaneseExamples, snapshot.data!),
            builder: (context, parsedSnapshot) {
              if (parsedSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (parsedSnapshot.hasError || !parsedSnapshot.hasData) {
                return Center(child: Text('解析失败：${parsedSnapshot.error}'));
              } else {
                //debugPrint('parsedExamples: ${parsedSnapshot.data!.keys}', wrapWidth: 4096);
                return Stack(
                  children: [
                    ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final result = snapshot.data![index];
                        //print('result: $result');
                        //print('posset: $posSet');
                        String word = result['word'];
                        String kana = result['kana'];
                        String keyWord = '$word$kana';
                        //print('keyWord: $keyWord');
                        //print(result['definition']);
                        List<String> definitions = result['definition'].split('（');
                        var beginSentenceIndex = 0;
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    word,
                                    style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    kana,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                posSet[keyWord]!.toSet().join(', '),
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...definitions.asMap().entries.map((entry) {
                                int definitionIndex = entry.key + 1;
                                String definitionText = entry.value;

                                var xx =  _buildDefinitionItem(
                                  context,
                                  definitionIndex,
                                  beginSentenceIndex,
                                  definitionText,
                                  word,
                                  parsedSnapshot.data![keyWord]!,
                                  allTranslations,
                                );

                                beginSentenceIndex += definitionText.split('▲').length - 1;
                                return xx;
                              }),
                            ],
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: GestureDetector(
                        onLongPress: () async {
                          final favorites = await TbLookup.getFavorites();
                          showDialog(
                            // ignore: use_build_context_synchronously
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('收藏的词汇'),
                                content: SizedBox(
                                  height: 400,
                                  width: 300,
                                  child: ListView.builder(
                                    itemCount: favorites.length,
                                    itemBuilder: (context, index) {
                                      String favoriteWord = favorites[index];
                                      return ListTile(
                                        title: FuriganaText(
                                          furiganaChars: _buildFuriganaChars(favoriteWord),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('关闭'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: FloatingActionButton(
                          backgroundColor: Colors.white,
                          onPressed: () async {
                            if (_isFavorite) {
                              await TbLookup.removeFromFavorites(widget.query);
                            } else {
                              await TbLookup.addToFavorites(widget.query);
                            }

                            setState(() {
                              _isFavorite = !_isFavorite;
                            });
                          },
                          child: Icon(
                            _isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Colors.pink.shade300,
                          ),
                        ),
                      ),
                    ),

                  ],
                );
              }
            },
          );
        }
      },
    );
  }

  List<FuriganaChar> _buildFuriganaChars(String word) {
    return word.split('').map((char) {
      return FuriganaChar(
        kanji: char,
        furigana: null,
      );
    }).toList();
  }

  // 获取所有日语例句并合并为一个字符串
  String _getAllJapaneseExamples(List<Map<String, dynamic>> data) {
    List<String> allJapaneseExamples = [];
    for (var result in data) {
      List<String> definitions = result['definition'].split('（');
      String word = result['word'];
      String kana = result['kana'];
      for (String definition in definitions) {
        List<String> examplePair = definition.split('▲').skip(1).toList();
        for (var example in examplePair) {
          List<String> parts = example.split('/');
          allJapaneseExamples.add("@$word$kana。${parts[0]}");
        }
      }
    }
    return allJapaneseExamples.join('。');
  }

  // 获取所有翻译
  List<String> _getAllTranslations(List<Map<String, dynamic>> data) {
    List<String> allTranslations = [];
    for (var result in data) {
      List<String> definitions = result['definition'].split('（');
      for (String definition in definitions) {
        List<String> examplePair = definition.split('▲').skip(1).toList();
        for (var example in examplePair) {
          List<String> parts = example.split('/');
          if (parts.length > 1) {
            allTranslations.add(parts[1]);
          } else {
            allTranslations.add('');
          }
        }
      }
    }
    return allTranslations;
  }

  Widget _buildDefinitionItem(BuildContext context, int index, int beginSentenceIndex, String text, String word, List<List<FuriganaChar>> parsedExamples, List<String> allTranslations) {
    List<String> parsedDef = text.split('▲');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '(${parsedDef[0]}',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        if (parsedDef.length > 1)
          _buildExampleItem(context, parsedExamples, word, beginSentenceIndex, parsedDef.length - 1, allTranslations),
      ],
    );
  }

  Widget _buildExampleItem(BuildContext context, List<List<FuriganaChar>> parsedExamples, String word, int beginSentenceIndex, int exampleCount, List<String> allTranslations) {
    List<Widget> exampleWidgets = [];
    for (int i = beginSentenceIndex; i < beginSentenceIndex + exampleCount; i++) {
      exampleWidgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Column(
                  children: [
                    SizedBox(height: 18),
                    Text('☆'),
                  ],
                ),
                Expanded(
                  child: FuriganaText(furiganaChars: parsedExamples[i]),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (allTranslations[i].isNotEmpty)
              Text(
                allTranslations[i],
                style: const TextStyle(color: Colors.grey),
              ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: exampleWidgets,
    );
  }

  Future<Map<String,List<List<FuriganaChar>>>> _parseAllExamples(String allJapaneseExamples, List<Map<String, dynamic>> snapshot) async {
    final SemanticParser parser = SemanticParser();
    List<Map<String, dynamic>> parsedSentences = parser.parseKuromojiWithPos(await parser.tokenizeText(allJapaneseExamples));

    Map<String,List<List<FuriganaChar>>> result = {};
    List<FuriganaChar> currentSentence = [];
    final sentenceEndRegex = RegExp(r'[。！？]');

    //debugPrint('snapshot: $snapshot', wrapWidth: 4096);
    List words = snapshot.map((entry) => entry['word']).toList();
    List kanas = snapshot.map((entry) => entry['kana']).toList();
    //print(allJapaneseExamples);
    //print('words: $words, kanas: $kanas');
    
    Map<String,String> word2Key = {};
    for (int i = 0; i < words.length; i++) {
      String key = '${words[i]}${kanas[i]}';
      //print("insert key : $key");
      posSet[key] = [];
      result[key] = [];
      word2Key[words[i]] = key;
    }

    String currentWord = '';
    bool undergoingWord = false;
    for (var entry in parsedSentences) {
      String kanji = entry['kanji'];
      String? furigana = entry['furigana'];
      String pos = entry['pos'];

      if (kanji == '@'){
        currentWord = '';
        undergoingWord = true;
        continue;
      }

      if (undergoingWord){
        if (kanji == '。'){
          undergoingWord = false;
          //print('currentWord: $currentWord');
        }else{
          currentWord += kanji;
        }
        continue;
      }

      if (words.contains(kanji) && !posSet[word2Key[kanji]]!.contains(pos)) {
        posSet[word2Key[kanji]]?.add(pos);
      }

      currentSentence.add(FuriganaChar(
        kanji: kanji,
        furigana: furigana,
        underline: words.contains(kanji),
        bold: words.contains(kanji),
      ));

      if (sentenceEndRegex.hasMatch(kanji)) {
        result[currentWord]?.add(currentSentence);
        currentSentence = [];
      }
    }

    if (currentSentence.isNotEmpty) {
      result[currentWord]?.add(currentSentence);
    }

    //print('result: ${result.keys}');
    return result;
  }

  void _navigateToDictionary(BuildContext context, String query) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DictionaryPage(initialQuery: query),  // 传递查询词汇
      ),
    );
  }
}
