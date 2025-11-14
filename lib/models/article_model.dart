// lib/models/article_model.dart
import 'package:intl/intl.dart';

class Article {
  final String? title;
  final String? description;
  final String? url;
  // Removed urlToImage
  final DateTime? publishedAt;

  Article({
    this.title,
    this.description,
    this.url,
    // Removed urlToImage from constructor
    this.publishedAt,
  });

  // Factory constructor to parse JSON from rss2json.com format
  factory Article.fromJson(Map<String, dynamic> json) {
    // --- Parse pubDate (rss2json.com usually provides "YYYY-MM-DD HH:MM:SS" or "Day, DD Mon YYYY HH:MM:SS GMT") ---
    DateTime? parsedDate;
    if (json['pubDate'] != null) {
      try {
        // Attempt ISO 8601 parsing first (e.g., "2023-11-20 10:30:00")
        String dateString = json['pubDate'].toString().replaceFirst(' ', 'T') + 'Z';
        parsedDate = DateTime.parse(dateString);
      } catch (e) {
        // If ISO 8601 fails, try common RSS date format (e.g., "Mon, 20 Nov 2023 10:30:00 GMT")
        try {
          // DateFormat handles various patterns; adjust if your feed uses a different format
          parsedDate = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parse(json['pubDate']);
        } catch (e2) {
          print('WARNING: Could not parse pubDate "${json['pubDate']}" with known formats. Error: $e2');
          parsedDate = null; // If all parsing fails, set to null
        }
      }
    }

    // --- All image extraction logic removed ---

    // Ensure URL has a scheme (http/https)
    String? rawUrl = json['link'];
    if (rawUrl != null && rawUrl.isNotEmpty) {
      rawUrl = rawUrl.trim(); // Trim any whitespace
      if (!rawUrl.startsWith('http://') && !rawUrl.startsWith('https://')) {
        rawUrl = 'https://$rawUrl'; // Prepend https:// if missing
      }
    }

    // Description might contain HTML. We'll strip it for cleaner display.
    String? descriptionText = json['description'] ?? json['content'];
    if (descriptionText != null) {
      // Basic HTML stripping (you might need a more robust package for complex HTML)
      descriptionText = descriptionText.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ').trim();
      descriptionText = descriptionText.replaceAll(RegExp(r'\s+'), ' '); // Collapse multiple spaces
    }

    return Article(
      title: json['title'],
      description: descriptionText,
      url: rawUrl, // 'link' from rss2json maps to 'url'
      // Removed urlToImage: imageUrl,
      publishedAt: parsedDate,
    );
  }
}