import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quick_template.dart';

class QuickTemplateHelper {
  static const String _key = 'quick_templates';

  static Future<List<QuickTemplate>> loadTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    return jsonList.map((e) => QuickTemplate.fromMap(json.decode(e))).toList();
  }

  static Future<void> saveTemplates(List<QuickTemplate> templates) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = templates.map((e) => json.encode(e.toMap())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  static Future<void> addTemplate(QuickTemplate template) async {
    final templates = await loadTemplates();
    templates.add(template);
    await saveTemplates(templates);
  }

  static Future<void> removeTemplate(int index) async {
    final templates = await loadTemplates();
    if (index >= 0 && index < templates.length) {
      templates.removeAt(index);
      await saveTemplates(templates);
    }
  }
} 