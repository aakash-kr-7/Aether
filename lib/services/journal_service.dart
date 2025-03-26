import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/journal_entry.dart';

class JournalService {
  final CollectionReference journalCollection =
      FirebaseFirestore.instance.collection('journal_Entries');

  Future<void> addEntry(JournalEntry entry) async {
    try {
      final docRef = journalCollection.doc();
      await docRef.set(entry.toMap()..['entryId'] = docRef.id);
      print("Entry added successfully with ID: ${docRef.id}");
    } catch (e) {
      print("Error adding journal entry: $e");
    }
  }

  Stream<List<JournalEntry>> getUserEntries(String userId) {
  return journalCollection
      .where('userId', isEqualTo: userId)
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) {
        print("RAW DATA: ${snapshot.docs.map((doc) => doc.data()).toList()}");
        return snapshot.docs.map((doc) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            return JournalEntry.fromMap(data);
          } catch (e) {
            print("Error converting entry: $e");
            return null; // Return null for invalid entries
          }
        }).whereType<JournalEntry>().toList(); // Filter valid entries
      });
}

  Future<void> deleteEntry(String entryId) async {
    try {
      await journalCollection.doc(entryId).delete();
      print("Entry deleted: $entryId");
    } catch (e) {
      print("Error deleting journal entry: $e");
    }
  }

  Future<void> updateEntry(String entryId, Map<String, dynamic> updatedData) async {
    try {
      if (updatedData.containsKey('date')) {
        updatedData['date'] = Timestamp.fromDate(updatedData['date']);
      }
      await journalCollection.doc(entryId).update(updatedData);
      print("Entry updated: $entryId");
    } catch (e) {
      print("Error updating journal entry: $e");
    }
  }

  Stream<List<Map<String, String>>> getEntrySummaries(String userId) {
    return journalCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final content = (data['content'] ?? 'No content').toString();
            return {
              'entryId': doc.id,
              'title': (data['title'] ?? 'Untitled').toString(),
              'summary': content.length > 50 ? '${content.substring(0, 50)}...' : content,
            };
          }).toList();
        });
  }

  Future<void> clearCache() async {
    try {
      await FirebaseFirestore.instance.clearPersistence();
      print("Firestore cache cleared.");
    } catch (e) {
      print("Error clearing cache: $e");
    }
  }
}
