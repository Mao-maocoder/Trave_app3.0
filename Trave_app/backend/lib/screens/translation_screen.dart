import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../services/translation_service.dart';
import '../services/voice_service.dart';
import '../widgets/optimized_card.dart';
import '../utils/ui_performance.dart';
import 'package:flutter/foundation.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({Key? key}) : super(key: key);

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  String _selectedFromLanguage = 'zh';
  String _selectedToLanguage = 'en';
  bool _isTranslating = false;
  bool _isRecording = false;
  bool _isPlaying = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // 防抖计时器
  Timer? _debounceTimer;

  // 缓存优化：预计算语言名称
  static const Map<String, Map<String, String>> _languageNames = {
    'zh': {'zh': '中文', 'en': 'Chinese'},
    'en': {'zh': '英文', 'en': 'English'},
  };

  static const List<String> _availableLanguages = ['zh', 'en'];

  // 预构建的常用短语数据，避免每次重新构建
  static const List<Map<String, String>> _commonPhrases = [
    {'zh': '你好', 'en': 'Hello', 'category': 'greeting'},
    {'zh': '谢谢', 'en': 'Thank you', 'category': 'greeting'},
    {'zh': '再见', 'en': 'Goodbye', 'category': 'greeting'},
    {'zh': '请问', 'en': 'Excuse me', 'category': 'greeting'},
    {'zh': '对不起', 'en': 'Sorry', 'category': 'greeting'},
    {'zh': '故宫在哪里？', 'en': 'Where is the Forbidden City?', 'category': 'travel'},
    {'zh': '怎么去天坛？', 'en': 'How do I get to the Temple of Heaven?', 'category': 'travel'},
    {'zh': '门票多少钱？', 'en': 'How much is the ticket?', 'category': 'travel'},
    {'zh': '开放时间是什么时候？', 'en': 'What are the opening hours?', 'category': 'travel'},
    {'zh': '厕所在哪里？', 'en': 'Where is the bathroom?', 'category': 'travel'},
    {'zh': '我想拍照', 'en': 'I want to take photos', 'category': 'travel'},
    {'zh': '这个多少钱？', 'en': 'How much is this?', 'category': 'shopping'},
    {'zh': '可以便宜一点吗？', 'en': 'Can you make it cheaper?', 'category': 'shopping'},
    {'zh': '我要这个', 'en': 'I want this', 'category': 'shopping'},
    {'zh': '很好吃', 'en': 'Very delicious', 'category': 'food'},
    {'zh': '我饿了', 'en': 'I am hungry', 'category': 'food'},
    {'zh': '推荐什么菜？', 'en': 'What do you recommend?', 'category': 'food'},
  ];

  static const Map<String, Map<String, String>> _categories = {
    'greeting': {'zh': '问候语', 'en': 'Greetings'},
    'travel': {'zh': '旅游', 'en': 'Travel'},
    'shopping': {'zh': '购物', 'en': 'Shopping'},
    'food': {'zh': '美食', 'en': 'Food'},
  };

  // 缓存分组后的短语，避免重复计算
  late final Map<String, List<Map<String, String>>> _groupedPhrases;

  // 获取语言显示名称（优化版本）
  String _getLanguageDisplayName(String langCode, bool isChinese) {
    return _languageNames[langCode]?[isChinese ? 'zh' : 'en'] ?? langCode;
  }

  @override
  void initState() {
    super.initState();
    
    // 预计算分组短语
    _groupedPhrases = {};
    for (final category in _categories.keys) {
      _groupedPhrases[category] = _commonPhrases
          .where((phrase) => phrase['category'] == category)
          .toList();
    }
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600), // 减少动画时间
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();

    // 添加输入监听器实现自动翻译防抖
    _inputController.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (_inputController.text.trim().isNotEmpty && !_isTranslating) {
        _translate();
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _animationController.dispose();
    _inputController.dispose();
    _outputController.dispose();
    VoiceService.dispose();
    super.dispose();
  }

  Future<void> _translate() async {
    final inputText = _inputController.text.trim();
    if (inputText.isEmpty) return;

    if (_isTranslating) return; // 防止重复调用

    setState(() {
      _isTranslating = true;
    });

    try {
      String translatedText = '';
      
      if (_selectedFromLanguage == 'zh' && _selectedToLanguage == 'en') {
        translatedText = await TranslationService.translateToEnglish(inputText);
      } else if (_selectedFromLanguage == 'en' && _selectedToLanguage == 'zh') {
        translatedText = await TranslationService.translateToChinese(inputText);
      } else {
        translatedText = await TranslationService.autoTranslate(inputText);
      }

      if (mounted) {
        setState(() {
          _outputController.text = translatedText;
          _isTranslating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTranslating = false;
        });

        final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
        final isChinese = localeProvider.locale == AppLocale.zh;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isChinese ? '翻译失败: $e' : 'Translation failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _swapLanguages() {
    setState(() {
      final temp = _selectedFromLanguage;
      _selectedFromLanguage = _selectedToLanguage;
      _selectedToLanguage = temp;
      
      final tempText = _inputController.text;
      _inputController.text = _outputController.text;
      _outputController.text = tempText;
    });
  }

  void _usePhrase(String phrase) {
    _inputController.text = phrase;
    _outputController.clear();
    // 短语使用后立即翻译
    _translate();
  }

  Future<void> _startVoiceInput() async {
    if (_isRecording) return;
    
    try {
      setState(() {
        _isRecording = true;
      });

      await VoiceService.startRecording();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('正在录音，请说话...'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRecording = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('录音失败: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _stopVoiceInput() async {
    if (!_isRecording) return;
    
    try {
      final audioPath = await VoiceService.stopRecording();
      
      if (audioPath != null && mounted) {
        setState(() {
          _isRecording = false;
          _isTranslating = true;
        });

        final recognizedText = await VoiceService.speechToText(audioPath);
        
        if (mounted) {
          setState(() {
            _inputController.text = recognizedText;
            _isTranslating = false;
          });

          await _translate();
        }
      } else if (mounted) {
        setState(() {
          _isRecording = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRecording = false;
          _isTranslating = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('语音识别失败: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _playTranslation() async {
    final outputText = _outputController.text.trim();
    if (outputText.isEmpty || _isPlaying) return;

    try {
      setState(() {
        _isPlaying = true;
      });

      final lang = _selectedToLanguage == 'zh' ? 'zh' : 'en';
      final audioPath = await VoiceService.textToSpeech(outputText, lang: lang);
      
      await VoiceService.playAudio(audioPath);
      
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('语音播放失败: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _clearInput() {
    _inputController.clear();
    _outputController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        final isChinese = localeProvider.locale == AppLocale.zh;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(isChinese ? '翻译助手' : 'Translation Assistant'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
          ),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _LanguageSelector(
                    selectedFromLanguage: _selectedFromLanguage,
                    selectedToLanguage: _selectedToLanguage,
                    isChinese: isChinese,
                    onFromLanguageChanged: (value) {
                      setState(() {
                        _selectedFromLanguage = value;
                      });
                    },
                    onToLanguageChanged: (value) {
                      setState(() {
                        _selectedToLanguage = value;
                      });
                    },
                    onSwapLanguages: _swapLanguages,
                  ),
                  const SizedBox(height: 20),
                  _TranslationArea(
                    inputController: _inputController,
                    outputController: _outputController,
                    isTranslating: _isTranslating,
                    isRecording: _isRecording,
                    isPlaying: _isPlaying,
                    isChinese: isChinese,
                    onTranslate: _translate,
                    onClearInput: _clearInput,
                    onStartVoiceInput: _startVoiceInput,
                    onStopVoiceInput: _stopVoiceInput,
                    onPlayTranslation: _playTranslation,
                    onStopAudio: VoiceService.stopAudio,
                  ),
                  const SizedBox(height: 20),
                  _CommonPhrases(
                    groupedPhrases: _groupedPhrases,
                    categories: _categories,
                    isChinese: isChinese,
                    onPhraseSelected: _usePhrase,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// 将语言选择器抽离为独立组件
class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({
    required this.selectedFromLanguage,
    required this.selectedToLanguage,
    required this.isChinese,
    required this.onFromLanguageChanged,
    required this.onToLanguageChanged,
    required this.onSwapLanguages,
  });

  final String selectedFromLanguage;
  final String selectedToLanguage;
  final bool isChinese;
  final ValueChanged<String> onFromLanguageChanged;
  final ValueChanged<String> onToLanguageChanged;
  final VoidCallback onSwapLanguages;

  String _getLanguageDisplayName(String langCode, bool isChinese) {
    const languageNames = {
      'zh': {'zh': '中文', 'en': 'Chinese'},
      'en': {'zh': '英文', 'en': 'English'},
    };
    return languageNames[langCode]?[isChinese ? 'zh' : 'en'] ?? langCode;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 400) {
                return _buildVerticalLayout();
              }
              return _buildHorizontalLayout();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalLayout() {
    return Column(
      children: [
        _buildDropdown(
          value: selectedFromLanguage,
          labelText: isChinese ? '源语言' : 'From',
          onChanged: onFromLanguageChanged,
        ),
        const SizedBox(height: 12),
        _buildSwapButton(vertical: true),
        const SizedBox(height: 12),
        _buildDropdown(
          value: selectedToLanguage,
          labelText: isChinese ? '目标语言' : 'To',
          onChanged: onToLanguageChanged,
        ),
      ],
    );
  }

  Widget _buildHorizontalLayout() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown(
            value: selectedFromLanguage,
            labelText: isChinese ? '源语言' : 'From',
            onChanged: onFromLanguageChanged,
          ),
        ),
        const SizedBox(width: 8),
        _buildSwapButton(vertical: false),
        const SizedBox(width: 8),
        Expanded(
          child: _buildDropdown(
            value: selectedToLanguage,
            labelText: isChinese ? '目标语言' : 'To',
            onChanged: onToLanguageChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String value,
    required String labelText,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      items: ['zh', 'en'].map((langCode) {
        final displayName = _getLanguageDisplayName(langCode, isChinese);
        return DropdownMenuItem(
          value: langCode,
          child: Text(
            displayName,
            style: const TextStyle(fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (value) => onChanged(value!),
    );
  }

  Widget _buildSwapButton({required bool vertical}) {
    return IconButton(
      onPressed: onSwapLanguages,
      icon: Icon(
        vertical ? Icons.swap_vert : Icons.swap_horiz,
        size: vertical ? 20 : 18,
      ),
      tooltip: isChinese ? '交换语言' : 'Swap Languages',
      style: IconButton.styleFrom(
        backgroundColor: Colors.blue[50],
        foregroundColor: Colors.blue[700],
        padding: const EdgeInsets.all(8),
      ),
    );
  }
}

// 将翻译区域抽离为独立组件
class _TranslationArea extends StatelessWidget {
  const _TranslationArea({
    required this.inputController,
    required this.outputController,
    required this.isTranslating,
    required this.isRecording,
    required this.isPlaying,
    required this.isChinese,
    required this.onTranslate,
    required this.onClearInput,
    required this.onStartVoiceInput,
    required this.onStopVoiceInput,
    required this.onPlayTranslation,
    required this.onStopAudio,
  });

  final TextEditingController inputController;
  final TextEditingController outputController;
  final bool isTranslating;
  final bool isRecording;
  final bool isPlaying;
  final bool isChinese;
  final VoidCallback onTranslate;
  final VoidCallback onClearInput;
  final VoidCallback onStartVoiceInput;
  final VoidCallback onStopVoiceInput;
  final VoidCallback onPlayTranslation;
  final VoidCallback onStopAudio;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildInputArea(),
              const SizedBox(height: 16),
              _buildTranslateButton(),
              const SizedBox(height: 16),
              _buildOutputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: inputController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: isChinese ? '输入要翻译的文本' : 'Enter text to translate',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: onClearInput,
              ),
            ),
          ),
        ),
        if (!kIsWeb) ...[
          const SizedBox(width: 8),
          _buildVoiceInputButton(),
        ],
      ],
    );
  }

  Widget _buildVoiceInputButton() {
    return Column(
      children: [
        IconButton(
          onPressed: isRecording ? onStopVoiceInput : onStartVoiceInput,
          icon: Icon(
            isRecording ? Icons.stop : Icons.mic,
            color: isRecording ? Colors.red : Colors.blue,
          ),
          tooltip: isChinese ? '语音输入' : 'Voice Input',
        ),
        if (isRecording)
          Text(
            isChinese ? '录音中...' : 'Recording...',
            style: const TextStyle(fontSize: 10, color: Colors.red),
          ),
      ],
    );
  }

  Widget _buildTranslateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isTranslating ? null : onTranslate,
        icon: isTranslating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.translate),
        label: Text(isTranslating
            ? (isChinese ? '翻译中...' : 'Translating...')
            : (isChinese ? '翻译' : 'Translate')),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildOutputArea() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: outputController,
            maxLines: 4,
            readOnly: true,
            decoration: InputDecoration(
              labelText: isChinese ? '翻译结果' : 'Translation Result',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ),
        const SizedBox(width: 8),
        _buildPlayButton(),
      ],
    );
  }

  Widget _buildPlayButton() {
    return Column(
      children: [
        IconButton(
          onPressed: isPlaying ? onStopAudio : onPlayTranslation,
          icon: Icon(
            isPlaying ? Icons.stop : Icons.volume_up,
            color: isPlaying ? Colors.red : Colors.green,
          ),
          tooltip: isChinese ? '播放翻译' : 'Play Translation',
        ),
        if (isPlaying)
          Text(
            isChinese ? '播放中...' : 'Playing...',
            style: const TextStyle(fontSize: 10, color: Colors.red),
          ),
      ],
    );
  }
}

// 将常用短语抽离为独立组件
class _CommonPhrases extends StatelessWidget {
  const _CommonPhrases({
    required this.groupedPhrases,
    required this.categories,
    required this.isChinese,
    required this.onPhraseSelected,
  });

  final Map<String, List<Map<String, String>>> groupedPhrases;
  final Map<String, Map<String, String>> categories;
  final bool isChinese;
  final ValueChanged<String> onPhraseSelected;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isChinese ? '常用短语' : 'Common Phrases',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...categories.entries.map((category) {
                final categoryPhrases = groupedPhrases[category.key] ?? [];
                return _buildCategorySection(category, categoryPhrases);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    MapEntry<String, Map<String, String>> category,
    List<Map<String, String>> categoryPhrases,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.value[isChinese ? 'zh' : 'en']!,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.blue[700],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categoryPhrases.map((phrase) {
            final displayText = phrase[isChinese ? 'zh' : 'en']!;
            return OptimizedChip(
              label: displayText,
              onPressed: () => onPhraseSelected(displayText),
              backgroundColor: Colors.blue[50],
              textColor: Colors.blue[700],
              fontSize: 11,
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}