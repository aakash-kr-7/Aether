import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.text,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  children: insight.tags.map((tag) => Chip(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    label: Text(tag, style: GoogleFonts.poppins(color: Colors.white)),
                  )).toList(),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      insight.type.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (!isLiked)
                      IconButton(
                        icon: const Icon(Icons.favorite_border, color: Colors.white),
                        onPressed: () => likeInsight(insight),
                      ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInsightSection(String title, List<Insight> insights, {bool isLiked = false}) {
    if (insights.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Text(
          "No $title yet.",
          style: GoogleFonts.poppins(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.white),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        ...insights.map((insight) => buildInsightCard(insight, isLiked: isLiked)).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 26, 75, 238), Color.fromARGB(255, 0, 138, 189)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : RefreshIndicator(
                  onRefresh: loadInsights,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Your Daily Insights',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      buildInsightSection('Recently Generated Insights', generatedInsights),
                      buildInsightSection('Liked Insights', likedInsights, isLiked: true),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
