// lib/services/news_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pashuu/models/article_model.dart'; // Ensure this model is correctly defined

class NewsService {
  // IMPORTANT: The rss2json.com service does NOT use your NewsAPI.org key.
  // The _apiKey field is now effectively unused by this service.
  final String _apiKey = 'fbffac84331d4247b3d91d8c31aa84ad'; // Kept for reference, but not used by rss2json

  // --- REFINED & URL-ENCODED RSS FEED URL ---
  // This method constructs and URL-encodes the Google News RSS feed URL
  // before passing it to rss2json.com.
  Future<String> _buildEncodedRssUrl() async {
    // 1. Define the specific Google News RSS feed URL
    // Refined query for "India" and keywords like "cattle", "buffalo", "animal disease", "veterinary", "farming"
    // Using parentheses to group OR conditions for better search precision.
    // SIMPLIFIED QUERY SLIGHTLY FOR BETTER RELIABILITY
    final String googleNewsSearchQuery = 'India+(cattle+OR+buffalo+OR+"animal+disease"+OR+veterinary+OR+farming)';
    final String googleNewsRssUrl = 'https://news.google.com/rss/search?q=$googleNewsSearchQuery&hl=en-IN&gl=IN&ceid=IN:en';

    // 2. URL-encode the entire Google News RSS URL
    // This is crucial to prevent special characters (&, ?) within the RSS feed URL
    // from being misinterpreted as parameters for rss2json.com itself.
    final String encodedGoogleNewsRssUrl = Uri.encodeComponent(googleNewsRssUrl);

    // 3. Construct the final rss2json.com API endpoint with the encoded Google News URL
    return 'https://api.rss2json.com/v1/api.json?rss_url=$encodedGoogleNewsRssUrl';
  }
  // --- END REFINED & URL-ENCODED RSS FEED URL ---


  Future<List<Article>> fetchNews() async {
    // Call the new method to get the correctly URL-encoded endpoint for rss2json.com
    final String url = await _buildEncodedRssUrl();

    // For debugging: Print the constructed URL to check it in your console
    print('DEBUG: News API Request URL (rss2json): $url');

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        // --- ADDED DEBUGGING PRINT FOR RAW JSON RESPONSE (truncated for large responses) ---
        print('DEBUG: RSS2JSON Raw Response (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
        // If the status is not 'ok', print the full response for detailed error inspection
        if (json['status'] != 'ok') {
          print('ERROR: RSS2JSON API response status not "ok". Full raw response: ${response.body}');
        }
        // -----------------------------------------------------------------------------------

        // rss2json.com returns "items" (list of articles) and "status" (API call status)
        if (json['status'] == 'ok' && json['items'] != null) {
          final List<dynamic> articlesJson = json['items'];
          print('DEBUG: Successfully fetched ${articlesJson.length} raw articles from rss2json.');

          // Map the raw JSON items to your Article model.
          // Filter out articles that might have missing crucial fields (title, url)
          // urlToImage is now handled more robustly in Article.fromJson, but we don't *require* it here.
          final List<Article> validArticles = articlesJson
              .map((json) => Article.fromJson(json)) // Uses the factory constructor in article_model.dart
              .where((article) =>
          article.title != null && article.title!.isNotEmpty &&
              article.url != null && article.url!.isNotEmpty) // Only require title and URL to be valid
              .toList();

          print('DEBUG: Filtered to ${validArticles.length} valid articles (title and URL present).');

          // Take only the first 10 valid articles to avoid clutter on the dashboard
          return validArticles.take(10).toList();
        } else {
          // If rss2json.com returns an error status or no items
          final String errorMessage = json['message'] ?? 'No items or unknown API error message.';
          print('ERROR: rss2json API Error Response: ${json['status']} - $errorMessage');
          throw Exception('rss2json API Error: $errorMessage');
        }
      } else {
        // If the HTTP request itself failed (e.g., network error, 404, 500)
        print('ERROR: HTTP Error loading news: Status Code ${response.statusCode}. Body: ${response.body}');
        throw Exception('Failed to load news: Status Code ${response.statusCode}. Body: ${response.body}');
      }
    } catch (e, st) {
      // Catch any network errors or exceptions during JSON parsing or HTTP call
      print('ERROR: Network or parsing error fetching news (rss2json): $e\n$st');
      throw Exception('Failed to connect to the news service. Check internet or API endpoint: $e');
    }
  }
}