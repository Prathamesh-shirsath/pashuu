// lib/services/news_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pashuu/models/article_model.dart';

class NewsService {
  final String _apiKey = 'fbffac84331d4247b3d91d8c31aa84ad';
  final String _baseUrl = 'https://newsapi.org/v2/everything?q=cattle+or+Buffalo&from=2025-10-05&sortBy=publishedAt';

  Future<List<Article>> fetchNews() async {
    // We are searching for news relevant to cattle, farming, and veterinary topics in India.
    final String url = '$_baseUrl?q=(cattle OR farming OR veterinary)&language=en&sortBy=publishedAt&apiKey=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<dynamic> articlesJson = json['articles'];

        // Take only the first 10 articles to avoid clutter
        return articlesJson.take(10).map((json) => Article.fromJson(json)).toList();
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed to load news');
      }
    } catch (e) {
      throw Exception('Failed to connect to the news service: $e');
    }
  }
}