import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/insight.dart';
import '../../services/insight_service.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({Key? key}) : super(key: key);

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final InsightService _insightService = InsightService();
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  List<Insight> generatedInsights = [];
  List<Insight> likedInsights = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadInsights();
  }

  Future<void> loadInsights() async {
    final gen = await _insightService.fetchGeneratedInsights(uid);
    final liked = await _insightService.fetchLikedInsights(uid);

    setState(() {
      generatedInsights = gen;
      likedInsights = liked;
      isLoading = false;
    });
  }

  Future<void> likeInsight(Insight insight) async {
    await _insightService.likeInsight(uid, insight);
    await loadInsights();
  }

  Widget buildInsightCard(Insight insight, {bool isLiked = false}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(insight.text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: insight.tags.map((tag) => Chip(label: Text(tag))).toList(),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(insight.type.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                if (!isLiked)
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () => likeInsight(insight),
                  )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildInsightSection(String title, List<Insight> insights, {bool isLiked = false}) {
    if (insights.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Text("No $title yet.", style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ...insights.map((insight) => buildInsightCard(insight, isLiked: isLiked)).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadInsights,
              child: ListView(
                children: [
                  buildInsightSection('Recently Generated Insights', generatedInsights),
                  buildInsightSection('Liked Insights', likedInsights, isLiked: true),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
