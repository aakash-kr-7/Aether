import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/journal_entry.dart';

class JournalService {
  final CollectionReference journalCollection = 
      FirebaseFirestore.instance.collection('journalEntries');

  // Create a new journal entry
  Future<void> addEntry(JournalEntry entry) async {
    try {
      await journalCollection.doc(entry.entryId).set(entry.toMap());
    } catch (e) {
      print("Error adding journal entry: $e");
    }
  }

  // Get journal entries for a user
  Stream<List<JournalEntry>> getUserEntries(String userId) {
    return journalCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => JournalEntry.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }

  // Delete a journal entry
  Future<void> deleteEntry(String entryId) async {
    try {
      await journalCollection.doc(entryId).delete();
    } catch (e) {
      print("Error deleting journal entry: $e");
    }
  }
}
