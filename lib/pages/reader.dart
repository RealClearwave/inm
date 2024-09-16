import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:inm/components/furigana.dart';
import 'package:shared_preferences/shared_preferences.dart';  // 导入 SharedPreferences
import '../components/inmview.dart';  // 导入 InmView 组件
import '../modules/semantic.dart';  // 导入 SemanticParser

class ReaderPage extends StatefulWidget {
  const ReaderPage({super.key});

  @override
  _ReaderPageState createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  final SemanticParser _parser = SemanticParser();
  final List<List<List<FuriganaChar>>> _pages = [];  // 已加载并解析的页面内容，每页5句
  List<List<String>> _allPages = [];  // 所有的分页数据
  final PageController _pageController = PageController();
  List<String> _recentFiles = []; // 最近打开的文件列表
  int _currentPage = 1;  // 当前页数
  int _totalPages = 1;  // 总页数
  bool _fileOpened = false;  // 标记是否已打开文件
  bool _isLoading = false;  // 是否正在加载新页面

  @override
  void initState() {
    super.initState();
    _loadRecentFiles();  // 加载最近打开的文件列表
    _pageController.addListener(_onScroll);  // 监听滚动事件
  }

  // 滚动时加载更多页面
  void _onScroll() {
    if (_pageController.position.pixels == _pageController.position.maxScrollExtent && !_isLoading) {
      _loadMorePages();  // 用户滚动到末尾，加载更多页面
    }
    // 更新当前页码
    setState(() {
      _currentPage = _pageController.page!.round() + 1;  // 页码从 1 开始
    });

    // 保存当前文件的最后阅读页数
    if (_fileOpened) {
      _saveLastReadPage(_currentPage);
    }
  }

  // 保存最后阅读的页码
  Future<void> _saveLastReadPage(int page) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'last_read_page_${_recentFiles.last}'; // 根据文件路径生成键
    await prefs.setInt(key, page);
  }


  
  // 懒加载更多页面，每次加载50页
  Future<void> _loadMorePages() async {
    if (_pages.length >= _allPages.length) return;  // 已经加载了全部内容

    setState(() {
      _isLoading = true;  // 开始加载，显示加载动画
    });

    // 加载下一个50页
    int nextPageEnd = (_pages.length + 50).clamp(0, _allPages.length);
    List<List<String>> nextPages = _allPages.sublist(_pages.length, nextPageEnd);
    List<List<List<FuriganaChar>>> parsedPages = await _parser.parsePages(nextPages);
    _pages.addAll(parsedPages);

    setState(() {
      _isLoading = false;  // 完成加载，隐藏加载动画
    });

    // 自动进入下一页
    if (nextPageEnd != 50 && _pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    }
  }


  // 选择文件并读取内容
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'], // 只允许选择文本文件
    );
    if (result != null) {
      File file = File(result.files.single.path!);
      _addToRecentFiles(file.path);  // 添加文件到最近打开列表
      String content = await file.readAsString(); // 读取文件内容
      List<String> splittedSentences = _parser.splitSentences(content);
      //print('Read $splittedSentences Sentences');
      _allPages = _parser.buildPages(splittedSentences);  // 分句
      _totalPages = _allPages.length;  // 计算总页数
      //print('Total Pages: $_totalPages');

      setState(() {
        _fileOpened = true;  // 标记文件已打开
      });
    } else {
      //final filePath = result?.files.single.path;
      //print('File Not Found : $filePath');
      setState(() {
      });
    }
  }

  // 添加文件到最近打开文件列表，并保存到 SharedPreferences
  Future<void> _addToRecentFiles(String filePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _recentFiles.add(filePath);
    _recentFiles = _recentFiles.toSet().toList();  // 去重
    await prefs.setStringList('recentFiles', _recentFiles);
    setState(() {});
  }

  // 加载最近打开的文件列表
  Future<void> _loadRecentFiles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentFiles = prefs.getStringList('recentFiles') ?? [];
    });
  }

  // 打开最近打开的文件
  Future<void> _openRecentFile(String filePath) async {
    File file = File(filePath);
    if (await file.exists()) {
      String content = await file.readAsString(); // 读取文件内容
      List<String> splittedSentences = _parser.splitSentences(content);
      _allPages = _parser.buildPages(splittedSentences);  // 分句
      _totalPages = _allPages.length;  // 计算总页数

      // 加载第一页内容
      _loadMorePages();

      setState(() {
        _fileOpened = true;  // 标记文件已打开
      });

      // 跳转到最后阅读页
      await _jumpToLastReadPage(filePath);
    }
  }

  Future<void> _jumpToLastReadPage(String filePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'last_read_page_$filePath';  // 根据文件路径生成键
    int? lastReadPage = prefs.getInt(key);

    if (lastReadPage != null && lastReadPage <= _totalPages) {
      // 首先加载直到目标页的所有页面内容
      await _loadPagesUntil(lastReadPage);

      // 使用 WidgetsBinding 来确保页面构建完成后再跳转
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(lastReadPage - 1);  // 页码是从0开始的，所以需要 -1
        }
      });

      // 提示用户已跳转到上次阅读的页码
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已跳转到上次阅读的第 $lastReadPage 页'))
      );
    }
  }

  // 加载直到目标页的所有页面内容
  Future<void> _loadPagesUntil(int targetPage) async {
    while (_pages.length < targetPage) {
      if (_pages.length >= _allPages.length) {
        break;  // 已经加载了所有页面
      }

      // 加载下一批页面，假设每次加载 50 页
      int nextPageEnd = (_pages.length + 50).clamp(0, _allPages.length);
      List<List<String>> nextPages = _allPages.sublist(_pages.length, nextPageEnd);
      List<List<List<FuriganaChar>>> parsedPages = await _parser.parsePages(nextPages);
      _pages.addAll(parsedPages);

      setState(() {
        _isLoading = false;  // 完成加载，隐藏加载动画
      });
    }
  }



  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _fileOpened?Text('読み ( $_currentPage / $_totalPages )'):const Text("読み"),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              _loadMorePages();  // 刷新页面
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _fileOpened
            ? _buildPageView()  // 如果文件已打开，显示内容分页
            : _buildRecentFilesList(),  // 否则显示最近打开的文件列表
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),  // 显示加载动画
        ],
      ),
    );
  }


  // 构建分页内容
  Widget _buildPageView() {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: _pages.length,
          itemBuilder: (context, index) {
            return InmView(pageContent: _pages[index]); // 使用 InmView 显示每页内容
          },
        ),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),  // 加载动画
          ),
      ],
    );
  }

  // 构建最近打开的文件列表
  Widget _buildRecentFilesList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 20),
        const Text('选择文件：'),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _pickFile,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade50),
          child: Text('打开本地文件', style: TextStyle(color: Colors.pink.shade300)),
        ),
        const SizedBox(height: 60),
        if (_recentFiles.isNotEmpty) ...[
          const Text('最近打开的文件：'),
          const SizedBox(height: 10),
          for (var file in _recentFiles)
            Card(
              child: ListTile(
              title: Text(file.split('/').last),
              leading: const Icon(Icons.file_copy),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => _openRecentFile(file), // 点击快速打开文件
              ),
            ),
        ] else
          const Text('没有最近打开的文件'),
      ],
    );
  }
}
